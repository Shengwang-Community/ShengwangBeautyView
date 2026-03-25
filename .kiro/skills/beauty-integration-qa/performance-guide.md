# 低端机性能优化指南

当用户反馈"低端机开播卡顿"、"美颜效果影响性能"、"需要优化低端机美颜"时，按以下优先级逐步建议并帮助修改代码。

---

## 优化建议优先级

### 建议 1：按设备打分屏蔽低端机能力（推荐首选）

**适用场景**：用户没有做任何设备分级，所有机型都开放了全部美颜功能。

**原理**：声网 SDK 内置设备打分，分数越低代表设备越弱。默认推荐策略：
- Android机型打分 < 65：隐藏整个美颜入口，不初始化美颜 SDK
- iOS机型打分 < 65：隐藏整个美颜入口，不初始化美颜 SDK
- Android机型打分 < 75：隐藏美妆和贴纸 tab（即使素材包里有这些模板也隐藏），只保留美颜和滤镜
- iOS机型打分 < 80：隐藏美妆和贴纸 tab（即使素材包里有这些模板也隐藏），只保留美颜和滤镜

**提出建议时的交互流程**：

1. 先向用户说明默认阈值（65 / 75），并询问是否接受，或希望调整分数
   - 例如用户可能希望 < 80 才隐藏美妆贴纸，或 < 60 才隐藏入口
2. 用户确认分数后，再询问平台（Android / iOS / 两端都要）
3. 拿到分数和平台后，直接帮改代码

**代码改动位置**：
- Android：`BeautyExampleActivity.kt` 的 `initializeBeauty()` 方法 + `ShengwangBeautyView` 的 `onPageListCreate()`
- iOS：`ExampleViewController.swift` 的 `initializeBeauty()` 方法 + `ShengwangBeautyView` 的 `onPageListCreate()`

**Android 示例**（以默认阈值 65 / 75 为例）：

```kotlin
// BeautyExampleActivity.kt
private fun initializeBeauty() {
    if (isInitialized) return
    isInitialized = true

    rtcEngine = createRtcEngine()

    // 获取设备打分
    val deviceScore = rtcEngine?.queryDeviceScore() ?: 100

    // < 65 分：设备太弱，不初始化美颜，隐藏美颜入口
    if (deviceScore < 65) {
        binding.tvBeauty.visibility = View.GONE
        return
    }

    val path = materialPath ?: return
    val success = ShengwangBeautyManager.initBeautySDK(path, rtcEngine!!)
    if (success) {
        ShengwangBeautyManager.enable(true)
        // 将设备打分传给 BeautyView，用于决定显示哪些 tab
        binding.beautyControlView.deviceScore = deviceScore
    }
}
```

```kotlin
// ShengwangBeautyView.kt - 新增 deviceScore 属性
var deviceScore: Int = 100  // 默认 100 分（不限制）

protected fun onPageListCreate(): List<BeautyPageInfo> {
    val pageList = mutableListOf<BeautyPageInfo>()

    // 美颜 tab（打分 >= 65 才到这里，始终显示）
    pageList.add(BeautyPageBuilder(beautyConfig) { refreshPageList() }.buildPage())

    // 美妆 tab：打分 >= 75 才显示
    if (deviceScore >= 75) {
        pageList.add(MakeupPageBuilder(beautyConfig).buildPage())
    }

    // 滤镜 tab
    pageList.add(FilterPageBuilder(beautyConfig).buildPage())

    // 贴纸 tab：打分 >= 75 才显示
    if (deviceScore >= 75) {
        pageList.add(StickerPageBuilder(beautyConfig).buildPage())
    }

    return pageList
}
```

**iOS 示例**（以默认阈值 65 / 75 为例）：

