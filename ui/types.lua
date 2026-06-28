---@meta framework.ui.types

---@alias framework.ui.handle any
---@alias framework.ui.length number|string|table

---@class framework.ui.size_spec
---@field width framework.ui.length
---@field height framework.ui.length
---@field min_width? number
---@field min_height? number
---@field max_width? number
---@field max_height? number
---@field aspect_ratio? number

---@class framework.ui.constraints
---@field min_width number
---@field max_width number
---@field min_height number
---@field max_height number

---@class framework.ui.rect
---@field x number
---@field y number
---@field width number
---@field height number

---@class framework.ui.padding
---@field left? number
---@field right? number
---@field top? number
---@field bottom? number
---@field x? number
---@field y? number

---@class framework.ui.relative_position
---@field x number
---@field y number

---@class framework.ui.object_config : lib.reactive.factory.options
---@field alpha? integer
---@field layer? framework.ui.handle
---@field parent? lib.reactive.factory
---@field type? framework.ui.type
---@field priority? integer
---@field progress? number
---@field color? lib.color|table
---@field align? framework.ui.position
---@field anchor? framework.ui.anchor
---@field image? any
---@field rotation? number
---@field show? boolean
---@field size? framework.ui.size_spec
---@field position? framework.ui.relative_position
---@field visual_scale? number
---@field layout_scale? number
---@field focusable? boolean
---@field clickable? boolean
---@field draggable? boolean
---@field text? string
---@field font_size? number
---@field font? any
---@field outline? framework.ui.text.outline|false
---@field over_length? any

---@class framework.ui.state
---@field HANDLE_TO_OBJECT table<framework.ui.handle, framework.ui>
---@field event_registry framework.ui.event.registry

---@class framework.ui.module
---@field settings framework.ui.settings
---@field event_registry framework.ui.event.registry

---@alias framework.ui.event.key
---| "left_up"
---| "left_down"
---| "right_up"
---| "right_down"
---| "focus"
---| "blur"
---| "click"

---@class framework.ui.event.registry
---@field get fun(key:framework.ui.event.key):reactive.event
---@field add fun(key:framework.ui.event.key, callback:fun(ui:framework.ui, ...:any)):function
---@field register fun(obj:framework.ui, event_map:table<framework.ui.event.key, reactive.event>)

---@class framework.ui
---@field factory lib.reactive.factory
---@field handle lib.reactive.ref
---@field priority lib.reactive.ref
---@field alpha lib.reactive.ref
---@field image lib.reactive.ref
---@field progress lib.reactive.ref
---@field rotation lib.reactive.ref
---@field color lib.reactive.ref
---@field children reactive.add
---@field type framework.ui.type
---@field layer framework.ui.layer
---@field hide_lock reactive.semaphore
---@field weak_show reactive.semaphore
---@field show lib.reactive.ref
---@field visible lib.reactive.computed
---@field window_size lib.reactive.ref
---@field size_spec lib.reactive.ref<framework.ui.size_spec>
---@field constraints lib.reactive.ref<framework.ui.constraints>
---@field content_size lib.reactive.computed
---@field measured_size lib.reactive.computed
---@field layout_rect lib.reactive.ref<framework.ui.rect>
---@field render_rect lib.reactive.computed
---@field visual_size lib.reactive.computed
---@field visual_scale lib.reactive.ref
---@field layout_scale lib.reactive.ref
---@field relative_position lib.reactive.ref
---@field pixel_position lib.reactive.ref
---@field is_layout_managed lib.reactive.ref<boolean>
---@field anchor lib.reactive.ref
---@field focusable lib.reactive.ref
---@field clickable lib.reactive.ref
---@field on_mouse_left_up reactive.event
---@field on_mouse_left_down reactive.event
---@field on_mouse_right_up reactive.event
---@field on_mouse_right_down reactive.event
---@field on_focus reactive.event
---@field on_blur reactive.event
---@field is_focused lib.reactive.ref
---@field on_click reactive.event
---@field draggable lib.reactive.ref
---@field on_drag_start reactive.event
---@field on_drag reactive.event
---@field on_drag_end reactive.event
---@field is_dragging lib.reactive.ref
---@field on_snap_hover reactive.event
---@field on_snap_leave reactive.event
---@field on_snap_drop reactive.event
---@field snap reactive.add
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
---@field font lib.reactive.ref
---@field font_pixel_size lib.reactive.ref
---@field font_size lib.reactive.ref
---@field text lib.reactive.ref
---@field align lib.reactive.ref
---@field outline lib.reactive.ref
---@field over_length lib.reactive.ref
---@field render_text lib.reactive.computed

---@class framework.ui.text.options: framework.ui.object_config

---@class framework.ui.progress: framework.ui
---@class framework.ui.button: framework.ui

