# 美颜特效SDK集成文档

本文档用于指导用户在已有工程中集成声网美颜 SDK。Agent 应根据用户的平台（Android/iOS）和集成方式，按步骤引导或自动完成代码调整。

## 集成前须知

1. 从声网技术支持获取最新支持美颜的RTC版本，pod或maven依赖
2. 美颜资源包（`AgoraBeautyMaterial.zip` 或 `AgoraBeautyMaterial.bundle`），联系声网技术支持获取，
也可自行把 bundle 部署在自己后端，不一定走本地化集成。
3. 二进制(单架构) size 对比三方如下表:

| 平台 | 相芯 | 商汤 | 火山 | 声网 |
|------|------|------|------|------|
| iOS | FURenderKit: 18.2MB | SenseLib: 21.1MB| Effectsdk<br>: 39.6MB | AgoraClearVision.xcframework: 9.1MB |
| Android | 包含 aar 约41.3MB | STMobileJNI-release.aar: 15.3MB | effectAAR-release.aar: 20.7MB | libagora_clear_vision_extension.so: 9.7MB |

4. 权限检查：美颜素材文件需要读写权限，移动端建议把 bundle 拷贝到沙盒。
5. 性能考虑：低端场景合理关闭部分功能，贴纸特效可做非动态的。可和声网技术支持沟通一次性能怎么适配，减少上线问题。

## 设备性能要求与推荐

声网美颜特效支持：iOS / Android / Mac / Windows 4 端。

声网美颜特效依赖内部设备打分判断，会对极低端场景（机型打分低于65）做一定限制。

```java
// 声网的设备打分直接从 sdk 获取
int deviceScore = mRtcEngine.queryDeviceScore(); // java
let deviceScore = agorakit.queryDeviceScore(); // swift
```

当调用 `addOrUpdateVideoEffect` 返回值非 0 时，请注意做必要的提示，告诉用户可能他的设备不支持。

SDK 常见错误码：
- `-2 ERR_INVALID_ARGUMENT`：参数错误，一般是节点类型和素材路径是无效值
- `-4 ERR_NOT_SUPPORTED`：设备打分太低端（美颜特效最低要求 65 分）
- `-7 ERR_NOT_INITIALIZED`：SDK engine 对象没有创建成功，或调用时序上有问题，需要保证先创建 sdk 再启用美颜插件

为了更好的 APP 设计，规避美颜特效开太多出现直播间卡顿现象，我们推荐：
- < 65 分，app 的 UI 界面不展示整个美颜特效功能入口
- < 75 分，app 的 UI 界面不展示美妆和贴纸功能
- 低端场景范围较广的客户，不推荐做复杂的动图贴纸，美妆也建议仅保留腮红/唇妆等必要项
- 如果客户有 1080P 或高帧率开播需求，除了上述通用策略，可联系声网技术支持协商更优的配置策略

## 美颜特效功能集合

所有原子功能:
- 美颜tab:
1. 基础美颜：磨皮/美白/清晰度/红润/锐化
2. 美型：按五官分类
a. 脸部美型：小头/瘦脸/额头/v脸/窄脸/瘦颧骨/下颌骨/下巴
b. 眼部美型：大眼/眼距/眼上下/眼睑下至/瞳孔/内眼角/外眼角
c. 鼻部美型：瘦鼻/长鼻/鼻翼/鼻梁/鼻尖/山根/鼻综合
d. 嘴部美型：嘴形/微笑/丰唇/缩人中
e. 眉毛美型：眉上下/眉粗细
3. 画质：色温/色调/饱和度/亮度
- 美妆tab：睫毛/眼影/眉妆/唇妆/腮红/修容
- 滤镜tab：现成模板，不区分子能力
- 贴纸tab：现成模板，不区分子能力

声网有一定量的美颜/美妆/滤镜/贴纸模板可以挑选。
滤镜/贴纸也支持自定义需求，可联系技术支持。
自定义人脸贴纸有制作要求，可支持动图效果。

模板的美颜参数，如果对美颜参数敏感（不希望被外部获取），可加密。


