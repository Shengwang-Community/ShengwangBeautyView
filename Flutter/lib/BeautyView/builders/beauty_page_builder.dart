// beauty_page_builder.dart
// Mirrors iOS BeautyPageBuilder.swift

import '../models/beauty_page_info.dart';
import 'i_page_builder.dart';

const String _iconBase = 'assets/Icons/';

/// Beauty module page builder (skin + face shape + image quality)
class BeautyPageBuilder implements IPageBuilder {
  final BeautyConfig beautyConfig;

  BeautyPageBuilder({required this.beautyConfig});

  @override
  Future<BeautyPageInfo> buildPage() async {
    final items = <BeautyItemInfo>[];

    // 1. Toggle
    final isEnabled = await beautyConfig.getBeautyEnable() || await beautyConfig.getFaceShapeEnable();
    items.add(BeautyItemInfo(
      name: 'beauty_effect_enable',
      iconAsset: null,
      isSelected: false,
      showSlider: false,
      type: BeautyItemTypeToggle(isEnabled),
      onItemClick: (_) async {
        beautyConfig.beautyEnable = !isEnabled;
        beautyConfig.faceShapeEnable = !isEnabled;
      },
    ));

    // 2. Reset
    items.add(BeautyItemInfo(
      name: 'beauty_effect_reset',
      iconAsset: '${_iconBase}beauty_ic_effect_reset.png',
      showSlider: false,
      type: const BeautyItemTypeReset(),
    ));

    await _addSkinBeautyItems(items);
    await _addFaceShapeItems(items);

    return BeautyPageInfo(
      name: 'beauty_group_beauty',
      itemList: items,
      type: BeautyModule.beauty,
    );
  }

  // MARK: - Skin beauty

  Future<void> _addSkinBeautyItems(List<BeautyItemInfo> items) async {
    final beautyEnabled = await beautyConfig.getBeautyEnable();
    _addSkin(items, 'beauty_effect_smoothness', 'beauty_ic_effect_smoothness',
        await beautyConfig.getSmoothnessAsync(), isSelected: beautyEnabled,
        onChanged: (v) => beautyConfig.smoothness = v);

    _addSkin(items, 'beauty_effect_lightness', 'beauty_ic_effect_lightness',
        await beautyConfig.getWhitenNaturalAsync(),
        onChanged: (v) => beautyConfig.whitenNatural = v);

    _addSkin(items, 'beauty_effect_redness', 'beauty_ic_effect_redness',
        await beautyConfig.getRednessAsync(),
        onChanged: (v) => beautyConfig.redness = v);

    _addSkin(items, 'beauty_effect_contrast_strength',
        'beauty_ic_effect_contrast_strength', await beautyConfig.getContrastStrengthAsync(),
        minValue: -1.0,
        onChanged: (v) => beautyConfig.contrastStrength = v);

    _addSkin(items, 'beauty_effect_sharpness', 'beauty_ic_effect_sharpness',
        await beautyConfig.getSharpnessAsync(),
        onChanged: (v) => beautyConfig.sharpness = v);

    _addSkin(items, 'beauty_effect_eye_pouch', 'beauty_ic_effect_eye_pouch',
        await beautyConfig.getEyePouchAsync(),
        onChanged: (v) => beautyConfig.eyePouch = v);

    _addSkin(items, 'beauty_effect_brighten_eye',
        'beauty_ic_effect_brighten_eye', await beautyConfig.getBrightenEyeAsync(),
        onChanged: (v) => beautyConfig.brightenEye = v);

    _addSkin(items, 'beauty_effect_whiten_teeth',
        'beauty_ic_effect_whiten_teeth', await beautyConfig.getWhitenTeethAsync(),
        onChanged: (v) => beautyConfig.whitenTeeth = v);

    _addSkin(items, 'beauty_effect_nasolabial_fold',
        'beauty_ic_effect_nasolabial_fold', await beautyConfig.getNasolabialFoldAsync(),
        onChanged: (v) => beautyConfig.nasolabialFold = v);
  }

  void _addSkin(
    List<BeautyItemInfo> items,
    String name,
    String icon,
    double value, {
    bool isSelected = false,
    double minValue = 0.0,
    double maxValue = 1.0,
    required void Function(double) onChanged,
  }) {
    items.add(BeautyItemInfo(
      name: name,
      iconAsset: '$_iconBase$icon.png',
      value: value,
      isSelected: isSelected,
      minValue: minValue,
      maxValue: maxValue,
      onValueChanged: onChanged,
    ));
  }

