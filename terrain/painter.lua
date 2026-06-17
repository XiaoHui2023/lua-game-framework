---@type lib.tablex
local table = require "lib.tablex"
---@class framework.terrain
local g = require ".base"
local list = require "lib.list"

---骞虫粦鎻掑€煎嚱鏁帮紙fade function锛?
---@param t number
---@return number
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

---绾挎€ф彃鍊?
---@param t number
---@param a number
---@param b number
---@return number
local function lerp(t, a, b)
    return a + t * (b - a)
end

---姊害鍑芥暟
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

---鍒涘缓缃崲琛紙鐢ㄤ簬鐢熸垚纭畾鎬ч殢鏈猴級
---@return integer[]
local function create_permutation()
    local permutation = {}
    for i = 0, 255 do
        permutation[i] = i
    end

    ---鍒濆鍖栫疆鎹㈣〃
    for i = 255, 1, -1 do
        local j = math.floor(math.random(0, i))
        permutation[i], permutation[j] = permutation[j], permutation[i]
    end
    -- 鎵╁睍鍒?12閬垮厤婧㈠嚭
    for i = 0, 255 do
        permutation[256 + i] = permutation[i]
    end

    return permutation
end

---浠庢暟缁勪腑闅忔満鎶藉彇N涓笉閲嶅鐨勫厓绱?
---@param array table 鍘熸暟缁?
---@param n integer 瑕佹娊鍙栫殑鏁伴噺
---@return table 鎶藉彇缁撴灉
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