## 集成步骤

### 步骤一：创建视频特效对象

在 RTCEngine 初始化完成后创建。

**Android 示例：**

```java
IVideoEffectObject mVideoEffectObject = mRtcEngine.createVideoEffectObject(
    "your/local/bundle/path/beauty_material_functional", // 本地素材路径
    Constants.MediaSourceType.PRIMARY_CAMERA_SOURCE
);
```

**iOS 示例：**

```swift
var videoEffectObject: AgoraVideoEffectObject?
videoEffectObject = agorakit.createVideoEffectObject(
    bundlePath: "your/local/bundle/path/beauty_material_functional",
    sourceType: .primaryCamera)
```

### 步骤二：添加与管理特效节点

#### 1. 特效节点类型
| 节点类型 | 说明 |
|---------|------|
| BEAUTY | 基础美颜+美型+美肤+画质，对应功能集合上的美颜tab |
| STYLE_MAKEUP | 风格妆，对应功能集合上的美妆tab |
| FILTER | 滤镜，对应功能集合上的滤镜tab |
| STICKER | 贴纸，对应功能集合上的贴纸tab |

#### 2. 加载特效节点

使用模板快速启用特效。

**Android 示例：**

```java
/* 添加美颜节点。指定"模板—主播" */
int result = mVideoEffectObject.addOrUpdateVideoEffect(
    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.getValue(), "模板—主播");
// 检查 result == 0 表示成功

/* 添加风格妆节点。未指定模板，使用默认模板 */
int result = mVideoEffectObject.addOrUpdateVideoEffect(
    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.getValue(), "");
// 检查 result == 0 表示成功

/* 更新风格妆节点的模板为"学姐妆" */
int result = mVideoEffectObject.addOrUpdateVideoEffect(
    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.getValue(), "学姐妆");
// 检查 result == 0 表示成功
```

**iOS 示例：**

```swift
/* 添加美颜节点。指定"模板—主播" */
let result = videoEffectObject?.addOrUpdateVideoEffect(
    nodeId: AgoraVideoEffectNodeId.beauty.rawValue,
    templateName: "模板-主播")
// 检查 result == 0 表示成功

/* 添加风格妆节点。未指定模板，使用默认模板 */
let result = videoEffectObject?.addOrUpdateVideoEffect(
    nodeId: AgoraVideoEffectNodeId.styleMakeup.rawValue,
    templateName: "")
// 检查 result == 0 表示成功

/* 更新风格妆节点的模板为"学姐妆" */
let result = videoEffectObject?.addOrUpdateVideoEffect(
    nodeId: AgoraVideoEffectNodeId.styleMakeup.rawValue,
    templateName: "学姐妆")
// 检查 result == 0 表示成功
```

#### 3. 设置特效参数

需要在添加过特效节点后才能修改该特效节点内的参数，支持设置 float/int/bool/string 类型参数。以 BEAUTY 节点为例：

**Android 示例：**

```java
/* 调节基础美颜中的参数 */
mVideoEffectObject.setVideoEffectFloatParam("beauty_effect_option", "smoothness", 0.7f); // 磨皮强度设置为0.7
mVideoEffectObject.setVideoEffectBoolParam("beauty_effect_option", "enable", false); // 关闭基础美颜+美肤+画质

/* 调节美肤中的参数 */
mVideoEffectObject.setVideoEffectFloatParam("face_buffing_option", "brighten_eye", 0.8f); // 亮眼强度设置为0.8

/* 调节画质中的参数 */
mVideoEffectObject.setVideoEffectFloatParam("beauty_effect_option", "saturation", 0.3f); // 饱和度强度设置为0.3

/* 调节美型中的参数 */
mVideoEffectObject.setVideoEffectIntParam("face_shape_beauty_option", "style", 0); // 美型切换到女神风格
mVideoEffectObject.setVideoEffectIntParam("face_shape_beauty_option", "intensity", 50); // 女神风格强度50%
```

**iOS 示例：**

