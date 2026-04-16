// beauty_colors.dart
// Mirrors iOS UIColor+Beauty.swift

import 'package:flutter/material.dart';

class BeautyColors {
  BeautyColors._();

  /// Main accent color (selected border, slider track, indicator)
  static const Color mainAccent = Color(0xFF1890FF);

  /// Dark semi-transparent background for the panel container
  static const Color darkCoverBg = Color(0xE6191919); // ~90% opacity

  /// Tab deselected text color
  static const Color tabDeselect = Color(0x99FFFFFF); // white 60%

  /// Tab selected text color
  static const Color tabSelect = Color(0xFFFFFFFF);

  /// Slider track (unselected portion)
  static const Color sliderTint = Color(0x33FFFFFF); // white 20%

  /// Item border (unselected)
  static const Color itemBorderUnselected = Color(0x14FFFFFF); // white 8%
}
