# Shengwang Beauty Control View

声网美颜控制组件，提供完整的美颜功能集成方案。支持 AAR 和源码两种集成方式。

## 🚀 快速开始

### 方式一：使用 AAR

#### 1. 生成 AAR 文件

在项目根目录运行打包脚本：

```bash
./lib/build-aar.sh
```

### 版本管理

修改 `lib/build-aar.sh` 脚本中的 `VERSION_NAME` 变量来设置版本号：

```bash
VERSION_NAME="1.0.0"  # 修改为你想要的版本号
```

版本号格式：`主版本.次版本.修订版本`（例如：`1.0.0`、`1.1.0`、`2.0.0`）

#### 2. 集成到项目

1. 将 AAR 文件复制到项目的 `libs` 目录（如 `app/libs/`）

2. 在 `app/build.gradle` 中添加：

```gradle
android {
    ...
    repositories {
        flatDir {
            dirs 'libs'
        }
    }
}

dependencies {
    // 添加 AAR 依赖
    implementation(name: 'shengwang-beauty-view-1.0.0', ext: 'aar')
    
    // Agora RTC SDK（必需）
    implementation 'io.agora.rtc:agora-special-full:4.5.2.9'
}
```

#### 3. 在代码中使用

```kotlin
// 1. 初始化 Agora RTC Engine（客户自己实现）
val rtcEngine = RtcEngine.create(context, appId, rtcEventHandler)

// 2. 准备美颜资源文件路径（必须先完成资源校验和解压）
//    将资源保存在 filesDir，不要使用 cacheDir 或 externalCacheDir。
val materialPath = File(
    context.filesDir,
    "AgoraBeautyMaterial/beauty_material_functional"
).absolutePath

// 3. 初始化美颜管理器
val success = ShengwangBeautyManager.initBeautySDK(materialPath, rtcEngine)
if (!success) {
    Log.e(TAG, "Failed to initialize beauty manager")
    return
}

// 4. 在布局中添加 ShengwangBeautyView
// XML 方式：
// <cn.shengwang.beauty.ui.ShengwangBeautyView
//     android:id="@+id/beautyControlView"
//     android:layout_width="match_parent"
//     android:layout_height="wrap_content" />

// 5. 刷新页面列表（当配置变化时，通常不需要手动调用，View 会自动刷新）
// beautyView.refreshPageList()

// 6. 重置/保存美颜参数（可选）
// beautyView.resetBeauty()  // 重置为默认值
// beautyView.saveBeauty()   // 保存当前参数

// 7. 销毁时清理资源
// ShengwangBeautyManager.unInitBeautySDK()
```

### 方式二：源码集成（直接拷贝 lib 模块）

如果需要源码集成，可以直接拷贝整个 `lib` 模块到客户项目中：

1. **拷贝 lib 模块**：将整个 `lib` 目录复制到客户项目中

2. **在 `settings.gradle.kts` 中添加模块**：

```kotlin
include(":lib")
```

3. **在 `app/build.gradle` 中添加依赖**：

```gradle
dependencies {
    // 依赖 lib 模块
    implementation(project(":lib"))
    
    // Agora RTC SDK（必需）
    implementation 'io.agora.rtc:agora-special-full:4.5.2.9'
    
    // 其他依赖...
}
```

## 📁 lib 项目结构

```
项目根目录/
├── lib/                          # 库模块（核心代码和资源）
│   ├── src/main/java/cn/shengwang/beauty/
│   │   ├── core/                 # 核心 SDK 封装
│   │   │   ├── ShengwangBeautyManager.kt
│   │   │   └── BeautyParameter.kt
│   │   ├── ui/                   # UI 组件
│   │   │   ├── ShengwangBeautyView.kt
│   │   │   ├── model/            # 数据模型
│   │   │   │   └── BeautyPageInfo.kt  # 包含 BeautyPageInfo, BeautyItemInfo, BeautyItemType, BeautyModule
│   │   │   ├── contract/         # 接口定义
│   │   │   │   └── IPageBuilder.kt
│   │   │   └── builder/          # 页面构建器
│   │   │       ├── BeautyPageBuilder.kt
│   │   │       ├── FilterPageBuilder.kt
│   │   │       ├── MakeupPageBuilder.kt
│   │   │       └── StickerPageBuilder.kt
└── └── src/main/res/             # 所有资源文件
```

## 🔧 组件配合使用说明

### ShengwangBeautyManager 与 ShengwangBeautyView 的关系

`ShengwangBeautyManager` 和 `ShengwangBeautyView` 是配合使用的两个组件，它们各司其职，共同完成美颜功能的实现：

