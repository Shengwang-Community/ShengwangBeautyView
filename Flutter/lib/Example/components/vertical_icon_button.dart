// vertical_icon_button.dart
// Mirrors iOS VerticalButton — icon on top, label below

import 'package:flutter/material.dart';

class VerticalIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const VerticalIconButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
