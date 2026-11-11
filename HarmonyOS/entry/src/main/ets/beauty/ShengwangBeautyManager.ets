import {
  Constants,
  FaceShapeArea,
  FaceShapeAreaOptions,
  IVideoEffectObject,
  RtcEngine,
  VideoEffectAction,
  VideoEffectNodeId
} from '@shengwang/rtc-full'
import { common } from '@kit.AbilityKit'
import preferences from '@ohos.data.preferences'

export class BeautyFloatParameter {
  public label: string
  public option: string
  public key: string
  public min: number
  public max: number
  public value: number

  public constructor(label: string, option: string, key: string,
    min: number, max: number, value: number) {
    this.label = label
    this.option = option
    this.key = key
    this.min = min
    this.max = max
    this.value = value
  }
}

export class FaceShapeParameter {
  public label: string
  public area: FaceShapeArea
  public min: number
  public max: number
  public value: number
  public valueSign: number

  public constructor(label: string, area: FaceShapeArea, min: number = 0,
    max: number = 100, valueSign: number = 1) {
    this.label = label
    this.area = area
    this.min = min
    this.max = max
    this.value = 0
    this.valueSign = valueSign
  }
}

export class EffectTemplate {
  public label: string
  public name: string

  public constructor(label: string, name: string) {
    this.label = label
    this.name = name
  }
}

export class CustomMakeupStyle {
  public label: string
  public style: number
  public color: number

  public constructor(label: string, style: number, color: number = 0) {
    this.label = label
    this.style = style
    this.color = color
  }
}

export class CustomMakeupParameter {
  public label: string
  public styleKey: string
  public colorKey: string | null
  public strengthKey: string
  public style: number
  public color: number
  public strength: number
  public styles: Array<CustomMakeupStyle>

  public constructor(label: string, styleKey: string, strengthKey: string,
    styles: Array<CustomMakeupStyle>, colorKey: string | null = null) {
    this.label = label
    this.styleKey = styleKey
    this.colorKey = colorKey
    this.strengthKey = strengthKey
    this.style = 0
    this.color = 0
    this.strength = 0
    this.styles = styles
  }
}

export class ShengwangBeautyManager {
  private static readonly PROVIDER = 'agora_video_filters_clear_vision'
  private static readonly EXTENSION = 'clear_vision'
  private static readonly PREFS_NAME = 'shengwang_beauty'
  private static readonly CUSTOM_MAKEUP_TEMPLATE = 'Makeup-Custom'

  private rtcEngine: RtcEngine | null = null
  private beautyEffect: IVideoEffectObject | null = null
  private context: common.UIAbilityContext | null = null
  private makeupIntensityMap: Map<string, number> = new Map<string, number>()
  private filterStrengthMap: Map<string, number> = new Map<string, number>()
  private loaded: boolean = false

  public beautyEnabled: boolean = false
  public filterEnabled: boolean = false
  public makeupEnabled: boolean = false
  public stickerEnabled: boolean = false
  public qualityEnabled: boolean = false
  public customMakeupEnabled: boolean = false
  public makeupName: string | null = null
  public filterName: string | null = null
  public stickerName: string | null = null
  public faceShapeStyle: number = 0
  public faceShapeIntensity: number = 0
  public lastResult: number = 0

  public readonly beautyParameters: Array<BeautyFloatParameter> = [
    new BeautyFloatParameter('磨皮', 'beauty_effect_option', 'smoothness', 0, 1, 0.7),
    new BeautyFloatParameter('美白', 'beauty_effect_option', 'lightness', 0, 1, 0.7),
    new BeautyFloatParameter('红润', 'beauty_effect_option', 'redness', 0, 1, 0.3),
    new BeautyFloatParameter('清晰度', 'beauty_effect_option', 'contrast_strength', -1, 1, 0),
    new BeautyFloatParameter('锐化', 'beauty_effect_option', 'sharpness', 0, 1, 0.6),
    new BeautyFloatParameter('去黑眼圈', 'face_buffing_option', 'eye_pouch', 0, 1, 0.8),
    new BeautyFloatParameter('亮眼', 'face_buffing_option', 'brighten_eye', 0, 1, 0.8),
    new BeautyFloatParameter('白牙', 'face_buffing_option', 'whiten_teeth', 0, 1, 0),
    new BeautyFloatParameter('去法令纹', 'face_buffing_option', 'nasolabial_fold', 0, 1, 0.8)
  ]

