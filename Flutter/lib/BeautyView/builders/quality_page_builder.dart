// quality_page_builder.dart

import '../models/beauty_page_info.dart';
import '../builders/beauty_page_builder.dart';
import 'i_page_builder.dart';

const String _iconBase = 'assets/Icons/';

class QualityPageBuilder implements IPageBuilder {
  final BeautyConfig beautyConfig;

  QualityPageBuilder({required this.beautyConfig});

  @override
  Future<BeautyPageInfo> buildPage() async {
    final items = <BeautyItemInfo>[];

    // Toggle
    final isEnabled = beautyConfig.qualityEnable;
    final toggleItem = BeautyItemInfo(
      name: 'beauty_effect_enable',
      iconAsset: null,
      isSelected: isEnabled,
      showSlider: false,
      type: BeautyItemTypeToggle(isEnabled),
      onItemClick: (_) async {
        beautyConfig.qualityEnable = !beautyConfig.qualityEnable;
      },
    );
    items.add(toggleItem);

    // 色温
    _addQualityItem(items, 'beauty_effect_temperature', 'beauty_ic_effect_temperature',
        await beautyConfig.getTemperatureAsync(), toggleItem,
        onChanged: (v) => beautyConfig.temperature = v);
    // 色调
    _addQualityItem(items, 'beauty_effect_hue', 'beauty_ic_effect_hue',
        await beautyConfig.getHueAsync(), toggleItem,
        onChanged: (v) => beautyConfig.hue = v);
    // 亮度
    _addQualityItem(items, 'beauty_effect_brightness', 'beauty_ic_effect_brightness',
        await beautyConfig.getBrightnessAsync(), toggleItem,
        onChanged: (v) => beautyConfig.brightness = v);
    // 饱和度
    _addQualityItem(items, 'beauty_effect_saturation', 'beauty_ic_effect_saturation',
        await beautyConfig.getSaturationAsync(), toggleItem,
        onChanged: (v) => beautyConfig.saturation = v);

    return BeautyPageInfo(
      name: 'beauty_group_quality',
      itemList: items,
      type: BeautyModule.beauty,
    );
  }

  /// UI 显示换算规则：SDK 值范围 -1.0~1.0 → UI 显示 -50~50（整数）
  void _addQualityItem(
    List<BeautyItemInfo> items,
    String name,
    String icon,
    double value,
    BeautyItemInfo toggleItem, {
    required void Function(double) onChanged,
  }) {
    items.add(BeautyItemInfo(
      name: name,
      iconAsset: '$_iconBase$icon.png',
      value: value * 50.0,  // -1.0~1.0 → -50~50
      minValue: -50.0,
      maxValue: 50.0,
      onValueChanged: (uiVal) {
        onChanged(uiVal / 50.0);  // -50~50 → -1.0~1.0
      },
      onItemClick: (itemInfo) async {
        beautyConfig.setQualityEnableInternal(true);
        toggleItem.type = const BeautyItemTypeToggle(true);
        toggleItem.name = 'beauty_effect_enable';
      },
    ));
  }
}
