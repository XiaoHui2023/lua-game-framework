---@class models.faction
local g = {}
---@type utils.hook
local hook = require "utils.hook"

---@type hook.add 阵营对象池
g.POOL_OBJECT = hook.add()

---@alias faction.stance
---| "neutral"    # 中立立场（既不伤害也不帮助）
---| "friendly"   # 友好立场（互相帮助，不伤害）
---| "hostile"    # 敌对立场（互相伤害，不帮助）

return g