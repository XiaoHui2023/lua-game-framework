# game

游戏全局模块，声明游戏级生命周期、设置和宿主能力入口。

- `apis.lua` 放游戏级 callback API。
- `settings.lua` 放框架默认开关。
- 运行时负责把引擎游戏事件接入这些 API。

## 设计特性

### 生命周期入口

游戏开始、初始化、调试模式等全局能力通过 API 进入框架。业务模块可以监听这些 API，而不是直接读宿主全局。

### 默认参数

模块默认值集中在 settings。项目配置可以覆盖 settings 表，框架门面不直接承载可变配置字段。

## 目录

```text
apis.lua     # 游戏级 callback API
init.lua     # 模块门面
settings.lua # 游戏默认参数
```
