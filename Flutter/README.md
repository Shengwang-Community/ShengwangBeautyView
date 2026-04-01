# ShengwangBeautyView（Flutter）

声网美颜视图组件的 Flutter 实现，提供美颜相关的视图组件和功能，支持 Android 与 iOS 双平台。

## 📁 项目结构（Demo 工程）

```
Flutter/
├── pubspec.yaml
├── assets/
│   ├── AgoraBeautyMaterial.zip    # 美颜材料包（需自行提供，见下方说明）
│   ├── zip.md5                    # 材料包校验文件
│   └── Icons/                     # 美颜功能图标
├── lib/
│   ├── main.dart                  # App 入口，负责权限申请与材料包解压
│   ├── agora.config.dart          # App ID / Token / Channel 配置
│   ├── Example/                   # 美颜功能使用示例
│   │   ├── example_page.dart      # 示例页面（RTC + 美颜面板）
│   │   └── beauty_control_bar.dart
│   ├── BeautyView/                # 美颜组件源码
│   │   ├── shengwang_beauty_sdk.dart   # SDK 封装（初始化、效果管理）
│   │   ├── shengwang_beauty_view.dart  # 美颜主视图入口
│   │   ├── builders/              # 各美颜页构建器
│   │   ├── components/            # 通用 UI 子组件
│   │   └── models/                # 数据模型
│   └── Utils/                     # 颜色、本地化等辅助工具
```

---

## 🚀 跑通 Demo

### 1. 安装依赖

进入 `Flutter` 目录，执行：

```bash
flutter pub get
```

### 2. 配置 App ID

打开 `lib/agora.config.dart`，填入在 [声网控制台](https://console.shengwang.cn/) 创建项目后获得的 **App ID**：

```dart
const String appId = 'your_actual_app_id_here';
const String token = '';        // 测试环境可留空
const String channelId = 'your_channel_id';
```

### 3. 美颜材料包

使用美颜功能需单独提供 **AgoraBeautyMaterial.zip** 材料包，组件不包含该资源。

- **获取方式**：联系声网技术支持获取 AgoraBeautyMaterial.zip 及对应的 zip.md5 文件。
- **放置方式**：将两个文件放入 `Flutter/assets/` 目录，确保 `pubspec.yaml` 中已声明：

```yaml
flutter:
  assets:
    - assets/AgoraBeautyMaterial.zip
    - assets/zip.md5
```

App 首次启动时会自动将材料包解压到沙盒目录，后续通过 MD5 校验决定是否重新解压，无需手动处理。

### 4. 运行 Demo

```bash
flutter run
```

点击 **Start Camera** 按钮，授予摄像头与麦克风权限后即可进入美颜预览页面。

---

## 📦 组件集成

将 `lib/BeautyView/` 整个目录拷贝到你的项目中，并在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  agora_rtc_engine:
    git:
      url: https://github.com/AgoraIO-Extensions/Agora-Flutter-SDK.git
      ref: 6.5.2-sp.4529.b.1
  path_provider: ^2.0.8
  archive: ^3.4.10
```

执行 `flutter pub get` 后即可使用。

### 材料包处理

材料包需解压到沙盒可写路径后，将路径传入 `initBeautySDK`。可参考 Demo 中 `main.dart` 的 `_prepareBundle()` 实现（支持 MD5 增量更新）：

```dart
final destPath = await _prepareBundle(); // 解压并返回沙盒路径
```

> 若传入只读路径（如 Flutter assets 原始路径），美颜参数将无法持久保存。

---

## 🔧 使用方法

### 初始化 SDK

```dart
await ShengwangBeautySDK.instance.initBeautySDK(
  rtcEngine: _engine,
  materialBundlePath: destPath + '/beauty_material_functional',
);
```

### 启用 / 关闭美颜

```dart
await ShengwangBeautySDK.instance.enable(true);   // 加入频道后开启
await ShengwangBeautySDK.instance.enable(false);  // 离开频道前关闭
```

### 嵌入美颜面板

```dart
ShengwangBeautyView(
  beautyConfig: ShengwangBeautySDK.instance.beautyConfig,
)
```

### 保存 / 重置美颜参数

```dart
final config = ShengwangBeautySDK.instance.beautyConfig;
config.saveBeauty(BeautyModule.beauty);   // 保存
config.resetBeauty(BeautyModule.beauty);  // 重置
```

### 销毁 SDK

```dart
await ShengwangBeautySDK.instance.unInitBeautySDK();
```

完整用法请参考 `lib/Example/example_page.dart`。

---

## 📁 BeautyView 组件结构

```
BeautyView/
├── shengwang_beauty_sdk.dart      # SDK 初始化、与 RTC 交互、效果管理
├── shengwang_beauty_view.dart     # 美颜主视图入口，对外暴露的 UI 组件
├── builders/                      # 各美颜页构建器
│   ├── beauty_page_builder.dart   # 美颜页
│   ├── filter_page_builder.dart   # 滤镜页
│   ├── makeup_page_builder.dart   # 美妆页
│   ├── sticker_page_builder.dart  # 贴纸页
│   └── i_page_builder.dart        # 页面构建器接口
├── components/                    # 通用 UI 子组件
│   ├── beauty_item_cell.dart      # 美颜项单元格
│   ├── beauty_segment_view.dart   # 分段（美颜/美妆/滤镜/贴纸）切换
│   ├── beauty_slider.dart         # 美颜滑块
│   └── item_list_view.dart        # 美颜项列表
└── models/
    └── beauty_page_info.dart      # 美颜页/项数据模型
```

- **shengwang_beauty_sdk.dart**：与 RTC 引擎、美颜引擎交互，管理初始化、销毁与参数配置。
- **shengwang_beauty_view.dart**：对外的美颜面板容器，内部组装 Builders 与 Components。
- **builders/**：按「美颜 / 美妆 / 滤镜 / 贴纸」分页构建内容。
- **components/**：可复用的列表、滑块、分段等控件。

---

## 💡 问题反馈

如果您在集成过程中遇到任何问题或有改进建议：

- 🤖 可通过 [声网支持](https://ticket.shengwang.cn/form) 联系技术支持人员
