# 本地美颜素材

请将完整的素材 ZIP 放到本目录，文件名保持为 `AgoraBeautyMaterial.zip`：

```text
HarmonyOS/entry/src/main/resources/rawfile/AgoraBeautyMaterial.zip
```

请使用与当前 UI 模板配套的完整素材包，并保留 ZIP 内 `beauty_material_functional/` 与 `resource/` 的同级关系，无需手动解压到本目录。应用首次运行时会将 ZIP 解压到沙箱的持久可写目录，以支持 SDK 保存参数。

该 ZIP 被 Git 忽略，不随代码提交。`icons/` 为 UI 图标，随代码保留。

可在 `HarmonyOS/` 下运行以下命令检查模板和共享资源：

```sh
node tools/verify-material.mjs
```

更换素材包时，需同步检查 UI 模板列表并更新 `BeautyMaterial.VERSION`、校验脚本中的预期 SHA-256 和 README 中的素材版本说明。完整准备步骤见 [Demo README](../../../../../README.md)。
