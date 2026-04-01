// beauty_page_info.dart
// Mirrors iOS BeautyPageInfo.swift + BeautyModule + BeautyItemType

/// Beauty module type
/// Corresponds to Agora RTC SDK's VIDEO_EFFECT_NODE_ID
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

/// Beauty page information
class BeautyPageInfo {
  /// Page name (localization key)
  final String name;
  /// Item list
  List<BeautyItemInfo> itemList;
  /// Whether selected (for Tab switching)
  bool isSelected;
  /// Page type
  final BeautyModule type;

  BeautyPageInfo({
    required this.name,
    required this.itemList,
    this.isSelected = false,
    this.type = BeautyModule.beauty,
  });
}

/// Beauty item information
class BeautyItemInfo {
  /// Item name (localization key)
  final String name;
  /// Item icon asset path
  final String? iconAsset;
  /// Current value
  double value;
  /// Whether selected
  bool isSelected;
  /// Value range (for slider)
  final double minValue;
  final double maxValue;
  /// Value change callback (triggered when slider is released)
  void Function(double value)? onValueChanged;
  /// Whether to show slider
  final bool showSlider;
  /// Item type
  final BeautyItemType type;
  /// Click callback
  Future<void> Function(BeautyItemInfo item)? onItemClick;

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
  });
}
