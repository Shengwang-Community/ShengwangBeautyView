// shengwang_beauty_sdk.dart
// Flutter equivalent of iOS ShengwangBeautySDK.swift

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'builders/beauty_page_builder.dart';
import 'models/beauty_page_info.dart';

// ── Module node IDs ───────────────────────────────────────────────────────────

class _NodeId {
  static const int beauty      = 1;
  static const int styleMakeup = 2;
  static const int filter      = 4;
  static const int sticker     = 8;
}

// ── ShengwangBeautySDK ────────────────────────────────────────────────────────

class ShengwangBeautySDK {
  ShengwangBeautySDK._();
  static final ShengwangBeautySDK instance = ShengwangBeautySDK._();

  RtcEngine?         _rtcEngine;
  VideoEffectObject? _beautyEffect;

  bool _beautyEnable  = false;
  bool _filterEnable  = false;
  bool _makeupEnable  = false;
  bool _stickerEnable = false;

  void Function()? beautyStateListener;

  late final AgoraBeautyConfig beautyConfig = AgoraBeautyConfig(sdk: this);

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<bool> initBeautySDK({
    required RtcEngine rtcEngine,
    required String materialBundlePath,
  }) async {
    if (materialBundlePath.isEmpty) return false;
    _rtcEngine = rtcEngine;

    await rtcEngine.enableExtension(
      provider: 'agora_video_filters_clear_vision',
      extension: 'clear_vision',
      enable: true,
      type: MediaSourceType.primaryCameraSource,
    );

    _beautyEffect = await rtcEngine.createVideoEffectObject(
      bundlePath: materialBundlePath,
      type: MediaSourceType.primaryCameraSource,
    );

    if (_beautyEffect == null) {
      print('[BeautySDK] Failed to create VideoEffectObject');
      _rtcEngine = null;
      return false;
    }

    _enable(true);
    print('[BeautySDK] Initialized successfully');

    _notifyStateChanged();
    return true;
  }

  Future<void> unInitBeautySDK() async {
    _enable(false);

    final effect = _beautyEffect;
    if (effect != null) {
      await _rtcEngine?.destroyVideoEffectObject(effect);
    }

    await _rtcEngine?.enableExtension(
      provider: 'agora_video_filters_clear_vision',
      extension: 'clear_vision',
      enable: false,
      type: MediaSourceType.primaryCameraSource,
    );

    _rtcEngine    = null;
    _beautyEffect = null;
    _beautyEnable  = false;
    _filterEnable  = false;
    _makeupEnable  = false;
    _stickerEnable = false;

    beautyConfig._stickerName = null;
    beautyConfig._filterName  = null;
    beautyConfig._makeupName  = null;

    print('[BeautySDK] unInitBeautySDK');
    _notifyStateChanged();
  }

  Future<void> enable(bool enable) async {
    _enable(enable);
    _notifyStateChanged();
  }

  // ── Private ─────────────────────────────────────────────────────────────────
  void _enable(bool enable) {
    _enableBeauty(enable);
    _enableFilter(enable);
    _enableMakeup(enable);
    _enableSticker(enable);
  }
  
  void _enableBeauty(bool enable) {
    final effect = _beautyEffect;
    if (effect == null || enable == _beautyEnable) return;
    if (enable) {
      effect.addOrUpdateVideoEffect(
          nodeId: _NodeId.beauty, templateName: beautyConfig._beautyName);
    } else {
      effect.removeVideoEffect(_NodeId.beauty);
    }
    _beautyEnable = enable;
  }

  void _enableFilter(bool enable) {
    final effect = _beautyEffect;
    if (effect == null || enable == _filterEnable) return;
    if (enable) {
      final name = beautyConfig._filterName;
      if (name != null) {
        effect.addOrUpdateVideoEffect(nodeId: _NodeId.filter, templateName: name);
      }
    } else {
      effect.removeVideoEffect(_NodeId.filter);
    }
    _filterEnable = enable;
  }

