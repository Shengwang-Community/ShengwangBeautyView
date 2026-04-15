# 声网美颜 SDK 集成 Q&A

<!-- 在此添加你的 Q&A 内容，格式示例如下 -->

## 通用问题

### Q: 集成美颜的文档与材料清单
A: https://my.feishu.cn/wiki/WysFw5ng7it1Z9kzBZVc2BtQnbd

### Q: 设备要求与性能推荐
A: 
- 声网美颜支持：native开发支持iOS/Android/Mac/Windows 4端，跨平台封装支持Unity和Flutter。
- 出于直播间流畅不卡顿考虑，声网建议按设备机型开放美颜能力：
1. 设备打分 < 65分，app的UI界面不展示整个美颜特效入口
2. 设备打分 < 75分，app的UI界面不展示美妆和贴纸tab

### Q: 美颜资源包从哪里获取

A: 美颜资源包（AgoraBeautyMaterial）不包含在仓库中，需要联系声网技术支持获取，同时会提供裁剪的skill。
- Android：将 `AgoraBeautyMaterial.zip` 放入 `app/src/main/assets/` 目录
- iOS：将 `AgoraBeautyMaterial.bundle` 拖入工程并勾选对应 Target

### Q: 集成注意事项
A: 
- android代码是kotlin写的，推荐先在此工程上跑通所有逻辑，打包成aar，再迁移到自己的工程里，这样如果你的工程是java写的也没有关系。
- 美颜素材里的模板可部署客户后端，走app内下载，只要保证解压后的目录结构正确就能正确加载效果，有此诉求的请联系声网技术支持。
- 
- 美颜tab上的能力较多，可适当择选，排列顺序也按功能优先级调整。
- 美妆/滤镜/贴纸tab是以模板的形式展示，每个tab用多少套也是可以根据实际需求+素材体积占用裁剪的。
- 工程里有声网设计icon，但如果原样使用在上架审核时会有风险，一定要稍微修改一下。

### Q: 集成代码包体积
默认包体积（单架构）:
- iOS AgoraClearVision.xcframework: 9.1MB
- Android libagora_clear_vision_extension.so 9.7MB
默认包体积做了算法性能自动适应，如果客户比较重型，想减小包体积，有以下选项供参考：
1. 如果机型高端，可去掉android的armv7架构。
2. 如果是谷歌审核遇到主包超200MB限制，推荐使用aar版本，而非默认的full包或full裁剪包，但此方案需要客户自己做ABB打包集成方案。aar包把所有插件都独立成单独aar了，不能依赖在同一个apk里。
示例：
implementation 'io.agora.rtc:lite-rtc-basic:4.5.2.195'   
implementation 'io.agora.rtc:clear-vision:4.5.2.195'
...
3. 申请特殊版裁剪算法体积。

### Q: 美颜资源包裁剪
当前资源包体积按功能分：
- 美颜美妆，2MB
- 滤镜全37套，一套约300KB，共10MB
- 贴纸全12套，共8MB
裁剪可使用声网技术支持提供的skill，以问答形式skill自动完成，比如：
“请开始裁剪，保留美颜和贴纸模板，然后加密”
“请开始裁剪，我只需要美妆的贴纸模板，贴纸只需要圣诞节、章鱼、猪可爱、卡通猫，且为静态款”
“请开始裁剪，只保留美妆模板，并且把气质妆设置为默认模板”

skill完成工作任务后，产物会放在Output目录下

### Q: 如何替换工程里的 icon？

A: 我没有直接生成或修改图片的能力，但可以告诉你需要替换哪些文件。

工程里的 icon 分两类：

**1. 美颜面板内的功能 icon（美颜/美妆/滤镜/贴纸各项的缩略图）**

这类 icon 数量较多（约 100 张），文件名以 `beauty_ic_` 开头，替换时保持文件名不变、直接覆盖即可：
- Android：`Android/lib/src/main/res/drawable-xxhdpi/beauty_ic_*.png`
- iOS：`iOS/ShengwangBeautyView/Resources/Icons/beauty_ic_*.png`

**2. Demo 工程的控制栏 icon（返回/美颜入口/切换摄像头/重置/保存）**

这类 icon 是 Demo 里的 UI 控件图标，集成到自己工程时通常会用自己的 UI，可以直接替换或不使用：
- Android：`Android/app/src/main/res/drawable-xxxhdpi/ic_back.png` 等 5 个文件
- iOS：Demo 里使用的是 SF Symbols 系统图标（`UIImage(systemName:...)`），不涉及本地图片文件

**替换建议：**
- 设计工具：Figma、Sketch、Adobe Illustrator 均可
- AI 生成工具：Midjourney、DALL-E、即梦等可以快速生成风格一致的图标
- 尺寸参考：Android xxhdpi 约 48×48px，iOS 建议提供 @2x/@3x 两套
- 替换后保持文件名不变，直接覆盖原文件即可生效，无需修改代码

### Q: 多语言适配
A: 声网默认只提供中英文案，小语种需要客户自己适配。文案默认行为是根据地区自动选中英，有UI切换文案需求的需要自行适配。

---

## Android 相关

<!-- 在此添加 Android 相关的 Q&A -->


## iOS 相关

<!-- 在此添加 iOS 相关的 Q&A -->