---@class framework.ui.model: framework.ui
---@field model lib.reactive.ref
---@field play fun(animation:any, is_loop?:boolean, speed?:number)

---@class framework.ui.effect: framework.ui
---@field model lib.reactive.ref
---@field loop lib.reactive.ref
---@field play fun(speed?:number)

---@class framework.ui.editbox: framework.ui
---@field is_int lib.reactive.ref
---@field on_input_change reactive.event
---@field content lib.reactive.ref
---@field length_limit lib.reactive.ref

---@class framework.ui.slider: framework.ui
---@field direction lib.reactive.ref
---@field percent lib.reactive.ref
---@field on_percent_change reactive.event

---@class framework.ui.container: framework.ui.void
---@field widgets reactive.add
---@field layout framework.ui.container.layout

---@class framework.ui.container.layout
---@field type lib.reactive.ref<framework.ui.container.layout.type>
---@field direction lib.reactive.ref<framework.ui.container.layout.direction>
---@field gap lib.reactive.ref<number>
---@field padding lib.reactive.ref<framework.ui.padding>
---@field align lib.reactive.ref<string>
---@field justify lib.reactive.ref<string>

---@alias framework.ui.container.layout.type
---| "none"
---| "overlay"
---| "stack"

---@alias framework.ui.container.layout.direction
---| "horizontal"
---| "vertical"

---@class framework.ui.container.layout.options
---@field type? framework.ui.container.layout.type
---@field direction? framework.ui.container.layout.direction
---@field gap? number
---@field padding? number|framework.ui.padding
---@field align? string
---@field justify? string

---@class framework.ui.container.options: framework.ui.object_config
---@field layout? framework.ui.container.layout.options

---@class framework.ui.slot.progress: framework.ui.progress
---@field include_in_content boolean 是否计入 slot 的内容尺寸

---@class framework.ui.slot.image: framework.ui.image
---@field include_in_content boolean 是否计入 slot 的内容尺寸

---@class framework.ui.slot.background: framework.ui.image
---@field include_in_content boolean 是否计入 slot 的内容尺寸

---@class framework.ui.slot.text: framework.ui.text
---@field include_in_content boolean 是否计入 slot 的内容尺寸

---@class framework.ui.slot.child.options: framework.ui.object_config
---@field enable? boolean 是否创建该子控件
---@field include_in_content? boolean 是否计入 slot 的内容尺寸

---@class framework.ui.slot.progress.options: framework.ui.slot.child.options

---@class framework.ui.slot.image.options: framework.ui.slot.child.options

---@class framework.ui.slot.background.options: framework.ui.slot.child.options

---@class framework.ui.slot.text.options: framework.ui.slot.child.options

---@class framework.ui.slot.options: framework.ui.object_config
---@field progress? framework.ui.slot.progress.options 进度子控件选项
---@field image? framework.ui.slot.image.options 图片子控件选项
---@field background? framework.ui.slot.background.options 背景子控件选项
---@field text? framework.ui.slot.text.options 文本子控件选项

---@class framework.ui.slot: framework.ui.void
---@field progress? framework.ui.slot.progress 进度子控件
---@field image? framework.ui.slot.image 图片子控件
---@field background? framework.ui.slot.background 背景子控件
---@field text? framework.ui.slot.text 文本子控件

---@alias framework.ui.type
---| "void"
---| "text"
---| "image"
---| "progress_ring"
---| "progress_bar"
---| "model"
---| "slider"
---| "input"
---| "button"
---| "effect"

---@alias framework.ui.position
---| "left_top"
---| "top_left"
---| "center_top"
---| "top_center"
---| "right_top"
---| "top_right"
---| "center_left"
---| "left_center"
---| "center"
---| "center_right"
---| "right_center"
---| "left_bottom"
---| "bottom_left"
---| "center_bottom"
---| "bottom_center"
---| "right_bottom"
---| "bottom_right"

---@alias framework.ui.layer_name
---| "DEFAULT"
---| "WINDOW"
---| "HUD"
---| "SYSTEM"
---| "CINEMATIC"

---@alias framework.ui.layer framework.ui.handle

---@class framework.ui.anchor
---@field point framework.ui.position
---@field relative_point framework.ui.position
---@field x number
---@field y number
---@field relative_ui? framework.ui

---@class framework.ui.anchor.offset_options
---@field vertical_space? number
---@field horizontal_space? number

---@class framework.ui.text.outline
---@field enable? boolean
---@field width? number
---@field color? lib.color|table
---@field alpha? number

---@class framework.ui.layer.registry
---@field DEFAULT framework.ui.handle?
---@field WINDOW framework.ui.handle?
---@field HUD framework.ui.handle?
---@field SYSTEM framework.ui.handle?
---@field CINEMATIC framework.ui.handle?

---@class framework.ui.text.render_result
---@field text string
---@field width number
---@field height number

return true