```swift
/* 调节基础美颜中的参数 */
videoEffectObject?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "smoothness", floatValue: 0.7) // 磨皮强度设置为0.7
videoEffectObject?.setVideoEffectBoolParam(option: "beauty_effect_option", key: "enable", boolValue: false) // 关闭基础美颜+美肤+画质

/* 调节美肤中的参数 */
videoEffectObject?.setVideoEffectFloatParam(option: "face_buffing_option", key: "brighten_eye", floatValue: 0.8) // 亮眼强度设置为0.8

/* 调节画质中的参数 */
videoEffectObject?.setVideoEffectFloatParam(option: "beauty_effect_option", key: "saturation", floatValue: 0.3) // 饱和度强度设置为0.3

/* 调节美型中的参数 */
videoEffectObject?.setVideoEffectIntParam(option: "face_shape_beauty_option", key: "style", intValue: 0) // 美型切换到女神风格
videoEffectObject?.setVideoEffectIntParam(option: "face_shape_beauty_option", key: "intensity", intValue: 50) // 女神风格强度50%
```

#### 4. 获取特效参数

可以获取当前特效节点的参数值，支持获取 float/int/bool 类型参数，用于 UI 的刷新。以 BEAUTY 节点为例：

**Android 示例：**

```java
/* 获取基础美颜中的参数 */
float smoothness = mVideoEffectObject.getVideoEffectFloatParam("beauty_effect_option", "smoothness"); // 获取磨皮强度
boolean enable = mVideoEffectObject.getVideoEffectBoolParam("beauty_effect_option", "enable"); // 获取基础美颜开关状态

/* 获取美型中的参数 */
int type = mVideoEffectObject.getVideoEffectIntParam("face_shape_beauty_option", "style"); // 获取美型风格类型
int intensity = mVideoEffectObject.getVideoEffectIntParam("face_shape_beauty_option", "intensity"); // 获取美型风格强度
```

**iOS 示例：**

```swift
/* 获取基础美颜中的参数 */
let smoothness = videoEffectObject?.getVideoEffectFloatParam(option: "beauty_effect_option", key: "smoothness") // 获取磨皮强度
let enable = videoEffectObject?.getVideoEffectBoolParam(option: "beauty_effect_option", key: "enable") // 获取基础美颜开关状态

/* 获取美型中的参数 */
let type = videoEffectObject?.getVideoEffectIntParam(option: "face_shape_beauty_option", key: "style") // 获取美型风格类型
let intensity = videoEffectObject?.getVideoEffectIntParam(option: "face_shape_beauty_option", key: "intensity") // 获取美型风格强度
```

#### 5. 保存与重置配置参数

保存操作：将主播调完参后的参数直接保存到本地，下次 `addOrUpdateVideoEffect` 加载节点时会自动调用之前保存好的参数。

重置操作：重置恢复为出厂时模板内的参数值。

> 注意：保存与重置操作后，下次 `addOrUpdateVideoEffect` 加载节点时会自动生效。保存与重置操作也可针对多个特效节点，即一次性保存多个节点。

**Android 示例：**

```java
// 保存当前 BEAUTY 节点的所有参数
mVideoEffectObject.performVideoEffectAction(
    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.getValue(),
    IVideoEffectObject.VIDEO_EFFECT_ACTION.SAVE);

// 用"|"运算同时保存多个节点
mVideoEffectObject.performVideoEffectAction(
    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.getValue() |
    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP.getValue(),
    IVideoEffectObject.VIDEO_EFFECT_ACTION.SAVE);

// 将 BEAUTY 节点的参数重置为默认
mVideoEffectObject.performVideoEffectAction(
    IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.getValue(),
    IVideoEffectObject.VIDEO_EFFECT_ACTION.RESET);
```

**iOS 示例：**

