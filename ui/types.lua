---@meta framework.ui.types

---Runtime UI handle
---@alias framework.ui.handle any

---@class framework.ui.object_config : lib.reactive.factory.options
---@field alpha? integer 透明度，范围 0 到 255
---@field layer? framework.ui.handle UI 分层句柄
---@field parent? framework.ui 父级 UI
---@field type? framework.ui.type UI 类型
---@field priority? integer 同级排序优先级
---@field progress? number 初始进度，范围 0 到 1
---@field color? lib.color|table 初始颜色
---@field align? framework.ui.position 文本对齐位置
---@field anchor? framework.ui.anchor 初始锚点配置
---@field image? any 初始图片资源
---@field rotation? number 初始旋转角度
---@field show? boolean 初始可见性
---@field scale_factor? number 整体缩放系数
---@field width_scale_factor? number 宽度缩放系数
---@field height_scale_factor? number 高度缩放系数
---@field size_mode? framework.ui.size_mode 尺寸适配模式
---@field width? number 相对宽度
---@field height? number 相对高度
---@field size? number 默认正方形尺寸比例
---@field focusable? boolean 是否接收焦点事件
---@field clickable? boolean 是否接收点击事件
---@field draggable? boolean 是否启用拖拽
---@field text? string 初始文本
---@field font_size? number 字号比例
---@field font? any 字体资源
---@field outline? framework.ui.text.outline|false 文本描边配置

---@class framework.ui.module
---@field settings framework.ui.settings UI 默认配置
---@field event_registry framework.ui.event.registry 共享 UI 鼠标事件注册表

---UI 鼠标事件名
---@alias framework.ui.event.key
---| "left_up" 左键抬起
---| "left_down" 左键按下
---| "right_up" 右键抬起
---| "right_down" 右键按下
---| "focus" 鼠标进入
---| "blur" 鼠标离开
---| "click" 点击

---@class framework.ui.event.registry
---@field get fun(key:framework.ui.event.key):reactive.event 按事件名获取共享响应式事件
---@field add fun(key:framework.ui.event.key, callback:fun(ui:framework.ui, ...:any)):function 按事件名添加全局回调并返回删除函数
---@field register fun(obj:framework.ui, event_map:table<framework.ui.event.key, reactive.event>) 将 UI 对象事件挂接到共享注册表

---@class framework.ui
---@field factory lib.reactive.factory UI 对象持有的响应式工厂包
---@field handle lib.reactive.ref 运行时 UI 句柄
---@field priority lib.reactive.ref 同级排序优先级
---@field alpha lib.reactive.ref 透明度
---@field image lib.reactive.ref 图片资源
---@field progress lib.reactive.ref 进度值
---@field rotation lib.reactive.ref 旋转角度
---@field color lib.reactive.ref 图片颜色
---@field children reactive.add 直接子级 UI 列表
---@field type framework.ui.type UI 类型
---@field layer framework.ui.layer UI 分层
---@field hide_lock reactive.semaphore 强制隐藏锁
---@field weak_show reactive.semaphore 弱显示锁
---@field show lib.reactive.ref 基础可见性
---@field visible lib.reactive.computed 最终可见性
---@field relative_size lib.reactive.computed 相对尺寸
---@field pixel_size lib.reactive.computed 像素尺寸
---@field visual_size lib.reactive.computed 用于布局与命中测试的视觉尺寸
---@field is_content_sized boolean 是否由内容决定像素尺寸
---@field relative_position lib.reactive.ref 相对窗口位置
---@field pixel_position lib.reactive.ref 像素位置
---@field anchor lib.reactive.ref 锚点配置
---@field focusable lib.reactive.ref 是否启用焦点事件
---@field clickable lib.reactive.ref 是否启用点击事件
---@field on_mouse_left_up reactive.event 鼠标左键抬起事件
---@field on_mouse_left_down reactive.event 鼠标左键按下事件
---@field on_mouse_right_up reactive.event 鼠标右键抬起事件
---@field on_mouse_right_down reactive.event 鼠标右键按下事件
---@field on_focus reactive.event 鼠标进入事件
---@field on_blur reactive.event 鼠标离开事件
---@field is_focused lib.reactive.ref 是否处于焦点状态
---@field on_click reactive.event 点击事件
---@field draggable lib.reactive.ref 是否启用拖拽
---@field on_drag_start reactive.event 拖拽开始事件
---@field on_drag reactive.event 拖拽过程事件
---@field on_drag_end reactive.event 拖拽结束事件
---@field is_dragging lib.reactive.ref 是否正在拖拽
---@field on_snap_hover reactive.event 吸附悬停事件
---@field on_snap_leave reactive.event 离开吸附目标事件
---@field on_snap_drop reactive.event 释放到吸附目标事件
---@field snap reactive.add 吸附目标集合
---@field anchor_center fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_left_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_right_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_top_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_bottom_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_right_top_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_top_right_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_right_bottom_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_left_top_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_top_left_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_left_bottom_outer fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_left_inner fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_right_inner fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_top_inner fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)
---@field anchor_bottom_inner fun(target_ui:framework.ui, opts?:framework.ui.anchor.offset_options)

---@class framework.ui.void: framework.ui

---@class framework.ui.image: framework.ui

---@class framework.ui.text: framework.ui

---@class framework.ui.progress: framework.ui

---@class framework.ui.button: framework.ui

---@class framework.ui.model: framework.ui