  public readonly qualityParameters: Array<BeautyFloatParameter> = [
    new BeautyFloatParameter('色温', 'beauty_effect_option', 'temperature', -1, 1, 0),
    new BeautyFloatParameter('色调', 'beauty_effect_option', 'hue', -1, 1, 0),
    new BeautyFloatParameter('饱和度', 'beauty_effect_option', 'saturation', -1, 1, 0),
    new BeautyFloatParameter('亮度', 'beauty_effect_option', 'brightness', -1, 1, 0)
  ]

  public readonly faceShapeParameters: Array<FaceShapeParameter> = [
    new FaceShapeParameter('瘦脸', FaceShapeArea.FACE_CONTOUR),
    new FaceShapeParameter('V脸', FaceShapeArea.MANDIBLE),
    new FaceShapeParameter('下巴', FaceShapeArea.CHIN, -100, 100),
    new FaceShapeParameter('下颌线', FaceShapeArea.CHEEK),
    new FaceShapeParameter('颧骨', FaceShapeArea.CHEEKBONE),
    new FaceShapeParameter('短脸', FaceShapeArea.FACE_LENGTH, 0, 100, -1),
    new FaceShapeParameter('窄脸', FaceShapeArea.FACE_WIDTH),
    new FaceShapeParameter('发际线', FaceShapeArea.FOREHEAD),
    new FaceShapeParameter('小头', FaceShapeArea.HEAD_SCALE),
    new FaceShapeParameter('瘦鼻', FaceShapeArea.NOSE_WIDTH),
    new FaceShapeParameter('山根', FaceShapeArea.NOSE_ROOT),
    new FaceShapeParameter('鼻梁', FaceShapeArea.NOSE_BRIDGE),
    new FaceShapeParameter('鼻尖', FaceShapeArea.NOSE_TIP),
    new FaceShapeParameter('鼻翼', FaceShapeArea.NOSE_WING),
    new FaceShapeParameter('鼻长', FaceShapeArea.NOSE_LENGTH, -100, 100),
    new FaceShapeParameter('鼻综合', FaceShapeArea.NOSE_GENERAL, -100, 100),
    new FaceShapeParameter('大眼', FaceShapeArea.EYE_SCALE),
    new FaceShapeParameter('眼距', FaceShapeArea.EYE_DISTANCE, -100, 100),
    new FaceShapeParameter('眼睑下至', FaceShapeArea.LOWER_EYELID),
    new FaceShapeParameter('内眼角', FaceShapeArea.EYE_INNER_CORNER, -100, 100),
    new FaceShapeParameter('外眼角', FaceShapeArea.EYE_OUTER_CORNER, -100, 100),
    new FaceShapeParameter('眼位', FaceShapeArea.EYE_POSITION, -100, 100),
    new FaceShapeParameter('瞳孔', FaceShapeArea.EYE_PUPILS),
    new FaceShapeParameter('微笑唇', FaceShapeArea.MOUTH_SMILE),
    new FaceShapeParameter('丰唇', FaceShapeArea.MOUTH_LIP),
    new FaceShapeParameter('嘴型', FaceShapeArea.MOUTH_SCALE, -100, 100),
    new FaceShapeParameter('缩人中', FaceShapeArea.MOUTH_POSITION),
    new FaceShapeParameter('眉粗细', FaceShapeArea.EYEBROW_THICKNESS, -100, 100),
    new FaceShapeParameter('眉上下', FaceShapeArea.EYEBROW_POSITION, -100, 100)
  ]

  public readonly makeupTemplates: Array<EffectTemplate> = [
    new EffectTemplate('学妹妆', 'Makeup-Young'),
    new EffectTemplate('学姐妆', 'Makeup-Mature'),
    new EffectTemplate('气质妆', 'Makeup-Aura'),
    new EffectTemplate('白皙妆', 'Makeup-Natural'),
    new EffectTemplate('优雅妆', 'Makeup-Graceful'),
    new EffectTemplate('粉晕妆', 'Makeup-Charm'),
    new EffectTemplate('俏皮妆', 'Makeup-Perkey'),
    new EffectTemplate('少女妆', 'Makeup-Maiden'),
    new EffectTemplate('深邃妆', 'Makeup-Insight'),
    new EffectTemplate('氤氲妆', 'Makeup-Misty')
  ]

