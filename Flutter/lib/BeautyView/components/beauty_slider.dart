// beauty_slider.dart
// Mirrors iOS BeautySlider.swift

import 'package:flutter/material.dart';
import '../models/beauty_page_info.dart';
import '../../Utils/beauty_colors.dart';

/// Custom slider with a floating value label that follows the thumb.
/// Throttles callbacks during drag (50ms), fires final value on release.
class BeautySlider extends StatefulWidget {
  final BeautyItemInfo itemInfo;

  const BeautySlider({Key? key, required this.itemInfo}) : super(key: key);

  @override
  State<BeautySlider> createState() => _BeautySliderState();
}

class _BeautySliderState extends State<BeautySlider> {
  late double _value;
  DateTime _lastCallbackTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const _throttleMs = 50;

  bool get _isIntegerRange => widget.itemInfo.maxValue > 1.0;

  @override
  void initState() {
    super.initState();
    _value = widget.itemInfo.value.clamp(
      widget.itemInfo.minValue,
      widget.itemInfo.maxValue,
    );
  }

  @override
  void didUpdateWidget(BeautySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemInfo != widget.itemInfo) {
      setState(() {
        _value = widget.itemInfo.value.clamp(
          widget.itemInfo.minValue,
          widget.itemInfo.maxValue,
        );
      });
    }
  }

  String get _labelText {
    if (_isIntegerRange) {
      return _value.toInt().toString();
    }
    final floored = (_value * 10) / 10;
    return floored.toStringAsFixed(1);
  }

  void _onChanged(double v) {
    setState(() => _value = v);
    final now = DateTime.now();
    if (now.difference(_lastCallbackTime).inMilliseconds >= _throttleMs) {
      _lastCallbackTime = now;
      _fireCallback(v);
    }
  }

  void _onChangeEnd(double v) {
    final finalValue = _isIntegerRange ? v.roundToDouble() : v;
    setState(() => _value = finalValue);
    _fireCallback(finalValue);
  }

  void _fireCallback(double v) {
    final val = _isIntegerRange ? v.roundToDouble() : v;
    widget.itemInfo.value = val;
    widget.itemInfo.onValueChanged?.call(val);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Value label row — aligns with slider thumb via LayoutBuilder
        LayoutBuilder(builder: (context, constraints) {
          final trackWidth = constraints.maxWidth - 28.0; // thumb radius offset
          final ratio = (widget.itemInfo.maxValue - widget.itemInfo.minValue) == 0
              ? 0.0
              : (_value - widget.itemInfo.minValue) /
                  (widget.itemInfo.maxValue - widget.itemInfo.minValue);
          final thumbX = 14.0 + ratio * trackWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const SizedBox(height: 17, width: double.infinity),
              Positioned(
                left: thumbX - 14,
                top: 0,
                child: SizedBox(
                  width: 28,
                  child: Text(
                    _labelText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 3),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: BeautyColors.mainAccent,
            inactiveTrackColor: BeautyColors.sliderTint,
            thumbColor: Colors.white,
            overlayColor: BeautyColors.mainAccent.withOpacity(0.2),
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: _value,
            min: widget.itemInfo.minValue,
            max: widget.itemInfo.maxValue,
            divisions: null,
            onChanged: _onChanged,
            onChangeEnd: _onChangeEnd,
          ),
        ),
      ],
    );
  }
}
