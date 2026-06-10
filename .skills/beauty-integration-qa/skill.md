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
- Flutter 集成说明：#[[file:Flutter/README.md]]
- Android Demo 核心示例：#[[file:Android/app/src/main/java/cn/shengwang/videobeauty/BeautyExampleActivity.kt]]
- iOS Demo 核心示例：#[[file:iOS/BeautyView/Example/ExampleViewController.swift]]
- Flutter Demo 核心示例：#[[file:Flutter/lib/Example/example_page.dart]]

## 知识库

- 常见问题解答：#[[file:.skills/beauty-integration-qa/qa.md]]
- 集成操作指南（含完整 API 和参数）：#[[file:.skills/beauty-integration-qa/integration-guide.md]]
- 模板列表与映射关系：#[[file:.skills/beauty-integration-qa/template-list.md]]
- 低端机性能优化指南：#[[file:.skills/beauty-integration-qa/performance-guide.md]]
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

### 打包交付

当用户说"整理完了，帮我打包""帮我构建产物"或类似表述时：

**Android**：执行 AAR 构建脚本，完成后告知产物路径。

```bash
# 在 Android 目录下执行
./lib/build-aar.sh
```

产物位置：`Android/release/shengwang-beauty-view-1.0.0.aar`

**iOS**：不需要构建，直接告知用户将 `iOS/ShengwangBeautyView` 目录拷贝到自己工程，通过本地 CocoaPods 依赖：

```ruby
pod 'ShengwangBeautyView', :path => './ShengwangBeautyView'
```

详细集成步骤参考 `iOS/README.md`。

**Flutter**：Flutter 没有二进制产物的概念，交付形式取决于用户目的：

1. **交付组件源码**（最常见）：直接将 `Flutter/lib/BeautyView/` 目录拷贝到用户工程，无需构建。告知用户在 `pubspec.yaml` 中添加以下依赖后执行 `flutter pub get`：

```yaml
dependencies:
  agora_rtc_engine:
    git:
      url: https://github.com/AgoraIO-Extensions/Agora-Flutter-SDK.git
      ref: 6.5.2-sp.4529.b.1
  path_provider: ^2.0.8
  archive: ^3.4.10
```

2. **构建 Android APK/AAB**：

```bash
# 在 Flutter 目录下执行
flutter build apk --release          # APK
flutter build appbundle --release    # AAB（推荐上架 Google Play）
```

产物位置：`Flutter/build/app/outputs/`

3. **构建 iOS IPA**：

```bash
# 在 Flutter 目录下执行
flutter build ios --release
```

构建完成后需用 Xcode 打开 `Flutter/ios/Runner.xcworkspace`，通过 **Product → Archive** 导出 IPA。需要配置好 Apple Developer 账号、Bundle ID 和 Provisioning Profile。

> 注意：Flutter 构建 iOS 时需要 macOS 环境，Android 构建无此限制。

### 小语种翻译

当用户需要适配小语种时，以英文文案为基准进行翻译，直接帮用户创建对应语言的文案文件。

**Android 文案位置**：
- 英文（基准）：`Android/lib/src/main/res/values-en/strings.xml`
- 新语言：`Android/lib/src/main/res/values-<语言代码>/strings.xml`
  - 日语 `values-ja`，韩语 `values-ko`，阿拉伯语 `values-ar`，法语 `values-fr`，西班牙语 `values-es`

**iOS 文案位置**：
- 英文（基准）：`iOS/ShengwangBeautyView/Resources/Localizations/en.lproj/Localizable.strings`
- 新语言：`iOS/ShengwangBeautyView/Resources/Localizations/<语言代码>.lproj/Localizable.strings`
  - 日语 `ja.lproj`，韩语 `ko.lproj`，阿拉伯语 `ar.lproj`，法语 `fr.lproj`，西班牙语 `es.lproj`

**翻译规则**：
1. 以英文文案为基准翻译，保持 key 不变，只翻译 value
2. 美颜功能词（Smooth、Whiten、V-Face 等）优先使用目标语言的美妆行业通用术语
3. 滤镜和贴纸名称（Serene、Latte、Christmas 等）可保留英文或意译，以自然为准
4. Android 中 `\n` 是换行符，翻译时保留换行逻辑（短词可不换行）
5. 翻译完成后告知用户：iOS 还需在 Xcode 的 Project > Info > Localizations 中手动添加对应语言

**Flutter 文案位置**：
- Flutter 的文案硬编码在 `Flutter/lib/Utils/beauty_localizer.dart` 的 Map 中，不是独立文件
- 英文（基准）：`_enStrings` Map
- 新语言：在 `beauty_localizer.dart` 中新增对应语言的 Map，并在 `beautyLocalized()` 函数里添加分支

**Flutter 翻译步骤**：
1. 在 `beauty_localizer.dart` 中参照 `_enStrings` 新增语言 Map，例如日语 `_jaStrings`
2. 在 `beautyLocalized()` 函数中添加对应分支：
```dart
if (lang == 'ja') {
  map = _jaStrings;
}
```
3. 翻译时保持 key 不变，只翻译 value；`\n` 换行符按需保留

**强制设置默认语言**：

当用户说"把美颜 UI 默认语言改为 xx 语"时，除了创建文案文件，还需要修改代码中的强制语言设置：

Android — 在初始化 `ShengwangBeautyView` 之前设置（通常在 `BeautyExampleActivity` 或 Application 里）：
```kotlin
// 强制日语（在 ShengwangBeautyView 初始化前调用）
ShengwangBeautyManager.forcedLanguage = "ja"
// 恢复跟随系统
ShengwangBeautyManager.forcedLanguage = null
```

iOS — 在初始化 `ShengwangBeautyView` 之前设置（通常在 `ExampleViewController` 或 AppDelegate 里）：
```swift
// 强制日语（在 ShengwangBeautyView 初始化前调用）
String.beautyForcedLanguage = "ja"
// 恢复跟随系统
String.beautyForcedLanguage = nil
```

常用语言代码：`ja`（日语）、`ko`（韩语）、`fr`（法语）、`ar`（阿拉伯语）、`es`（西班牙语）、`de`（德语）、`pt`（葡萄牙语）

Flutter — 在创建 `ExamplePage` 时通过 `lang` 参数传入，或直接调用 `BeautyLocalizer.setLang()`：
```dart
// 方式一：通过 ExamplePage 的 lang 参数（推荐）
ExamplePage(
  materialBundlePath: destPath,
  lang: 'ja',  // 传入语言代码
)

// 方式二：直接设置（在 ShengwangBeautyView 显示前调用）
BeautyLocalizer.setLang('ja');
// 恢复英文
BeautyLocalizer.setLang('en');
```

Flutter 的语言设置是运行时切换，不需要重启 App，但需要在 `ShengwangBeautyView` 渲染前设置好。

### 回答语言
使用中文回答。