  // MARK: - Face shape

  Future<void> _addFaceShapeItems(List<BeautyItemInfo> items) async {
    _addFace(items, 'beauty_face_shape_face_contour',
        'beauty_ic_face_shape_face_contour', (await beautyConfig.getFaceContour()).toDouble(),
        onChanged: (v) => beautyConfig.faceContour = v.toInt());

    _addFace(items, 'beauty_face_shape_mandible',
        'beauty_ic_face_shape_mandible', (await beautyConfig.getMandible()).toDouble(),
        onChanged: (v) => beautyConfig.mandible = v.toInt());

    _addFace(items, 'beauty_face_shape_chin', 'beauty_ic_face_shape_chin',
        (await beautyConfig.getChin()).toDouble(),
        minValue: -100, onChanged: (v) => beautyConfig.chin = v.toInt());

    _addFace(items, 'beauty_face_shape_cheek', 'beauty_ic_face_shape_cheek',
        (await beautyConfig.getCheek()).toDouble(),
        onChanged: (v) => beautyConfig.cheek = v.toInt());

    _addFace(items, 'beauty_face_shape_cheekbone',
        'beauty_ic_face_shape_cheekbone', (await beautyConfig.getCheekbone()).toDouble(),
        onChanged: (v) => beautyConfig.cheekbone = v.toInt());

    _addFace(items, 'beauty_face_shape_face_length',
        'beauty_ic_face_shape_face_length', (await beautyConfig.getFaceLength()).toDouble(),
        minValue: -100, onChanged: (v) => beautyConfig.faceLength = v.toInt());

    _addFace(items, 'beauty_face_shape_face_width',
        'beauty_ic_face_shape_face_width', (await beautyConfig.getFaceWidth()).toDouble(),
        onChanged: (v) => beautyConfig.faceWidth = v.toInt());

    _addFace(items, 'beauty_face_shape_fore_head',
        'beauty_ic_face_shape_fore_head', (await beautyConfig.getForeHead()).toDouble(),
        onChanged: (v) => beautyConfig.foreHead = v.toInt());

    _addFace(items, 'beauty_face_shape_head_scale',
        'beauty_ic_face_shape_head_scale', (await beautyConfig.getHeadScale()).toDouble(),
        onChanged: (v) => beautyConfig.headScale = v.toInt());

    _addFace(items, 'beauty_face_shape_nose_width',
        'beauty_ic_face_shape_nose_width', (await beautyConfig.getNoseWidth()).toDouble(),
        onChanged: (v) => beautyConfig.noseWidth = v.toInt());

    _addFace(items, 'beauty_face_shape_nose_root',
        'beauty_ic_face_shape_nose_root', (await beautyConfig.getNoseRoot()).toDouble(),
        onChanged: (v) => beautyConfig.noseRoot = v.toInt());

    _addFace(items, 'beauty_face_shape_nose_bridge',
        'beauty_ic_face_shape_nose_bridge', (await beautyConfig.getNoseBridge()).toDouble(),
        onChanged: (v) => beautyConfig.noseBridge = v.toInt());

    _addFace(items, 'beauty_face_shape_nose_tip',
        'beauty_ic_face_shape_nose_tip', (await beautyConfig.getNoseTip()).toDouble(),
        onChanged: (v) => beautyConfig.noseTip = v.toInt());

    _addFace(items, 'beauty_face_shape_nose_wing',
        'beauty_ic_face_shape_nose_wing', (await beautyConfig.getNoseWing()).toDouble(),
        onChanged: (v) => beautyConfig.noseWing = v.toInt());

    _addFace(items, 'beauty_face_shape_nose_length',
        'beauty_ic_face_shape_nose_length', (await beautyConfig.getNoseLength()).toDouble(),
        minValue: -100, onChanged: (v) => beautyConfig.noseLength = v.toInt());

    _addFace(items, 'beauty_face_shape_nose_general',
        'beauty_ic_face_shape_nose_general', (await beautyConfig.getNoseGeneral()).toDouble(),
        minValue: -100, onChanged: (v) => beautyConfig.noseGeneral = v.toInt());

    _addFace(items, 'beauty_face_shape_eye_scale',
        'beauty_ic_face_shape_eye_scale', (await beautyConfig.getEyeScale()).toDouble(),
        onChanged: (v) => beautyConfig.eyeScale = v.toInt());

    _addFace(items, 'beauty_face_shape_eye_distance',
        'beauty_ic_face_shape_eye_distance', (await beautyConfig.getEyeDistance()).toDouble(),
        minValue: -100, onChanged: (v) => beautyConfig.eyeDistance = v.toInt());

    _addFace(items, 'beauty_face_shape_eye_lid',
        'beauty_ic_face_shape_eye_lid', (await beautyConfig.getEyeLid()).toDouble(),
        onChanged: (v) => beautyConfig.eyeLid = v.toInt());

    _addFace(items, 'beauty_face_shape_inner_corner',
        'beauty_ic_face_shape_inner_corner', (await beautyConfig.getEyeInnerCorner()).toDouble(),
        minValue: -100, onChanged: (v) => beautyConfig.eyeInnerCorner = v.toInt());

    _addFace(items, 'beauty_face_shape_outer_corner',
        'beauty_ic_face_shape_outer_corner', (await beautyConfig.getEyeOuterCorner()).toDouble(),
        minValue: -100, onChanged: (v) => beautyConfig.eyeOuterCorner = v.toInt());

    _addFace(items, 'beauty_face_shape_eye_position',
        'beauty_ic_face_shape_eye_position', (await beautyConfig.getEyePosition()).toDouble(),
        minValue: -100, onChanged: (v) => beautyConfig.eyePosition = v.toInt());

    _addFace(items, 'beauty_face_shape_eye_pupils',
        'beauty_ic_face_shape_eye_pupils', (await beautyConfig.getEyePupils()).toDouble(),
        onChanged: (v) => beautyConfig.eyePupils = v.toInt());

    _addFace(items, 'beauty_face_shape_mouth_smile',
        'beauty_ic_face_shape_mouth_smile', (await beautyConfig.getMouthSmile()).toDouble(),
        onChanged: (v) => beautyConfig.mouthSmile = v.toInt());

    _addFace(items, 'beauty_face_shape_mouth_lip',
        'beauty_ic_face_shape_mouth_lip', (await beautyConfig.getMouthLip()).toDouble(),
        onChanged: (v) => beautyConfig.mouthLip = v.toInt());

    _addFace(items, 'beauty_face_shape_mouth_scale',
        'beauty_ic_face_shape_mouth_scale', (await beautyConfig.getMouthScale()).toDouble(),
        minValue: -100, onChanged: (v) => beautyConfig.mouthScale = v.toInt());

    _addFace(items, 'beauty_face_shape_mouth_position',
        'beauty_ic_face_shape_mouth_position', (await beautyConfig.getMouthPosition()).toDouble(),
        onChanged: (v) => beautyConfig.mouthPosition = v.toInt());

    _addFace(items, 'beauty_face_shape_eyebrow_thickness',
        'beauty_ic_face_shape_eyebrow_thickness',
        (await beautyConfig.getEyebrowThickness()).toDouble(),
        minValue: -100,
        onChanged: (v) => beautyConfig.eyebrowThickness = v.toInt());

    _addFace(items, 'beauty_face_shape_eyebrow_position',
        'beauty_ic_face_shape_eyebrow_position',
        (await beautyConfig.getEyebrowPosition()).toDouble(),
        minValue: -100,
        onChanged: (v) => beautyConfig.eyebrowPosition = v.toInt());
  }