  void _enableMakeup(bool enable) {
    final effect = _beautyEffect;
    if (effect == null || enable == _makeupEnable) return;
    if (enable) {
      final name = beautyConfig._makeupName;
      if (name != null) {
        effect.addOrUpdateVideoEffect(nodeId: _NodeId.styleMakeup, templateName: name);
      }
    } else {
      effect.removeVideoEffect(_NodeId.styleMakeup);
    }
    _makeupEnable = enable;
  }

  void _enableSticker(bool enable) {
    final effect = _beautyEffect;
    if (effect == null || enable == _stickerEnable) return;
    if (enable) {
      final name = beautyConfig._stickerName;
      if (name != null) {
        effect.addOrUpdateVideoEffect(nodeId: _NodeId.sticker, templateName: name);
      }
    } else {
      effect.removeVideoEffect(_NodeId.sticker);
    }
    _stickerEnable = enable;
  }

  void _notifyStateChanged() => beautyStateListener?.call();
}

// ── AgoraBeautyConfig ─────────────────────────────────────────────────────────

class AgoraBeautyConfig extends BeautyConfig {
  final ShengwangBeautySDK sdk;
  AgoraBeautyConfig({required this.sdk});

  VideoEffectObject? get _effect => sdk._beautyEffect;
  RtcEngine?        get _engine => sdk._rtcEngine;