```swift
// ExampleViewController.swift
private func initializeBeauty() {
    guard rtcEngine == nil else { return }
    // ...创建 rtcEngine...

    // 获取设备打分
    let deviceScore = Int(rtcEngine.queryDeviceScore())

    // < 65 分：设备太弱，不初始化美颜，隐藏美颜入口
    if deviceScore < 65 {
        beautyButton.isHidden = true
        return
    }

    ShengwangBeautySDK.shared.initBeautySDK(rtcEngine: rtcEngine, materialBundlePath: beautyMaterialPath)
    ShengwangBeautySDK.shared.enable(true)

    // 将设备打分传给 BeautyView，用于决定显示哪些 tab
    beautyView?.deviceScore = deviceScore
}
```

```swift
// ShengwangBeautyView.swift - 新增 deviceScore 属性
public var deviceScore: Int = 100  // 默认 100 分（不限制）

internal func onPageListCreate() -> [BeautyPageInfo] {
    var pages: [BeautyPageInfo] = []

    // 美颜 tab（打分 >= 65 才到这里，始终显示）
    pages.append(beautyBuilder.buildPage())

    // 美妆 tab：打分 >= 75 才显示
    if deviceScore >= 75 {
        pages.append(makeupBuilder.buildPage())
    }

    // 滤镜 tab
    pages.append(filterBuilder.buildPage())

    // 贴纸 tab：打分 >= 75 才显示
    if deviceScore >= 75 {
        pages.append(stickerBuilder.buildPage())
    }

    return pages
}
```

> 注意：以上示例中的 tab 显示逻辑需结合当前素材包的实际内容（即 `onPageListCreate` 里已有的注释/启用状态），打分判断叠加在素材包判断之上，两者都满足才显示对应 tab。

### 建议 2：裁剪美颜 tab 下非必要子功能

**适用场景**：美颜 tab 内功能项太多（美肤 + 美型 + 画质共 30+ 项），低端机逐帧处理压力大，或用户反馈 UI 太复杂。

**原理**：`BeautyPageBuilder` 里每个 `addSkinBeautyItem` / `addFaceShapeItem` / `addQualityItem` 调用对应一个 UI 项，注释掉即可从 UI 移除，不影响 SDK 底层运行。

**提出建议时的交互流程**：

1. 告知用户默认推荐保留的功能项（见下表），询问是否需要增加
2. 询问是否需要结合建议 1 的设备打分做区分：
   - 例如：打分 >= 75 展示完整美颜 tab，打分 < 75 只展示精简版
   - 如果需要，询问具体分数阈值
3. 确认保留项和平台后，直接帮改代码

**默认推荐保留项**：

| 分类 | 保留项 |
|------|--------|
| 美肤 | 磨皮、美白、清晰度、锐化、红润、去黑眼圈、白牙 |
| 美型 | 瘦脸、V脸、下颌骨、大眼、瘦鼻、嘴形、微笑 |
| 画质 | 全部移除 |

**代码改动位置**：
- Android：`Android/lib/src/main/java/cn/shengwang/beauty/ui/builder/BeautyPageBuilder.kt`
## Agent 行为规范

1. 当用户提问涉及"低端机卡顿"、"性能优化"、"美颜太卡"、"低端设备"等关键词时，主动触发此流程
2. 按建议 1 → 建议 2 的顺序逐个提出，不要一次全抛出
3. 每个建议都先询问用户是否接受或调整参数，不要直接改代码
4. 两个建议都沟通完后，汇总用户的所有决定，打印最终优化结论，格式示例：

   ```
   根据你的要求，最终优化方案如下：
   - 设备打分 < 65：隐藏整个美颜入口
   - 设备打分 < 80：隐藏美妆、贴纸 tab
   - 美颜 tab 在所有机型上仅保留：磨皮、美白、清晰度、红润、去黑眼圈、白牙、瘦脸、V脸、下颌骨、大眼、瘦鼻、嘴形、微笑
   
   确认无误后我将开始修改代码。
   ```