```swift
// 保存当前 BEAUTY 节点的所有参数
videoEffectObject?.performVideoEffectAction(
    nodeId: AgoraVideoEffectNodeId.beauty.rawValue,
    actionId: AgoraVideoEffectAction.save)

// 用"|"运算同时保存多个节点
videoEffectObject?.performVideoEffectAction(
    nodeId: AgoraVideoEffectNodeId.beauty.rawValue | AgoraVideoEffectNodeId.styleMakeup.rawValue,
    actionId: AgoraVideoEffectAction.save)

// 将 BEAUTY 节点的参数重置为默认
videoEffectObject?.performVideoEffectAction(
    nodeId: AgoraVideoEffectNodeId.beauty.rawValue,
    actionId: AgoraVideoEffectAction.reset)
```

#### 6. 移除特效节点

使用完成后可以移除特效节点。

**Android 示例：**

```java
// 移除BEAUTY节点
mVideoEffectObject.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.BEAUTY.getValue());

// 移除STICKER节点
mVideoEffectObject.removeVideoEffect(IVideoEffectObject.VIDEO_EFFECT_NODE_ID.STICKER.getValue());
```

**iOS 示例：**

```swift
// 移除BEAUTY节点
videoEffectObject?.removeVideoEffect(nodeId: AgoraVideoEffectNodeId.beauty.rawValue)

// 移除STICKER节点
videoEffectObject?.removeVideoEffect(nodeId: AgoraVideoEffectNodeId.sticker.rawValue)
```

### 步骤三：销毁特效对象

当不需要使用特效或需要销毁 RTCEngine 前，请销毁特效对象以释放资源。

请注意先执行完插件相关的操作，再去释放 sdk。

```
销毁顺序：
即将进行销毁执行操作
1. removeVideoEffect（可选，destroyVideoEffectObject 会自动清理节点）
2. destroyVideoEffectObject
SDK退频道，释放 RtcEngine
3. stopPreview
4. leaveChannel
5. RtcEngine.destroy()
```

**Android 示例：**

```java
mRtcEngine.destroyVideoEffectObject(mVideoEffectObject);
mVideoEffectObject = null;
```

**iOS 示例：**

```swift
agorakit.destroyVideoEffectObject(videoEffectObject)
videoEffectObject = nil
```

## 支持参数合集

> 🌟 请注意，参数合集虽然是开放的，但并不是所有参数都必要手动调，一般来说在预设模板的基础上去做必要的控制就可以了。

所有参数均是通过上面的 `setVideoEffectXXXParam` / `getVideoEffectXXXParam` 进行操作。

### 美颜模板-基础

| table | options | 值范围 | 说明 |
|-------|---------|--------|------|
| beauty_effect_option | enable | bool | 打开与关闭美颜模板 |
| | smoothness | float 0.0~1.0 | 磨皮强度 |
| | lightness | float 0.0~1.0 | 美白强度 |
| | whiten_lut_path | string 自定义美白滤镜的相对路径 | 此功能支持客户自定义切换声网默认素材包中冷白："../resource/whiten/lengbai.png" 粉白："../resource/whiten/fenbai.png" 超白："../resource/whiten/chaobai.png" 默认自然白："" |
| | redness | float 0.0~1.0 | 红润强度 |
| | sharpness | float 0.0~1.0 | 锐化强度 |
| | contrast_strength | float -1.0~1.0 | 清晰度强度 |

### 美颜模板-画质

| table | options | 值范围 | 说明 |
|-------|---------|--------|------|
| beauty_effect_option | hue | float -1.0~1.0 | 色调强度 |
| | temperature | float -1.0~1.0 | 色温强度 |
| | saturation | float -1.0~1.0 | 饱和度强度 |
| | brightness | float -1.0~1.0 | 亮度强度 |

### 美颜模板-美肤

| table | options | 值范围 | 说明 |
|-------|---------|--------|------|
| face_buffing_option | eye_pouch | float 0.0~1.0 | 去眼袋/去黑眼圈强度 |
| | brighten_eye | float 0.0~1.0 | 亮眼强度 |
| | nasolabial_fold | float 0.0~1.0 | 去法令纹强度 |
| | whiten_teeth | float 0.0~1.0 | 白牙强度 |

### 美颜模板-美型