  // Internal fields
  String  _beautyName = '';
  String? _makeupName;
  String? _filterName;
  String? _stickerName;

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Future<double> _getFloat(String option, String key, double fallback) async {
    final e = _effect;
    if (e == null) return fallback;
    try {
      return await e.getVideoEffectFloatParam(option: option, key: key);
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> _getBool(String option, String key, bool fallback) async {
    final e = _effect;
    if (e == null) return fallback;
    try {
      return await e.getVideoEffectBoolParam(option: option, key: key);
    } catch (_) {
      return fallback;
    }
  }

  Future<int> _getFaceShape(FaceShapeArea area) async {
    final engine = _engine;
    if (engine == null) return 0;
    try {
      final opts = await engine.getFaceShapeAreaOptions(shapeArea: area);
      return opts.shapeIntensity ?? 0;
    } catch (_) {
      return 0;
    }
  }

  void _setFaceShape(FaceShapeArea area, int v) {
    _engine?.setFaceShapeAreaOptions(
      options: FaceShapeAreaOptions(shapeArea: area, shapeIntensity: v),
    );
  }

  // ── Beauty enable ────────────────────────────────────────────────────────────

  @override
  Future<bool> getBeautyEnable() =>
      _getBool('beauty_effect_option', 'enable', false);
  @override
  set beautyEnable(bool v) {
    _effect?.setVideoEffectBoolParam(
        option: 'beauty_effect_option', key: 'enable', param: v);
    sdk._notifyStateChanged();
  }

  @override
  Future<bool> getFaceShapeEnable() =>
      _getBool('face_shape_beauty_option', 'enable', false);
  @override
  set faceShapeEnable(bool v) {
    _effect?.setVideoEffectBoolParam(
        option: 'face_shape_beauty_option', key: 'enable', param: v);
    sdk._notifyStateChanged();
  }

  // ── Skin beauty ──────────────────────────────────────────────────────────────

  @override
  Future<double> getSmoothnessAsync() =>
      _getFloat('beauty_effect_option', 'smoothness', 0.0);
  @override
  set smoothness(double v) => _effect?.setVideoEffectFloatParam(
      option: 'beauty_effect_option', key: 'smoothness', param: v);

  @override
  Future<double> getWhitenNaturalAsync() =>
      _getFloat('beauty_effect_option', 'lightness', 0.0);
  @override
  set whitenNatural(double v) {
    _effect?.setVideoEffectStringParam(
        option: 'beauty_effect_option', key: 'whiten_lut_path', param: '');
    _effect?.setVideoEffectFloatParam(
        option: 'beauty_effect_option', key: 'lightness', param: v);
  }

  @override
  Future<double> getRednessAsync() =>
      _getFloat('beauty_effect_option', 'redness', 0.0);
  @override
  set redness(double v) => _effect?.setVideoEffectFloatParam(
      option: 'beauty_effect_option', key: 'redness', param: v);

  @override
  Future<double> getContrastStrengthAsync() =>
      _getFloat('beauty_effect_option', 'contrast_strength', 0.0);
  @override
  set contrastStrength(double v) => _effect?.setVideoEffectFloatParam(
      option: 'beauty_effect_option', key: 'contrast_strength', param: v);

  @override
  Future<double> getSharpnessAsync() =>
      _getFloat('beauty_effect_option', 'sharpness', 0.0);
  @override
  set sharpness(double v) => _effect?.setVideoEffectFloatParam(
      option: 'beauty_effect_option', key: 'sharpness', param: v);

  @override
  Future<double> getEyePouchAsync() =>
      _getFloat('face_buffing_option', 'eye_pouch', 0.0);
  @override
  set eyePouch(double v) => _effect?.setVideoEffectFloatParam(
      option: 'face_buffing_option', key: 'eye_pouch', param: v);

  @override
  Future<double> getBrightenEyeAsync() =>
      _getFloat('face_buffing_option', 'brighten_eye', 0.0);
  @override
  set brightenEye(double v) => _effect?.setVideoEffectFloatParam(
      option: 'face_buffing_option', key: 'brighten_eye', param: v);

  @override
  Future<double> getWhitenTeethAsync() =>
      _getFloat('face_buffing_option', 'whiten_teeth', 0.0);
  @override
  set whitenTeeth(double v) => _effect?.setVideoEffectFloatParam(
      option: 'face_buffing_option', key: 'whiten_teeth', param: v);

  @override
  Future<double> getNasolabialFoldAsync() =>
      _getFloat('face_buffing_option', 'nasolabial_fold', 0.0);
  @override
  set nasolabialFold(double v) => _effect?.setVideoEffectFloatParam(
      option: 'face_buffing_option', key: 'nasolabial_fold', param: v);

  // ── Image quality ────────────────────────────────────────────────────────────

  @override
  Future<double> getTemperatureAsync() =>
      _getFloat('beauty_effect_option', 'temperature', 0.0);
  @override
  set temperature(double v) => _effect?.setVideoEffectFloatParam(
      option: 'beauty_effect_option', key: 'temperature', param: v);

  @override
  Future<double> getHueAsync() =>
      _getFloat('beauty_effect_option', 'hue', 0.0);
  @override
  set hue(double v) => _effect?.setVideoEffectFloatParam(
      option: 'beauty_effect_option', key: 'hue', param: v);

  @override
  Future<double> getSaturationAsync() =>
      _getFloat('beauty_effect_option', 'saturation', 0.0);
  @override
  set saturation(double v) => _effect?.setVideoEffectFloatParam(
      option: 'beauty_effect_option', key: 'saturation', param: v);

  @override
  Future<double> getBrightnessAsync() =>
      _getFloat('beauty_effect_option', 'brightness', 0.0);
  @override
  set brightness(double v) => _effect?.setVideoEffectFloatParam(
      option: 'beauty_effect_option', key: 'brightness', param: v);

  // ── Face shape params ────────────────────────────────────────────────────────

  @override Future<int> getFaceContour() => _getFaceShape(FaceShapeArea.faceShapeAreaFacecontour);
  @override set faceContour(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaFacecontour, v);

  @override Future<int> getMandible() => _getFaceShape(FaceShapeArea.faceShapeAreaMandible);
  @override set mandible(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaMandible, v);

  @override Future<int> getChin() => _getFaceShape(FaceShapeArea.faceShapeAreaChin);
  @override set chin(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaChin, v);

  @override Future<int> getCheek() => _getFaceShape(FaceShapeArea.faceShapeAreaCheek);
  @override set cheek(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaCheek, v);

  @override Future<int> getCheekbone() => _getFaceShape(FaceShapeArea.faceShapeAreaCheekbone);
  @override set cheekbone(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaCheekbone, v);

  @override Future<int> getFaceLength() => _getFaceShape(FaceShapeArea.faceShapeAreaFacelength);
  @override set faceLength(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaFacelength, v);

  @override Future<int> getFaceWidth() => _getFaceShape(FaceShapeArea.faceShapeAreaFacewidth);
  @override set faceWidth(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaFacewidth, v);

  @override Future<int> getForeHead() => _getFaceShape(FaceShapeArea.faceShapeAreaForehead);
  @override set foreHead(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaForehead, v);

  @override Future<int> getHeadScale() => _getFaceShape(FaceShapeArea.faceShapeAreaHeadscale);
  @override set headScale(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaHeadscale, v);

  @override Future<int> getNoseWidth() => _getFaceShape(FaceShapeArea.faceShapeAreaNosewidth);
  @override set noseWidth(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaNosewidth, v);

  @override Future<int> getNoseRoot() => _getFaceShape(FaceShapeArea.faceShapeAreaNoseroot);
  @override set noseRoot(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaNoseroot, v);

  @override Future<int> getNoseBridge() => _getFaceShape(FaceShapeArea.faceShapeAreaNosebridge);
  @override set noseBridge(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaNosebridge, v);

  @override Future<int> getNoseTip() => _getFaceShape(FaceShapeArea.faceShapeAreaNosetip);
  @override set noseTip(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaNosetip, v);

  @override Future<int> getNoseWing() => _getFaceShape(FaceShapeArea.faceShapeAreaNosewing);
  @override set noseWing(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaNosewing, v);

  @override Future<int> getNoseLength() => _getFaceShape(FaceShapeArea.faceShapeAreaNoselength);
  @override set noseLength(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaNoselength, v);

  @override Future<int> getNoseGeneral() => _getFaceShape(FaceShapeArea.faceShapeAreaNosegeneral);
  @override set noseGeneral(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaNosegeneral, v);

  @override Future<int> getEyeScale() => _getFaceShape(FaceShapeArea.faceShapeAreaEyescale);
  @override set eyeScale(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaEyescale, v);

  @override Future<int> getEyeDistance() => _getFaceShape(FaceShapeArea.faceShapeAreaEyedistance);
  @override set eyeDistance(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaEyedistance, v);

  @override Future<int> getEyeLid() => _getFaceShape(FaceShapeArea.faceShapeAreaLowereyelid);
  @override set eyeLid(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaLowereyelid, v);

  @override Future<int> getEyeInnerCorner() => _getFaceShape(FaceShapeArea.faceShapeAreaEyeinnercorner);
  @override set eyeInnerCorner(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaEyeinnercorner, v);

  @override Future<int> getEyeOuterCorner() => _getFaceShape(FaceShapeArea.faceShapeAreaEyeoutercorner);
  @override set eyeOuterCorner(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaEyeoutercorner, v);

  @override Future<int> getEyePosition() => _getFaceShape(FaceShapeArea.faceShapeAreaEyeposition);
  @override set eyePosition(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaEyeposition, v);

  @override Future<int> getEyePupils() => _getFaceShape(FaceShapeArea.faceShapeAreaEyepupils);
  @override set eyePupils(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaEyepupils, v);

  @override Future<int> getMouthSmile() => _getFaceShape(FaceShapeArea.faceShapeAreaMouthsmile);
  @override set mouthSmile(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaMouthsmile, v);

  @override Future<int> getMouthLip() => _getFaceShape(FaceShapeArea.faceShapeAreaMouthlip);
  @override set mouthLip(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaMouthlip, v);

  @override Future<int> getMouthScale() => _getFaceShape(FaceShapeArea.faceShapeAreaMouthscale);
  @override set mouthScale(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaMouthscale, v);

  @override Future<int> getMouthPosition() => _getFaceShape(FaceShapeArea.faceShapeAreaMouthposition);
  @override set mouthPosition(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaMouthposition, v);

  @override Future<int> getEyebrowThickness() => _getFaceShape(FaceShapeArea.faceShapeAreaEyebrowthickness);
  @override set eyebrowThickness(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaEyebrowthickness, v);

  @override Future<int> getEyebrowPosition() => _getFaceShape(FaceShapeArea.faceShapeAreaEyebrowposition);
  @override set eyebrowPosition(int v) => _setFaceShape(FaceShapeArea.faceShapeAreaEyebrowposition, v);

  // ── Makeup ───────────────────────────────────────────────────────────────────

  @override
  String? get makeupName => _makeupName;
  @override
  set makeupName(String? v) {
    if (_makeupName == v) return;
    _makeupName = v;
    if (v == null) {
      _effect?.removeVideoEffect(_NodeId.styleMakeup);
    } else if (sdk._makeupEnable) {
      _effect?.addOrUpdateVideoEffect(nodeId: _NodeId.styleMakeup, templateName: v);
    }
  }

  @override
  Future<double> getMakeupIntensityAsync() =>
      _getFloat('style_makeup_option', 'styleIntensity', 0.0);
  @override
  set makeupIntensity(double v) {
    if (_makeupName == null) return;
    _effect?.setVideoEffectFloatParam(
        option: 'style_makeup_option', key: 'styleIntensity', param: v);
  }

  // ── Filter ───────────────────────────────────────────────────────────────────

  @override
  String? get filterName => _filterName;
  @override
  set filterName(String? v) {
    if (_filterName == v) return;
    _filterName = v;
    if (v == null) {
      _effect?.removeVideoEffect(_NodeId.filter);
    } else if (sdk._filterEnable) {
      _effect?.addOrUpdateVideoEffect(nodeId: _NodeId.filter, templateName: v);
    }
  }

  @override
  Future<double> getFilterStrengthAsync() =>
      _getFloat('filter_effect_option', 'strength', 0.0);
  @override
  set filterStrength(double v) {
    if (_filterName == null) return;
    _effect?.setVideoEffectFloatParam(
        option: 'filter_effect_option', key: 'strength', param: v);
  }

  // ── Sticker ──────────────────────────────────────────────────────────────────

  @override
  String? get stickerName => _stickerName;
  @override
  set stickerName(String? v) {
    if (_stickerName == v) return;
    _stickerName = v;
    if (v == null) {
      _effect?.removeVideoEffect(_NodeId.sticker);
    } else if (sdk._stickerEnable) {
      _effect?.addOrUpdateVideoEffect(nodeId: _NodeId.sticker, templateName: v);
    }
  }

  // ── Reset / Save ─────────────────────────────────────────────────────────────

  @override
  void resetBeauty([BeautyModule? module]) {
    final modules = module != null
        ? [module]
        : [BeautyModule.beauty, BeautyModule.styleMakeup, BeautyModule.filter];
    for (final m in modules) {
      _effect?.performVideoEffectAction(
          nodeId: _moduleToNodeId(m), actionId: VideoEffectAction.reset);
    }
    sdk._notifyStateChanged();
  }

  @override
  void saveBeauty([BeautyModule? module]) {
    final modules = module != null
        ? [module]
        : [BeautyModule.beauty, BeautyModule.styleMakeup, BeautyModule.filter];
    for (final m in modules) {
      _effect?.performVideoEffectAction(
          nodeId: _moduleToNodeId(m), actionId: VideoEffectAction.save);
    }
    sdk._notifyStateChanged();
  }

  int _moduleToNodeId(BeautyModule m) {
    switch (m) {
      case BeautyModule.beauty:      return _NodeId.beauty;
      case BeautyModule.styleMakeup: return _NodeId.styleMakeup;
      case BeautyModule.filter:      return _NodeId.filter;
      case BeautyModule.sticker:     return _NodeId.sticker;
    }
  }
}
