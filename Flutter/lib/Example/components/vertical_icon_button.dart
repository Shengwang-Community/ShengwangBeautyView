// vertical_icon_button.dart
// Mirrors iOS VerticalButton — icon on top, label below

import 'package:flutter/material.dart';

class VerticalIconButton extends StatelessWidget {
  final IconData? icon;
  final String? assetIcon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const VerticalIconButton({
    Key? key,
    this.icon,
    this.assetIcon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  })  : assert(icon != null || assetIcon != null, 'Provide either icon or assetIcon'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assetIcon != null)
            Image.asset(assetIcon!, width: 24, height: 24, color: color)
          else
            Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
