# 声网美颜 SDK 工程导航

## Skill 目录

本仓库包含以下 skill，位于 `.skills/beauty-integration-qa/`：

| 文件 | 用途 |
|------|------|
| `skill.md` | Skill 入口，工程上下文与 Agent 行为规范 |
| `integration-guide.md` | 完整集成文档，含 API 参数、节点类型、模板列表 |
| `qa.md` | 常见问题解答（包体积、资源包获取、注意事项等） |
| `performance-guide.md` | 低端机性能优化指南（设备打分分级、tab 裁剪） |
| `template-list.md` | 滤镜/美妆/贴纸模板名称与映射关系 |

Skill 入口文件：`#[[file:.skills/beauty-integration-qa/skill.md]]`

---

## 声网 SDK 依赖版本

各平台当前使用的声网 SDK 版本如下，有人询问版本或依赖配置时直接参考此节。

### iOS
文件：`iOS/podfile`
```ruby
pod 'AgoraRtcEngine_iOS', '4.5.3', :subspecs => ['RtcBasic', 'ClearVision']
```
- 当前版本：**4.5.3**
- 只引入了 `RtcBasic` 和 `ClearVision` 两个 subspec，ClearVision 是美颜插件所在模块

### Android
文件：`Android/app/build.gradle`
```groovy
implementation 'io.agora.rtc:full-rtc-basic:4.5.3'
implementation 'io.agora.rtc:clear-vision:4.5.3'
```
- 当前版本：**4.5.3**
- 支持本地 SDK（`USE_LOCAL_SDK=true`）和 Maven 两种方式，Maven 方式用上面两行依赖

### Flutter
文件：`Flutter/pubspec.yaml`
```yaml
agora_rtc_engine:
  git:
    url: https://github.com/AgoraIO-Extensions/Agora-Flutter-SDK.git
    ref: 6.5.2-sp.4529.b.1
```
- 当前版本：**6.5.2-sp.4529.b.1**（特殊版本，通过 git ref 引入，非 pub.dev 正式版）
- Flutter SDK 版本号与 Android/iOS 不同，是 Flutter 封装层的版本

---

## Android

#[[file:Android/README.md]]

---

## iOS

#[[file:iOS/README.md]]

---

## Flutter

#[[file:Flutter/README.md]]