| table | options | 值范围 | 说明 |
|-------|---------|--------|------|
| face_shape_beauty_option | enable | bool | 打开/关闭美型 |
| | style | int -1（无）; 0（女神）; 1（男神）; 2（自然） | 美型风格，类似抖音会对所有打开的美型部位再增强强度，这样不需要一个个部位 set |
| | intensity | int 0~100 | 风格强度 |

美型的精细捏脸部位见以下表，捏脸部位比较多，相对上面其它参数也比较特殊
调节特别地请用 API（setFaceShapeAreaOptions/getFaceShapeAreaOptions） 去控制：

| 部位 | 细节 | 名称 | 值域（int） | 作用 |
|------|------|------|------------|------|
| 脸部 | HeadScale | 小头 | 0~100 | 缩小整个头 |
| | ForeHead | 额头/发际线 | 0~100 | 拉低发际线 |
| | FaceContour | 瘦脸 | 0~100 | 缩小整个脸部轮廓 |
| | FaceLength | 长脸 | -100~100 | 垂直方向脸拉伸：正数拉长，负数缩短 |
| | FaceWidth | 窄脸 | 0~100 | 水平方向缩窄脸 |
| | Cheekbone | 瘦颧骨 | 0~100 | 压缩颧骨突出部位 |
| | Cheek | 脸颊/瘦下颌骨 | 0~100 | 下颌线整体内部收缩 |
| | Mandible | 下颚（V脸） | 0~100 | V脸效果，适合圆脸 |
| | Chin | 下巴 | -100~100 | 下巴拉长（正数）与收缩（负数） |
| 眼部 | EyeScale | 大眼 | 0~100 | 眼睛整体放大 |
| | EyeDistance | 眼距 | -100~100 | 双眼眼距调节，正值为收窄，负值为拉大 |
| | EyePosition | 眼上下 | -100~100 | 双眼上下调节，正值为上移，负值为下移 |
| | LowerEyelid | 眼睑下至 | 0~100 | 下眼皮向外突出效果 |
| | EyePupils | 眼瞳 | 0~100 | 眼瞳放大效果 |
| | EyeInnerCorner | 内眼角 | -100~100 | 内眼角的位置。正值为向鼻子收缩，负值为反方向 |
| | EyeOuterCorner | 外眼角 | -100~100 | 外眼角的位置。正值为向眼睛外扩，负值为向眼睛内收缩 |
| 鼻子 | NoseLength | 长鼻 | -100~100 | 长鼻效果。正值为变长，负值为变短 |
| | NoseWidth | 瘦鼻 | 0~100 | 瘦鼻效果 |
| | NoseWing | 鼻翼 | 0~100 | 鼻翼收缩效果 |
| | NoseRoot | 山根 | 0~100 | 山根收缩效果（山根为鼻梁顶端，双眼中点位置） |
| | NoseBridge | 鼻梁 | 0~100 | 鼻梁收缩效果 |
| | NoseTip | 鼻尖 | 0~100 | 鼻尖收缩效果 |
| | NoseGeneral | 鼻综合 | -100~100 | 鼻整体收缩效果。正值为变小，负值为变大 |
| 嘴巴 | MouthScale | 嘴形 | -100~100 | 嘴巴缩放。正值为变大，负值为变小 |
| | MouthPosition | 人中/嘴上下 | 0~100 | "人中"是嘴的上下位置，一般瘦脸比较大需要人中往上提一些保证五官对称。正值为上移 |
| | MouthSmile | 微笑 | 0~100 | 嘴角微笑强度 |
| | MouthLip | 丰唇 | 0~100 | 丰唇效果 |
| 眉毛 | EyebrowPosition | 眉毛高低 | -100~100 | 双眉上下，正值为上移，负值为下移 |
| | EyebrowThickness | 眉毛粗细 | -100~100 | 双眉粗细。正值为变粗，负值为变细 |

**Android 示例：**

