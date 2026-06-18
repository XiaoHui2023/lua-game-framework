# lua-game-framework

Lua game framework layer. The framework owns domain models, lifecycle helpers,
and reactive state. It must not read a global engine directly; the host
application installs an engine adapter before loading runtime modules, and
runtime modules perform engine-specific injection.

## Host Injection

The host entry should install the engine once:

```lua
require "framework.engine".install_y3(y3, {
    log = log,
    GameAPI = GameAPI,
})

require "runtime"
```

Runtime bindings then read the adapter through:

```lua
local engine = require "framework.engine".require()
local y3 = engine.y3
```

For another engine, provide the same capabilities through `framework.engine.set`.
The reusable library should depend on the injected adapter, not on `_G.y3`.

The generic runtime expects these adapter fields:

```lua
require "framework.engine".set({
    log = {
        error = function(message) end,
    },
    math_backend = {
        random_float = function(min, max) end,
        sin = function(value) end,
        asin = function(value) end,
        cos = function(value) end,
        atan = function(value) end,
    },
    schedule_next_frame = function(flush) end,
    configure_log = function(debug_enabled) end,
    is_debug_mode = function() return false end,
})
```

Engine-specific runtime files may require extra adapter fields. The Y3 runtime
bindings use `engine.y3` and `engine.GameAPI`.

## Layout

```text
runtime/            host bootstrap, framework injection, and library backend setup
lib/reactive/       engine-independent reactive primitives
framework/          reusable engine-independent game framework
framework/state_machine/ hierarchical state machine for gameplay orchestration
config/             project-level defaults and overrides
scene/              map scene instances
prefab/             reusable prefab definitions
game/systems/       gameplay systems
game/plugins/       optional gameplay/UI/camera plugins
```

Inside a framework domain module:

```text
init.lua            public module facade and same-directory load order
state.lua           module-level mutable state; plain Lua values only
types.lua           EmmyLua-only payload/object type declarations when they would crowd init.lua
settings.lua        framework default values and overridable knobs
apis.lua            callback.api declarations owned by this framework module
impl/               engine-independent callback handler registrations
factory/create file domain object construction API, named by responsibility
```

Avoid generic `base.lua`, `config.lua`, and `api.lua` in framework submodules. Split them
by responsibility instead: use `init.lua` for the facade/contract and load order,
`state.lua` for module-level mutable state, `settings.lua` for defaults, `types.lua` for
large annotation-only type blocks, and `apis.lua` only for callback API
declarations. Module-level state must be plain Lua data, not reactive refs,
events, or semaphores. Framework modules expose stable callback APIs from
`apis.lua` through their module facade, and load engine-independent `impl/`
handlers exactly once from `init.lua`. Engine-specific bindings live under
`runtime/framework/`; framework API declarations do not require
`framework.engine` or other runtime adapters. External engine capabilities are
also callback APIs: declare them in `framework/*/apis.lua`, implement them in
`runtime/framework/*`, and let framework `impl/` handlers handle pure state or
engine-independent behavior.

## State Machine

`framework.state_machine` follows common state machine/statechart vocabulary:
`machine`, `state`, `transition`, `guard`, `action`, `entry`, `exit`, and
parent/child states. It is meant for gameplay orchestration such as blocking,
counterattacks, projectiles, timed states, active/passive interrupts, and
owner-based cleanup.

```lua
local sm = require "framework.state_machine"

local machine = sm.machine({ name = "hero_state", owner = hero })

local block = sm.state({
    name = "block",
    machine = machine,
    on_entry = function(state)
        state:add_timer(1.0, function()
            state:done("timeout")
        end)
    end,
})

block:on("attacked", function(state, attack)
    state:done("counter")
end, { once = true })

block:transition_to({
    name = "counter",
    on_entry = function(_, context)
        -- context.reason == "counter"
    end,
})

block:start()
machine:emit("attacked", attack)
machine:destroy("unit_destroy")
```

## Load Order

The application should load in this order:

```text
framework.engine install
runtime
config
scene / systems / plugins
```

Project defaults in `config/framework/*` must load before scene or system code
creates framework objects.
