---@type framework.event.apis
local event_apis = require "framework.event.apis"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

-- 桥接框架输入事件到 UI 鼠标移动 API。
event_apis.ON_MOUSE_MOVE_ASYNC(function(api)
    local data = api.input
    local window_size_api = apis.GET_WINDOW_SIZE({})
    assert(window_size_api.width ~= nil, "framework.ui.mouse requires runtime backend width")
    assert(window_size_api.height ~= nil, "framework.ui.mouse requires runtime backend height")
    apis.ON_MOUSE_MOVE_ASYNC({
        position = {
            x = data.window_pos.x / window_size_api.width,
            y = data.window_pos.y / window_size_api.height,
        },
    })
end)
