// filter_page_builder.dart
// Mirrors iOS FilterPageBuilder.swift

import '../models/beauty_page_info.dart';
import '../builders/beauty_page_builder.dart';
import 'i_page_builder.dart';

const String _iconBase = 'assets/Icons/';

class FilterPageBuilder implements IPageBuilder {
  final BeautyConfig beautyConfig;

  FilterPageBuilder({required this.beautyConfig});

  @override
  Future<BeautyPageInfo> buildPage() async {
    final items = <BeautyItemInfo>[];
    final currentStrength = await beautyConfig.getFilterStrengthAsync();

    // None
    items.add(BeautyItemInfo(
      name: 'beauty_effect_none',
      iconAsset: '${_iconBase}beauty_ic_none.png',
      isSelected: beautyConfig.filterName == null,
      showSlider: false,
      type: const BeautyItemTypeNone(),
      onItemClick: (_) async { beautyConfig.filterName = null; },
    ));

    _add(items, 'beauty_filter_serene', 'beauty_ic_filter_serene', 'Filter-Serene', currentStrength);
    _add(items, 'beauty_filter_urban', 'beauty_ic_filter_urban', 'Filter-Urban', currentStrength);
    _add(items, 'beauty_filter_glow', 'beauty_ic_filter_glow', 'Filter-Glow', currentStrength);
    _add(items, 'beauty_filter_gilt', 'beauty_ic_filter_gilt', 'Filter-Gilt', currentStrength);
    _add(items, 'beauty_filter_cream', 'beauty_ic_filter_cream', 'Filter-Cream', currentStrength);
    _add(items, 'beauty_filter_latte', 'beauty_ic_filter_latte', 'Filter-Latte', currentStrength);
    _add(items, 'beauty_filter_summer', 'beauty_ic_filter_summer', 'Filter-Summer', currentStrength);
    _add(items, 'beauty_filter_daily', 'beauty_ic_filter_daily', 'Filter-Daily', currentStrength);
    _add(items, 'beauty_filter_gentleman', 'beauty_ic_filter_genyleman', 'Filter-Gentleman', currentStrength);
    _add(items, 'beauty_filter_vanilla', 'beauty_ic_filter_vanila', 'Filter-Vanilla', currentStrength);
    _add(items, 'beauty_filter_bright', 'beauty_ic_filter_bright', 'Filter-Bright', currentStrength);
    _add(items, 'beauty_filter_peach', 'beauty_ic_filter_peach', 'Filter-Peach', currentStrength);
    _add(items, 'beauty_filter_ink', 'beauty_ic_filter_ink', 'Filter-Ink', currentStrength);
    _add(items, 'beauty_filter_film', 'beauty_ic_filter_film', 'Filter-Film', currentStrength);
    _add(items, 'beauty_filter_sunny', 'beauty_ic_filter_sunny', 'Filter-Sunny', currentStrength);
    _add(items, 'beauty_filter_comic', 'beauty_ic_filter_comic', 'Filter-Comic', currentStrength);
    _add(items, 'beauty_filter_dreamy', 'beauty_ic_filter_dreamy', 'Filter-Dreamy', currentStrength);
    _add(items, 'beauty_filter_cotton', 'beauty_ic_filter_cotton', 'Filter-Cotton', currentStrength);
    _add(items, 'beauty_filter_soda', 'beauty_ic_filter_soda', 'Filter-Soda', currentStrength);
    _add(items, 'beauty_filter_moonlight', 'beauty_ic_filter_moonlight', 'Filter-Moonlight', currentStrength);
    _add(items, 'beauty_filter_white_tea', 'beauty_ic_filter_whitetea', 'Filter-WhiteTea', currentStrength);
    _add(items, 'beauty_filter_tranquil', 'beauty_ic_filter_tranquil', 'Filter-Tranquil', currentStrength);
    _add(items, 'beauty_filter_insta_style', 'beauty_ic_filter_ins', 'Filter-Ins', currentStrength);
    _add(items, 'beauty_filter_street', 'beauty_ic_filter_street', 'Filter-Street', currentStrength);
    _add(items, 'beauty_filter_puff', 'beauty_ic_filter_puff', 'Filter-Puff', currentStrength);
    _add(items, 'beauty_filter_collection', 'beauty_ic_filter_collection', 'Filter-Collection', currentStrength);
    _add(items, 'beauty_filter_salty', 'beauty_ic_filter_salty', 'Filter-Salty', currentStrength);
    _add(items, 'beauty_filter_texture', 'beauty_ic_filter_texture', 'Filter-Texture', currentStrength);
    _add(items, 'beauty_filter_colorful', 'beauty_ic_filter_colorful', 'Filter-Colorful', currentStrength);
    _add(items, 'beauty_filter_snow', 'beauty_ic_filter_snow', 'Filter-Snow', currentStrength);
    _add(items, 'beauty_filter_blush', 'beauty_ic_filter_blush', 'Filter-Blush', currentStrength);
    _add(items, 'beauty_filter_nostalgia', 'beauty_ic_filter_nostalgia', 'Filter-Nostalgia', currentStrength);
    _add(items, 'beauty_filter_caramel', 'beauty_ic_filter_caramel', 'Filter-Caramel', currentStrength);
    _add(items, 'beauty_filter_tipsy', 'beauty_ic_filter_tipsy', 'Filter-Tipsy', currentStrength);
    _add(items, 'beauty_filter_lavender', 'beauty_ic_filter_lavender', 'Filter-Lavender', currentStrength);
    _add(items, 'beauty_filter_rouge', 'beauty_ic_filter_rouge', 'Filter-Rouge', currentStrength);
    _add(items, 'beauty_filter_misty', 'beauty_ic_filter_misty', 'Filter-Misty', currentStrength);

    return BeautyPageInfo(
      name: 'beauty_group_filter',
      itemList: items,
      type: BeautyModule.filter,
    );
  }

  void _add(List<BeautyItemInfo> items, String name, String icon, String filterName, double strength) {
    items.add(BeautyItemInfo(
      name: name,
      iconAsset: '$_iconBase$icon.png',
      value: beautyConfig.filterName == filterName ? strength : 0.0,
      isSelected: beautyConfig.filterName == filterName,
      minValue: 0.0,
      maxValue: 1.0,
      onValueChanged: (v) => beautyConfig.filterStrength = v,
      onItemClick: (itemInfo) async {
        beautyConfig.filterName = filterName;
        itemInfo.value = await beautyConfig.getFilterStrengthAsync();
      },
    ));
  }
}
