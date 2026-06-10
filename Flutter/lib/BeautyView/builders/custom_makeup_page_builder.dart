// custom_makeup_page_builder.dart

import '../models/beauty_page_info.dart';
import '../builders/beauty_page_builder.dart';
import 'i_page_builder.dart';

const String _iconBase = 'assets/Icons/';

class CustomMakeupPageBuilder implements IPageBuilder {
  final BeautyConfig beautyConfig;

  CustomMakeupPageBuilder({required this.beautyConfig});

  @override
  Future<BeautyPageInfo> buildPage() async {
    final items = <BeautyItemInfo>[];

    final isEnabled = beautyConfig.customMakeupEnable;
    items.add(BeautyItemInfo(
      name: 'beauty_effect_enable',
      iconAsset: null,
      isSelected: isEnabled,
      showSlider: false,
      type: BeautyItemTypeToggle(isEnabled),
      onItemClick: (_) async {
        beautyConfig.customMakeupEnable = !beautyConfig.customMakeupEnable;
      },
    ));

    items.add(_buildCategory('beauty_custom_makeup_lipstick', 'beauty_ic_makeup_category_lipstick', _buildLipstickItems()));
    items.add(_buildCategory('beauty_custom_makeup_blush', 'beauty_ic_makeup_category_blush', _buildBlushItems()));
    items.add(_buildCategory('beauty_custom_makeup_contour', 'beauty_ic_makeup_category_contour', _buildContourItems()));
    items.add(_buildCategory('beauty_custom_makeup_eyeshadow', 'beauty_ic_makeup_category_shadow', _buildEyeshadowItems()));
    items.add(_buildCategory('beauty_custom_makeup_eyebrow', 'beauty_ic_makeup_category_eyebrow', _buildEyebrowItems()));
    items.add(_buildCategory('beauty_custom_makeup_lash', 'beauty_ic_makeup_category_lash', _buildLashItems()));
    items.add(_buildCategory('beauty_custom_makeup_pupil', 'beauty_ic_makeup_category_pupil', _buildPupilItems()));

    return BeautyPageInfo(
      name: 'beauty_group_custom_makeup',
      itemList: items,
      type: BeautyModule.styleMakeup,
    );
  }

  BeautyItemInfo _buildCategory(String name, String icon, List<BeautyItemInfo> subItems) {
    return BeautyItemInfo(
      name: name,
      iconAsset: '$_iconBase$icon.png',
      showSlider: false,
      type: const BeautyItemTypeSubMenu(),
      subItems: subItems,
    );
  }

  // ── Lipstick ──
  BeautyItemInfo _buildSubLipstick(String name, String icon, int style, int color) {
    return BeautyItemInfo(
      name: name, iconAsset: '$_iconBase$icon',
      value: beautyConfig.customLipstickStrength,
      isSelected: beautyConfig.customLipstickStyle == style,
      minValue: 0.0, maxValue: 1.0,
      itemStyle: style, itemColor: color,
      onValueChanged: (v) => beautyConfig.customLipstickStrength = v,
      onItemClick: (item) async {
        beautyConfig.setCustomMakeupEnableInternal(true);
        beautyConfig.customLipstickStyle = item.itemStyle;
        beautyConfig.customLipstickColor = item.itemColor;
        item.value = beautyConfig.customLipstickStrength;
      },
    );
  }

  List<BeautyItemInfo> _buildLipstickItems() => [
    BeautyItemInfo(name: 'beauty_effect_none', iconAsset: '${_iconBase}beauty_ic_none.png', isSelected: beautyConfig.customLipstickStyle == 0, showSlider: false, type: const BeautyItemTypeNone(), onItemClick: (_) async { beautyConfig.customLipstickStyle = 0; }),
    _buildSubLipstick('beauty_custom_makeup_lipstick_vibrant_orange', 'beauty_ic_makeup_lipstick_001.png', 1, 9),
    _buildSubLipstick('beauty_custom_makeup_lipstick_velvet_red', 'beauty_ic_makeup_lipstick_003.png', 1, 6),
    _buildSubLipstick('beauty_custom_makeup_lipstick_plum', 'beauty_ic_makeup_lipstick_004.png', 1, 3),
    _buildSubLipstick('beauty_custom_makeup_lipstick_pink', 'beauty_ic_makeup_lipstick_005.png', 1, 5),
    _buildSubLipstick('beauty_custom_makeup_lipstick_grapefruit', 'beauty_ic_makeup_lipstick_006.png', 1, 8),
  ];

