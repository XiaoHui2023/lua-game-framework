---@type lib.tablex
local table = require "lib.tablex"
---@class framework.terrain
local M = require "framework.terrain"
---@type framework.terrain.apis
local apis = require ".apis"

---@param painter terrain.painter 地形绘制器
---@param center_position point 绘制区域中心点
---@param radius number 绘制区域半径
---@param step number 采样步长
---@return terrain.map map 生成的地形映射
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

---@param map terrain.map 地形映射
---@param size number 地形块尺寸
local function render_terrain_map(map,size)
    for position, terrain_id in table.sorted_pairs(map) do
        apis.SET_TEXTURE({ position = position, texture = terrain_id, range = size })
    end
end

---@param terrain_group terrain.group 地形组
---@param max_count integer 最大生成数量
---@param center_position point 生成区域中心点
---@param radius number 生成区域半径
---@param size? number 地形块尺寸
M.render_circle_stage = function(terrain_group, max_count, center_position, radius, size)
    size = size or M.settings.UNIT_SIZE

    local painter = M.create_painter(terrain_group, max_count)

    local terrain_map = calculate_terrain_map(painter, center_position, radius, size)
    
    -- 娓叉煋
    render_terrain_map(terrain_map,size)
end

return M