  void _addFace(
    List<BeautyItemInfo> items,
    String name,
    String icon,
    double value, {
    double minValue = 0.0,
    double maxValue = 100.0,
    required void Function(double) onChanged,
  }) {
    items.add(BeautyItemInfo(
      name: name,
      iconAsset: '$_iconBase$icon.png',
      value: value,
      minValue: minValue,
      maxValue: maxValue,
      onValueChanged: onChanged,
    ));
  }

}


// ---------------------------------------------------------------------------
// BeautyConfig — abstract interface, mirrors ShengwangBeautySDK.BeautyConfig
// Concrete implementation is provided by the host app.
// ---------------------------------------------------------------------------
abstract class BeautyConfig {
  // Beauty enable — async getters read from engine
  Future<bool> getBeautyEnable();
  set beautyEnable(bool v);
  Future<bool> getFaceShapeEnable();
  set faceShapeEnable(bool v);

  // Skin — async getters read from engine
  Future<double> getSmoothnessAsync();
  set smoothness(double v);
  Future<double> getWhitenNaturalAsync();
  set whitenNatural(double v);
  Future<double> getRednessAsync();
  set redness(double v);
  Future<double> getContrastStrengthAsync();
  set contrastStrength(double v);
  Future<double> getSharpnessAsync();
  set sharpness(double v);
  Future<double> getEyePouchAsync();
  set eyePouch(double v);
  Future<double> getBrightenEyeAsync();
  set brightenEye(double v);
  Future<double> getWhitenTeethAsync();
  set whitenTeeth(double v);
  Future<double> getNasolabialFoldAsync();
  set nasolabialFold(double v);

