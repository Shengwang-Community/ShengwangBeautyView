// sticker_page_builder.dart
// Mirrors iOS StickerPageBuilder.swift

import '../models/beauty_page_info.dart';
import '../builders/beauty_page_builder.dart';
import 'i_page_builder.dart';

const String _iconBase = 'assets/Icons/';

class StickerPageBuilder implements IPageBuilder {
  final BeautyConfig beautyConfig;

  StickerPageBuilder({required this.beautyConfig});

  @override
  Future<BeautyPageInfo> buildPage() async {
    final items = <BeautyItemInfo>[];

    // None
    items.add(BeautyItemInfo(
      name: 'beauty_effect_none',
      iconAsset: '${_iconBase}beauty_ic_none.png',
      isSelected: beautyConfig.stickerName == null,
      showSlider: false,
      type: const BeautyItemTypeNone(),
      onItemClick: (_) async { beautyConfig.stickerName = null; },
    ));

    _add(items, 'beauty_sticker_christmas', 'beauty_ic_sticker_christmas', 'Sticker-Christmas');
    _add(items, 'beauty_sticker_squid', 'beauty_ic_sticker_squid', 'Sticker-Squid');
    _add(items, 'beauty_sticker_piggy', 'beauty_ic_sticker_piggy', 'Sticker-Piggy');
    _add(items, 'beauty_sticker_long_cat', 'beauty_ic_sticker_long_cat', 'Sticker-Longcat');
    _add(items, 'beauty_sticker_hairhoop', 'beauty_ic_sticker_hairhoop', 'Sticker-Hairhoop');
    _add(items, 'beauty_sticker_relax_time', 'beauty_ic_sticker_relax_time', 'Sticker-Relax');
    _add(items, 'beauty_sticker_cartoon_cat', 'beauty_ic_sticker_cartoon_cat', 'Sticker-Cartooncat');
    _add(items, 'beauty_sticker_butterfly', 'beauty_ic_sticker_butterfly', 'Sticker-Butterfly');
    _add(items, 'beauty_sticker_brush', 'beauty_ic_sticker_brush', 'Sticker-Brush');
    _add(items, 'beauty_sticker_cyber_glass', 'beauty_ic_sticker_cyber_glass', 'Sticker-Glass');
    _add(items, 'beauty_sticker_neon_tiara', 'beauty_ic_sticker_neon_tiara', 'Sticker-Tiara');
    _add(items, 'beauty_sticker_love_glass', 'beauty_ic_sticker_love_glass', 'Sticker-Love');

    return BeautyPageInfo(
      name: 'beauty_group_sticker',
      itemList: items,
      type: BeautyModule.sticker,
    );
  }

  void _add(List<BeautyItemInfo> items, String name, String icon, String stickerName) {
    items.add(BeautyItemInfo(
      name: name,
      iconAsset: '$_iconBase$icon.png',
      isSelected: beautyConfig.stickerName == stickerName,
      showSlider: false,
      onItemClick: (_) async { beautyConfig.stickerName = stickerName; },
    ));
  }
}
