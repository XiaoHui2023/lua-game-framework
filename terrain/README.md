# terrain

地形模块，负责地表纹理绘制、纹理组和地形渲染请求。

- palette 描述纹理组和混合数量。
- painter 负责把点位和纹理选择整理成绘制数据。
- render 通过 callback API 把绘制请求交给运行时。

## 设计特性

### 纹理组

地形绘制以纹理组为单位组织。场景或地图配置可以提供组，绘制逻辑只关心选择和混合。

### 绘制分层

painter 处理“画哪里、用什么纹理”，render 处理“如何提交绘制”。运行时再把抽象请求翻译成引擎调用。

## 目录

```text
apis.lua     # 地形 callback API
init.lua     # 模块门面与类型
painter.lua  # 地形绘制数据整理
render.lua   # 绘制请求提交
settings.lua # 地形默认参数
```