  public readonly filterTemplates: Array<EffectTemplate> = [
    new EffectTemplate('沉稳', 'Filter-Serene'),
    new EffectTemplate('都市', 'Filter-Urban'),
    new EffectTemplate('流光', 'Filter-Glow'),
    new EffectTemplate('流金', 'Filter-Gilt'),
    new EffectTemplate('奶油', 'Filter-Cream'),
    new EffectTemplate('拿铁', 'Filter-Latte'),
    new EffectTemplate('柠夏', 'Filter-Summer'),
    new EffectTemplate('日常', 'Filter-Daily'),
    new EffectTemplate('绅士', 'Filter-Gentleman'),
    new EffectTemplate('香草', 'Filter-Vanilla'),
    new EffectTemplate('白瓷', 'Filter-Bright'),
    new EffectTemplate('白桃', 'Filter-Peach'),
    new EffectTemplate('苍墨', 'Filter-Ink'),
    new EffectTemplate('胶片', 'Filter-Film'),
    new EffectTemplate('霁晴', 'Filter-Sunny'),
    new EffectTemplate('漫画', 'Filter-Comic'),
    new EffectTemplate('梦幻', 'Filter-Dreamy'),
    new EffectTemplate('棉绒', 'Filter-Cotton'),
    new EffectTemplate('苏打', 'Filter-Soda'),
    new EffectTemplate('月白', 'Filter-Moonlight'),
    new EffectTemplate('白茶', 'Filter-Whitetea'),
    new EffectTemplate('沉谧', 'Filter-Tranquil'),
    new EffectTemplate('ins风', 'Filter-Ins'),
    new EffectTemplate('老街', 'Filter-Street'),
    new EffectTemplate('泡芙', 'Filter-Puff'),
    new EffectTemplate('私藏', 'Filter-Collection'),
    new EffectTemplate('盐汽水', 'Filter-Salty'),
    new EffectTemplate('质感', 'Filter-Texture'),
    new EffectTemplate('气色', 'Filter-Colorful'),
    new EffectTemplate('初雪', 'Filter-Snow'),
    new EffectTemplate('粉霞', 'Filter-Blush'),
    new EffectTemplate('怀旧', 'Filter-Nostalgia'),
    new EffectTemplate('焦糖', 'Filter-Caramel'),
    new EffectTemplate('微醺', 'Filter-Tipsy'),
    new EffectTemplate('薰衣草', 'Filter-Lavender'),
    new EffectTemplate('胭脂', 'Filter-Rouge'),
    new EffectTemplate('氤氲', 'Filter-Misty')
  ]

  public readonly stickerTemplates: Array<EffectTemplate> = [
    new EffectTemplate('圣诞节', 'Sticker-Christmas'),
    new EffectTemplate('章鱼', 'Sticker-Squid'),
    new EffectTemplate('猪可爱', 'Sticker-Piggy'),
    new EffectTemplate('辫子猫', 'Sticker-Longcat'),
    new EffectTemplate('粉色发箍', 'Sticker-Hairhoop'),
    new EffectTemplate('没有烦恼', 'Sticker-Relax'),
    new EffectTemplate('卡通猫', 'Sticker-Cartooncat'),
    new EffectTemplate('蝴蝶', 'Sticker-Butterfly'),
    new EffectTemplate('粉刷时光', 'Sticker-Brush'),
    new EffectTemplate('赛博眼镜', 'Sticker-Glass'),
    new EffectTemplate('霓虹皇冠', 'Sticker-Tiara'),
    new EffectTemplate('爱心眼镜', 'Sticker-Love')
  ]

