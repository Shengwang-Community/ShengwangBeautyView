# ShengwangBeautyView

声网美颜视图组件，提供美颜相关的视图组件和功能。

## 📁 项目结构（Demo 工程）

Demo 工程主要结构如下（使用 CocoaPods 时请打开 `BeautyView.xcworkspace`，不要直接打开 `.xcodeproj`）：

```
iOS/
├── BeautyView.xcworkspace         # 使用 CocoaPods 时请打开此 workspace
├── Podfile
├── BeautyView/                    # Demo App
│   ├── Example/                   # 美颜功能使用示例
│   │   ├── ExampleViewController.swift
│   │   └── MainViewController.swift
│   └── General/                  # App 入口、Storyboard、Info.plist 等
└── ShengwangBeautyView/           # 美颜组件源码（集成时通过 Pod 引用或拷贝）
```

---

## 🚀 跑通 Demo

按以下步骤可在本仓库中直接运行美颜 Demo，无需先集成到自己的项目。

### 1. 下载源码并打开工程

下载或克隆本仓库，进入 **`iOS`** 目录。在终端执行：

```bash
pod install
```

然后用 Xcode 打开 **`BeautyView.xcworkspace`**（勿打开 `.xcodeproj`）。此时即可在 Xcode 中看到完整工程结构及后续需要配置的 KeyCenter。

### 2. 配置 App ID

工程内**构建脚本**会在**首次编译时**自动从 `KeyCenter.swift.example` 生成 `KeyCenter.swift`。若在工程中尚未看到 `KeyCenter.swift`，先执行一次编译（⌘B），脚本会创建该文件并在未配置时提示你填写 App ID。

在 Xcode 中打开 **`BeautyView/KeyCenter.swift`**，将 `YOUR_APP_ID_HERE` 替换为你在 [声网控制台](https://console.shengwang.cn/) 创建项目后获得的 **App ID**（字符串形式，需加引号）：

```swift
// 示例（请替换为你的真实 App ID）
static let AppId: String = "your_actual_app_id_here"
```

保存后再次编译并运行即可。

### 3. 美颜材料包

使用美颜功能需单独提供 **AgoraBeautyMaterial.bundle** 材料包，组件不包含该资源。

- **获取方式**：联系声网技术支持获取 AgoraBeautyMaterial.bundle。
- **放置方式**：将材料包加入 App 的 **Copy Bundle Resources**，Demo 运行时从 Main Bundle 读取并传入 SDK。

### 4. 运行 Demo

选择目标设备，点击 Run（▶️）运行。

---

## 📦 组件集成

通过 **CocoaPods + 本地 path** 集成源码。熟悉 CocoaPods 的用户可自行决定组件放置位置并设置 `:path`；不熟悉的用户按下面最简方式即可完成集成。

1. **放置组件**：将本仓库中的 `iOS/ShengwangBeautyView` 整个文件夹拷贝到主工程目录下，与 `Podfile` 同级（若放在其他目录，相应修改下面 `:path` 即可）。
2. **在 Podfile 中添加**：

```ruby
pod 'ShengwangBeautyView', :path => './ShengwangBeautyView'
```

3. **安装依赖**：在 Podfile 所在目录执行 `pod install`，之后使用 **`.xcworkspace`** 打开工程。

4. **美颜材料包**：将 **AgoraBeautyMaterial.bundle** 加入 Copy Bundle Resources 或置于沙盒可访问路径，初始化时取路径传入 `initBeautySDK(rtcEngine:materialBundlePath:)`。

---

### 使用方法

集成后的初始化、创建美颜视图、保存/重置等用法，请直接参考 Demo 工程中的 **`BeautyView/Example/ExampleViewController.swift`**。  
工程为 Objective-C 时，可通过 `@import ShengwangBeautyView` 或 Xcode 生成的 `-Swift.h` 调用。

---

## 📁 ShengwangBeautyView 组件结构

便于在源码级修改或排查问题时理解各文件职责。

```
ShengwangBeautyView/
├── ShengwangBeautyView.podspec    # CocoaPods 描述文件
├── Classes/                       # 源码目录
│   ├── Core/                      # 核心 SDK 封装
│   │   ├── ShengwangBeautySDK.swift   # 美颜 SDK 初始化、与 RTC 交互、效果管理
│   │   └── BeautyParameter.swift     # 美颜参数模型
│   ├── Models/
│   │   └── BeautyPageInfo.swift      # 美颜页/项数据模型（如 BeautyPageInfo、BeautyItemInfo 等）
│   ├── ShengwangBeautyView.swift     # 美颜主视图入口，对外暴露的 UI 组件
│   ├── UI/
│   │   ├── Builders/                  # 各美颜页构建器
│   │   │   ├── BeautyPageBuilder.swift   # 美颜页
│   │   │   ├── FilterPageBuilder.swift   # 滤镜页
│   │   │   ├── MakeupPageBuilder.swift   # 美妆页
│   │   │   └── StickerPageBuilder.swift  # 贴纸页
│   │   ├── Components/                 # 通用 UI 子组件
│   │   │   ├── BeautyItemCell.swift     # 美颜项单元格
│   │   │   ├── BeautySegmentView.swift  # 分段（美颜/美妆/滤镜/贴纸）切换
│   │   │   ├── BeautySlider.swift       # 美颜滑块
│   │   │   └── ItemListView.swift       # 美颜项列表
│   │   └── Contracts/
│   │       └── IPageBuilder.swift       # 页面构建器协议
│   └── Utils/
│       ├── BeautyIconHelper.swift      # 图标资源处理
│       ├── StringLocalizer.swift       # 文案本地化
│       ├── UIColor+Beauty.swift        # 颜色扩展
│       └── UIView+Beauty.swift        # 视图布局等扩展
└── Resources/                     # 美颜资源（贴纸、滤镜等）
```

- **Core**：与 RTC 引擎、美颜引擎交互，初始化与销毁、参数配置。
- **ShengwangBeautyView.swift**：对外的美颜面板容器，内部组装 Builders 与 Components。
- **UI/Builders**：按「美颜 / 美妆 / 滤镜 / 贴纸」等分页构建内容。
- **UI/Components**：可复用的列表、滑块、分段等控件。
- **Utils**：图标、多语言、颜色与布局等辅助。

---

## 版本

- 0.1.0 - 初始版本

## 要求

- iOS 11.0+
- Swift 5.0+
