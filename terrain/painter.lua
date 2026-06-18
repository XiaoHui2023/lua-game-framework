---@type lib.tablex
local table = require "lib.tablex"
---@class framework.terrain
local M = require ".base"
local list = require "lib.list"

---@param t number
---@return number
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

---@param t number
---@param a number
---@param b number
---@return number
local function lerp(t, a, b)
    return a + t * (b - a)
end

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

---@return integer[]
local function create_permutation()
    local permutation = {}
    for i = 0, 255 do
        permutation[i] = i
    end

    for i = 255, 1, -1 do
        local j = math.floor(math.random(0, i))
        permutation[i], permutation[j] = permutation[j], permutation[i]
    end
    for i = 0, 255 do
        permutation[256 + i] = permutation[i]
    end

    return permutation
end

---@param array table 参数说明
---@param n integer 参数说明
---@return table 返回值
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

---@param terrain_group terrain.group 参数说明
---@param selection integer 参数说明
---@return terrain.painter
M.create_painter = function (terrain_group, selection)
    ---@class terrain.painter
    local o = {}

    ---@type table
    local terrains = select_random(terrain_group, selection)
    local main_terrain = list(terrains).pop_random()

    ---@field noise_frequency number 字段说明
    ---@field noise_octaves integer 字段说明
    ---@field noise_persistence number 字段说明
    ---@field noise_lacunarity number 棰戠巼澧為暱
    ---@field voronoi_cell_size number 字段说明
    ---@field voronoi_blend number 字段说明
    o.config = {
        noise_frequency = 0.004,
        noise_octaves = 4,
        noise_persistence = 0.5,
        noise_lacunarity = 2.0,
        voronoi_cell_size = 180,
        voronoi_blend = 0.15,
    }

    ---@type integer[]
    local permutation = create_permutation()

    ---@param x number
    ---@param y number
    ---@return number 返回值
    local function perlin_noise_2d(x, y)
        local xi = math.floor(x) % 256
        local yi = math.floor(y) % 256
        
        local xf = x - math.floor(x)
        local yf = y - math.floor(y)
        
        local u = fade(xf)
        local v = fade(yf)
        
        local aa = permutation[permutation[xi] + yi]
        local ab = permutation[permutation[xi] + yi + 1]
        local ba = permutation[permutation[xi + 1] + yi]
        local bb = permutation[permutation[xi + 1] + yi + 1]
        
        local x1 = lerp(u, grad(aa, xf, yf), grad(ba, xf - 1, yf))
        local x2 = lerp(u, grad(ab, xf, yf - 1), grad(bb, xf - 1, yf - 1))
        
        return lerp(v, x1, x2)
    end

    ---@param x number
    ---@param y number
    ---@param octaves integer 灞傛暟
    ---@param persistence number 参数说明
    ---@param lacunarity number 参数说明
    ---@return number 返回值
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
        
        return (total / max_value + 1) / 2
    end

    ---@param x number 参数说明
    ---@param y number 参数说明
    ---@param center_position point 参数说明
    ---@param radius number 参数说明
    ---@return integer|nil 绾圭悊ID
    o.paint_radial = function(x, y, center_position, radius)
        local sum_terrain = #terrains
        if sum_terrain == 0 then return main_terrain end
        
        local cfg = o.config
        
        local dx = x - center_position.x
        local dy = y - center_position.y
        local distance = math.sqrt(dx * dx + dy * dy)
        local normalized_dist = distance / radius
        
        local main_noise = fbm(
            y * cfg.noise_frequency * 0.5,
            3,
            0.5,
            2.0
        )
        
        local detail_noise = fbm(
            y * cfg.noise_frequency * 15,
            2,
            0.3,
            2.5
        )
        
        local center_strength = (1 - normalized_dist) ^ 1.5
        
        local main_threshold = center_strength * 0.6 + main_noise * 0.4
        
        if main_threshold > 0.5 then
            return main_terrain
        end
        
        local accent_threshold = detail_noise + normalized_dist * 0.2
        
        if accent_threshold > 0.7 then
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
            return main_terrain
        end
    end

    return o
end


return M