```kotlin
import io.agora.rtc2.video.FaceShapeAreaOptions

// 调节一个美型部位
val areaOption = FaceShapeAreaOptions()
// 美型部位，见上面枚举
areaOption.shapeArea = FaceShapeAreaOptions.FACE_SHAPE_AREA_HEADSCALE
// 该部位的捏脸强度，0-100
areaOption.shapeIntensity = 50
// 设置捏脸参数，需要打开了美型，才能看到效果
rtcEngine.setFaceShapeAreaOptions(areaOption)
// 获取当前捏脸强度，用于刷新ui
var strength = rtcEngine.getFaceShapeAreaOptions(FaceShapeAreaOptions.FACE_SHAPE_AREA_HEADSCALE)?.shapeIntensity ?: 0
```

**iOS 示例：**

```swift
// 调节一个美型部位
let areaOption = AgoraFaceShapeAreaOptions()
// 美型部位，见上面枚举
areaOption.shapeArea = AgoraFaceShapeArea.headScale
// 该部位的捏脸强度，0-100
areaOption.shapeIntensity = 50
// 设置捏脸参数，需要打开了美型，才能看到效果
agoraKit?.setFaceShapeAreaOptions(areaOption)
// 获取当前捏脸强度，用于刷新ui
let getValue = agoraKit?.getFaceShapeAreaOptions(AgoraFaceShapeArea.headScale)
if getValue != nil {
    let strength = getValue?.shapeIntensity
}
```

## 美妆模板

> 🌟 风格妆滤镜与滤镜是互斥的，和抖音一样的逻辑，为了保证妆容搭配。所以在风格妆滤镜生效时，普通滤镜会失效，也可以选择定制模板时不做风格妆滤镜。

### 1. 风格妆全局参数

| table | options | 值范围 | 说明 |
|-------|---------|--------|------|
| style_makeup_option | styleIntensity | float 0.0~1.0 | 风格妆强度 |
| | filterStrength | float 0.0~1.0 | 风格妆滤镜强度 |

### 2. 美妆部位配置

> 🌟 如果集成美妆类似抖音的形式，整个妆风格均按预设的，则不需要进行美妆部位配置，仅调节第 1 节中的风格妆参数即可。

> 🌟 部位的样式 style 建议按模板保持一致，非必要不进行调整，会让美妆搭配过于复杂。单独调节色号与部位强度能满足大部分场景。

| table | options | 值范围 | 说明 |
|-------|---------|--------|------|
| **眉毛（Brow）** | | | |
| makeup_options | browStyle | int 1~10 | 眉毛样式编号（按使用的模板固定，非必要不做切换）<br>"001":"淑女","002":"温润","003":"标准",<br>"004":"柳叶","005":"茸茸","006":"野生",<br>"007":"细眉","008":"英朗","009":"挺拔",<br>"010":"平锋" |
| | browColor | int 0~2 | 眉毛色号：0-素材原色 1-深棕色 2-浅棕色 |
| | browStrength | float 0.0~1.0 | 眉毛强度 |
| **睫毛（Lash）** | | | |
| makeup_options | lashStyle | int 2/3/4/5/7/8/9/10 | 睫毛样式编号（按使用的模板固定）<br>"002":"细腻","003":"翅膀","004":"卷翘",<br>"005":"漫画","007":"自然","008":"乖巧",<br>"009":"下垂","010":"边翘" |
| | lashColor | int 0~2 | 睫毛色号：0-素材原色 1-深棕色 2-浅棕色 |
| | lashStrength | float 0.0~1.0 | 睫毛强度 |
| **眼影（Shadow）** | | | |
| makeup_options | shadowStyle | int 1~11 | 眼影样式编号（按使用的模板固定）<br>"001":"艳紫","002":"绚蓝","003":"冰糖山楂",<br>"004":"大地棕","005":"韩系","006":"艳丽",<br>"007":"杏子","008":"浅粉","009":"深粉",<br>"010":"高级灰","011":"粉褐" |
| | shadowStrength | float 0.0~1.0 | 眼影强度 |
| **美瞳（Pupil）** | | | |
| makeup_options | pupilStyle | int 1~7 | 美瞳样式编号（按使用的模板固定）<br>"001":"灰褐","002":"浅蓝","003":"灰绿",<br>"004":"灰瞳","005":"火星","006":"欣欣",<br>"007":"原生" |
| | pupilStrength | float 0.0~1.0 | 美瞳强度 |
| **腮红（Blush）** | | | |
| makeup_options | blushStyle | int 1~11 | 腮红样式编号（按使用的模板固定）<br>"001":"粉黛","002":"含羞","003":"蜜桃",<br>"004":"微醺","005":"气色","006":"日曦",<br>"007":"晒伤","008":"素醉","009":"元气",<br>"010":"彩云","011":"夜星" |
| | blushColor | int 0~5 | 腮红色号：0-素材原色 1-粉嫩 2-蜜桃橘 3-珊瑚橙 4-樱花粉 5-玫瑰粉 |
| | blushStrength | float 0.0~1.0 | 腮红强度 |
| **唇妆（Lip）** | | | |
| makeup_options | lipStyle | int 1~6 | 唇妆样式编号（按使用的模板固定）<br>"001":"樱桃","002":"娇媚","003":"亮泽",<br>"004":"雾面","005":"咬唇","006":"晕染" |
| | lipColor | int 0~10 | 唇妆色号：0-素材原色 1-豆沙粉 2-复古红 3-梅子色 4-珊瑚色 5-少女粉 6-丝绒红 7-西瓜红 8-西柚色 9-元气橘 10-脏橘色 |
| | lipStrength | float 0.0~1.0 | 唇妆强度 |
| **修容（Facial）** | | | |
| makeup_options | facialStyle | int 1/2/3/4/6/8/9 | 修容样式编号（按使用的模板固定）<br>"001":"立体","002":"浅白","003":"丰满",<br>"004":"暗影","006":"阴影","008":"高亮",<br>"009":"均匀" |
| | facialStrength | float 0.0~1.0 | 修容强度 |