---@param terrain_group terrain.group 鍦伴潰绾圭悊缁?
---@param selection integer 閫夊彇鏁伴噺
---@return terrain.painter
g.create_painter = function (terrain_group, selection)
    ---@class terrain.painter
    local o = {}

    ---@type table 鍦伴潰绾圭悊缁?
    local terrains = select_random(terrain_group, selection)
    local main_terrain = list(terrains).pop_random()

    ---@class terrain.painter.config 閰嶇疆鍙傛暟
    ---@field noise_frequency number 鍩虹鍣０棰戠巼
    ---@field noise_octaves integer 鍣０灞傛暟
    ---@field noise_persistence number 鎸箙琛板噺
    ---@field noise_lacunarity number 棰戠巼澧為暱
    ---@field voronoi_cell_size number 鍖哄煙澶у皬
    ---@field voronoi_blend number 杈圭晫娣峰悎姣斾緥锛?-1锛?
    o.config = {
        -- 鍣０鍙傛暟
        noise_frequency = 0.004,
        noise_octaves = 4,
        noise_persistence = 0.5,
        noise_lacunarity = 2.0,
        -- 娌冪綏璇轰紛鍙傛暟
        voronoi_cell_size = 180,
        voronoi_blend = 0.15,
    }

    ---@type integer[]
    local permutation = create_permutation()

    ---浜岀淮鏌忔灄鍣０
    ---@param x number
    ---@param y number
    ---@return number 杩斿洖-1鍒?涔嬮棿鐨勫€?
    local function perlin_noise_2d(x, y)
        -- 鍗曞厓鏍煎潗鏍?
        local xi = math.floor(x) % 256
        local yi = math.floor(y) % 256
        
        -- 鍗曞厓鏍煎唴鐩稿浣嶇疆
        local xf = x - math.floor(x)
        local yf = y - math.floor(y)
        
        -- 骞虫粦鏇茬嚎
        local u = fade(xf)
        local v = fade(yf)
        
        -- 鍝堝笇鍊?
        local aa = permutation[permutation[xi] + yi]
        local ab = permutation[permutation[xi] + yi + 1]
        local ba = permutation[permutation[xi + 1] + yi]
        local bb = permutation[permutation[xi + 1] + yi + 1]
        
        -- 姊害璁＄畻骞舵彃鍊?
        local x1 = lerp(u, grad(aa, xf, yf), grad(ba, xf - 1, yf))
        local x2 = lerp(u, grad(ab, xf, yf - 1), grad(bb, xf - 1, yf - 1))
        
        return lerp(v, x1, x2)
    end

    ---澶氬眰鍣０鍙犲姞
    ---@param x number
    ---@param y number
    ---@param octaves integer 灞傛暟
    ---@param persistence number 鎸佺画搴︼紙姣忓眰鎸箙琛板噺锛?
    ---@param lacunarity number 闂撮殭搴︼紙姣忓眰棰戠巼澧為暱锛?
    ---@return number 杩斿洖0鍒?涔嬮棿鐨勫€?
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
        
        -- 褰掍竴鍖栧埌 0-1
        return (total / max_value + 1) / 2
    end

    ---缁樺埗甯︽笎鍙樼殑鍦板舰锛堢敤浜庡渾褰㈠尯鍩燂級
    ---浠庝腑蹇冨悜澶栬緪灏勶紝涓績涓昏鏄富绾圭悊锛岃秺寰€澶栫偣缂€瓒婂
    ---@param x number 涓栫晫鍧愭爣X
    ---@param y number 涓栫晫鍧愭爣Y
    ---@param center_position point 涓績鐐?
    ---@param radius number 鍗婂緞
    ---@return integer|nil 绾圭悊ID
    o.paint_radial = function(x, y, center_position, radius)
        local sum_terrain = #terrains
        if sum_terrain == 0 then return main_terrain end
        
        local cfg = o.config
        
        -- 璁＄畻鍒颁腑蹇冪殑璺濈
        local dx = x - center_position.x
        local dy = y - center_position.y
        local distance = math.sqrt(dx * dx + dy * dy)
        local normalized_dist = distance / radius
        
        -- 浣庨鍣０锛屽垱寤虹矖澶х殑涓诲尯鍩?
        local main_noise = fbm(
            x * cfg.noise_frequency * 0.5,  -- 浣庨鐜囷紝浜х敓澶у潡鍖哄煙
            y * cfg.noise_frequency * 0.5,
            3,
            0.5,
            2.0
        )
        
        -- 楂橀鍣０锛岀敤浜庣敓鎴愮粏灏忕殑鐐圭紑
        local detail_noise = fbm(
            x * cfg.noise_frequency * 15,  -- 楂橀鐜囷紝浜х敓缁嗗皬鍙樺寲
            y * cfg.noise_frequency * 15,
            2,
            0.3,
            2.5
        )
        
        -- 鏍规嵁璺濈璁＄畻涓荤汗鐞嗙殑寮哄害锛堜腑蹇冨己锛屽鍥村急锛?
        -- 浣跨敤1.5娆℃柟锛岃鎵╂暎鏇村揩
        local center_strength = (1 - normalized_dist) ^ 1.5
        
        -- 缁勫悎浣庨鍣０鍜屼腑蹇冨己搴︼紝鍐冲畾鏄惁浣跨敤涓荤汗鐞?
        -- 涓績锛歝enter_strength 鎺ヨ繎 1锛屽嚑涔庡繀鐒舵槸涓荤汗鐞?
        -- 澶栧洿锛歝enter_strength 鎺ヨ繎 0锛屼富瑕佺湅鍣０
        local main_threshold = center_strength * 0.6 + main_noise * 0.4
        
        -- 鎻愰珮闃堝€煎埌 0.5锛岀缉灏忎富绾圭悊鍖哄煙
        if main_threshold > 0.5 then
            return main_terrain
        end
        
        -- 鍚﹀垯锛屼娇鐢ㄩ珮棰戝櫔澹板喅瀹氱偣缂€绾圭悊
        -- 澶栧洿鍖哄煙鎵嶄細璧板埌杩欓噷
        local accent_threshold = detail_noise + normalized_dist * 0.2
        
        -- 闄嶄綆闃堝€煎埌 0.7锛岃鐐圭紑鏇存棭鍑虹幇
        if accent_threshold > 0.7 then
            -- 浣跨敤鏌忔灄鍣０閫夋嫨鐐圭紑绾圭悊锛岃鐩搁偦鐐圭紑鏇磋繛缁?
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
            -- 榛樿杩斿洖涓荤汗鐞?
            return main_terrain
        end
    end

    return o
end


return g