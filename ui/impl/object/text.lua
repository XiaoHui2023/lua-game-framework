---@type framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param o ui
---@param options ui.options
return function(o, options)
    if o.type ~= "text" then
        return
    end

    apis.SET_TEXT({ handle = o.handle(), text = options.text or "" })
end
