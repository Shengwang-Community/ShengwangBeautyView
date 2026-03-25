# 声网美颜 SDK 快速集成 Skill

## Skill 目的

帮助开发者快速将声网美颜特效集成到已有的 RTC 工程中。目标用户不一定熟悉美颜逻辑，也不一定会仔细看文档，因此 Agent 应主动理解用户意图，直接帮助修改代码，而不是只给文档链接。

## 工程上下文

本仓库是声网美颜 SDK 的集成示例工程，包含：

- Android 端：核心库在 `Android/lib/`，Demo 在 `Android/app/`
- iOS 端：核心组件在 `iOS/ShengwangBeautyView/`，Demo 在 `iOS/BeautyView/`

Demo 工程是最佳参考，用户遇到不确定的集成问题时，优先对照 Demo 代码给出答案。

## 关键参考文件

- Android 集成说明：#[[file:Android/README.md]]
- Android 库说明：#[[file:Android/lib/README.md]]
- iOS 集成说明：#[[file:iOS/README.md]]
- Android Demo 核心示例：#[[file:Android/app/src/main/java/cn/shengwang/videobeauty/BeautyExampleActivity.kt]]
- iOS Demo 核心示例：#[[file:iOS/BeautyView/Example/ExampleViewController.swift]]

## 知识库

- 常见问题解答：#[[file:.kiro/skills/beauty-integration-qa/qa.md]]
- 集成操作指南（含完整 API 和参数）：#[[file:.kiro/skills/beauty-integration-qa/integration-guide.md]]
- 模板列表与映射关系：#[[file:.kiro/skills/beauty-integration-qa/template-list.md]]
- 低端机性能优化指南：#[[file:.kiro/skills/beauty-integration-qa/performance-guide.md]]
- 素材包配置文件（真实模板名来源）：#[[file:iOS/BeautyView/Example/AgoraBeautyMaterial.bundle/beauty_material_encrypted/config.json]]

## Agent 行为规范

### 主动帮改代码
用户描述需求时（如"我想加个磨皮"、"怎么开美颜"、"我想在退出时关掉美颜"），不要只回答理论，要直接定位到用户工程的相关文件，给出可以直接使用的代码修改。

### 先问平台
如果用户没有说明是 Android 还是 iOS，先确认平台再给出对应代码。

### 理解美颜逻辑再回答
用户可能不懂"节点"、"模板"这些概念，遇到这类问题时用通俗语言解释，再给代码。核心逻辑：
- 美颜/美妆/滤镜/贴纸是四个独立的"节点"，用 `addOrUpdateVideoEffect` 加载，用 `removeVideoEffect` 关闭
- 节点加载后才能调参数（`setVideoEffectXXXParam`）
- 美型的捏脸部位用单独的 `setFaceShapeAreaOptions` API 控制
- 风格妆滤镜和普通滤镜互斥，同时只能生效一个

### 集成顺序不能错
初始化：先创建 RtcEngine → 再 createVideoEffectObject → 再 addOrUpdateVideoEffect
销毁：先 destroyVideoEffectObject → 再 leaveChannel/destroy RtcEngine

### 优先使用封装好的组件
如果用户使用的是本仓库的 lib 模块（Android）或 ShengwangBeautyView pod（iOS），优先引导使用封装好的 `ShengwangBeautyManager` / `ShengwangBeautySDK` 和 `ShengwangBeautyView`，而不是直接操作底层 API，除非用户有定制需求。

### 回答语言
使用中文回答。
