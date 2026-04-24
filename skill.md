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

---

## 按素材包适配 UI

**常见提问**：「请开始按素材包适配UI」、「美颜素材包已更新，请开始适配UI」

### 操作步骤

1. **读取素材包的 `config.json`**，确认实际可用模板列表。
   - 素材包路径规则见 `.skills/beauty-integration-qa/template-list.md`
   - Android：解压 `Android/app/src/main/assets/AgoraBeautyMaterial.zip`，读取 `beauty_material_functional/config.json`（或 `beauty_material_encrypted/config.json`）
   - iOS：直接读取 `iOS/BeautyView/Example/AgoraBeautyMaterial.bundle/beauty_material_functional/config.json`（或 encrypted 目录）
   - 取 `user_interface_option` 的所有 key 作为实际可用模板

2. **对比各 PageBuilder 的 UI 项**，按模板名前缀分类：
   - `Makeup-` → `MakeupPageBuilder`（Android + iOS）
   - `Filter-` → `FilterPageBuilder`（Android + iOS）
   - `Sticker-` → `StickerPageBuilder`（Android + iOS）
   - `Beauty-` → 美颜 tab 不受影响（参数项不依赖模板名）

3. **注释掉素材包里不存在的 UI 项**，保留存在的，注释格式：
   - Android（Kotlin）：`// 注释原因 — 素材包不含此模板，已注释` + 用 `//` 注释掉调用代码
   - iOS（Swift）：`// 注释原因 — not in material package, commented out` + 用 `//` 注释掉调用代码

4. **Flutter 不动**。

### 注意事项

- 贴纸的 `-Lite` 静态版（如 `Sticker-Piggy-Lite`）在代码里没有单独 UI 项，只需保留对应动态版的 item 即可
- 某类型模板全部不存在时，整个 tab 可以删除（但通常只注释 item，不删 tab）
- Android 和 iOS 需同步修改，两端 config.json 内容应一致（仅 Beauty-Anchor 路径不同）
- 修改完后用 `getDiagnostics` 验证无编译错误
