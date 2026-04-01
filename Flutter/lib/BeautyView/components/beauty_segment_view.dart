// beauty_segment_view.dart
// Mirrors iOS BeautySegmentView.swift

import 'package:flutter/material.dart';
import '../../Utils/beauty_colors.dart';

/// Tab bar with animated underline indicator.
class BeautySegmentView extends StatefulWidget {
  final List<String> titles;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const BeautySegmentView({
    Key? key,
    required this.titles,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<BeautySegmentView> createState() => _BeautySegmentViewState();
}

class _BeautySegmentViewState extends State<BeautySegmentView> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  @override
  void didUpdateWidget(BeautySegmentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.titles.length != widget.titles.length) {
      _syncKeys();
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _syncKeys() {
    while (_tabKeys.length < widget.titles.length) {
      _tabKeys.add(GlobalKey());
    }
    while (_tabKeys.length > widget.titles.length) {
      _tabKeys.removeLast();
    }
  }

  void _scrollToSelected() {
    if (widget.selectedIndex < 0 ||
        widget.selectedIndex >= _tabKeys.length) return;
    final key = _tabKeys[widget.selectedIndex];
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        alignment: 0.5, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(widget.titles.length, (index) {
            final isSelected = index == widget.selectedIndex;
            return GestureDetector(
              key: _tabKeys[index],
              onTap: () => widget.onTabSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.titles[index],
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? BeautyColors.tabSelect
                            : BeautyColors.tabDeselect,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: 2,
                      width: isSelected ? 30 : 0,
                      decoration: BoxDecoration(
                        color: BeautyColors.tabSelect,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
