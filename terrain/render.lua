---@type lib.tablex
local table = require "lib.tablex"
---@class framework.terrain
local M = require ".base"

---@param painter terrain.painter 参数说明
---@param center_position point 参数说明
---@param radius number 参数说明
---@param step number 参数说明
---@return terrain.map 返回值
local function calculate_terrain_map(painter, center_position, radius, step)
    local center_x,center_y = center_position.x,center_position.y
    ---@type terrain.map
    local map = {}
    
    local min_x = center_x - radius
    local max_x = center_x + radius
    local min_y = center_y - radius
    local max_y = center_y + radius
    
    for x = min_x, max_x, step do
        for y = min_y, max_y, step do
            local dx = x - center_x
            local dy = y - center_y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance <= radius then
                local terrain_id = painter.paint_radial(x, y,center_position, radius)
                map[{x = x, y = y}] = terrain_id
            end
        end
    end
    
    return map
end

---@param map terrain.map 参数说明
---@param size number 参数说明
local function render_terrain_map(map,size)
    for position, terrain_id in table.sorted_pairs(map) do
        M.set_texture(position, terrain_id,size)
    end
end

---@param terrain_group terrain.group 参数说明
---@param max_count integer 参数说明
---@param center_position point 参数说明
---@param radius number 参数说明
---@param size? number 参数说明
M.render_circle_stage = function(terrain_group, max_count, center_position, radius, size)
    size = size or M.UNIT_SIZE

    local painter = M.create_painter(terrain_group, max_count)

    local terrain_map = calculate_terrain_map(painter, center_position, radius, size)
    
    -- 娓叉煋
    render_terrain_map(terrain_map,size)
end

return M