5. 收到用户明确肯定（"确认"、"OK"、"没问题"、"好的"等）后，立即开始改代码
6. 如果用户两个建议都没接受，回答："没有需要改动的内容。" 不做任何代码修改
7. 改完后简要告知改了哪些文件
addSkinBeautyItem(items, R.string.beauty_effect_smoothness, R.drawable.beauty_ic_effect_smoothness, beautyConfig.smoothness, isSelected = beautyConfig.beautyEnable) { beautyConfig.smoothness = it }
// 美白
addSkinBeautyItem(items, R.string.beauty_effect_lightness, R.drawable.beauty_ic_effect_lightness, beautyConfig.whitenNatural) { beautyConfig.whitenNatural = it }
// 清晰度
addSkinBeautyItem(items, R.string.beauty_effect_contrast_strength, R.drawable.beauty_ic_effect_contrast_strength, beautyConfig.contrastStrength, valueRange = -1.0f..1.0f) { beautyConfig.contrastStrength = it }
// 红润
addSkinBeautyItem(items, R.string.beauty_effect_redness, R.drawable.beauty_ic_effect_redness, beautyConfig.redness) { beautyConfig.redness = it }
// 去黑眼圈
addSkinBeautyItem(items, R.string.beauty_effect_eye_pouch, R.drawable.beauty_ic_effect_eye_pouch, beautyConfig.eyePouch) { beautyConfig.eyePouch = it }
// 白牙
addSkinBeautyItem(items, R.string.beauty_effect_whiten_teeth, R.drawable.beauty_ic_effect_whiten_teeth, beautyConfig.whitenTeeth) { beautyConfig.whitenTeeth = it }
// 移除：锐化、亮眼、去法令纹
```

在 `addFaceShapeItems()` 中只保留：
```kotlin
// 瘦脸
addFaceShapeItem(items, R.string.beauty_face_shape_face_contour, R.drawable.beauty_ic_face_shape_face_contour, beautyConfig.faceContour) { beautyConfig.faceContour = it }
// V脸
addFaceShapeItem(items, R.string.beauty_face_shape_mandible, R.drawable.beauty_ic_face_shape_mandible, beautyConfig.mandible) { beautyConfig.mandible = it }
// 下颌骨
addFaceShapeItem(items, R.string.beauty_face_shape_cheek, R.drawable.beauty_ic_face_shape_cheek, beautyConfig.cheek) { beautyConfig.cheek = it }
// 大眼
addFaceShapeItem(items, R.string.beauty_face_shape_eye_scale, R.drawable.beauty_ic_face_shape_eye_scale, beautyConfig.eyeScale) { beautyConfig.eyeScale = it }
// 瘦鼻
addFaceShapeItem(items, R.string.beauty_face_shape_nose_width, R.drawable.beauty_ic_face_shape_nose_width, beautyConfig.noseWidth) { beautyConfig.noseWidth = it }
// 嘴形
addFaceShapeItem(items, R.string.beauty_face_shape_mouth_scale, R.drawable.beauty_ic_face_shape_mouth_scale, beautyConfig.mouthScale, valueRange = -100f..100f) { beautyConfig.mouthScale = it }
// 微笑
addFaceShapeItem(items, R.string.beauty_face_shape_mouth_smile, R.drawable.beauty_ic_face_shape_mouth_smile, beautyConfig.mouthSmile) { beautyConfig.mouthSmile = it }
// 移除：其余所有美型项
```

`addQualityItems()` 整个方法调用注释掉：
```kotlin
// addQualityItems(beautyItems)  // 低端机移除画质调节
```

**如果用户需要结合打分区分**，在 `BeautyPageBuilder` 构造时传入 `deviceScore`，在 `buildPage()` 里按分数决定调用完整版还是精简版的 `addSkinBeautyItems` / `addFaceShapeItems`。
1. 希望保留哪些项？还是直接用上面推荐方案？
2. 确认平台（Android / iOS / 两端都要）

---

## Agent 行为规范

1. 当用户提问涉及"低端机卡顿"、"性能优化"、"美颜太卡"、"低端设备"等关键词时，主动触发此流程
2. 按建议 1 → 建议 2 的顺序逐个提出，不要一次全抛出
3. 用户说"接受"或"好的"或"帮我改"后，立即定位到对应文件帮助修改代码
4. 改完后告知用户改了哪里，以及下一个可选的优化建议
5. 如果用户只说"接受"但没说平台，先问清楚再改
