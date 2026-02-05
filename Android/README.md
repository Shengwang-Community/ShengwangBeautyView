# Shengwang-Beauty Android

Demo 展示如何快速集成声网美颜功能。

## 📁 项目结构

主要代码位于 `app/src/main/java/cn/shengwang/videobeauty/` 目录下：

- **BeautyMainActivity.kt** - 主界面，提供频道名称输入和加入频道功能
- **BeautyExampleActivity.kt** - 美颜功能使用示例，展示如何初始化和使用 BeautyManager
- **lib/** - 美颜 SDK 库模块，提供 `ShengwangBeautyManager` 和 `ShengwangBeautyView`

## ⚠️ 前置准备

### 1. 获取美颜资源包
**美颜资源文件未包含在本仓库中**，需要联系声网技术支持获取：

- 资源包名称：`AgoraBeautyMaterial.zip`
- 获取方式：联系声网技术支持团队
- 放置位置：`app/src/main/assets/AgoraBeautyMaterial.zip`
- MD5 校验：将资源包的 MD5 值写入 `app/src/main/assets/AgoraBeautyMaterialMd5.txt`

> ⚠️ 注意：没有美颜资源包，应用将无法正常运行美颜功能。

### 2. MD5 校验机制

应用启动时会自动进行资源校验：
- 读取 `AgoraBeautyMaterialMd5.txt` 中的 MD5 值
- 与本地已解压资源的 MD5 对比
- MD5 不匹配时自动更新 `filter_xxx` 和 `sticker_xxx` 目录

生成 MD5 值：
```bash
md5 app/src/main/assets/AgoraBeautyMaterial.zip
# 或
md5sum app/src/main/assets/AgoraBeautyMaterial.zip
```

### 3. 配置 Agora SDK 依赖

项目支持两种方式集成 Agora RTC SDK：

#### 方式一：Maven 依赖

在 `gradle.properties` 中设置：
```properties
USE_LOCAL_SDK=false
```

SDK 版本在 `app/build.gradle` 中配置：
```gradle
implementation('io.agora.rtc:agora-special-full:4.5.2.9') {
    exclude group: 'io.agora.rtc', module: 'full-screen-sharing'
}
```

#### 方式二：本地 SDK 包

1. 联系声网技术支持获取 SDK 开发包（zip 格式）
2. 解压后将 `aar` 和 `so` 库放入 `app/agora-sdk/` 目录
3. 在 `gradle.properties` 中设置：
   ```properties
   USE_LOCAL_SDK=true
   ```

目录结构示例：
```
app/agora-sdk/
├── agora-rtc-sdk.jar
├── arm64-v8a/
│   └── *.so
└── armeabi-v7a/
    └── *.so
```

## 🚀 快速开始

1. **设置 App ID**：在项目根目录的 `gradle.properties` 文件中配置你的 Agora App ID
   ```properties
   appId=your_app_id_here
   ```

2. **放置美颜资源**：将 `AgoraBeautyMaterial.zip` 放入 `app/src/main/assets/` 目录

3. **配置 SDK 依赖**：选择 Maven 或本地 SDK 方式（见上方说明）

4. **运行项目**：
   - 首次启动会自动解压美颜资源到缓存目录
   - 输入频道名称加入频道
   - 点击美颜按钮调节美颜参数

详细使用说明请参考 `lib/README.md`。

## 📦 打包 AAR

如需将美颜 SDK 打包为 AAR 供其他项目使用：

```bash
# 在项目根目录或 lib 目录运行
./lib/build-aar.sh
```

打包后的 AAR 文件位于 `release/shengwang-beauty-view-1.0.0.aar`


## 💡 问题反馈

如果您在集成过程中遇到任何问题或有改进建议：

- 🤖 可通过 [声网支持](https://ticket.shengwang.cn/form) 联系技术支持人员
