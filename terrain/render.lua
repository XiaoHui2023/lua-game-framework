---@class models.terrain
local g = require ".base"

---计算圆形区域的纹理映射
---@param painter terrain.painter 地形绘制器
---@param center_position point 圆心点
---@param radius number 半径
---@param step number 绘画点之间的间隔
---@return terrain.map 点到纹理的映射表
local function calculate_terrain_map(painter, center_position, radius, step)
    local center_x,center_y = center_position.x,center_position.y
    ---@type terrain.map
    local map = {}
    
    -- 遍历包围盒内的所有点
    local min_x = center_x - radius
    local max_x = center_x + radius
    local min_y = center_y - radius
    local max_y = center_y + radius
    
    for x = min_x, max_x, step do
        for y = min_y, max_y, step do
            -- 检查是否在圆内
            local dx = x - center_x
            local dy = y - center_y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance <= radius then
                -- 使用 painter 计算该点的纹理
                local terrain_id = painter.paint_radial(x, y,center_position, radius)
                map[{x = x, y = y}] = terrain_id
            end
        end
    end
    
    return map
end

---根据映射表渲染地形
---@param map terrain.map 地形映射表
---@param size number 绘画点的大小
local function render_terrain_map(map,size)
    for position, terrain_id in table.sorted_pairs(map) do
        g.set_texture(position, terrain_id,size)
    end
end

---渲染圆形舞台
---@param terrain_group terrain.group 纹理组
---@param max_count integer 最大抽取数量
---@param center_position point 圆心点
---@param radius number 半径
---@param size? number 绘画点的大小
g.render_circle_stage = function(terrain_group, max_count, center_position, radius, size)
    size = size or g.UNIT_SIZE

    local painter = g.create_painter(terrain_group, max_count)

    -- 计算映射表
    local terrain_map = calculate_terrain_map(painter, center_position, radius, size)
    
    -- 渲染
    render_terrain_map(terrain_map,size)
end

return g