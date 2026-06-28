require "framework.ui.types"

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
---@field PLAY_ANIMATION lib.callback.api 播放 UI 模型动画
---@field ON_MOUSE_EVENT lib.callback.api 绑定 UI 鼠标事件
---@field SET_IMAGE lib.callback.api 设置 UI 图片资源
---@field SET_IMAGE_COLOR lib.callback.api 设置 UI 图片颜色
---@field SET_TEXT_COLOR lib.callback.api 设置 UI 文本颜色
---@field SET_TEXT_OVER_LENGTH lib.callback.api 设置 UI 文本超长处理
---@field SET_ALPHA lib.callback.api 设置 UI 透明度
---@field GET_WINDOW_SIZE lib.callback.api 获取窗口真实尺寸
---@field GET_SCRIPT_POSITION lib.callback.api 获取脚本计算的 UI 位置
---@field GET_SCRIPT_SIZE lib.callback.api 获取脚本计算的 UI 尺寸
---@field GET_SCRIPT_RECT lib.callback.api 获取脚本计算的 UI 矩形
---@field GET_ENGINE_RELATIVE_POSITION lib.callback.api 从引擎读取 UI 相对位置
---@field GET_ENGINE_ABSOLUTE_POSITION lib.callback.api 从引擎读取 UI 绝对位置
---@field GET_ENGINE_SIZE lib.callback.api 从引擎读取 UI 设定尺寸
---@field GET_ENGINE_REAL_SIZE lib.callback.api 从引擎读取 UI 真实尺寸
---@field GET_ENGINE_RECT lib.callback.api 从引擎读取 UI 绝对矩形
---@field GET_ENGINE_REAL_RECT lib.callback.api 从引擎读取 UI 真实绝对矩形
---@field SET_SIZE lib.callback.api 设置 UI 尺寸
---@field SET_FONT_SIZE lib.callback.api 设置字体尺寸并写回实际值
---@field SET_TEXT_ALIGNMENT lib.callback.api 设置文本排列方式
---@field SET_POSITION lib.callback.api 设置 UI 位置
---@field SET_ANCHOR lib.callback.api 设置 UI 锚点
---@field CREATE_ANCHOR lib.callback.api 创建并规范化 framework.ui.anchor 数据包
---@field SET_PARENT lib.callback.api 设置 UI 父控件
---@field SET_PROGRESS lib.callback.api 设置 UI 进度值
---@field SET_ROTATION lib.callback.api 设置 UI 旋转角度
local M = {}

---@type lib.callback
local callback = require "lib.callback"

---@class framework.ui.MouseMoveAsync: lib.callback.instance
---@field position point 鼠标在窗口内的比例坐标
---@type lib.callback.api
M.ON_MOUSE_MOVE_ASYNC = callback.api({ name = "ui.ON_MOUSE_MOVE_ASYNC" })

---@class framework.ui.WindowSizeChange: lib.callback.instance
---@field width integer 窗口宽度，单位像素
---@field height integer 窗口高度，单位像素
---@type lib.callback.api
M.ON_WINDOW_SIZE_CHANGE = callback.api({ name = "ui.ON_WINDOW_SIZE_CHANGE" })

---@class framework.ui.Created: lib.callback.instance
---@field ui framework.ui 已创建的 UI 对象
---@type lib.callback.api
M.ON_CREATE = callback.api({ name = "ui.ON_CREATE" })

---@class framework.ui.api.ObjectCreated: lib.callback.instance
---@field ui framework.ui 正在装配的 UI 对象
---@field options framework.ui.object_config 创建 UI 时传入的选项
---@type lib.callback.api
M.OBJECT_CREATED = callback.api({ name = "ui.OBJECT_CREATED" })

---@class framework.ui.api.CreateObject: lib.callback.instance
---@field options framework.ui.object_config? 创建参数
---@field ui framework.ui? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_OBJECT = callback.api({ name = "ui.CREATE_OBJECT" })

---@class framework.ui.api.CreateVoid: lib.callback.instance
---@field options framework.ui.object_config? 创建参数
---@field options_extra framework.ui.object_config? 额外创建参数，注册实现会合并到 options
---@field ui framework.ui.void? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_VOID = callback.api({ name = "ui.CREATE_VOID" })

