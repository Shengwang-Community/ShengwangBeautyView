import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { router } from '@kit.ArkUI'
import { Constants, RtcEngine, RtcEngineConfig, VideoCanvas,
  ChannelMediaOptions, VideoEncoderConfiguration, VideoEffectNodeId } from '@shengwang/rtc-full'
import { LocalConfig } from '../config/LocalConfig'
import { BeautyPageParams } from './BeautyMain'
import { ShengwangBeautyManager } from '../beauty/ShengwangBeautyManager'
import { ShengwangBeautyPanel } from '../beauty/ShengwangBeautyPanel'
import { setBeautyWindowColor } from '../beauty/BeautyWindow'

@Entry
@Component
struct BeautyExample {
  @State ready: boolean = false
  @State panelVisible: boolean = false
  @State revision: number = 0
  private engine: RtcEngine | null = null
  private manager: ShengwangBeautyManager = new ShengwangBeautyManager()
  private disposed: boolean = false
  private previewStarted: boolean = false
  private params: BeautyPageParams = { materialPath: '', channel: '' }

  aboutToAppear(): void {
    this.params = router.getParams() as BeautyPageParams
  }

  private check(result: number, action: string): void {
    console.info(`[BeautyDemo] ${action} result=${result}`)
    if (result < 0) { throw new Error(`${action} (${result})`) }
  }

  private async initialize(): Promise<void> {
    if (this.engine !== null || this.disposed) { return }
    try {
      const config = new RtcEngineConfig(getContext(this) as common.UIAbilityContext)
      config.mAppId = LocalConfig.APP_ID
      config.mEventHandler = {}
      config.mEventHandler.onJoinChannelSuccess = (channel: string, uid: number, elapsed: number) => {
        console.info(`[BeautyDemo] joined uid=${uid}`)
      }
      config.mEventHandler.onError = (code: number, message: string) => {
        console.error(`[BeautyDemo] RTC error=${code}, ${message}`)
        this.getUIContext().getPromptAction().showToast({ message: `通话错误 (${code})` })
      }
      config.mEventHandler.onFirstLocalVideoFrame =
        (source: Constants.VideoSourceType, width: number, height: number, elapsed: number) => {
          console.info(`[BeautyDemo] first local frame ${width}x${height}`)
        }
      const engine = RtcEngine.create(config)
      this.engine = engine
      this.check(engine.enableVideo(), 'enableVideo')
      const encoder = new VideoEncoderConfiguration()
      encoder.dimensions.width = 720
      encoder.dimensions.height = 1280
      encoder.frameRate = 15
      this.check(engine.setVideoEncoderConfiguration(encoder), 'video configuration')
      this.manager = new ShengwangBeautyManager(getContext(this) as common.UIAbilityContext)
      const ready = await this.manager.initialize(this.params.materialPath, engine)
      if (this.disposed) { return }
      this.check(ready ? 0 : this.manager.lastResult || -1, 'beauty initialize')
      this.ready = ready
      const canvas = new VideoCanvas('beauty-local')
      canvas.uid = 0
      canvas.renderMode = VideoCanvas.RENDER_MODE_HIDDEN
      this.check(engine.setupLocalVideo(canvas), 'setupLocalVideo')
      this.check(engine.startPreview(), 'startPreview')
      this.previewStarted = true
      if (this.params.channel.length > 0) {
        const options = new ChannelMediaOptions()
        options.channelProfile = Constants.ChannelProfile.LIVE_BROADCASTING
        options.clientRoleType = Constants.ClientRole.BROADCASTER
        options.publishCameraTrack = true
        options.publishMicrophoneTrack = true
        options.autoSubscribeVideo = true
        options.autoSubscribeAudio = true
        this.check(engine.joinChannelWithOptions(LocalConfig.TOKEN, this.params.channel, 0, options), 'joinChannel')
      }
      this.revision++
    } catch (error) {
      const detail = error as BusinessError
      this.getUIContext().getPromptAction().showToast({ message: `初始化失败：${detail.message || '请检查配置'}` })
      console.error(`[BeautyDemo] initialize failed: ${detail.message}, stack=${detail.stack}`)
    }
  }

