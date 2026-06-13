---@class models.terrain
local g = require ".base"
local list = require "list"

---平滑插值函数（fade function）
---@param t number
---@return number
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

---线性插值
---@param t number
---@param a number
---@param b number
---@return number
local function lerp(t, a, b)
    return a + t * (b - a)
end

---梯度函数
---@param hash integer
---@param x number
---@param y number
---@return number
local function grad(hash, x, y)
    local h = hash % 4
    if h == 0 then return x + y
    elseif h == 1 then return -x + y
    elseif h == 2 then return x - y
    else return -x - y
    end
end

---创建置换表（用于生成确定性随机）
---@return integer[]
local function create_permutation()
    local permutation = {}
    for i = 0, 255 do
        permutation[i] = i
    end

    ---初始化置换表
    for i = 255, 1, -1 do
        local j = math.floor(math.random(0, i))
        permutation[i], permutation[j] = permutation[j], permutation[i]
    end
    -- 扩展到512避免溢出
    for i = 0, 255 do
        permutation[256 + i] = permutation[i]
    end

    return permutation
end

---从数组中随机抽取N个不重复的元素
---@param array table 原数组
---@param n integer 要抽取的数量
---@return table 抽取结果
local function select_random(array, n)
    local m = #array
    if n >= m then
        return table.clone(array)
    end
    
    ---@type list
    local li = list(array)
    li.shuffle()
    return li.slice(1,n).to_table()
end

---@param terrain_group terrain.group 地面纹理组
---@param selection integer 选取数量
---@return terrain.painter
g.create_painter = function (terrain_group, selection)
    ---@class terrain.painter
    local o = {}

    ---@type table 地面纹理组
    local terrains = select_random(terrain_group, selection)
    local main_terrain = list(terrains).pop_random()

    ---@class terrain.painter.config 配置参数
    ---@field noise_frequency number 基础噪声频率
    ---@field noise_octaves integer 噪声层数
    ---@field noise_persistence number 振幅衰减
    ---@field noise_lacunarity number 频率增长
    ---@field voronoi_cell_size number 区域大小
    ---@field voronoi_blend number 边界混合比例（0-1）
    o.config = {
        -- 噪声参数
        noise_frequency = 0.004,
        noise_octaves = 4,
        noise_persistence = 0.5,
        noise_lacunarity = 2.0,
        -- 沃罗诺伊参数
        voronoi_cell_size = 180,
        voronoi_blend = 0.15,
    }

    ---@type integer[]
    local permutation = create_permutation()

    ---二维柏林噪声
    ---@param x number
    ---@param y number
    ---@return number 返回-1到1之间的值
    local function perlin_noise_2d(x, y)
        -- 单元格坐标
        local xi = math.floor(x) % 256
        local yi = math.floor(y) % 256
        
        -- 单元格内相对位置
        local xf = x - math.floor(x)
        local yf = y - math.floor(y)
        
        -- 平滑曲线
        local u = fade(xf)
        local v = fade(yf)
        
        -- 哈希值
        local aa = permutation[permutation[xi] + yi]
        local ab = permutation[permutation[xi] + yi + 1]
        local ba = permutation[permutation[xi + 1] + yi]
        local bb = permutation[permutation[xi + 1] + yi + 1]
        
        -- 梯度计算并插值
        local x1 = lerp(u, grad(aa, xf, yf), grad(ba, xf - 1, yf))
        local x2 = lerp(u, grad(ab, xf, yf - 1), grad(bb, xf - 1, yf - 1))
        
        return lerp(v, x1, x2)
    end

    ---多层噪声叠加
    ---@param x number
    ---@param y number
    ---@param octaves integer 层数
    ---@param persistence number 持续度（每层振幅衰减）
    ---@param lacunarity number 间隙度（每层频率增长）
    ---@return number 返回0到1之间的值
    local function fbm(x, y, octaves, persistence, lacunarity)
        local total = 0
        local frequency = 1
        local amplitude = 1
        local max_value = 0
        
        for i = 1, octaves do
            total = total + perlin_noise_2d(x * frequency, y * frequency) * amplitude
            max_value = max_value + amplitude
            amplitude = amplitude * persistence
            frequency = frequency * lacunarity
        end
        
        -- 归一化到 0-1
        return (total / max_value + 1) / 2
    end

    ---绘制带渐变的地形（用于圆形区域）
    ---从中心向外辐射，中心主要是主纹理，越往外点缀越多
    ---@param x number 世界坐标X
    ---@param y number 世界坐标Y
    ---@param center_position point 中心点
    ---@param radius number 半径
    ---@return integer|nil 纹理ID
    o.paint_radial = function(x, y, center_position, radius)
        local sum_terrain = #terrains
        if sum_terrain == 0 then return main_terrain end
        
        local cfg = o.config
        
        -- 计算到中心的距离
        local dx = x - center_position.x
        local dy = y - center_position.y
        local distance = math.sqrt(dx * dx + dy * dy)
        local normalized_dist = distance / radius
        
        -- 低频噪声，创建粗大的主区域
        local main_noise = fbm(
            x * cfg.noise_frequency * 0.5,  -- 低频率，产生大块区域
            y * cfg.noise_frequency * 0.5,
            3,
            0.5,
            2.0
        )
        
        -- 高频噪声，用于生成细小的点缀
        local detail_noise = fbm(
            x * cfg.noise_frequency * 15,  -- 高频率，产生细小变化
            y * cfg.noise_frequency * 15,
            2,
            0.3,
            2.5
        )
        
        -- 根据距离计算主纹理的强度（中心强，外围弱）
        -- 使用1.5次方，让扩散更快
        local center_strength = (1 - normalized_dist) ^ 1.5
        
        -- 组合低频噪声和中心强度，决定是否使用主纹理
        -- 中心：center_strength 接近 1，几乎必然是主纹理
        -- 外围：center_strength 接近 0，主要看噪声
        local main_threshold = center_strength * 0.6 + main_noise * 0.4
        
        -- 提高阈值到 0.5，缩小主纹理区域
        if main_threshold > 0.5 then
            return main_terrain
        end
        
        -- 否则，使用高频噪声决定点缀纹理
        -- 外围区域才会走到这里
        local accent_threshold = detail_noise + normalized_dist * 0.2
        
        -- 降低阈值到 0.7，让点缀更早出现
        if accent_threshold > 0.7 then
            -- 使用柏林噪声选择点缀纹理，让相邻点缀更连续
            local selection_noise = fbm(
                x * cfg.noise_frequency * 2,
                y * cfg.noise_frequency * 2,
                2,
                0.5,
                2.0
            )
            
            local accent_index = math.floor(selection_noise * sum_terrain) + 1
            accent_index = math.max(1, math.min(accent_index, sum_terrain))
            
            return terrains[accent_index]
        else
            -- 默认返回主纹理
            return main_terrain
        end
    end

    return o
end


return g