---@class framework.ui.api.CreateImage: lib.callback.instance
---@field options framework.ui.object_config? 创建参数
---@field options_extra framework.ui.object_config? 额外创建参数，注册实现会合并到 options
---@field ui framework.ui.image? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_IMAGE = callback.api({ name = "ui.CREATE_IMAGE" })

---@class framework.ui.api.CreateText: lib.callback.instance
---@field options framework.ui.text.options? 创建参数
---@field options_extra framework.ui.object_config? 额外创建参数，注册实现会合并到 options
---@field ui framework.ui.text? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_TEXT = callback.api({ name = "ui.CREATE_TEXT" })

---@class framework.ui.api.CreateButton: lib.callback.instance
---@field options framework.ui.button.options? 创建参数
---@field ui framework.ui.button? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_BUTTON = callback.api({ name = "ui.CREATE_BUTTON" })

---@class framework.ui.api.CreateModel: lib.callback.instance
---@field options framework.ui.model.options? 创建参数
---@field ui framework.ui.model? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_MODEL = callback.api({ name = "ui.CREATE_MODEL" })

---@class framework.ui.api.CreateEffect: lib.callback.instance
---@field options framework.ui.effect.options? 创建参数
---@field ui framework.ui.effect? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_EFFECT = callback.api({ name = "ui.CREATE_EFFECT" })

---@class framework.ui.api.CreateProgress: lib.callback.instance
---@field options framework.ui.object_config? 创建参数
---@field options_extra framework.ui.object_config? 额外创建参数，注册实现会合并到 options
---@field ui framework.ui.progress? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_PROGRESS = callback.api({ name = "ui.CREATE_PROGRESS" })

---@class framework.ui.api.CreateProgressRing: lib.callback.instance
---@field options framework.ui.object_config? 创建参数
---@field ui framework.ui.progress? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_PROGRESS_RING = callback.api({ name = "ui.CREATE_PROGRESS_RING" })

---@class framework.ui.api.CreateProgressBar: lib.callback.instance
---@field options framework.ui.object_config? 创建参数
---@field ui framework.ui.progress? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_PROGRESS_BAR = callback.api({ name = "ui.CREATE_PROGRESS_BAR" })

---@class framework.ui.api.CreateContainer: lib.callback.instance
---@field options framework.ui.container.options? 创建参数
---@field options_extra framework.ui.container.options? 额外容器参数，注册实现会合并到 options
---@field ui framework.ui.container? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_CONTAINER = callback.api({ name = "ui.CREATE_CONTAINER" })

---@class framework.ui.api.CreateSlot: lib.callback.instance
---@field options framework.ui.slot.options? 创建参数
---@field options_extra framework.ui.slot.options? 额外槽位参数，注册实现会合并到 options
---@field ui framework.ui.slot? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_SLOT = callback.api({ name = "ui.CREATE_SLOT" })

---@class framework.ui.api.CreateEditbox: lib.callback.instance
---@field options framework.ui.editbox.options? 创建参数
---@field ui framework.ui.editbox? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_EDITBOX = callback.api({ name = "ui.CREATE_EDITBOX" })

---@class framework.ui.api.CreateSlider: lib.callback.instance
---@field options framework.ui.slider.options? 创建参数
---@field ui framework.ui.slider? 创建完成的 UI 对象
---@type lib.callback.api
M.CREATE_SLIDER = callback.api({ name = "ui.CREATE_SLIDER" })

---@class framework.ui.api.SetupReactiveFields: lib.callback.instance
---@field ui framework.ui 正在装配基础响应式字段的 UI 对象
---@field options framework.ui.object_config UI 创建参数，供字段阶段设置初始值
---@type lib.callback.api
M.SETUP_REACTIVE_FIELDS = callback.api({ name = "ui.SETUP_REACTIVE_FIELDS" })