  public readonly customMakeupParameters: Array<CustomMakeupParameter> = [
    new CustomMakeupParameter('口红', 'lipStyle', 'lipStrength', [
      new CustomMakeupStyle('无', 0),
      new CustomMakeupStyle('活力橙', 1, 9),
      new CustomMakeupStyle('绒雾红', 1, 6),
      new CustomMakeupStyle('梅子', 1, 3),
      new CustomMakeupStyle('嫩粉', 1, 5),
      new CustomMakeupStyle('西柚', 1, 8)
    ], 'lipColor'),
    new CustomMakeupParameter('腮红', 'blushStyle', 'blushStrength', [
      new CustomMakeupStyle('无', 0),
      new CustomMakeupStyle('粉雾', 1, 0),
      new CustomMakeupStyle('蜜桃', 3, 2),
      new CustomMakeupStyle('微醉', 2, 0),
      new CustomMakeupStyle('魅惑', 8, 3),
      new CustomMakeupStyle('云朵', 10, 0)
    ], 'blushColor'),
    new CustomMakeupParameter('修容', 'facialStyle', 'facialStrength', [
      new CustomMakeupStyle('无', 0),
      new CustomMakeupStyle('立体', 1),
      new CustomMakeupStyle('匀肤', 9),
      new CustomMakeupStyle('饱满', 3),
      new CustomMakeupStyle('轮廓', 6),
      new CustomMakeupStyle('提亮', 8)
    ]),
    new CustomMakeupParameter('眼影', 'shadowStyle', 'shadowStrength', [
      new CustomMakeupStyle('无', 0),
      new CustomMakeupStyle('紫罗兰', 2),
      new CustomMakeupStyle('玫瑰', 9),
      new CustomMakeupStyle('浆果', 11),
      new CustomMakeupStyle('大地', 4),
      new CustomMakeupStyle('韩系', 5),
      new CustomMakeupStyle('杏桃', 7)
    ]),
    new CustomMakeupParameter('眉毛', 'browStyle', 'browStrength', [
      new CustomMakeupStyle('无', 0),
      new CustomMakeupStyle('婉约', 1),
      new CustomMakeupStyle('温柔', 2),
      new CustomMakeupStyle('标准', 3),
      new CustomMakeupStyle('柳叶', 4),
      new CustomMakeupStyle('毛流', 5),
      new CustomMakeupStyle('野生', 6)
    ]),
    new CustomMakeupParameter('睫毛', 'lashStyle', 'lashStrength', [
      new CustomMakeupStyle('无', 0),
      new CustomMakeupStyle('精致', 2, 1),
      new CustomMakeupStyle('飞扬', 3, 0),
      new CustomMakeupStyle('卷翘', 4, 1),
      new CustomMakeupStyle('漫画', 5, 0),
      new CustomMakeupStyle('上扬', 9, 1)
    ], 'lashColor'),
    new CustomMakeupParameter('美瞳', 'pupilStyle', 'pupilStrength', [
      new CustomMakeupStyle('无', 0),
      new CustomMakeupStyle('棕褐', 1),
      new CustomMakeupStyle('天空蓝', 2),
      new CustomMakeupStyle('翡翠绿', 3),
      new CustomMakeupStyle('高级灰', 4),
      new CustomMakeupStyle('火星', 5),
      new CustomMakeupStyle('自然', 7)
    ])
  ]

  public constructor(context?: common.UIAbilityContext) {
    if (context !== undefined) {
      this.context = context
    }
  }

  public isInitialized(): boolean {
    return this.rtcEngine !== null && this.beautyEffect !== null
  }

  public async initialize(materialPath: string, rtcEngine: RtcEngine): Promise<boolean> {
    this.rtcEngine = rtcEngine
    this.lastResult = rtcEngine.enableExtension(
      ShengwangBeautyManager.PROVIDER,
      ShengwangBeautyManager.EXTENSION,
      true,
      Constants.MediaSourceType.PRIMARY_CAMERA)
    if (this.lastResult !== 0) {
      this.rtcEngine = null
      return false
    }

    this.beautyEffect = rtcEngine.createVideoEffectObject(
      materialPath, Constants.MediaSourceType.PRIMARY_CAMERA) ?? null
    if (this.beautyEffect === null) {
      rtcEngine.enableExtension(ShengwangBeautyManager.PROVIDER,
        ShengwangBeautyManager.EXTENSION, false, Constants.MediaSourceType.PRIMARY_CAMERA)
      this.rtcEngine = null
      this.lastResult = -1
      return false
    }

    const enableResult = this.setEnabled(true)
    if (enableResult < 0) {
      rtcEngine.destroyVideoEffectObject(this.beautyEffect)
      rtcEngine.enableExtension(ShengwangBeautyManager.PROVIDER,
        ShengwangBeautyManager.EXTENSION, false, Constants.MediaSourceType.PRIMARY_CAMERA)
      this.beautyEffect = null
      this.rtcEngine = null
      this.lastResult = enableResult
      return false
    }
    await this.restoreSavedTemplates()
    this.refreshParameters()
    return true
  }

