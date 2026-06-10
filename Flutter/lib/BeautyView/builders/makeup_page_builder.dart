// makeup_page_builder.dart
// Mirrors iOS MakeupPageBuilder.swift

import '../models/beauty_page_info.dart';
import '../builders/beauty_page_builder.dart';
import 'i_page_builder.dart';

const String _iconBase = 'assets/Icons/';

class MakeupPageBuilder implements IPageBuilder {
  final BeautyConfig beautyConfig;

  MakeupPageBuilder({required this.beautyConfig});

  @override
  Future<BeautyPageInfo> buildPage() async {
    final items = <BeautyItemInfo>[];
    final currentIntensity = await beautyConfig.getMakeupIntensityAsync();

    // None
    items.add(BeautyItemInfo(
      name: 'beauty_effect_none',
      iconAsset: '${_iconBase}beauty_ic_none.png',
      isSelected: beautyConfig.makeupName == null,
      showSlider: false,
      type: const BeautyItemTypeNone(),
      onItemClick: (_) async { beautyConfig.makeupName = null; },
    ));

    _add(items, 'beauty_makeup_young', 'beauty_ic_makeup_young', 'Makeup-Young', currentIntensity);
    _add(items, 'beauty_makeup_mature', 'beauty_ic_makeup_mature', 'Makeup-Mature', currentIntensity);
    _add(items, 'beauty_makeup_aura', 'beauty_ic_makeup_aura', 'Makeup-Aura', currentIntensity);
    _add(items, 'beauty_makeup_natural', 'beauty_ic_makeup_natural', 'Makeup-Natural', currentIntensity);
    _add(items, 'beauty_makeup_graceful', 'beauty_ic_makeup_graceful', 'Makeup-Graceful', currentIntensity);
    _add(items, 'beauty_makeup_charm', 'beauty_ic_makeup_charm', 'Makeup-Charm', currentIntensity);
    _add(items, 'beauty_makeup_perky', 'beauty_ic_makeup_perky', 'Makeup-Perkey', currentIntensity);
    _add(items, 'beauty_makeup_maiden', 'beauty_ic_makeup_maiden', 'Makeup-Maiden', currentIntensity);
    _add(items, 'beauty_makeup_insight', 'beauty_ic_makeup_insight', 'Makeup-Insight', currentIntensity);
    _add(items, 'beauty_makeup_misty', 'beauty_ic_makeup_misty', 'Makeup-Misty', currentIntensity);

    return BeautyPageInfo(
      name: 'beauty_group_makeup',
      itemList: items,
      type: BeautyModule.styleMakeup,
    );
  }

  void _add(List<BeautyItemInfo> items, String name, String icon, String makeupName, double intensity) {
    final uiValue = beautyConfig.makeupName == makeupName ? intensity * 100.0 : 0.0;
    items.add(BeautyItemInfo(
      name: name,
      iconAsset: '$_iconBase$icon.png',
      value: uiValue,
      isSelected: beautyConfig.makeupName == makeupName,
      minValue: 0.0,
      maxValue: 100.0,
      onValueChanged: (uiVal) => beautyConfig.makeupIntensity = uiVal / 100.0,
      onItemClick: (itemInfo) async {
        beautyConfig.makeupName = makeupName;
        final sdkValue = await beautyConfig.getMakeupIntensityAsync();
        itemInfo.value = sdkValue * 100.0;
      },
    ));
  }
}