  // ── Blush ──
  BeautyItemInfo _buildSubBlush(String name, String icon, int style, int color) {
    return BeautyItemInfo(
      name: name, iconAsset: '$_iconBase$icon',
      value: beautyConfig.customBlushStrength,
      isSelected: beautyConfig.customBlushStyle == style,
      minValue: 0.0, maxValue: 1.0,
      itemStyle: style, itemColor: color,
      onValueChanged: (v) => beautyConfig.customBlushStrength = v,
      onItemClick: (item) async {
        beautyConfig.setCustomMakeupEnableInternal(true);
        beautyConfig.customBlushStyle = item.itemStyle;
        beautyConfig.customBlushColor = item.itemColor;
        item.value = beautyConfig.customBlushStrength;
      },
    );
  }

  List<BeautyItemInfo> _buildBlushItems() => [
    BeautyItemInfo(name: 'beauty_effect_none', iconAsset: '${_iconBase}beauty_ic_none.png', isSelected: beautyConfig.customBlushStyle == 0, showSlider: false, type: const BeautyItemTypeNone(), onItemClick: (_) async { beautyConfig.customBlushStyle = 0; }),
    _buildSubBlush('beauty_custom_makeup_blush_powder', 'beauty_ic_makeup_blush_001.png', 1, 0),
    _buildSubBlush('beauty_custom_makeup_blush_peach', 'beauty_ic_makeup_blush_003.png', 3, 2),
    _buildSubBlush('beauty_custom_makeup_blush_tipsy', 'beauty_ic_makeup_blush_004.png', 2, 0),
    _buildSubBlush('beauty_custom_makeup_blush_enchanted', 'beauty_ic_makeup_blush_008.png', 8, 3),
    _buildSubBlush('beauty_custom_makeup_blush_cloud', 'beauty_ic_makeup_blush_010.png', 10, 0),
  ];

  // ── Contour ──
  BeautyItemInfo _buildSubFacial(String name, String icon, int style) {
    return BeautyItemInfo(
      name: name, iconAsset: '$_iconBase$icon',
      value: beautyConfig.customFacialStrength,
      isSelected: beautyConfig.customFacialStyle == style,
      minValue: 0.0, maxValue: 1.0, itemStyle: style,
      onValueChanged: (v) => beautyConfig.customFacialStrength = v,
      onItemClick: (item) async {
        beautyConfig.setCustomMakeupEnableInternal(true);
        beautyConfig.customFacialStyle = item.itemStyle;
        item.value = beautyConfig.customFacialStrength;
      },
    );
  }

  List<BeautyItemInfo> _buildContourItems() => [
    BeautyItemInfo(name: 'beauty_effect_none', iconAsset: '${_iconBase}beauty_ic_none.png', isSelected: beautyConfig.customFacialStyle == 0, showSlider: false, type: const BeautyItemTypeNone(), onItemClick: (_) async { beautyConfig.customFacialStyle = 0; }),
    _buildSubFacial('beauty_custom_makeup_contour_sculpt', 'beauty_ic_makeup_contour_001.png', 1),
    _buildSubFacial('beauty_custom_makeup_contour_even', 'beauty_ic_makeup_contour_009.png', 9),
    _buildSubFacial('beauty_custom_makeup_contour_plump', 'beauty_ic_makeup_contour_003.png', 3),
    _buildSubFacial('beauty_custom_makeup_contour_contour', 'beauty_ic_makeup_contour_006.png', 6),
    _buildSubFacial('beauty_custom_makeup_contour_highlight', 'beauty_ic_makeup_contour_008.png', 8),
  ];