  public uninitialize(): void {
    const engine = this.rtcEngine
    const effect = this.beautyEffect
    if (engine === null || effect === null) {
      return
    }
    this.setEnabled(false)
    engine.destroyVideoEffectObject(effect)
    engine.enableExtension(ShengwangBeautyManager.PROVIDER,
      ShengwangBeautyManager.EXTENSION, false, Constants.MediaSourceType.PRIMARY_CAMERA)
    this.beautyEffect = null
    this.rtcEngine = null
    this.loaded = false
    this.makeupName = null
    this.filterName = null
    this.stickerName = null
    this.makeupIntensityMap.clear()
    this.filterStrengthMap.clear()
  }

  public setEnabled(enabled: boolean): number {
    if (this.beautyEffect === null || this.rtcEngine === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    if (enabled && !this.loaded) {
      this.lastResult = this.beautyEffect.addOrUpdateVideoEffect(VideoEffectNodeId.BEAUTY, '')
      if (this.lastResult < 0) { return this.lastResult }
      this.beautyEnabled = true
      this.filterEnabled = true
      this.makeupEnabled = true
      this.stickerEnabled = true
      this.beautyEffect.setVideoEffectBoolParam('beauty_effect_option', 'enable', true)
      this.beautyEffect.setVideoEffectBoolParam('face_shape_beauty_option', 'enable', true)
      this.loaded = true
    }
    // Bypass the extension without recreating nodes: comparison must preserve slider values.
    this.lastResult = this.rtcEngine.enableExtension(ShengwangBeautyManager.PROVIDER,
      ShengwangBeautyManager.EXTENSION, enabled, Constants.MediaSourceType.PRIMARY_CAMERA)
    return this.lastResult
  }

  public setBeautyEnabled(enabled: boolean): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    this.lastResult = this.beautyEffect.setVideoEffectBoolParam(
      'beauty_effect_option', 'enable', enabled)
    const faceResult = this.beautyEffect.setVideoEffectBoolParam(
      'face_shape_beauty_option', 'enable', enabled)
    this.lastResult = this.lastResult < 0 ? this.lastResult : faceResult
    if (this.lastResult === 0) { this.beautyEnabled = enabled }
    console.info(`[ShengwangBeauty] beauty enabled=${enabled} result=${this.lastResult}`)
    return this.lastResult
  }

