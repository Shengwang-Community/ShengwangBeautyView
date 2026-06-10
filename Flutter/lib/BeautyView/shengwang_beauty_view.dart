// shengwang_beauty_view.dart

import 'package:flutter/material.dart';
import 'models/beauty_page_info.dart';
import 'builders/beauty_page_builder.dart';
import 'builders/custom_makeup_page_builder.dart';
import 'builders/quality_page_builder.dart';
import 'builders/filter_page_builder.dart';
import 'builders/sticker_page_builder.dart';
import 'components/beauty_segment_view.dart';
import 'components/beauty_slider.dart';
import 'components/item_list_view.dart';
import 'shengwang_beauty_sdk.dart';
import '../Utils/beauty_colors.dart';
import '../Utils/beauty_localizer.dart';

class ShengwangBeautyView extends StatefulWidget {
  final BeautyConfig beautyConfig;
  final List<BeautyPageInfo> Function(BeautyConfig config)? pageListBuilder;

  const ShengwangBeautyView({
    Key? key,
    required this.beautyConfig,
    this.pageListBuilder,
  }) : super(key: key);

  @override
  State<ShengwangBeautyView> createState() => _ShengwangBeautyViewState();
}

class _ShengwangBeautyViewState extends State<ShengwangBeautyView> {
  late List<BeautyPageInfo> _pageList;
  int _currentPageIndex = 0;
  BeautyItemInfo? _selectedItem;

  // Sub-menu state
  bool _isInSubMenu = false;
  String _subMenuTitle = '';
  int _subMenuPageIndex = -1;

  late final BeautyPageBuilder _beautyBuilder;
  late final QualityPageBuilder _qualityBuilder;
  late final CustomMakeupPageBuilder _customMakeupBuilder;
  late final FilterPageBuilder _filterBuilder;
  late final StickerPageBuilder _stickerBuilder;

  @override
  void initState() {
    super.initState();
    _beautyBuilder = BeautyPageBuilder(beautyConfig: widget.beautyConfig);
    _qualityBuilder = QualityPageBuilder(beautyConfig: widget.beautyConfig);
    _customMakeupBuilder = CustomMakeupPageBuilder(beautyConfig: widget.beautyConfig);
    _filterBuilder = FilterPageBuilder(beautyConfig: widget.beautyConfig);
    _stickerBuilder = StickerPageBuilder(beautyConfig: widget.beautyConfig);

    _pageList = [];
    _buildPageListAsync().then((pages) {
      if (mounted) setState(() => _pageList = pages);
      _updateSelectedItemForPage(_currentPageIndex);
    });

    ShengwangBeautySDK.instance.beautyStateListener = () {
      if (mounted) refreshPageList();
    };
  }

  @override
  void dispose() {
    ShengwangBeautySDK.instance.beautyStateListener = null;
    super.dispose();
  }

  Future<List<BeautyPageInfo>> _buildPageListAsync() async {
    if (widget.pageListBuilder != null) {
      return widget.pageListBuilder!(widget.beautyConfig);
    }
    return [
      await _beautyBuilder.buildPage(),
      await _qualityBuilder.buildPage(),
      await _customMakeupBuilder.buildPage(),
      await _filterBuilder.buildPage(),
      await _stickerBuilder.buildPage(),
    ];
  }

  void refreshPageList() {
    final savedIndex = _currentPageIndex;
    _buildPageListAsync().then((pages) {
      if (!mounted) return;
      setState(() => _pageList = pages);
      if (savedIndex < _pageList.length) {
        _updateSelectedItemForPage(savedIndex);
      }
    });
  }

  void _updateSelectedItemForPage(int pageIndex) {
    if (pageIndex >= _pageList.length) return;
    final page = _pageList[pageIndex];
    final idx = page.itemList.indexWhere((e) => e.isSelected);
    setState(() {
      _selectedItem = idx >= 0 ? page.itemList[idx] : null;
    });
  }

  void _onSelectedChanged(int pageIndex, int itemIndex) {
    final item = _pageList[pageIndex].itemList[itemIndex];
    setState(() {
      _selectedItem = item.showSlider ? item : null;
    });
  }

  void _onItemClick(int pageIndex, int itemIndex) async {
    final page = _pageList[pageIndex];
    final item = page.itemList[itemIndex];
    final type = item.type;

    if (type is BeautyItemTypeReset) {
      widget.beautyConfig.resetBeauty(BeautyModule.beauty);
      refreshPageList();
      return;
    }

    if (type is BeautyItemTypeToggle) {
      await item.onItemClick?.call(item);
      // Toggle handled by onItemClick callback (triggers refreshPageList via notifyStateChanged)
      return;
    }

    if (type is BeautyItemTypeSubMenu) {
      final subItems = item.subItems;
      if (subItems != null && subItems.isNotEmpty) {
        setState(() {
          page.parentItemList = page.itemList;
          page.itemList = subItems;
          _isInSubMenu = true;
          _subMenuTitle = beautyLocalized(item.name);
          _subMenuPageIndex = pageIndex;
          _selectedItem = null;
        });
      }
      return;
    }

    // Normal / None
    await item.onItemClick?.call(item);

    for (final i in page.itemList) {
      i.isSelected = false;
    }
    item.isSelected = true;

    setState(() {});
    _onSelectedChanged(pageIndex, itemIndex);
  }

  void _onSubMenuBack() {
    setState(() {
      _isInSubMenu = false;
      _subMenuTitle = '';
    });
    // Rebuild page list to get latest toggle state
    refreshPageList();
  }

  void _onTabSelected(int index) {
    setState(() => _currentPageIndex = index);
    _updateSelectedItemForPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final titles = _pageList.map((p) => beautyLocalized(p.name)).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slider
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: (_selectedItem != null && _selectedItem!.showSlider)
              ? Padding(
                  key: ValueKey(_selectedItem!.name),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: BeautySlider(itemInfo: _selectedItem!),
                )
              : const SizedBox(key: ValueKey('empty'), height: 0),
        ),
        const SizedBox(height: 10),
        // Panel
        Container(
          decoration: const BoxDecoration(
            color: BeautyColors.darkCoverBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Tab bar OR Sub-menu bar
              _isInSubMenu ? _buildSubMenuBar() : BeautySegmentView(
                titles: titles,
                selectedIndex: _currentPageIndex,
                onTabSelected: _onTabSelected,
              ),
              // Item pages
              SizedBox(
                height: 104,
                child: IndexedStack(
                  index: _currentPageIndex,
                  children: List.generate(_pageList.length, (index) {
                    return ItemListView(
                      pageIndex: index,
                      pageInfo: _pageList[index],
                      onSelectedChanged: _onSelectedChanged,
                      onItemClick: _onItemClick,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubMenuBar() {
    return SizedBox(
      height: 35,
      child: Row(
        children: [
          const SizedBox(width: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onSubMenuBack,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/Icons/beauty_ic_back.png',
                width: 24, height: 24,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                _subMenuTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // balance the back button
        ],
      ),
    );
  }
}
