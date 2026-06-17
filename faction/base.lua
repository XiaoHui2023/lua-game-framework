---@class framework.faction
local g = {}
---@type lib.reactive
local hook = require "lib.reactive"

---@type hook.add 闃佃惀瀵硅薄鍒楄〃
g.POOL_OBJECT = hook.collection()

---@alias faction.stance
---| "neutral"    # 涓珛绔嬪満锛堟棦涓嶄激瀹充篃涓嶅府鍔╋級
---| "friendly"   # 鍙嬪ソ绔嬪満锛堜簰鐩稿府鍔╋紝涓嶄激瀹筹級
---| "hostile"    # 鏁屽绔嬪満锛堜簰鐩镐激瀹筹紝涓嶅府鍔╋級

return g