  public setFloatParameter(parameter: BeautyFloatParameter, value: number): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    if (parameter.key === 'lightness') {
      this.beautyEffect.setVideoEffectStringParam(
        'beauty_effect_option', 'whiten_lut_path', '')
    }
    this.lastResult = this.beautyEffect.setVideoEffectFloatParam(
      parameter.option, parameter.key, value)
    if (this.lastResult === 0) { parameter.value = value }
    console.info(`[ShengwangBeauty] float ${parameter.key}=${value} result=${this.lastResult}`)
    return this.lastResult
  }

  public setQualityEnabled(enabled: boolean): void {
    this.qualityEnabled = enabled
    if (!enabled) {
      this.qualityParameters.forEach((parameter: BeautyFloatParameter) => {
        this.setFloatParameter(parameter, 0)
      })
    }
  }

  public setFaceShapeParameter(parameter: FaceShapeParameter, value: number): number {
    if (this.rtcEngine === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    const options = new FaceShapeAreaOptions(parameter.area,
      Math.round(value * parameter.valueSign))
    this.lastResult = this.rtcEngine.setFaceShapeAreaOptions(
      options, Constants.MediaSourceType.PRIMARY_CAMERA)
    if (this.lastResult === 0) { parameter.value = value }
    console.info(`[ShengwangBeauty] face ${parameter.area}=${value} result=${this.lastResult}`)
    return this.lastResult
  }

  public setFaceShapeStyle(style: number): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    this.faceShapeStyle = style
    this.lastResult = this.beautyEffect.setVideoEffectIntParam(
      'face_shape_beauty_option', 'style', style)
    return this.lastResult
  }

  public setFaceShapeIntensity(intensity: number): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    this.faceShapeIntensity = intensity
    this.lastResult = this.beautyEffect.setVideoEffectIntParam(
      'face_shape_beauty_option', 'intensity', intensity)
    return this.lastResult
  }

  public selectMakeup(name: string | null): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    if (name === null) {
      if (this.makeupName === null) {
        return 0
      }
      if (this.makeupName.length === 0) {
        this.makeupName = null
        this.customMakeupEnabled = false
        this.lastResult = 0
        return 0
      }
      this.lastResult = this.beautyEffect.removeVideoEffect(VideoEffectNodeId.STYLE_MAKEUP)
      this.makeupName = null
      this.customMakeupEnabled = false
      return this.lastResult
    }
    if (name.length === 0) {
      this.lastResult = this.makeupEnabled ? this.beautyEffect.addOrUpdateVideoEffect(
        VideoEffectNodeId.STYLE_MAKEUP, ShengwangBeautyManager.CUSTOM_MAKEUP_TEMPLATE) : 0
      if (this.lastResult === 0) {
        this.makeupName = ''
        this.customMakeupEnabled = true
      }
      console.info(`[ShengwangBeauty] activate custom makeup template, result=${this.lastResult}`)
      return this.lastResult
    }
    this.lastResult = this.makeupEnabled ?
      this.beautyEffect.addOrUpdateVideoEffect(VideoEffectNodeId.STYLE_MAKEUP, name) : 0
    if (this.lastResult === 0 && name.length > 0) {
      this.makeupName = name
      this.customMakeupEnabled = false
      const cached = this.makeupIntensityMap.get(name)
      if (cached !== undefined) {
        this.setMakeupIntensity(cached)
      }
    }
    console.info(`[ShengwangBeauty] makeup ${name} result=${this.lastResult}`)
    return this.lastResult
  }

  public getMakeupIntensity(): number {
    if (this.beautyEffect === null || this.makeupName === null) {
      return 0
    }
    const cached = this.makeupIntensityMap.get(this.makeupName)
    if (cached !== undefined) {
      return cached
    }
    const value = this.beautyEffect.getVideoEffectFloatParam(
      'style_makeup_option', 'styleIntensity')
    this.makeupIntensityMap.set(this.makeupName, value)
    return value
  }

  public setMakeupIntensity(value: number): number {
    if (this.beautyEffect === null || this.makeupName === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    this.makeupIntensityMap.set(this.makeupName, value)
    this.lastResult = this.beautyEffect.setVideoEffectFloatParam(
      'style_makeup_option', 'styleIntensity', value)
    return this.lastResult
  }

  public setMakeupFilterStrength(value: number): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    this.lastResult = this.beautyEffect.setVideoEffectFloatParam(
      'style_makeup_option', 'filterStrength', value)
    return this.lastResult
  }

  public getMakeupFilterStrength(): number {
    if (this.beautyEffect === null || this.makeupName === null) {
      return 0
    }
    return this.beautyEffect.getVideoEffectFloatParam(
      'style_makeup_option', 'filterStrength')
  }

  public setCustomMakeupEnabled(enabled: boolean): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    if (enabled) {
      const nodeResult = this.selectMakeup('')
      if (nodeResult < 0) {
        console.info(`[ShengwangBeauty] prepare custom makeup node, result=${nodeResult}`)
        return nodeResult
      }
    }
    this.lastResult = this.beautyEffect.setVideoEffectBoolParam(
      'makeup_options', 'enable_mu', enabled)
    this.customMakeupEnabled = this.lastResult === 0 ? enabled : this.customMakeupEnabled
    console.info(`[ShengwangBeauty] custom makeup enabled=${enabled}, result=${this.lastResult}`)
    if (this.lastResult === 0 && !enabled &&
      this.makeupName !== null && this.makeupName.length === 0) {
      this.selectMakeup(null)
    }
    return this.lastResult
  }

  public setCustomMakeupStyle(parameter: CustomMakeupParameter,
    style: number, color: number): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    if (!this.customMakeupEnabled) {
      const enableResult = this.setCustomMakeupEnabled(true)
      if (enableResult < 0) {
        return enableResult
      }
    }
    parameter.style = style
    parameter.color = color
    this.lastResult = this.beautyEffect.setVideoEffectIntParam(
      'makeup_options', parameter.styleKey, style)
    const styleResult = this.lastResult
    let colorResult = 0
    if (parameter.colorKey !== null) {
      colorResult = this.beautyEffect.setVideoEffectIntParam(
        'makeup_options', parameter.colorKey, color)
      if (this.lastResult === 0) {
        this.lastResult = colorResult
      }
    }
    console.info(`[ShengwangBeauty] makeup style ${parameter.styleKey}=${style}, ` +
      `${parameter.colorKey ?? 'noColor'}=${color}, styleResult=${styleResult}, colorResult=${colorResult}`)
    return this.lastResult
  }

  public setCustomMakeupStrength(parameter: CustomMakeupParameter, strength: number): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    if (!this.customMakeupEnabled) {
      const enableResult = this.setCustomMakeupEnabled(true)
      if (enableResult < 0) {
        return enableResult
      }
    }
    parameter.strength = strength
    this.lastResult = this.beautyEffect.setVideoEffectFloatParam(
      'makeup_options', parameter.strengthKey, strength)
    console.info(`[ShengwangBeauty] makeup strength ${parameter.strengthKey}=${strength}, ` +
      `result=${this.lastResult}`)
    return this.lastResult
  }

  public selectFilter(name: string | null): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    if (name === null) {
      if (this.filterName === null) {
        return 0
      }
      this.lastResult = this.beautyEffect.removeVideoEffect(VideoEffectNodeId.FILTER)
      this.filterName = null
      return this.lastResult
    }
    this.lastResult = this.filterEnabled ?
      this.beautyEffect.addOrUpdateVideoEffect(VideoEffectNodeId.FILTER, name) : 0
    if (this.lastResult === 0) {
      this.filterName = name
      const cached = this.filterStrengthMap.get(name)
      if (cached !== undefined) {
        this.setFilterStrength(cached)
      }
    }
    console.info(`[ShengwangBeauty] filter ${name} result=${this.lastResult}`)
    return this.lastResult
  }

  public getFilterStrength(): number {
    if (this.beautyEffect === null || this.filterName === null) {
      return 0
    }
    const cached = this.filterStrengthMap.get(this.filterName)
    if (cached !== undefined) {
      return cached
    }
    const value = this.beautyEffect.getVideoEffectFloatParam(
      'filter_effect_option', 'strength')
    this.filterStrengthMap.set(this.filterName, value)
    return value
  }

  public setFilterStrength(value: number): number {
    if (this.beautyEffect === null || this.filterName === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    this.filterStrengthMap.set(this.filterName, value)
    this.lastResult = this.beautyEffect.setVideoEffectFloatParam(
      'filter_effect_option', 'strength', value)
    return this.lastResult
  }

  public selectSticker(name: string | null): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    if (name === null) {
      if (this.stickerName === null) {
        return 0
      }
      this.lastResult = this.beautyEffect.removeVideoEffect(VideoEffectNodeId.STICKER)
      if (this.lastResult === 0) { this.stickerName = null }
      return this.lastResult
    }
    this.lastResult = this.stickerEnabled ?
      this.beautyEffect.addOrUpdateVideoEffect(VideoEffectNodeId.STICKER, name) : 0
    if (this.lastResult === 0) { this.stickerName = name }
    console.info(`[ShengwangBeauty] sticker ${name} result=${this.lastResult}`)
    return this.lastResult
  }

  public setStickerStrength(value: number): number {
    if (this.beautyEffect === null || this.stickerName === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    this.lastResult = this.beautyEffect.setVideoEffectFloatParam(
      'sticker_effect_option', 'strength', value)
    return this.lastResult
  }

  public getStickerStrength(): number {
    if (this.beautyEffect === null || this.stickerName === null) {
      return 0
    }
    return this.beautyEffect.getVideoEffectFloatParam(
      'sticker_effect_option', 'strength')
  }

  public reset(nodeId: VideoEffectNodeId): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    if (!this.hasNode(nodeId)) { return 0 }
    this.lastResult = this.beautyEffect.performVideoEffectAction(
      nodeId, VideoEffectAction.RESET)
    if (this.lastResult === 0) {
      if (nodeId === VideoEffectNodeId.BEAUTY ||
        nodeId === VideoEffectNodeId.STYLE_MAKEUP) {
        this.refreshParameters()
      }
      if (nodeId === VideoEffectNodeId.STYLE_MAKEUP && this.makeupName !== null) {
        this.makeupIntensityMap.delete(this.makeupName)
      } else if (nodeId === VideoEffectNodeId.FILTER && this.filterName !== null) {
        this.filterStrengthMap.delete(this.filterName)
      }
    }
    console.info(`[ShengwangBeauty] reset node=${nodeId}, result=${this.lastResult}`)
    return this.lastResult
  }

  public save(nodeId: VideoEffectNodeId): number {
    if (this.beautyEffect === null) {
      return -Constants.ErrorCode.ERR_NOT_INITIALIZED
    }
    this.lastResult = this.hasNode(nodeId) ?
      this.beautyEffect.performVideoEffectAction(nodeId, VideoEffectAction.SAVE) : 0
    if (this.lastResult !== 0) { return this.lastResult }
    if (this.context !== null) {
      const store = preferences.getPreferencesSync(this.context,
        { name: ShengwangBeautyManager.PREFS_NAME })
      if (nodeId === VideoEffectNodeId.STYLE_MAKEUP) {
        store.putSync('makeupName', this.makeupName ?? '__none__')
      }
      if (nodeId === VideoEffectNodeId.FILTER) {
        store.putSync('filterName', this.filterName ?? '__none__')
      }
      if (nodeId === VideoEffectNodeId.STICKER) {
        store.putSync('stickerName', this.stickerName ?? '__none__')
      }
      store.flushSync()
    }
    console.info(`[ShengwangBeauty] save node=${nodeId}, result=${this.lastResult}`)
    return this.lastResult
  }

  public refreshParameters(): void {
    if (this.beautyEffect === null) {
      return
    }
    this.beautyParameters.forEach((parameter: BeautyFloatParameter) => {
      parameter.value = this.beautyEffect!.getVideoEffectFloatParam(
        parameter.option, parameter.key)
    })
    this.qualityParameters.forEach((parameter: BeautyFloatParameter) => {
      parameter.value = this.beautyEffect!.getVideoEffectFloatParam(
        parameter.option, parameter.key)
    })
    this.qualityEnabled = this.qualityParameters.some((parameter: BeautyFloatParameter) => parameter.value !== 0)
    this.customMakeupEnabled = this.beautyEffect.getVideoEffectBoolParam(
      'makeup_options', 'enable_mu')
    this.customMakeupParameters.forEach((parameter: CustomMakeupParameter) => {
      parameter.style = this.beautyEffect!.getVideoEffectIntParam(
        'makeup_options', parameter.styleKey)
      parameter.strength = this.beautyEffect!.getVideoEffectFloatParam(
        'makeup_options', parameter.strengthKey)
      if (parameter.colorKey !== null) {
        parameter.color = this.beautyEffect!.getVideoEffectIntParam(
          'makeup_options', parameter.colorKey)
      }
    })
    if (this.rtcEngine !== null) {
      this.faceShapeStyle = this.beautyEffect.getVideoEffectIntParam(
        'face_shape_beauty_option', 'style')
      this.faceShapeIntensity = this.beautyEffect.getVideoEffectIntParam(
        'face_shape_beauty_option', 'intensity')
      this.faceShapeParameters.forEach((parameter: FaceShapeParameter) => {
        const options = this.rtcEngine!.getFaceShapeAreaOptions(
          parameter.area, Constants.MediaSourceType.PRIMARY_CAMERA)
        if (options !== undefined) {
          parameter.value = options.shapeIntensity * parameter.valueSign
        }
      })
    }
  }

  private async restoreSavedTemplates(): Promise<void> {
    if (this.context === null) {
      return
    }
    const store = await preferences.getPreferences(
      this.context, ShengwangBeautyManager.PREFS_NAME)
    const unset = '__unset__'
    const makeupName = store.getSync('makeupName', unset) as string
    const filterName = store.getSync('filterName', unset) as string
    const stickerName = store.getSync('stickerName', unset) as string
    if (filterName !== unset) {
      this.selectFilter(filterName === '__none__' ? null : filterName)
    }
    if (stickerName !== unset) {
      this.selectSticker(stickerName === '__none__' ? null : stickerName)
    }
    if (makeupName !== unset) {
      this.selectMakeup(makeupName === '__none__' ? null : makeupName)
    }
  }

  private hasNode(nodeId: VideoEffectNodeId): boolean {
    if (nodeId === VideoEffectNodeId.STYLE_MAKEUP) { return this.makeupName !== null }
    if (nodeId === VideoEffectNodeId.FILTER) { return this.filterName !== null }
    if (nodeId === VideoEffectNodeId.STICKER) { return this.stickerName !== null }
    return this.loaded
  }
}