  // Image quality — async getters read from engine
  Future<double> getTemperatureAsync();
  set temperature(double v);
  Future<double> getHueAsync();
  set hue(double v);
  Future<double> getSaturationAsync();
  set saturation(double v);
  Future<double> getBrightnessAsync();
  set brightness(double v);

  // Face shape — async getters read from engine
  Future<int> getFaceContour();
  set faceContour(int v);
  Future<int> getMandible();
  set mandible(int v);
  Future<int> getChin();
  set chin(int v);
  Future<int> getCheek();
  set cheek(int v);
  Future<int> getCheekbone();
  set cheekbone(int v);
  Future<int> getFaceLength();
  set faceLength(int v);
  Future<int> getFaceWidth();
  set faceWidth(int v);
  Future<int> getForeHead();
  set foreHead(int v);
  Future<int> getHeadScale();
  set headScale(int v);
  Future<int> getNoseWidth();
  set noseWidth(int v);
  Future<int> getNoseRoot();
  set noseRoot(int v);
  Future<int> getNoseBridge();
  set noseBridge(int v);
  Future<int> getNoseTip();
  set noseTip(int v);
  Future<int> getNoseWing();
  set noseWing(int v);
  Future<int> getNoseLength();
  set noseLength(int v);
  Future<int> getNoseGeneral();
  set noseGeneral(int v);
  Future<int> getEyeScale();
  set eyeScale(int v);
  Future<int> getEyeDistance();
  set eyeDistance(int v);
  Future<int> getEyeLid();
  set eyeLid(int v);
  Future<int> getEyeInnerCorner();
  set eyeInnerCorner(int v);
  Future<int> getEyeOuterCorner();
  set eyeOuterCorner(int v);
  Future<int> getEyePosition();
  set eyePosition(int v);
  Future<int> getEyePupils();
  set eyePupils(int v);
  Future<int> getMouthSmile();
  set mouthSmile(int v);
  Future<int> getMouthLip();
  set mouthLip(int v);
  Future<int> getMouthScale();
  set mouthScale(int v);
  Future<int> getMouthPosition();
  set mouthPosition(int v);
  Future<int> getEyebrowThickness();
  set eyebrowThickness(int v);
  Future<int> getEyebrowPosition();
  set eyebrowPosition(int v);

  // Makeup
  String? get makeupName;
  set makeupName(String? v);
  Future<double> getMakeupIntensityAsync();
  set makeupIntensity(double v);

  // Filter
  String? get filterName;
  set filterName(String? v);
  Future<double> getFilterStrengthAsync();
  set filterStrength(double v);

  // Sticker
  String? get stickerName;
  set stickerName(String? v);

  // Quality enable
  bool get qualityEnable;
  set qualityEnable(bool v);
  void setQualityEnableInternal(bool v);

  // Custom Makeup
  bool get customMakeupEnable;
  set customMakeupEnable(bool v);
  void setCustomMakeupEnableInternal(bool v);

  int get customLipstickStyle;
  set customLipstickStyle(int v);
  int get customLipstickColor;
  set customLipstickColor(int v);
  double get customLipstickStrength;
  set customLipstickStrength(double v);

  int get customBlushStyle;
  set customBlushStyle(int v);
  int get customBlushColor;
  set customBlushColor(int v);
  double get customBlushStrength;
  set customBlushStrength(double v);

  int get customFacialStyle;
  set customFacialStyle(int v);
  double get customFacialStrength;
  set customFacialStrength(double v);

  int get customEyeshadowStyle;
  set customEyeshadowStyle(int v);
  double get customEyeshadowStrength;
  set customEyeshadowStrength(double v);

  int get customEyebrowStyle;
  set customEyebrowStyle(int v);
  double get customEyebrowStrength;
  set customEyebrowStrength(double v);

  int get customLashStyle;
  set customLashStyle(int v);
  int get customLashColor;
  set customLashColor(int v);
  double get customLashStrength;
  set customLashStrength(double v);

  int get customPupilStyle;
  set customPupilStyle(int v);
  double get customPupilStrength;
  set customPupilStrength(double v);

  // Reset
  void resetBeauty([BeautyModule? module]);
  
  // Save
  void saveBeauty([BeautyModule? module]);
}
