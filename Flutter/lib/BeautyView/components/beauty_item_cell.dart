// beauty_item_cell.dart
// Mirrors iOS BeautyItemCell.swift + BeautyImageItemCell + BeautyToggleCell

import 'package:flutter/material.dart';
import '../models/beauty_page_info.dart';
import '../../Utils/beauty_colors.dart';
import '../../Utils/beauty_localizer.dart';

// ---------------------------------------------------------------------------
// BeautyItemCell — icon inside a rounded border container (beauty module)
// ---------------------------------------------------------------------------
class BeautyItemCell extends StatelessWidget {
  final BeautyItemInfo itemInfo;
  final VoidCallback onTap;


  const BeautyItemCell({
    Key? key,
    required this.itemInfo,
    required this.onTap,
  
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = itemInfo.isSelected;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? BeautyColors.mainAccent
                      : BeautyColors.itemBorderUnselected,
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: itemInfo.iconAsset != null
                    ? Image.asset(
                        itemInfo.iconAsset!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      )
                    : const SizedBox(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              beautyLocalized(itemInfo.name),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BeautyImageItemCell — full-bleed image (filter / makeup / sticker)
// ---------------------------------------------------------------------------
class BeautyImageItemCell extends StatelessWidget {
  final BeautyItemInfo itemInfo;
  final VoidCallback onTap;


  const BeautyImageItemCell({
    Key? key,
    required this.itemInfo,
    required this.onTap,
  
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = itemInfo.isSelected;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? BeautyColors.mainAccent
                      : BeautyColors.itemBorderUnselected,
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: itemInfo.iconAsset != null
                    ? Image.asset(
                        itemInfo.iconAsset!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              beautyLocalized(itemInfo.name),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BeautyToggleCell — on/off switcher icon
// ---------------------------------------------------------------------------
class BeautyToggleCell extends StatelessWidget {
  final BeautyItemInfo itemInfo;
  final VoidCallback onTap;


  const BeautyToggleCell({
    Key? key,
    required this.itemInfo,
    required this.onTap,
  
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnabled = itemInfo.type is BeautyItemTypeToggle
        ? (itemInfo.type as BeautyItemTypeToggle).isEnabled
        : false;

    final iconAsset = isEnabled
        ? 'assets/Icons/beauty_switcher_on.png'
        : 'assets/Icons/beauty_switcher_off.png';

    final label = isEnabled
        ? beautyLocalized('beauty_effect_enable')
        : beautyLocalized('beauty_effect_disable');

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Image.asset(
                  iconAsset,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
