import { VideoEffectNodeId } from '@shengwang/rtc-full'
import { BeautyFloatParameter, EffectTemplate, FaceShapeParameter, ShengwangBeautyManager } from './ShengwangBeautyManager'

class BeautyControlItem {
  id: string
  label: string
  icon: string
  kind: string
  index: number
  name: string

  constructor(id: string, label: string, icon: string, kind: string, index: number = -1, name: string = '') {
    this.id = id
    this.label = label
    this.icon = icon
    this.kind = kind
    this.index = index
    this.name = name
  }
}

// Android shengwang_beauty_view.xml / control_item.xml, with dp dimensions expressed in vp.
@Component
export struct ShengwangBeautyPanel {
  manager: ShengwangBeautyManager = new ShengwangBeautyManager()
  @Link @Watch('synchronize') revision: number
  @State private currentTab: number = 0
  @State private items: BeautyControlItem[] = []
  @State private selectedId: string = 'float-0'
  @State private value: number = 0
  @State private minimum: number = 0
  @State private maximum: number = 100
  @State private sliderVisible: boolean = true
  private readonly tabs: string[] = ['美颜', '画质', '风格妆', '滤镜', '贴纸']
  private readonly scroller: Scroller = new Scroller()
  private selections: string[] = ['float-0', '', 'none', 'none', 'none']
  private lastUpdate: number = 0
  private readonly faceIcons: string[] = [
    'face_contour', 'mandible', 'chin', 'cheek', 'cheekbone', 'face_length', 'face_width', 'fore_head',
    'head_scale', 'nose_width', 'nose_root', 'nose_bridge', 'nose_tip', 'nose_wing', 'nose_length',
    'nose_general', 'eye_scale', 'eye_distance', 'eye_lid', 'inner_corner', 'outer_corner', 'eye_position',
    'eye_pupils', 'mouth_smile', 'mouth_lip', 'mouth_scale', 'mouth_position', 'eyebrow_thickness', 'eyebrow_position'
  ]
  private readonly faceLabels: string[] = [
    '瘦脸', 'v脸', '瘦下巴', '下颌线', '瘦颧骨', '长脸', '窄脸', '发际线', '小头', '瘦鼻',
    '山根', '鼻梁', '鼻尖', '鼻翼', '长鼻', '鼻综合', '大眼', '眼距', '眼睑下至', '内眼角',
    '外眼角', '眼移动', '瞳孔', '微笑唇', '丰唇', '嘴型', '缩人中', '眉粗细', '眉上下'
  ]

  aboutToAppear(): void {
    this.selections[2] = this.manager.makeupName ?? 'none'
    this.selections[3] = this.manager.filterName ?? 'none'
    this.selections[4] = this.manager.stickerName ?? 'none'
    this.synchronize()
  }

  private synchronize(): void {
    this.items = this.createItems()
    this.selectedId = this.selections[this.currentTab]
    this.updateSlider()
  }