  private async saveAll(): Promise<void> {
    const nodes: VideoEffectNodeId[] = [VideoEffectNodeId.BEAUTY, VideoEffectNodeId.STYLE_MAKEUP,
      VideoEffectNodeId.FILTER]
    let result = 0
    for (const node of nodes) {
      const current = this.manager.save(node)
      if (current < 0) { result = current }
    }
    this.report(result, '已保存')
  }

  private resetAll(): void {
    const nodes: VideoEffectNodeId[] = [VideoEffectNodeId.BEAUTY, VideoEffectNodeId.STYLE_MAKEUP,
      VideoEffectNodeId.FILTER]
    let result = 0
    for (const node of nodes) {
      const current = this.manager.reset(node)
      if (current < 0) { result = current }
    }
    this.revision++
    this.report(result, '已重置')
  }

  private report(result: number, message: string): void {
    this.getUIContext().getPromptAction().showToast({ message: result === 0 ? message : `操作失败 (${result})` })
  }

  onPageHide(): void {
    if (this.previewStarted) {
      this.engine?.stopPreview()
      this.engine?.enableLocalVideo(false)
      if (this.params.channel.length > 0) { this.engine?.enableLocalAudio(false) }
    }
  }

  onPageShow(): void {
    setBeautyWindowColor(getContext(this) as common.UIAbilityContext, '#000000')
    if (this.previewStarted && !this.disposed) {
      this.engine?.enableLocalVideo(true)
      if (this.params.channel.length > 0) { this.engine?.enableLocalAudio(true) }
      this.engine?.startPreview()
    }
  }

  aboutToDisappear(): void {
    this.disposed = true
    this.manager.uninitialize()
    this.engine?.leaveChannel()
    this.engine?.stopPreview()
    if (this.engine !== null) { RtcEngine.destroy() }
    this.engine = null
    console.info('[BeautyDemo] released')
  }

  onBackPress(): boolean {
    router.back()
    return true
  }

  @Builder
  private toolbarButton(label: string, icon: string, id: string, action: () => void) {
    Button({ type: ButtonType.Normal }) {
      Column({ space: 2 }) {
        Image(`resource://RAWFILE/icons/${icon}.png`).width(24).height(24).objectFit(ImageFit.Contain)
        Text(label).fontSize(14).fontWeight(FontWeight.Medium).fontColor(Color.White).height(20)
      }
    }.width(44).height(60).padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(Color.Transparent).borderRadius(22).onClick(action).id(id)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      XComponent({ id: 'beauty-local', type: XComponentType.SURFACE, libraryname: Constants.AGORA_LIB_NAME })
        .width('100%').height('100%').onLoad(() => this.initialize())
      Row().width('100%').height('100%').backgroundColor(Color.Transparent)
        .onClick(() => { this.panelVisible = false }).id('preview-dismiss-panel')
      if (this.ready) {
        ShengwangBeautyPanel({ manager: this.manager, revision: $revision })
          .visibility(this.panelVisible ? Visibility.Visible : Visibility.None)
      }
      Button({ type: ButtonType.Circle }) {
        Image('resource://RAWFILE/icons/ic_back.png').width(24).height(24).objectFit(ImageFit.Contain)
      }.width(48).height(48).padding(12).backgroundColor(Color.Transparent)
        .position({ x: 16, y: 16 }).onClick(() => router.back()).id('back-to-main')
      Column() {
        this.toolbarButton('美颜', 'ic_beauty', 'beauty-panel-toggle', () => { this.panelVisible = !this.panelVisible })
        this.toolbarButton('切换', 'ic_camera', 'switch-camera', () => { this.engine?.switchCamera() })
        this.toolbarButton('保存', 'ic_save', 'save-beauty', () => { this.saveAll() })
        this.toolbarButton('重置', 'ic_reset', 'reset-beauty', () => { this.resetAll() })
      }.padding(8).backgroundColor('#D9151325').borderRadius(20)
        .position({ x: '100%', y: '50%' }).translate({ x: -68, y: '-50%' })
        .enabled(this.ready).id('beauty-toolbar')
    }.width('100%').height('100%').backgroundColor(Color.Black)
  }
}