## 滤镜模板

> 🌟 与风格妆滤镜互斥

| table | options | 值范围 | 说明 |
|-------|---------|--------|------|
| filter_effect_option | enable | bool | 滤镜模板开关 |
| | strength | float 0.0~1.0 | 滤镜强度 |

## 贴纸模板

| table | options | 值范围 | 说明 |
|-------|---------|--------|------|
| sticker_effect_option | enable | bool | 贴纸模板开关 |
| | strength | float 0.0~1.0 | 贴纸的透明度。一般贴纸设计怎样就怎样展示，无特别需求请不要调参 |

## 自定义

> 🌟 自定义参数不会被加密，开放给客户自由选择，不需要通过声网支持，可自行调节。

| table | options | 值范围 | 说明 |
|-------|---------|--------|------|
| engine_option | beautify_max | int 0 默认 / 1 一张脸 / 2 两张脸 | 0：默认行为，声网美颜 SDK 会磨皮和美型 2 张脸，但美妆和贴纸只会美化一张脸；1：不管哪个功能，都只美化 1 张脸（推荐低端机打开）；2：不管哪个功能，都会美化 2 张脸（推荐直播间 2 人场景打开） |
| beauty_custom_option | auto_sharpness | bool 自动锐化 | 声网默认打开，如有需要可自行关闭。自动锐化是为了与磨皮配合，防止主播调不好。 |
| | smooth_factor | float 0.0~1.0 | 遮瑕强度，默认 1.0，秀场用户不希望吃妆可调低 |
| | brightness_scale | float > 1.0 增强 / 0.0~1.0 减弱 | 提亮最大强度，亮度不够的客户可适当拉升 |
| face_shape_custom_option | face_custom_factor | 瘦脸部位增幅 > 1.0 为增强 / 0.0~1.0 为减弱 | 作用于所有脸部美型，但不可滥用，推荐范围 1.0~1.5 |
| | eye_custom_factor | 眼部位增幅 > 1.0 为增强 / 0.0~1.0 为减弱 | 作用于所有眼部美型，但不可滥用，推荐范围 1.0~1.3 |
| | nose_custom_factor | 鼻部位增幅 > 1.0 为增强 / 0.0~1.0 为减弱 | 作用于所有鼻部美型，但不可滥用，推荐范围 1.0~1.3 |
| | mouth_custom_factor | 嘴部位增幅 > 1.0 为增强 / 0.0~1.0 为减弱 | 作用于所有嘴部美型，但不可滥用，推荐范围 1.0~1.5 |
| | eyebrow_custom_factor | 眉部位增幅 > 1.0 为增强 / 0.0~1.0 为减弱 | 作用于所有眉美型，但不可滥用，推荐范围 1.0~1.5 |
| | max_crop_percent | 美型边缘裁切比例，因为人脸太靠近屏幕美型会带来边缘像素模糊的问题。开一定裁切可避开此问题 | 默认值 0.015（即 1.5%）推荐范围 0.0~0.05 |
| makeup_custom_option | brow_custom_factor | 眉妆强度控制 > 1.0 为增强 / 0.0~1.0 为减弱 | 非必要不滥用 |
| | shadow_custom_factor | 眼影强度控制 > 1.0 为增强 / 0.0~1.0 为减弱 | 非必要不滥用 |
| | lash_custom_factor | 睫毛强度控制 > 1.0 为增强 / 0.0~1.0 为减弱 | 非必要不滥用 |
| | blush_custom_factor | 腮红强度控制 > 1.0 为增强 / 0.0~1.0 为减弱 | 非必要不滥用 |
| | facial_custom_factor | 修容强度控制 > 1.0 为增强 / 0.0~1.0 为减弱 | 非必要不滥用 |
| | lip_custom_factor | 唇妆强度控制 > 1.0 为增强 / 0.0~1.0 为减弱 | 非必要不滥用 |

