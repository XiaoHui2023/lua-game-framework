---@class framework.ui.apis
---@field ON_MOUSE_MOVE_ASYNC lib.callback.api 本地异步鼠标移动事件
---@field ON_WINDOW_SIZE_CHANGE lib.callback.api 窗口尺寸变化事件
---@field ON_CREATE lib.callback.api UI 对象创建完成事件
---@field OBJECT_CREATED lib.callback.api UI 对象创建后的框架内装配事件
---@field CREATE lib.callback.api 创建 UI 控件并写回句柄
---@field DELETE lib.callback.api 删除 UI 控件
---@field SET_TEXT lib.callback.api 设置 UI 文本内容
---@field SET_VISIBLE lib.callback.api 设置 UI 可见性
---@field SET_MODEL lib.callback.api 设置 UI 模型资源
---@field PLAY_EFFECT lib.callback.api 播放 UI 特效
---@field PLAY_ANIMA lib.callback.api 播放 UI 模型动画
---@field ON_MOUSE_EVENT lib.callback.api 绑定 UI 鼠标事件
---@field SET_IMAGE lib.callback.api 设置 UI 图片资源
---@field SET_IMAGE_COLOR lib.callback.api 设置 UI 图片颜色
---@field SET_ALPHA lib.callback.api 设置 UI 透明度
---@field GET_WINDOW_SIZE lib.callback.api 获取窗口真实尺寸
---@field SET_SIZE lib.callback.api 设置 UI 尺寸
---@field SET_FONT_SIZE lib.callback.api 设置字体尺寸并写回实际值
---@field SET_TEXT_ALIGNMENT lib.callback.api 设置文本排列方式
---@field SET_POSITION lib.callback.api 设置 UI 位置
---@field SET_ANCHOR lib.callback.api 设置 UI 锚点
---@field SET_PARENT lib.callback.api 设置 UI 父控件
---@field SET_PROGRESS lib.callback.api 设置 UI 进度值
---@field SET_ROTATION lib.callback.api 设置 UI 旋转角度
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class ui.MouseMoveAsync
---@field position point 鼠标在窗口内的比例坐标
M.ON_MOUSE_MOVE_ASYNC = callback.api({ name = "ui.ON_MOUSE_MOVE_ASYNC" })

---@class ui.WindowSizeChange
---@field width integer 窗口宽度，单位像素
---@field height integer 窗口高度，单位像素
M.ON_WINDOW_SIZE_CHANGE = callback.api({ name = "ui.ON_WINDOW_SIZE_CHANGE" })

---@class ui.Created
---@field ui ui 已创建的 UI 对象
M.ON_CREATE = callback.api({ name = "ui.ON_CREATE" })

---@class ui.api.ObjectCreated
---@field ui ui 正在装配的 UI 对象
---@field options ui.options 创建 UI 时传入的选项
M.OBJECT_CREATED = callback.api({ name = "ui.OBJECT_CREATED" })

---@class ui.api.Create
---@field type ui.type? UI 类型，省略时创建空节点
---@field parent_handle ui.handle? 父控件句柄，省略时挂到根节点
---@field handle ui.handle? 运行时写回的控件句柄
M.CREATE = callback.api({ name = "ui.CREATE" })

---@class ui.api.Handle
---@field handle ui.handle
M.DELETE = callback.api({ name = "ui.DELETE" })

---@class ui.api.SetText
---@field handle ui.handle
---@field text string
M.SET_TEXT = callback.api({ name = "ui.SET_TEXT" })

---@class ui.api.SetVisible
---@field handle ui.handle
---@field visible boolean
M.SET_VISIBLE = callback.api({ name = "ui.SET_VISIBLE" })

---@class ui.api.SetModel
---@field handle ui.handle
---@field model any
M.SET_MODEL = callback.api({ name = "ui.SET_MODEL" })

---@class ui.api.PlayEffect
---@field handle ui.handle
---@field effect any
---@field is_loop boolean? 是否循环播放
---@field speed number? 播放速度
M.PLAY_EFFECT = callback.api({ name = "ui.PLAY_EFFECT" })

---@class ui.api.PlayAnima
---@field handle ui.handle
---@field anima any
---@field is_loop boolean? 是否循环播放
---@field speed number? 播放速度
M.PLAY_ANIMA = callback.api({ name = "ui.PLAY_ANIMA" })

---@class ui.api.OnMouseEvent
---@field handle ui.handle
---@field event string
---@field func fun()
---@field remove_func fun()? 运行时写回的解绑函数
M.ON_MOUSE_EVENT = callback.api({ name = "ui.ON_MOUSE_EVENT" })

---@class ui.api.SetImage
---@field ui ui
---@field image py.Texture|string
M.SET_IMAGE = callback.api({ name = "ui.SET_IMAGE" })

---@class ui.api.SetImageColor
---@field ui ui
---@field color color
M.SET_IMAGE_COLOR = callback.api({ name = "ui.SET_IMAGE_COLOR" })

---@class ui.api.SetAlpha
---@field handle ui.handle
---@field alpha number
M.SET_ALPHA = callback.api({ name = "ui.SET_ALPHA" })

---@class ui.api.GetWindowSize
---@field width integer? 运行时写回的窗口宽度
---@field height integer? 运行时写回的窗口高度
M.GET_WINDOW_SIZE = callback.api({ name = "ui.GET_WINDOW_SIZE" })

---@class ui.api.SetSize
---@field ui ui
---@field width number
---@field height number
M.SET_SIZE = callback.api({ name = "ui.SET_SIZE" })

---@class ui.api.SetFontSize
---@field handle ui.handle
---@field size number
---@field value number? 运行时写回的实际字号
M.SET_FONT_SIZE = callback.api({ name = "ui.SET_FONT_SIZE" })

---@class ui.api.SetTextAlignment
---@field handle ui.handle
---@field pos ui.position
M.SET_TEXT_ALIGNMENT = callback.api({ name = "ui.SET_TEXT_ALIGNMENT" })

---@class ui.text.outline
---@field enable? boolean
---@field width? number
---@field color? color
---@field alpha? number

---@class ui.api.SetTextOutline
---@field handle ui.handle
---@field outline ui.text.outline|nil|false
M.SET_TEXT_OUTLINE = callback.api({ name = "ui.SET_TEXT_OUTLINE" })

---@class ui.api.SetPosition
---@field ui ui
---@field x number
---@field y number
M.SET_POSITION = callback.api({ name = "ui.SET_POSITION" })

---@class ui.api.SetAnchor
---@field ui ui
---@field x number
---@field y number
M.SET_ANCHOR = callback.api({ name = "ui.SET_ANCHOR" })

---@class ui.api.SetParent
---@field ui ui
---@field parent_handle ui.handle?
M.SET_PARENT = callback.api({ name = "ui.SET_PARENT" })

---@class ui.api.SetProgress
---@field ui ui
---@field progress number
M.SET_PROGRESS = callback.api({ name = "ui.SET_PROGRESS" })

---@class ui.api.SetRotation
---@field ui ui
---@field rotation number
M.SET_ROTATION = callback.api({ name = "ui.SET_ROTATION" })

return M
