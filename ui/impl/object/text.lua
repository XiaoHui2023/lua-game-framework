---@type framework.ui
local M = require "framework.ui"
---@type framework.ui.apis
local apis = require "framework.ui.apis"

---@param o framework.ui 要装配文本能力的 UI 对象
---@param options framework.ui.options UI 创建参数
return function(o, options)
    if o.type ~= "text" then
        return
    end

    apis.SET_TEXT({ handle = o.handle(), text = options.text or "" })
end