## 可选素材中英文对照

### 滤镜

暖色系：暖色调、季节色。冷白色系：冷色调、白色、胶片色。氛围系：适合亚洲女生审美。环境系：滤镜感较重。

| 分类 | 中文 | 英文 |
|------|------|------|
| 暖色系（10款） | 沉稳 | serene |
| | 都市 | urban |
| | 流光 | glow |
| | 鎏金 | gilt |
| | 奶油 | cream |
| | 拿铁 | latte |
| | 柠夏 | summer |
| | 日常 | daily |
| | 绅士 | gentleman |
| | 香草 | vanilla |
| 冷/白色系（10款） | 白瓷 | bright |
| | 白桃 | peach |
| | 苍墨 | ink |
| | 胶片 | film |
| | 霁晴 | sunny |
| | 漫画 | comic |
| | 梦幻 | dreamy |
| | 棉绒 | cotton |
| | 苏打 | soda |
| | 月白 | moonlight |
| 氛围系（9款） | 白茶 | WhiteTea |
| | 沉谧 | tranquil |
| | ins风 | insta-style |
| | 老街 | street |
| | 泡芙 | puff |
| | 私藏 | collection |
| | 盐汽水 | salty |
| | 质感 | texture |
| | 气色 | colorful |
| 环境系（8款） | 初雪 | snow |
| | 粉霞 | blush |
| | 怀旧 | nostalgia |
| | 焦糖 | caramel |
| | 微醺 | tipsy |
| | 薰衣草 | lavender |
| | 胭脂 | rouge |
| | 氤氲 | misty |

### 风格妆

仅以成套风格妆集成客户需要，按部位配置的不需要。

| 中文 | 英文 |
|------|------|
| 学妹 | young |
| 学姐 | mature |
| 气质 | aura |
| 白皙 | natural |
| 优雅 | graceful |
| 粉晕 | charm |
| 俏皮 | perky |
| 少女 | maiden |
| 深邃 | insight |
| 氤氲 | misty |

### 贴纸

| 中文 | 英文 |
|------|------|
| 圣诞节 | christmas |
| 章鱼 | squid |
| 猪可爱 | piggy |
| 辫子猫 | longcat |
| 粉色发箍 | hairhoop |
| 没有烦恼 | relaxtime |
| 卡通猫 | cartooncat |
| 蝴蝶 | butterfly |
| 粉刷时光 | brush |
| 赛博眼镜 | cyberglass |
| 霓虹皇冠 | neontiara |
| 爱心眼镜 | loveglass |