  private createItems(): BeautyControlItem[] {
    const result: BeautyControlItem[] = []
    if (this.currentTab === 0 || this.currentTab === 1) {
      const enabled = this.currentTab === 0 ? this.manager.beautyEnabled : this.manager.qualityEnabled
      result.push(new BeautyControlItem('toggle', enabled ? '已开启' : '关闭',
        enabled ? 'beauty_switcher_on' : 'beauty_switcher_off', 'toggle'))
      if (this.currentTab === 0) {
        result.push(new BeautyControlItem('reset', '重置', 'beauty_ic_effect_reset', 'reset'))
        this.manager.beautyParameters.forEach((parameter: BeautyFloatParameter, index: number) => {
          result.push(new BeautyControlItem(`float-${index}`, parameter.label,
            `beauty_ic_effect_${parameter.key}`, 'float', index))
        })
        this.manager.faceShapeParameters.forEach((parameter: FaceShapeParameter, index: number) => {
          result.push(new BeautyControlItem(`face-${index}`, this.faceLabels[index],
            `beauty_ic_face_shape_${this.faceIcons[index]}`, 'face', index))
        })
      } else {
        const order: number[] = [0, 1, 3, 2]
        order.forEach((index: number) => {
          const parameter = this.manager.qualityParameters[index]
          result.push(new BeautyControlItem(`float-${index}`, parameter.label,
            `beauty_ic_effect_${parameter.key}`, 'float', index))
        })
      }
      return result
    }
    result.push(new BeautyControlItem('none', '无', 'beauty_ic_none', 'none'))
    const templates = this.currentTab === 2 ? this.manager.makeupTemplates :
      this.currentTab === 3 ? this.manager.filterTemplates : this.manager.stickerTemplates
    templates.forEach((template: EffectTemplate, index: number) => {
      let suffix = template.name.substring(template.name.indexOf('-') + 1).toLowerCase()
      const prefix = this.currentTab === 2 ? 'makeup' : this.currentTab === 3 ? 'filter' : 'sticker'
      if (prefix === 'makeup' && suffix === 'perkey') { suffix = 'perky' }
      if (prefix === 'filter' && suffix === 'gentleman') { suffix = 'genyleman' }
      if (prefix === 'filter' && suffix === 'vanilla') { suffix = 'vanila' }
      if (prefix === 'sticker') {
        const names: string[] = ['christmas', 'squid', 'piggy', 'long_cat', 'hairhoop', 'relax_time',
          'cartoon_cat', 'butterfly', 'brush', 'cyber_glass', 'neon_tiara', 'love_glass']
        suffix = names[index]
      }
      result.push(new BeautyControlItem(template.name, template.label, `beauty_ic_${prefix}_${suffix}`,
        'template', index, template.name))
    })
    return result
  }

  private updateSlider(): void {
    const item = this.items.find((entry: BeautyControlItem) => entry.id === this.selectedId)
    this.sliderVisible = item !== undefined && (item.kind === 'float' || item.kind === 'face' ||
      (item.kind === 'template' && this.currentTab !== 4))
    this.minimum = 0
    this.maximum = 100
    if (item === undefined || !this.sliderVisible) { return }
    if (item.kind === 'float') {
      const parameter = this.currentTab === 0 ? this.manager.beautyParameters[item.index] :
        this.manager.qualityParameters[item.index]
      this.minimum = parameter.min < 0 ? -50 : 0
      this.maximum = parameter.min < 0 ? 50 : 100
      this.value = parameter.value * (parameter.min < 0 ? 50 : 100)
    } else if (item.kind === 'face') {
      const parameter = this.manager.faceShapeParameters[item.index]
      this.minimum = parameter.min < 0 ? -50 : 0
      this.maximum = parameter.min < 0 ? 50 : 100
      this.value = parameter.value * (parameter.min < 0 ? 0.5 : 1)
    } else {
      this.value = (this.currentTab === 2 ? this.manager.getMakeupIntensity() :
        this.manager.getFilterStrength()) * 100
    }
    this.value = Math.max(this.minimum, Math.min(this.maximum, this.value))
  }

  private selectTab(index: number): void {
    this.currentTab = index
    this.synchronize()
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
  }

  private selectItem(item: BeautyControlItem): void {
    let result = 0
    if (item.kind === 'toggle') {
      if (this.currentTab === 0) {
        result = this.manager.setBeautyEnabled(!this.manager.beautyEnabled)
      } else {
        this.manager.setQualityEnabled(!this.manager.qualityEnabled)
        result = this.manager.lastResult
      }
      this.reportFailure(result)
      this.synchronize()
      return
    }
    if (item.kind === 'reset') {
      result = this.manager.reset(VideoEffectNodeId.BEAUTY)
      this.reportFailure(result)
      this.synchronize()
      return
    }
    if (item.kind === 'none' || item.kind === 'template') {
      const name = item.kind === 'none' ? null : item.name
      result = this.currentTab === 2 ? this.manager.selectMakeup(name) : this.currentTab === 3 ?
        this.manager.selectFilter(name) : this.manager.selectSticker(name)
    } else if (this.currentTab === 0 && !this.manager.beautyEnabled) {
      result = this.manager.setBeautyEnabled(true)
    } else if (this.currentTab === 1) {
      this.manager.setQualityEnabled(true)
    }
    if (result === 0) {
      this.selections[this.currentTab] = item.id
      this.synchronize()
    }
    this.reportFailure(result)
  }

