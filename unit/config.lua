---@class framework.unit
---@field DEFAULT_POSITION point 默认出生点
---@field DEFAULT_FACING number 默认出生朝向
---@field DEFAULT_KEY any 榛樿鍑虹敓鍗曚綅KEY
---@field DEFAULT_MOVE_SPEED number 榛樿鍑虹敓绉婚€?
---@field DEFAULT_BASE_ATTACK_SPEED number 榛樿鍑虹敓鍩虹鏀诲嚮閫熷害
---@field DEFAULT_ATTACK_SPEED number 榛樿鍑虹敓鏀诲嚮閫熷害
---@field DEFAULT_ATTACK_RANGE number 榛樿鍑虹敓鏀诲嚮鑼冨洿
---@field DEFAULT_TURN_SPEED number 榛樿鍑虹敓杞韩閫熷害
---@field DEFAULT_MODEL model 榛樿鍑虹敓妯″瀷
---@field DEFAULT_PLAYER player 榛樿鍑虹敓鐜╁
---@field DEFAULT_HEALTH number 榛樿鍑虹敓琛€閲?
---@field DEFAULT_MAX_HEALTH number 榛樿鍑虹敓鏈€澶ц閲?
---@field DEFAULT_DAMAGE number 榛樿鍑虹敓鍩虹浼ゅ
---@field DEFAULT_FACTION faction 榛樿鍑虹敓闃佃惀
---@field DEFAULT_COLOR_ENABLE boolean 榛樿鍑虹敓棰滆壊浣胯兘
---@field DEFAULT_COLOR color 榛樿鍑虹敓棰滆壊
---@field DEFAULT_OVERLAY_ENABLE boolean 榛樿鍑虹敓瑕嗙洊浣胯兘
---@field DEFAULT_OVERLAY color 榛樿鍑虹敓瑕嗙洊
---@field DEFAULT_OUTLINE_ENABLE boolean 榛樿鍑虹敓鎻忚竟浣胯兘
---@field DEFAULT_OUTLINE color 榛樿鍑虹敓鎻忚竟
---@field DEFAULT_ALPHA number 榛樿鍑虹敓閫忔槑搴?
---@field DEFAULT_ANIMATION_SPEED number 榛樿鍑虹敓鍔ㄧ敾閫熷害
---@field DEFAULT_HEIGHT number 榛樿鍑虹敓楂樺害
---@field DEFAULT_SCALE number 榛樿鍑虹敓缂╂斁
---@field DEFAULT_SCALE_X number 榛樿鍑虹敓X杞寸缉鏀?
---@field DEFAULT_SCALE_Y number 榛樿鍑虹敓Y杞寸缉鏀?
---@field DEFAULT_SCALE_Z number 榛樿鍑虹敓Z杞寸缉鏀?
local g = require ".base"
---@type lib.colorlib
local color = require "lib.color"

g.DEFAULT_POSITION = {x = 0, y = 0}
g.DEFAULT_FACING = 0
g.DEFAULT_KEY = nil
g.DEFAULT_MOVE_SPEED = 225
g.DEFAULT_BASE_ATTACK_SPEED = 1
g.DEFAULT_ATTACK_SPEED = 1
g.DEFAULT_ATTACK_RANGE = 175
g.DEFAULT_TURN_SPEED = 10
g.DEFAULT_MODEL = nil
g.DEFAULT_PLAYER = nil
g.DEFAULT_HEALTH = 100
g.DEFAULT_MAX_HEALTH = 100
g.DEFAULT_DAMAGE = 1
g.DEFAULT_FACTION = nil
g.DEFAULT_COLOR_ENABLE = false
g.DEFAULT_COLOR = color.WHITE
g.DEFAULT_OVERLAY_ENABLE = false
g.DEFAULT_OVERLAY = color.WHITE
g.DEFAULT_OUTLINE_ENABLE = false
g.DEFAULT_OUTLINE = color.WHITE
g.DEFAULT_ALPHA = 255
g.DEFAULT_ANIMATION_SPEED = 1
g.DEFAULT_HEIGHT = 0
g.DEFAULT_SCALE = 1
g.DEFAULT_SCALE_X = 1
g.DEFAULT_SCALE_Y = 1
g.DEFAULT_SCALE_Z = 1

return g