---@class framework.ui.api.SetupReactiveLogic: lib.callback.instance
---@field ui framework.ui 已完成基础字段装配的 UI 对象
---@field options framework.ui.object_config UI 创建参数，供逻辑阶段绑定监听和生命周期
---@type lib.callback.api
M.SETUP_REACTIVE_LOGIC = callback.api({ name = "ui.SETUP_REACTIVE_LOGIC" })
---@class framework.ui.api.Create: lib.callback.instance
---@field type framework.ui.type? UI 类型，省略时创建空节点
---@field parent_handle framework.ui.handle? 父控件句柄，省略时挂到根节点
---@field handle framework.ui.handle? 运行时写回的控件句柄
---@type lib.callback.api
M.CREATE = callback.api({ name = "ui.CREATE" })

---@class framework.ui.api.Handle: lib.callback.instance
---@field handle framework.ui.handle 要删除或操作的控件句柄
---@type lib.callback.api
M.DELETE = callback.api({ name = "ui.DELETE" })

---@class framework.ui.api.SetText: lib.callback.instance
---@field handle framework.ui.handle 要设置文本的控件句柄
---@field text string 新文本内容
---@type lib.callback.api
M.SET_TEXT = callback.api({ name = "ui.SET_TEXT" })

---@class framework.ui.api.SetVisible: lib.callback.instance
---@field handle framework.ui.handle 要设置可见性的控件句柄
---@field visible boolean 是否显示控件
---@type lib.callback.api
M.SET_VISIBLE = callback.api({ name = "ui.SET_VISIBLE" })

---@class framework.ui.api.SetModel: lib.callback.instance
---@field handle framework.ui.handle 要设置模型的控件句柄
---@field model any 模型资源标识
---@type lib.callback.api
M.SET_MODEL = callback.api({ name = "ui.SET_MODEL" })

---@class framework.ui.api.PlayEffect: lib.callback.instance
---@field handle framework.ui.handle 要播放特效的控件句柄
---@field effect any 特效资源标识
---@field is_loop boolean? 是否循环播放
---@field speed number? 播放速度
---@type lib.callback.api
M.PLAY_EFFECT = callback.api({ name = "ui.PLAY_EFFECT" })

---@class framework.ui.api.PlayAnimation: lib.callback.instance
---@field handle framework.ui.handle 要播放动画的模型控件句柄
---@field animation any 动画资源或动画名
---@field is_loop boolean? 是否循环播放
---@field speed number? 播放速度
---@type lib.callback.api
M.PLAY_ANIMATION = callback.api({ name = "ui.PLAY_ANIMATION" })

---@class framework.ui.api.OnMouseEvent: lib.callback.instance
---@field handle framework.ui.handle 要绑定鼠标事件的控件句柄
---@field event string 运行时鼠标事件名
---@field func fun() 鼠标事件触发回调
---@field remove_func fun()? 运行时写回的解绑函数
---@type lib.callback.api
M.ON_MOUSE_EVENT = callback.api({ name = "ui.ON_MOUSE_EVENT" })

---@class framework.ui.api.SetImage: lib.callback.instance
---@field ui framework.ui 要设置图片的 UI 对象
---@field image py.Texture|string 图片资源或图片路径
---@type lib.callback.api
M.SET_IMAGE = callback.api({ name = "ui.SET_IMAGE" })

---@class framework.ui.api.SetImageColor: lib.callback.instance
---@field ui framework.ui 要设置图片颜色的 UI 对象
---@field color lib.color|table 图片颜色
---@type lib.callback.api
M.SET_IMAGE_COLOR = callback.api({ name = "ui.SET_IMAGE_COLOR" })

---@class framework.ui.api.SetTextColor: lib.callback.instance
---@field ui framework.ui 要设置文本颜色的 UI 对象
---@field color lib.color|table 文本颜色
---@type lib.callback.api
M.SET_TEXT_COLOR = callback.api({ name = "ui.SET_TEXT_COLOR" })

---@class framework.ui.api.SetTextOverLength: lib.callback.instance
---@field handle framework.ui.handle 要设置文本超长处理的控件句柄
---@field mode any 超长处理模式
---@field min_size? number 自适应最小字号
---@type lib.callback.api
M.SET_TEXT_OVER_LENGTH = callback.api({ name = "ui.SET_TEXT_OVER_LENGTH" })