  private changeValue(value: number): void {
    const item = this.items.find((entry: BeautyControlItem) => entry.id === this.selectedId)
    if (item === undefined) { return }
    let result = 0
    if (item.kind === 'float') {
      const parameter = this.currentTab === 0 ? this.manager.beautyParameters[item.index] :
        this.manager.qualityParameters[item.index]
      result = this.manager.setFloatParameter(parameter, value / (parameter.min < 0 ? 50 : 100))
    } else if (item.kind === 'face') {
      const parameter = this.manager.faceShapeParameters[item.index]
      result = this.manager.setFaceShapeParameter(parameter, value * (parameter.min < 0 ? 2 : 1))
    } else if (this.currentTab === 2) {
      result = this.manager.setMakeupIntensity(value / 100)
    } else if (this.currentTab === 3) {
      result = this.manager.setFilterStrength(value / 100)
    }
    this.reportFailure(result)
    if (result !== 0) { this.updateSlider() }
  }

  private reportFailure(result: number): void {
    if (result !== 0) {
      this.getUIContext().getPromptAction().showToast({ message: `操作失败 (${result})` })
    }
  }

  @Builder
  private controlItem(item: BeautyControlItem) {
    Column() {
      Image(`resource://RAWFILE/icons/${item.icon}.png`)
        .width(48).height(48).objectFit(ImageFit.Contain)
        .padding(item.kind === 'template' ? 2 : 8)
        .borderRadius(24)
        .border({ width: item.kind === 'toggle' ? 0 : 1,
          color: this.selectedId === item.id ? '#7A59FB' : '#14FFFFFF' })
        .onClick(() => this.selectItem(item))
        .accessibilityText(item.label).id(`beauty-item-${this.currentTab}-${item.id}`)
      Text(item.label).fontSize(12).fontColor(Color.White).margin({ top: 4 }).maxLines(1)
    }.padding(8).height('100%').constraintSize({ minWidth: 64 }).justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      if (this.sliderVisible) {
        Column() {
          Stack({ alignContent: Alignment.TopStart }) {
            Text(`${Math.round(this.value)}`).fontSize(14).fontColor('#F1F1F1')
              .width(36).height(28).textAlign(TextAlign.Center)
              .position({ x: `${(this.value - this.minimum) / (this.maximum - this.minimum) * 100}%`, y: 0 })
              .translate({ x: -18 })
          }.width('calc(100% - 24vp)').height(28)
          Slider({ value: this.value, min: this.minimum, max: this.maximum, step: 1,
            style: SliderStyle.OutSet })
            .width('100%').height(40).blockColor(Color.White).blockSize({ width: 24, height: 24 })
            .trackColor('#80FFFFFF').selectedColor('#7A59FB').trackThickness(4)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.value = value
              const now = Date.now()
              if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click || now - this.lastUpdate >= 50) {
                this.lastUpdate = now
                this.changeValue(value)
              }
            }).id('beauty-slider')
        }.width('100%').padding({ left: 20, right: 20 })
      }
      Column() {
        Scroll() {
          Row() {
            ForEach(this.tabs, (label: string, index: number) => {
              Column() {
                Text(label).fontSize(14).fontWeight(FontWeight.Medium).height(34)
                  .fontColor(this.currentTab === index ? Color.White : '#C6C4DD')
                Row().width(label.length * 14).height(1)
                  .backgroundColor(this.currentTab === index ? Color.White : Color.Transparent)
              }.width(Math.max(72, label.length * 14 + 32)).height(35)
                .onClick(() => this.selectTab(index)).id(`beauty-tab-${index}`)
            })
          }
        }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off).width('100%').height(35)
          .align(Alignment.Start)
        List({ scroller: this.scroller }) {
          ForEach(this.items, (item: BeautyControlItem) => {
            ListItem() { this.controlItem(item) }
          // A toggle keeps its logical ID, but its label/icon change. Recreate that item
          // when the icon changes so ForEach cannot retain its previous plain-object content.
          }, (item: BeautyControlItem) => `${this.currentTab}-${item.id}-${item.icon}`)
        }.listDirection(Axis.Horizontal).height(120).width('100%').scrollBar(BarState.Off)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 }).id('beauty-items')
      }.width('100%').padding({ top: 20, bottom: 20 }).backgroundColor('#D9151325')
        .borderRadius({ topLeft: 20, topRight: 20 })
    }.width('100%')
  }
}
