# Shengwang-Beauty HarmonyOS

Demo 展示如何快速集成声网美颜功能。

## 前置准备

### 1. 开发环境

- 安装 DevEco Studio 和 HarmonyOS 6.1.0 / API 23 SDK。
- 准备 HarmonyOS 5.0.2 / API 14 及以上的 arm64 真机，开启开发者模式和 USB 调试。

### 2. 获取美颜资源包

美颜资源包未包含在本仓库中，请联系声网技术支持获取配套的 `AgoraBeautyMaterial.zip`，放到：

```text
entry/src/main/resources/rawfile/AgoraBeautyMaterial.zip
```

保持完整 ZIP，无需手动解压。应用首次运行时会自动解压素材。

### 3. 配置 SDK 依赖

请联系声网技术支持获取支持高级美颜的 HarmonyOS SDK，将交付包中的 `rtc/sdk/AgoraRtcSdk.har` 复制到：

```text
libs/AgoraRtcSdk.har
```

以上路径均相对于 `HarmonyOS/` 目录，项目已配置该 HAR 的本地依赖。

## 快速开始

1. **创建本地配置**：在 `HarmonyOS/` 目录执行：

   ```sh
   cp entry/src/main/ets/config/LocalConfig.example.ets entry/src/main/ets/config/LocalConfig.ets
   cp build-profile.template.json5 build-profile.json5
   ```

2. **设置 App ID**：打开 `entry/src/main/ets/config/LocalConfig.ets`，填写自己的 `APP_ID`。若项目启用 Token 鉴权，同时填写服务端签发的 `TOKEN`，频道名须与 Token 一致，Demo 的 UID 为 `0`。

3. **同步和签名**：用 DevEco Studio 打开 `HarmonyOS/`，执行 **Sync and Refresh Project**。在 **File → Project Structure → Project → Signing Configs** 中开启自动签名，登录开发者账号并连接真机。

4. **运行项目**：点击 **Run** 编译安装，允许相机和麦克风权限，输入频道名并点击「加入频道」，再点击「美颜」调节参数。
