---@type lib.tablex
local table = require "lib.tablex"
---@class framework.terrain
local g = require ".base"

---璁＄畻鍦嗗舰鍖哄煙鐨勭汗鐞嗘槧灏?
---@param painter terrain.painter 鍦板舰缁樺埗鍣?
---@param center_position point 鍦嗗績鐐?
---@param radius number 鍗婂緞
---@param step number 缁樼敾鐐逛箣闂寸殑闂撮殧
---@return terrain.map 鐐瑰埌绾圭悊鐨勬槧灏勮〃
local function calculate_terrain_map(painter, center_position, radius, step)
    local center_x,center_y = center_position.x,center_position.y
    ---@type terrain.map
    local map = {}
    
    -- 閬嶅巻鍖呭洿鐩掑唴鐨勬墍鏈夌偣
    local min_x = center_x - radius
    local max_x = center_x + radius
    local min_y = center_y - radius
    local max_y = center_y + radius
    
    for x = min_x, max_x, step do
        for y = min_y, max_y, step do
            -- 妫€鏌ユ槸鍚﹀湪鍦嗗唴
            local dx = x - center_x
            local dy = y - center_y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance <= radius then
                -- 浣跨敤 painter 璁＄畻璇ョ偣鐨勭汗鐞?
                local terrain_id = painter.paint_radial(x, y,center_position, radius)
                map[{x = x, y = y}] = terrain_id
            end
        end
    end
    
    return map
end

---鏍规嵁鏄犲皠琛ㄦ覆鏌撳湴褰?
---@param map terrain.map 鍦板舰鏄犲皠琛?
---@param size number 缁樼敾鐐圭殑澶у皬
local function render_terrain_map(map,size)
    for position, terrain_id in table.sorted_pairs(map) do
        g.set_texture(position, terrain_id,size)
    end
end

---娓叉煋鍦嗗舰鑸炲彴
---@param terrain_group terrain.group 绾圭悊缁?
---@param max_count integer 鏈€澶ф娊鍙栨暟閲?
---@param center_position point 鍦嗗績鐐?
---@param radius number 鍗婂緞
---@param size? number 缁樼敾鐐圭殑澶у皬
g.render_circle_stage = function(terrain_group, max_count, center_position, radius, size)
    size = size or g.UNIT_SIZE

    local painter = g.create_painter(terrain_group, max_count)

    -- 璁＄畻鏄犲皠琛?
    local terrain_map = calculate_terrain_map(painter, center_position, radius, size)
    
    -- 娓叉煋
    render_terrain_map(terrain_map,size)
end

return g