---@class framework.ui.api.SetAlpha: lib.callback.instance
---@field handle framework.ui.handle 要设置透明度的控件句柄
---@field alpha number 透明度，范围 0 到 255
---@type lib.callback.api
M.SET_ALPHA = callback.api({ name = "ui.SET_ALPHA" })

---@class framework.ui.api.GetWindowSize: lib.callback.instance
---@field width integer? 运行时写回的窗口宽度
---@field height integer? 运行时写回的窗口高度
---@type lib.callback.api
M.GET_WINDOW_SIZE = callback.api({ name = "ui.GET_WINDOW_SIZE" })

---@class framework.ui.api.GetScriptPosition: lib.callback.instance
---@field ui framework.ui 要查询的 UI 对象
---@field x number? 脚本计算的 X 坐标
---@field y number? 脚本计算的 Y 坐标
---@type lib.callback.api
M.GET_SCRIPT_POSITION = callback.api({ name = "ui.GET_SCRIPT_POSITION" })

---@class framework.ui.api.GetScriptSize: lib.callback.instance
---@field ui framework.ui 要查询的 UI 对象
---@field width number? 脚本计算的宽度
---@field height number? 脚本计算的高度
---@type lib.callback.api
M.GET_SCRIPT_SIZE = callback.api({ name = "ui.GET_SCRIPT_SIZE" })

---@class framework.ui.api.GetScriptRect: lib.callback.instance
---@field ui framework.ui 要查询的 UI 对象
---@field x number? 脚本计算的 X 坐标
---@field y number? 脚本计算的 Y 坐标
---@field width number? 脚本计算的宽度
---@field height number? 脚本计算的高度
---@field rect framework.ui.rect? 脚本计算的矩形
---@type lib.callback.api
M.GET_SCRIPT_RECT = callback.api({ name = "ui.GET_SCRIPT_RECT" })

---@class framework.ui.api.GetEngineRelativePosition: lib.callback.instance
---@field ui framework.ui 要查询的 UI 对象
---@field available boolean? 引擎是否提供该读取能力
---@field x number? 引擎读取的相对 X 坐标
---@field y number? 引擎读取的相对 Y 坐标
---@type lib.callback.api
M.GET_ENGINE_RELATIVE_POSITION = callback.api({ name = "ui.GET_ENGINE_RELATIVE_POSITION" })

---@class framework.ui.api.GetEngineAbsolutePosition: lib.callback.instance
---@field ui framework.ui 要查询的 UI 对象
---@field available boolean? 引擎是否提供该读取能力
---@field x number? 引擎读取的绝对 X 坐标
---@field y number? 引擎读取的绝对 Y 坐标
---@type lib.callback.api
M.GET_ENGINE_ABSOLUTE_POSITION = callback.api({ name = "ui.GET_ENGINE_ABSOLUTE_POSITION" })

---@class framework.ui.api.GetEngineSize: lib.callback.instance
---@field ui framework.ui 要查询的 UI 对象
---@field available boolean? 引擎是否提供该读取能力
---@field width number? 引擎读取的宽度
---@field height number? 引擎读取的高度
---@type lib.callback.api
M.GET_ENGINE_SIZE = callback.api({ name = "ui.GET_ENGINE_SIZE" })

---@class framework.ui.api.GetEngineRealSize: lib.callback.instance
---@field ui framework.ui 要查询的 UI 对象
---@field available boolean? 引擎是否提供该读取能力
---@field width number? 引擎读取的真实宽度
---@field height number? 引擎读取的真实高度
---@type lib.callback.api
M.GET_ENGINE_REAL_SIZE = callback.api({ name = "ui.GET_ENGINE_REAL_SIZE" })

---@class framework.ui.api.GetEngineRect: lib.callback.instance
---@field ui framework.ui 要查询的 UI 对象
---@field available boolean? 引擎是否提供该读取能力
---@field x number? 引擎读取的绝对 X 坐标
---@field y number? 引擎读取的绝对 Y 坐标
---@field width number? 引擎读取的宽度
---@field height number? 引擎读取的高度
---@field rect framework.ui.rect? 引擎读取的绝对矩形
---@type lib.callback.api
M.GET_ENGINE_RECT = callback.api({ name = "ui.GET_ENGINE_RECT" })

