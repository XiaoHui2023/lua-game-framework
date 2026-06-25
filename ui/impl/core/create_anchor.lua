---@type lib.metatablex
local metatable = require "lib.metatablex"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

apis.CREATE_ANCHOR(function(api)
    ---@type framework.ui.anchor
    local anchor = api.anchor or {}

    anchor.point = anchor.point or "center"
    anchor.relative_point = anchor.relative_point or "center"
    anchor.x = anchor.x or 0
    anchor.y = anchor.y or 0

    api.anchor = metatable.with_tostring(anchor, function()
        local fields = { anchor.point, anchor.relative_point }
        if anchor.x and anchor.x ~= 0 then
            table.insert(fields, string.format("x=%.2f", anchor.x))
        end
        if anchor.y and anchor.y ~= 0 then
            table.insert(fields, string.format("y=%.2f", anchor.y))
        end
        if anchor.relative_ui then
            table.insert(fields, tostring(anchor.relative_ui))
        end
        local attrs = table.concat(fields, ",")
        return string.format("<ui.anchor %s>", attrs)
    end)
end)

return true
