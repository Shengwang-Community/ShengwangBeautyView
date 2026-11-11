# 本地声网 SDK

本目录不包含 SDK 二进制。请从声网获取支持高级美颜的 HarmonyOS SDK，将交付包中的 `rtc/sdk/AgoraRtcSdk.har` 复制为：

```text
HarmonyOS/libs/AgoraRtcSdk.har
```

当前验证版本为 `@shengwang/rtc-full@4.6.70-rc.1`，该 HAR 包含 RTC 和 ClearVision 原生库，无需单独复制 `.so`。

推荐在 `HarmonyOS/` 下同时导入 SDK 和素材包：

```sh
node tools/setup.mjs /path/to/AgoraRtcSdk.har /path/to/AgoraBeautyMaterial.zip
```

HAR 和安装生成的 `oh_modules/` 均被 Git 忽略。App ID、素材位置和签名步骤见 [Demo README](../README.md)。
