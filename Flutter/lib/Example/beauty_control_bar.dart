// beauty_control_bar.dart
// Mirrors iOS ExampleViewController's right-side control stack.
//
// A vertical column of icon buttons pinned to the right edge, vertically
// centered. Overlay it on top of the video preview with a Stack.
//
// Usage:
//   Stack(children: [
//     videoPreview,
//     BeautyControlBar(
//       onBeautyTap: () { ... },
//       onSwitchCamera: () { ... },
//       onSave: () { ... },
//       onReset: () { ... },
//     ),
//   ])

import 'package:flutter/material.dart';
import 'components/vertical_icon_button.dart';
import '../Utils/beauty_localizer.dart';

class BeautyControlBar extends StatelessWidget {
  final VoidCallback onBeautyTap;
  final VoidCallback onSwitchCamera;
  final VoidCallback onSave;
  final VoidCallback onReset;
  final VoidCallback onJoinLeave;
  final bool isJoined;

  const BeautyControlBar({
    Key? key,
    required this.onBeautyTap,
    required this.onSwitchCamera,
    required this.onSave,
    required this.onReset,
    required this.onJoinLeave,
    required this.isJoined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            VerticalIconButton(
              icon: isJoined ? Icons.call_end : Icons.call,
              label: isJoined ? beautyLocalized('beauty_setting_leave') : beautyLocalized('beauty_setting_join'),
              onTap: onJoinLeave,
              color: isJoined ? Colors.redAccent : Colors.white,
            ),
            const SizedBox(height: 20),
            VerticalIconButton(
              assetIcon: 'assets/Icons/ic_beauty.png',
              label: beautyLocalized('beauty_setting_beauty'),
              onTap: onBeautyTap,
            ),
            const SizedBox(height: 20),
            VerticalIconButton(
              assetIcon: 'assets/Icons/ic_camera.png',
              label: beautyLocalized('beauty_setting_switch_camera'),
              onTap: onSwitchCamera,
            ),
            const SizedBox(height: 20),
            VerticalIconButton(
              assetIcon: 'assets/Icons/ic_save.png',
              label: beautyLocalized('beauty_setting_save'),
              onTap: onSave,
            ),
            const SizedBox(height: 20),
            VerticalIconButton(
              assetIcon: 'assets/Icons/ic_reset.png',
              label: beautyLocalized('beauty_setting_reset'),
              onTap: onReset,
            ),
          ],
        ),
      ),
    );
  }
}
