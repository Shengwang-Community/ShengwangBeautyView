// item_list_view.dart
// Mirrors iOS ItemListView.swift

import 'package:flutter/material.dart';
import '../models/beauty_page_info.dart';
import 'beauty_item_cell.dart';

/// Horizontal scrolling list of beauty items for a single page.
class ItemListView extends StatefulWidget {
  final int pageIndex;
  final BeautyPageInfo pageInfo;
  final void Function(int pageIndex, int itemIndex) onSelectedChanged;
  final void Function(int pageIndex, int itemIndex) onItemClick;

  const ItemListView({
    Key? key,
    required this.pageIndex,
    required this.pageInfo,
    required this.onSelectedChanged,
    required this.onItemClick,
  }) : super(key: key);

  @override
  State<ItemListView> createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(ItemListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  void _syncKeys() {
    final count = widget.pageInfo.itemList.length;
    while (_itemKeys.length < count) _itemKeys.add(GlobalKey());
    while (_itemKeys.length > count) _itemKeys.removeLast();
  }

  void _scrollToSelected() {
    final idx = widget.pageInfo.itemList.indexWhere((e) => e.isSelected);
    if (idx < 0 || idx >= _itemKeys.length) return;
    final ctx = _itemKeys[idx].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx,
        alignment: 0.5, duration: const Duration(milliseconds: 300));
  }

  void _handleItemClick(int itemIndex) {
    widget.onItemClick(widget.pageIndex, itemIndex);
  }

  Widget _buildCell(int index) {
    final item = widget.pageInfo.itemList[index];
    final key = _itemKeys[index];

    if (item.type is BeautyItemTypeToggle) {
      return BeautyToggleCell(
        key: key,
        itemInfo: item,
        onTap: () => _handleItemClick(index),
      );
    }

    final isImageModule = widget.pageInfo.type == BeautyModule.filter ||
        widget.pageInfo.type == BeautyModule.sticker ||
        widget.pageInfo.type == BeautyModule.styleMakeup;

    if (isImageModule && item.type is BeautyItemTypeNormal) {
      return BeautyImageItemCell(
        key: key,
        itemInfo: item,
        onTap: () => _handleItemClick(index),
      );
    }

    return BeautyItemCell(
      key: key,
      itemInfo: item,
      onTap: () => _handleItemClick(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(widget.pageInfo.itemList.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildCell(index),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