#### 职责分工

**ShengwangBeautyManager（美颜管理器）**
- 负责美颜功能的初始化和销毁
- 管理美颜效果的底层实现（与 Agora RTC SDK 交互）
- 提供美颜配置接口（`beautyConfig`）
- 提供美颜开关控制（`enable()`）
- 管理美颜资源文件和效果节点

**ShengwangBeautyView（UI 组件）**
- 提供可视化的美颜控制界面
- 通过 `ShengwangBeautyManager.beautyConfig` 直接访问和修改美颜参数
- 监听管理器状态变化，自动刷新 UI 显示
- 提供参数保存和重置功能

#### 使用流程

**基本顺序：**
1. 先初始化 `ShengwangBeautyManager`（必须先完成，详见上方"快速开始"部分）
2. 再添加 `ShengwangBeautyView` UI 组件
3. 销毁时调用 `ShengwangBeautyManager.unInitBeautySDK()` 清理资源


## 🔧 API 使用说明

### 主要 API

#### ShengwangBeautyManager（美颜管理器）

**初始化美颜管理器**
```kotlin
val success = ShengwangBeautyManager.initBeautySDK(materialPath, rtcEngine)
```
初始化美颜管理器，返回 `true` 表示成功，`false` 表示失败。

**参数说明：**
- `materialPath`: 美颜资源文件目录路径（必须确保资源文件已校验并解压到该目录）
- `rtcEngine`: Agora RTC Engine 实例

**销毁美颜管理器**
```kotlin
ShengwangBeautyManager.unInitBeautySDK()
```
清理所有资源，在不再使用美颜功能时调用。

**美颜开关**
```kotlin
ShengwangBeautyManager.enable(true)  // 开启美颜
ShengwangBeautyManager.enable(false) // 关闭美颜
```

**美颜配置**
```kotlin
val config = ShengwangBeautyManager.beautyConfig
config.smoothness = 0.7f      // 磨皮强度
config.whitenNatural = 0.7f  // 美白强度
config.redness = 0.3f        // 红润强度
// ... 更多配置参数
```

#### ShengwangBeautyView

**刷新页面列表**
```kotlin
beautyView.refreshPageList()
```
当美颜配置发生变化时，调用此方法刷新 UI 显示。

**重置美颜参数**
```kotlin
// 重置美颜模块（默认）
beautyView.resetBeauty()

// 重置指定模块
beautyView.resetBeauty(BeautyModule.FILTER)      // 重置滤镜
beautyView.resetBeauty(BeautyModule.STYLE_MAKEUP) // 重置美妆
beautyView.resetBeauty(BeautyModule.STICKER)      // 重置贴纸
```
重置操作会将参数恢复为出厂时模板内的默认值。注意：重置后，下次 `addOrUpdate` 加载节点时会自动生效。

**保存美颜参数**
```kotlin
// 保存美颜模块（默认）
beautyView.saveBeauty()

// 保存指定模块
beautyView.saveBeauty(BeautyModule.FILTER)
beautyView.saveBeauty(BeautyModule.STYLE_MAKEUP)
beautyView.saveBeauty(BeautyModule.STICKER)
```

保存操作会将当前调整的参数保存到本地，下次 `addOrUpdate` 加载节点时会自动调用之前保存的参数。

**资源更新场景：**
资源准备逻辑应在每次初始化前检查素材目录和 `beauty_material_functional/config.json`，并将随素材包发布的版本/hash 与上次成功解压后保存的值比较。版本变化时只更新根 `config.json` 和模板目录：`filter_*`/`sticker_*` 完整替换，其他模板只覆盖不删除，已有 `save.json` 会自然保留。

`filesDir` 只会在卸载应用或“清除数据”时删除。遇到这些情况仍需自动恢复资源，不能要求用户重新安装应用。

#### BeautyModule（模块类型）

```kotlin
typealias BeautyModule = IVideoEffectObject.VIDEO_EFFECT_NODE_ID

// 可用值：
BeautyModule.BEAUTY          // 美颜模块（美肤+美型+画质）
BeautyModule.STYLE_MAKEUP     // 风格妆模块
BeautyModule.FILTER           // 滤镜模块
BeautyModule.STICKER          // 贴纸模块
```

#### BeautyItemType（功能项类型）

```kotlin
enum class BeautyItemType {
    NORMAL,  // 普通参数项（默认）
    TOGGLE,  // 开关项（如美颜总开关）
    RESET,   // 重置项
    NONE     // 无效果项（如取消贴纸/美妆）
}
```
