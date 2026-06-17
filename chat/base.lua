---@class framework.chat
local g = {}
---@type fun(tb?: any[]): list
local list = require "lib.list"
---@type framework.chat.apis
local apis = require ".apis"

g.ON_INPUT = apis.ON_INPUT
g.ON_MESSAGE_CHANGE = apis.ON_MESSAGE_CHANGE

---@class message
---@field player player
---@field content string

---@type list<message>
g.MESSAGE_HISTORY = list()

return g
