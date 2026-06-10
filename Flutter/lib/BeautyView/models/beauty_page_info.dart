// beauty_page_info.dart

/// Beauty module type
enum BeautyModule {
  beauty,       // value: 1
  styleMakeup,  // value: 2
  filter,       // value: 4
  sticker,      // value: 8
}

/// Beauty item type
abstract class BeautyItemType {
  const BeautyItemType();
}

class BeautyItemTypeNormal extends BeautyItemType {
  const BeautyItemTypeNormal();
}

class BeautyItemTypeToggle extends BeautyItemType {
  final bool isEnabled;
  const BeautyItemTypeToggle(this.isEnabled);
}

class BeautyItemTypeReset extends BeautyItemType {
  const BeautyItemTypeReset();
}

class BeautyItemTypeNone extends BeautyItemType {
  const BeautyItemTypeNone();
}

class BeautyItemTypeSubMenu extends BeautyItemType {
  const BeautyItemTypeSubMenu();
}

class BeautyItemTypeBack extends BeautyItemType {
  const BeautyItemTypeBack();
}

/// Beauty page information
class BeautyPageInfo {
  final String name;
  List<BeautyItemInfo> itemList;
  /// Parent item list — saved when drilling into a sub-menu, restored on back
  List<BeautyItemInfo>? parentItemList;
  bool isSelected;
  final BeautyModule type;

  BeautyPageInfo({
    required this.name,
    required this.itemList,
    this.parentItemList,
    this.isSelected = false,
    this.type = BeautyModule.beauty,
  });
}

/// Beauty item information
class BeautyItemInfo {
  String name;
  String? iconAsset;
  double value;
  bool isSelected;
  final double minValue;
  final double maxValue;
  void Function(double value)? onValueChanged;
  final bool showSlider;
  BeautyItemType type;
  Future<void> Function(BeautyItemInfo item)? onItemClick;
  /// Sub-items for hierarchical menus
  final List<BeautyItemInfo>? subItems;
  /// Sub-item style (for custom makeup SDK style param)
  final int itemStyle;
  /// Sub-item color (for custom makeup SDK color param)
  final int itemColor;

  BeautyItemInfo({
    required this.name,
    this.iconAsset,
    this.value = 0.0,
    this.isSelected = false,
    this.minValue = 0.0,
    this.maxValue = 1.0,
    this.onValueChanged,
    this.showSlider = true,
    this.type = const BeautyItemTypeNormal(),
    this.onItemClick,
    this.subItems,
    this.itemStyle = 0,
    this.itemColor = 0,
  });
}