---@class framework.ui.api.GetEngineRealRect: lib.callback.instance
---@field ui framework.ui 要查询的 UI 对象
---@field available boolean? 引擎是否提供该读取能力
---@field x number? 引擎读取的绝对 X 坐标
---@field y number? 引擎读取的绝对 Y 坐标
---@field width number? 引擎读取的真实宽度
---@field height number? 引擎读取的真实高度
---@field rect framework.ui.rect? 引擎读取的真实绝对矩形
---@type lib.callback.api
M.GET_ENGINE_REAL_RECT = callback.api({ name = "ui.GET_ENGINE_REAL_RECT" })

---@class framework.ui.api.SetSize: lib.callback.instance
---@field ui framework.ui 要设置尺寸的 UI 对象
---@field width number 目标宽度
---@field height number 目标高度
---@type lib.callback.api
M.SET_SIZE = callback.api({ name = "ui.SET_SIZE" })

---@class framework.ui.api.SetFontSize: lib.callback.instance
---@field handle framework.ui.handle 要设置字号的文本控件句柄
---@field size number 框架字号比例
---@field value number? 运行时写回的实际字号
---@type lib.callback.api
M.SET_FONT_SIZE = callback.api({ name = "ui.SET_FONT_SIZE" })

---@class framework.ui.api.SetTextAlignment: lib.callback.instance
---@field handle framework.ui.handle 要设置对齐的文本控件句柄
---@field pos framework.ui.position 文本对齐位置
---@type lib.callback.api
M.SET_TEXT_ALIGNMENT = callback.api({ name = "ui.SET_TEXT_ALIGNMENT" })

---@class framework.ui.api.SetTextOutline: lib.callback.instance
---@field handle framework.ui.handle 要设置描边的文本控件句柄
---@field outline framework.ui.text.outline|nil|false 描边配置，nil 或 false 表示关闭描边
---@type lib.callback.api
M.SET_TEXT_OUTLINE = callback.api({ name = "ui.SET_TEXT_OUTLINE" })

---@class framework.ui.api.SetPosition: lib.callback.instance
---@field ui framework.ui 要设置位置的 UI 对象
---@field x number 目标横坐标
---@field y number 目标纵坐标
---@type lib.callback.api
M.SET_POSITION = callback.api({ name = "ui.SET_POSITION" })

---@class framework.ui.api.SetAnchor: lib.callback.instance
---@field ui framework.ui 要设置锚点的 UI 对象
---@field x number 锚点横向比例
---@field y number 锚点纵向比例
---@type lib.callback.api
M.SET_ANCHOR = callback.api({ name = "ui.SET_ANCHOR" })

---@class framework.ui.api.CreateAnchor: lib.callback.instance
---@field anchor framework.ui.anchor? 输入锚点配置，运行后写回规范化锚点数据包
---@type lib.callback.api
M.CREATE_ANCHOR = callback.api({ name = "ui.CREATE_ANCHOR" })

---@class framework.ui.api.SetParent: lib.callback.instance
---@field ui framework.ui 要调整父级的 UI 对象
---@field parent_handle framework.ui.handle? 目标父控件句柄，省略时挂到根节点
---@type lib.callback.api
M.SET_PARENT = callback.api({ name = "ui.SET_PARENT" })

---@class framework.ui.api.SetProgress: lib.callback.instance
---@field ui framework.ui 要设置进度的 UI 对象
---@field progress number 进度值，范围 0 到 1
---@type lib.callback.api
M.SET_PROGRESS = callback.api({ name = "ui.SET_PROGRESS" })

---@class framework.ui.api.SetRotation: lib.callback.instance
---@field ui framework.ui 要设置旋转的 UI 对象
---@field rotation number 旋转角度
---@type lib.callback.api
M.SET_ROTATION = callback.api({ name = "ui.SET_ROTATION" })

return M