  // ── Eyeshadow ──
  BeautyItemInfo _buildSubShadow(String name, String icon, int style) {
    return BeautyItemInfo(
      name: name, iconAsset: '$_iconBase$icon',
      value: beautyConfig.customEyeshadowStrength,
      isSelected: beautyConfig.customEyeshadowStyle == style,
      minValue: 0.0, maxValue: 1.0, itemStyle: style,
      onValueChanged: (v) => beautyConfig.customEyeshadowStrength = v,
      onItemClick: (item) async {
        beautyConfig.setCustomMakeupEnableInternal(true);
        beautyConfig.customEyeshadowStyle = item.itemStyle;
        item.value = beautyConfig.customEyeshadowStrength;
      },
    );
  }

  List<BeautyItemInfo> _buildEyeshadowItems() => [
    BeautyItemInfo(name: 'beauty_effect_none', iconAsset: '${_iconBase}beauty_ic_none.png', isSelected: beautyConfig.customEyeshadowStyle == 0, showSlider: false, type: const BeautyItemTypeNone(), onItemClick: (_) async { beautyConfig.customEyeshadowStyle = 0; }),
    _buildSubShadow('beauty_custom_makeup_eyeshadow_violet', 'beauty_ic_makeup_eyeshadow_001.png', 2),
    _buildSubShadow('beauty_custom_makeup_eyeshadow_rose', 'beauty_ic_makeup_eyeshadow_009.png', 9),
    _buildSubShadow('beauty_custom_makeup_eyeshadow_berry', 'beauty_ic_makeup_eyeshadow_003.png', 11),
    _buildSubShadow('beauty_custom_makeup_eyeshadow_earth', 'beauty_ic_makeup_eyeshadow_004.png', 4),
    _buildSubShadow('beauty_custom_makeup_eyeshadow_korean', 'beauty_ic_makeup_eyeshadow_005.png', 5),
    _buildSubShadow('beauty_custom_makeup_eyeshadow_apricot', 'beauty_ic_makeup_eyeshadow_007.png', 7),
  ];

  // ── Eyebrow ──
  BeautyItemInfo _buildSubEyebrow(String name, String icon, int style) {
    return BeautyItemInfo(
      name: name, iconAsset: '$_iconBase$icon',
      value: beautyConfig.customEyebrowStrength,
      isSelected: beautyConfig.customEyebrowStyle == style,
      minValue: 0.0, maxValue: 1.0, itemStyle: style,
      onValueChanged: (v) => beautyConfig.customEyebrowStrength = v,
      onItemClick: (item) async {
        beautyConfig.setCustomMakeupEnableInternal(true);
        beautyConfig.customEyebrowStyle = item.itemStyle;
        item.value = beautyConfig.customEyebrowStrength;
      },
    );
  }

  List<BeautyItemInfo> _buildEyebrowItems() => [
    BeautyItemInfo(name: 'beauty_effect_none', iconAsset: '${_iconBase}beauty_ic_none.png', isSelected: beautyConfig.customEyebrowStyle == 0, showSlider: false, type: const BeautyItemTypeNone(), onItemClick: (_) async { beautyConfig.customEyebrowStyle = 0; }),
    _buildSubEyebrow('beauty_custom_makeup_eyebrow_lady', 'beauty_ic_makeup_eyebrow_001.png', 1),
    _buildSubEyebrow('beauty_custom_makeup_eyebrow_gentle', 'beauty_ic_makeup_eyebrow_002.png', 2),
    _buildSubEyebrow('beauty_custom_makeup_eyebrow_standard', 'beauty_ic_makeup_eyebrow_003.png', 3),
    _buildSubEyebrow('beauty_custom_makeup_eyebrow_willow', 'beauty_ic_makeup_eyebrow_004.png', 4),
    _buildSubEyebrow('beauty_custom_makeup_eyebrow_fluffy', 'beauty_ic_makeup_eyebrow_005.png', 5),
    _buildSubEyebrow('beauty_custom_makeup_eyebrow_wild', 'beauty_ic_makeup_eyebrow_006.png', 6),
  ];

