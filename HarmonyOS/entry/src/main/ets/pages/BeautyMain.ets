import { abilityAccessCtrl, common } from '@kit.AbilityKit'
import { router } from '@kit.ArkUI'
import { BeautyMaterial } from '../beauty/BeautyMaterial'
import { LocalConfig } from '../config/LocalConfig'
import { setBeautyWindowColor } from '../beauty/BeautyWindow'

export interface BeautyPageParams {
  materialPath: string
  channel: string
}

@Entry
@Component
struct BeautyMain {
  @State channel: string = `shengwang_beauty_${Math.floor(Math.random() * 90000 + 10000)}`
  @State inputFocused: boolean = false
  @State ready: boolean = false
  @State busy: boolean = false
  @State status: string = '正在准备美颜素材…'
  private materialPath: string = ''

  aboutToAppear(): void {
    this.prepare()
  }

  onPageShow(): void {
    setBeautyWindowColor(getContext(this) as common.UIAbilityContext, '#1A1A2E')
  }

  private async prepare(): Promise<void> {
    try {
      this.materialPath = await BeautyMaterial.prepare(getContext(this) as common.UIAbilityContext)
      this.ready = true
      this.status = '素材已就绪'
    } catch (error) {
      this.status = '素材准备失败，点击重试'
      console.error(`[BeautyDemo] material failed: ${JSON.stringify(error)}`)
    }
  }

  private async enter(): Promise<void> {
    if (this.busy || !this.ready) { return }
    if (LocalConfig.APP_ID.length !== 32) {
      this.getUIContext().getPromptAction().showToast({ message: '请先配置声网 App ID' })
      return
    }
    const name = this.channel.trim()
    if (name.length === 0 || name.length > 64 || !/^[a-zA-Z0-9_\-]+$/.test(name)) {
      this.getUIContext().getPromptAction().showToast({ message: '频道名请使用 1–64 位字母、数字、下划线或短横线' })
      return
    }
    this.busy = true
    try {
      const context = getContext(this) as common.UIAbilityContext
      const permissions = await abilityAccessCtrl.createAtManager().requestPermissionsFromUser(context,
        ['ohos.permission.CAMERA', 'ohos.permission.MICROPHONE'])
      if (permissions.authResults.some((result: number) => result !== 0)) {
        this.getUIContext().getPromptAction().showToast({ message: '请允许相机权限；通话还需要麦克风权限' })
        return
      }
      const params: BeautyPageParams = { materialPath: this.materialPath, channel: name }
      await router.pushUrl({ url: 'pages/BeautyExample', params: params })
    } catch (error) {
      console.error(`[BeautyDemo] enter failed: ${JSON.stringify(error)}`)
      this.getUIContext().getPromptAction().showToast({ message: '无法打开预览，请重试' })
    } finally {
      this.busy = false
    }
  }

  build() {
    Column() {
      Text('声网美颜 View').fontSize(22).fontWeight(FontWeight.Medium).fontColor(Color.White)
        .width('100%').height(56).textAlign(TextAlign.Center)
      Scroll() {
        Column() {
          Stack({ alignContent: Alignment.Start }) {
            TextInput({ text: this.channel, placeholder: this.inputFocused ? '请输入频道名称' : '频道名称' })
              .height(56).fontSize(16).fontColor(Color.White).placeholderColor('#888888')
              .backgroundColor(Color.Transparent).borderRadius(4).padding({ left: 16, right: 12 })
              .border({ width: this.inputFocused ? 2 : 1, color: this.inputFocused ? '#6C63FF' : '#888888' })
              .cancelButton({ style: CancelButtonStyle.INPUT, icon: { color: '#AAAAAA' } })
              .onChange((value: string) => { this.channel = value })
              .onFocus(() => { this.inputFocused = true })
              .onBlur(() => { this.inputFocused = false })
              .id('channel-name')
            if (this.inputFocused || this.channel.length > 0) {
              Text('频道名称').fontSize(12).fontColor(this.inputFocused ? '#6C63FF' : '#AAAAAA')
                .padding({ left: 4, right: 4 }).backgroundColor('#1A1A2E')
                .position({ x: 12, y: -7 })
            }
          }.width('100%').margin({ top: 8 })
          Button('加入频道', { type: ButtonType.Normal })
            .width('100%').height(56).borderRadius(12).fontSize(14).fontWeight(FontWeight.Medium)
            .fontColor(Color.White).backgroundColor('#6C63FF').margin({ top: 24 })
            .enabled(this.ready && !this.busy).onClick(() => this.enter()).id('join-channel')
          if (!this.ready) {
            Column() {
              LoadingProgress().width(40).height(40).color('#6C63FF')
              Text('0%').fontSize(16).fontWeight(FontWeight.Medium).fontColor(Color.White)
                .margin({ top: 16 })
              Text(this.status).fontSize(12).fontColor('#AAAAAA').margin({ top: 4 })
            }.width('100%').padding(24).margin({ top: 32 }).onClick(() => this.prepare())
          }
        }.width('100%').padding(24)
      }.layoutWeight(1).width('100%').align(Alignment.Top)
    }.width('100%').height('100%').backgroundColor('#1A1A2E')
  }
}