---@class framework.ui.effect: framework.ui

---@class framework.ui.editbox: framework.ui

---@class framework.ui.slider: framework.ui

---@class framework.ui.container: framework.ui.void
---@field layout framework.ui.container.layout 容器布局状态
---@field add_child fun(ui:framework.ui) 将子 UI 加入容器布局
---@field add_children fun(uis:framework.ui[]) 批量将子 UI 加入容器布局
---@field remove_child fun(ui:framework.ui) 将子 UI 移出容器布局

---@class framework.ui.container.layout
---@field type lib.reactive.ref<framework.ui.container.layout.type> Container layout type.
---@field flow lib.reactive.ref<framework.ui.container.layout.flow> Container layout flow.
---@field reverse lib.reactive.ref<boolean> Whether to use reversed child order.
---@field spacing lib.reactive.ref<number> Spacing ratio between adjacent children.
---@field padding lib.reactive.ref<number> Padding ratio before the first child.

---Container child display mode.
---@alias framework.ui.container.mode
---| "single"
---| "stack"

---Container layout type.
---@alias framework.ui.container.layout.type
---| "horizontal"
---| "vertical"

---Horizontal stack flow.
---@alias framework.ui.container.layout.horizontal_flow
---| "left_to_right"
---| "right_to_left"

---Vertical stack flow.
---@alias framework.ui.container.layout.vertical_flow
---| "top_to_bottom"
---| "bottom_to_top"

---Container layout flow.
---@alias framework.ui.container.layout.flow framework.ui.container.layout.horizontal_flow|framework.ui.container.layout.vertical_flow

---@class framework.ui.container.layout.base_options
---@field reverse? boolean Whether to use reversed child order.
---@field spacing? number Spacing ratio between adjacent children.
---@field padding? number Padding ratio before the first child.

---@class framework.ui.container.layout.horizontal_options: framework.ui.container.layout.base_options
---@field type? "horizontal" Horizontal stack layout.
---@field flow? framework.ui.container.layout.horizontal_flow Horizontal stack flow.

---@class framework.ui.container.layout.vertical_options: framework.ui.container.layout.base_options
---@field type "vertical" Vertical stack layout.
---@field flow? framework.ui.container.layout.vertical_flow Vertical stack flow.

---Container layout options.
---@alias framework.ui.container.layout.options framework.ui.container.layout.horizontal_options|framework.ui.container.layout.vertical_options

---@class framework.ui.container.options: framework.ui.object_config
---@field mode? framework.ui.container.mode Child display mode.
---@field layout? framework.ui.container.layout.options Layout options.

---@class framework.ui.slot: framework.ui.void
---@field progress? framework.ui.progress 进度子控件
---@field image? framework.ui.image 图标子控件
---@field background? framework.ui.image 背景子控件
---@field text? framework.ui.text 文本子控件

---UI 控件类型
---@alias framework.ui.type
---| "void" 空节点
---| "text" 文本控件
---| "image" 图片控件
---| "progress_ring" 环形进度控件
---| "progress_bar" 条形进度控件
---| "model" 模型控件
---| "slider" 滑动条控件
---| "input" 输入框控件
---| "button" 按钮控件
---| "effect" 特效控件

---UI 锚点或文本对齐位置
---@alias framework.ui.position
---| "left_top" 左上
---| "top_left" 上左
---| "center_top" 中上
---| "top_center" 上中
---| "right_top" 右上
---| "top_right" 上右
---| "center_left" 中左
---| "left_center" 左中
---| "center" 中心
---| "center_right" 中右
---| "right_center" 右中
---| "left_bottom" 左下
---| "bottom_left" 下左
---| "center_bottom" 中下
---| "bottom_center" 下中
---| "right_bottom" 右下
---| "bottom_right" 下右

---UI 尺寸适配模式
---@alias framework.ui.size_mode
---| "fill" 拉伸填满目标尺寸
---| "contain" 保持比例并完整放入目标尺寸

---UI 分层名称
---@alias framework.ui.layer_name
---| "DEFAULT" 默认层
---| "WINDOW" 窗口层
---| "HUD" HUD 层
---| "SYSTEM" 系统层
---| "CINEMATIC" 过场层

---UI 分层句柄
---@alias framework.ui.layer framework.ui.handle

---@class framework.ui.anchor
---@field point framework.ui.position 当前 UI 锚点
---@field relative_point framework.ui.position 目标锚点
---@field x number 横向偏移比例
---@field y number 纵向偏移比例
---@field relative_ui? framework.ui 相对目标 UI

---@class framework.ui.anchor.offset_options
---@field vertical_space? number 纵向间距偏移
---@field horizontal_space? number 横向间距偏移

---@class framework.ui.text.outline
---@field enable? boolean Whether text outline is enabled.
---@field width? number Outline width.
---@field color? lib.color|table Outline color.
---@field alpha? number Outline alpha.

---@class framework.ui.layer.registry
---@field DEFAULT framework.ui.handle? 默认层句柄
---@field WINDOW framework.ui.handle? 窗口层句柄
---@field HUD framework.ui.handle? HUD 层句柄
---@field SYSTEM framework.ui.handle? 系统层句柄
---@field CINEMATIC framework.ui.handle? 过场层句柄

---@class framework.ui.text.render_result
---@field text string 渲染后的文本
---@field width number 文本像素宽度
---@field height number 文本像素高度

return true