  // ── Lash ──
  BeautyItemInfo _buildSubLash(String name, String icon, int style, int color) {
    return BeautyItemInfo(
      name: name, iconAsset: '$_iconBase$icon',
      value: beautyConfig.customLashStrength,
      isSelected: beautyConfig.customLashStyle == style,
      minValue: 0.0, maxValue: 1.0,
      itemStyle: style, itemColor: color,
      onValueChanged: (v) => beautyConfig.customLashStrength = v,
      onItemClick: (item) async {
        beautyConfig.setCustomMakeupEnableInternal(true);
        beautyConfig.customLashStyle = item.itemStyle;
        beautyConfig.customLashColor = item.itemColor;
        item.value = beautyConfig.customLashStrength;
      },
    );
  }

  List<BeautyItemInfo> _buildLashItems() => [
    BeautyItemInfo(name: 'beauty_effect_none', iconAsset: '${_iconBase}beauty_ic_none.png', isSelected: beautyConfig.customLashStyle == 0, showSlider: false, type: const BeautyItemTypeNone(), onItemClick: (_) async { beautyConfig.customLashStyle = 0; }),
    _buildSubLash('beauty_custom_makeup_lash_delicate', 'beauty_ic_makeup_lash_002.png', 2, 1),
    _buildSubLash('beauty_custom_makeup_lash_wing', 'beauty_ic_makeup_lash_003.png', 3, 0),
    _buildSubLash('beauty_custom_makeup_lash_curly', 'beauty_ic_makeup_lash_004.png', 4, 1),
    _buildSubLash('beauty_custom_makeup_lash_comic', 'beauty_ic_makeup_lash_005.png', 5, 0),
    _buildSubLash('beauty_custom_makeup_lash_rise', 'beauty_ic_makeup_lash_009.png', 9, 1),
  ];

  // ── Pupil ──
  BeautyItemInfo _buildSubPupil(String name, String icon, int style) {
    return BeautyItemInfo(
      name: name, iconAsset: '$_iconBase$icon',
      value: beautyConfig.customPupilStrength,
      isSelected: beautyConfig.customPupilStyle == style,
      minValue: 0.0, maxValue: 1.0, itemStyle: style,
      onValueChanged: (v) => beautyConfig.customPupilStrength = v,
      onItemClick: (item) async {
        beautyConfig.setCustomMakeupEnableInternal(true);
        beautyConfig.customPupilStyle = item.itemStyle;
        item.value = beautyConfig.customPupilStrength;
      },
    );
  }

  List<BeautyItemInfo> _buildPupilItems() => [
    BeautyItemInfo(name: 'beauty_effect_none', iconAsset: '${_iconBase}beauty_ic_none.png', isSelected: beautyConfig.customPupilStyle == 0, showSlider: false, type: const BeautyItemTypeNone(), onItemClick: (_) async { beautyConfig.customPupilStyle = 0; }),
    _buildSubPupil('beauty_custom_makeup_pupil_hazel', 'beauty_ic_makeup_pupil_001.png', 1),
    _buildSubPupil('beauty_custom_makeup_pupil_skyblue', 'beauty_ic_makeup_pupil_002.png', 2),
    _buildSubPupil('beauty_custom_makeup_pupil_green', 'beauty_ic_makeup_pupil_003.png', 3),
    _buildSubPupil('beauty_custom_makeup_pupil_gray', 'beauty_ic_makeup_pupil_004.png', 4),
    _buildSubPupil('beauty_custom_makeup_pupil_mars', 'beauty_ic_makeup_pupil_005.png', 5),
    _buildSubPupil('beauty_custom_makeup_pupil_natural', 'beauty_ic_makeup_pupil_007.png', 7),
  ];
}
