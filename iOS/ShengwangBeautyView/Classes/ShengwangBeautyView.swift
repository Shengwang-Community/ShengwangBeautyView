//
//  BeautyView.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import UIKit

/// Shengwang Beauty Control View
/// Specifically designed for Shengwang beauty control interface
///
/// Supports:
/// - Module-level switch: Quickly remove entire first-level menu modules
/// - Atomic capability-level simplification: Hide specific parameters within modules
///
/// Design principles:
/// - UI components establish 1:1 mapping with SDK API, avoiding secondary encapsulation in intermediate layers
/// - Value conversion is done at the UI layer, values passed to SDK are in the original range expected by SDK
/// - Ensure UI performance is fully synchronized with algorithm effects
@objc public class ShengwangBeautyView: UIView {
    
    // MARK: - Properties
    
    /// Direct access to configuration using ShengwangBeautySDK.beautyConfig
    private var beautyConfig: ShengwangBeautySDK.BeautyConfig {
        return ShengwangBeautySDK.shared.beautyConfig
    }
    
    // MARK: - Builder Instances
    
    /// Builder instances stored as properties to avoid being released
    private lazy var beautyBuilder: BeautyPageBuilder = {
        BeautyPageBuilder(beautyConfig: beautyConfig)
    }()
    
    private lazy var makeupBuilder: MakeupPageBuilder = {
        MakeupPageBuilder(beautyConfig: beautyConfig)
    }()
    
    private lazy var filterBuilder: FilterPageBuilder = {
        FilterPageBuilder(beautyConfig: beautyConfig)
    }()
    
    private lazy var stickerBuilder: StickerPageBuilder = {
        StickerPageBuilder(beautyConfig: beautyConfig)
    }()
    
    /// Page list
    /// 
    /// Note: External assignment (e.g., refreshPageList()) will trigger didSet and update UI.
    public var pageList: [BeautyPageInfo] = [] {
        didSet {
            let oldCount = oldValue.count
            let newCount = pageList.count
            if oldCount != newCount {
                modifyPageListUI()
            } else {
                refreshPageListUI()
            }
        }
    }
    
    // MARK: - UI Components
    
    private lazy var slider: BeautySlider = {
        let slider = BeautySlider()
        slider.isHidden = true
        return slider
    }()
    
    private lazy var segmentView: BeautySegmentView = {
        let segmentView = BeautySegmentView()
        segmentView.onTabSelected = { [weak self] index in
            self?.onTabSelected(index)
        }
        return segmentView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    
    private var containerView = UIView()
    
    private var itemListViewList: [ItemListView] = []
    private var itemListViewLayoutConstraints: [NSLayoutConstraint] = []
    private var currentPageIndex: Int = 0
    private var currentItemIndex: Int = 0
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        pageList = onPageListCreate()
        setupUIComponents()
    }
    
    private func setupUIComponents() {
        containerView.backgroundColor = .beauty_dark_cover_bg
        
        addSubview(slider)
        addSubview(containerView)
        containerView.addSubview(segmentView)
        containerView.addSubview(scrollView)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        segmentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: topAnchor),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            slider.heightAnchor.constraint(equalToConstant: 30),
            containerView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            segmentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            segmentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            segmentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            segmentView.heightAnchor.constraint(equalToConstant: 35),
            scrollView.topAnchor.constraint(equalTo: segmentView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        containerView.setRoundingCorners([.topLeft, .topRight], radius: 20)
        let scrollViewHeight = scrollView.bounds.height
        if scrollViewHeight > 0 {
            scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(itemListViewList.count), height: scrollViewHeight)
        }
        layoutItemListViews()
    }
    
    // MARK: - Lifecycle
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview != nil {
            ShengwangBeautySDK.shared.beautyStateListener = { [weak self] in
                self?.refreshPageList()
            }
        } else {
            ShengwangBeautySDK.shared.beautyStateListener = nil
        }
    }
    
    // MARK: - Page List Creation
    
    /// Create page list
    /// Subclasses can override this method to customize page list
    internal func onPageListCreate() -> [BeautyPageInfo] {
        var pages: [BeautyPageInfo] = []
        
        pages.append(beautyBuilder.buildPage())
        pages.append(makeupBuilder.buildPage())
        pages.append(filterBuilder.buildPage())
        pages.append(stickerBuilder.buildPage())
        
        return pages
    }
    
    // MARK: - Public Methods
    
    /// Refresh page list
    /// Re-call onPageListCreate() to generate page list and update UI display
    ///
    /// Note: This method will trigger page list reconstruction, which may cause current selected state to be lost
    /// It is recommended to call when configuration changes, not frequently
    ///
    /// Fix: After refresh, restore scroll view to previous page position and update slider for selected item
    @objc public func refreshPageList() {
        // Save current selected page index
        let savedPageIndex = currentPageIndex
        pageList = onPageListCreate()
        
        // Fix: Restore scroll view to previous page position after refresh
        if savedPageIndex >= 0 && savedPageIndex < pageList.count {
            scrollToPage(at: savedPageIndex, animated: false)
            currentPageIndex = savedPageIndex
            // Update slider for selected item of new page
            updateSelectedItemForPage(at: savedPageIndex)
        }
    }
    
    /// Callback when selected item changes
    /// - Parameters:
    ///   - pageIndex: Page index
    ///   - itemIndex: Item index
    internal func onSelectedChanged(pageIndex: Int, itemIndex: Int) {
        let pageInfo = pageList[pageIndex]
        let itemInfo = pageInfo.itemList[itemIndex]
        
        if itemInfo.showSlider {
            setupSlider(itemInfo)
            slider.isHidden = false
        } else {
            slider.isHidden = true
        }
    }
    
    /// Handle item click
    /// - Parameters:
    ///   - pageIndex: Page index
    ///   - itemIndex: Item index
    private func onItemClick(pageIndex: Int, itemIndex: Int) {
        let pageInfo = pageList[pageIndex]
        let itemInfo = pageInfo.itemList[itemIndex]
        
        switch itemInfo.type {
        case .reset:
            // Handle reset item: reset parameters and refresh page list
            beautyConfig.resetBeauty()
            refreshPageList()
            
        case .toggle(let isEnabled):
            // Handle toggle item: toggle beauty and face shape state
            if isEnabled {
                beautyConfig.beautyEnable = false
                beautyConfig.faceShapeEnable = false
            } else {
                beautyConfig.beautyEnable = true
                beautyConfig.faceShapeEnable = true
            }
        case .normal, .none:
            // Call item-specific onClick callback for normal items (updates config like stickerName, filterName, etc.)
            itemInfo.onItemClick?(itemInfo)
            
            // Normal parameter item: update selected state and trigger selected changed callback
            let previouslySelectedItem = pageInfo.itemList.firstIndex { item in
                item.isSelected
            }
            if let prevIndex = previouslySelectedItem {
                pageInfo.itemList[prevIndex].isSelected = false
            }
            
            itemInfo.isSelected = true
            itemListViewList[pageIndex].updatePageInfo(pageInfo)
            currentItemIndex = itemIndex
            onSelectedChanged(pageIndex: pageIndex, itemIndex: itemIndex)
        }
    }
    
    /// Setup slider parameters and listeners
    /// - Parameter itemInfo: Item information, including value range, current value, etc.
    ///
    /// Note:
    /// - All listeners will be cleared first to avoid triggering callbacks when setting values
    /// - Value change listener only updates UI during sliding, does not trigger business callbacks
    /// - Business callbacks are only triggered when user releases the slider
    private func setupSlider(_ itemInfo: BeautyItemInfo) {
        slider.configure(with: itemInfo)
    }
    
    /// Reset operation:
    /// Reset to default parameter values in the template.
    ///
    /// Note: After save and reset operations, they will automatically take effect the next time addOrUpdate loads the node
    /// - Parameter type: Page type (corresponds to SDK VIDEO_EFFECT_NODE_ID)
    public func resetBeauty(_ type: BeautyModule = .beauty) {
        beautyConfig.resetBeauty(type)
        refreshPageList()
    }
    
    /// Reset beauty by module raw value (for Objective-C). Raw values: 1=beauty, 2=styleMakeup, 4=filter, 8=sticker.
    @objc public func resetBeauty(typeRawValue: UInt) {
        let type = BeautyModule(rawValue: typeRawValue) ?? .beauty
        resetBeauty(type)
    }
    
    /// Save operation:
    /// Save the parameters adjusted by the anchor to local storage, and the next time addOrUpdate loads the node,
    /// it will automatically call the previously saved parameters.
    ///
    /// Note: After save and reset operations, they will automatically take effect the next time addOrUpdate loads the node
    /// - Parameter type: Page type (corresponds to SDK VIDEO_EFFECT_NODE_ID)
    public func saveBeauty(_ type: BeautyModule = .beauty) {
        beautyConfig.saveBeauty(type)
    }
    
    /// Save beauty by module raw value (for Objective-C). Raw values: 1=beauty, 2=styleMakeup, 4=filter, 8=sticker.
    @objc public func saveBeauty(typeRawValue: UInt) {
        let type = BeautyModule(rawValue: typeRawValue) ?? .beauty
        saveBeauty(type)
    }
    
    // MARK: - Private Methods
    
    /// Modify UI: Reorganize views (called when pageList count changes)
    /// Will recreate or remove ItemListView, and re-layout
    private func modifyPageListUI() {
        let selectedPageIndex: Int
        if currentPageIndex < pageList.count {
            selectedPageIndex = currentPageIndex
        } else if let index = pageList.firstIndex(where: { $0.isSelected }) {
            selectedPageIndex = index
            currentPageIndex = index
        } else if !pageList.isEmpty {
            selectedPageIndex = 0
            currentPageIndex = 0
            updatePageSelectionState(to: 0)
        } else {
            selectedPageIndex = 0
        }
        
        segmentView.titles = pageList.map { $0.name.localized }
        segmentView.selectedIndex = selectedPageIndex
        
        // Reorganize views: remove excess, create new, update existing
        let oldCount = itemListViewList.count
        let newCount = pageList.count
        
        // Remove excess views
        if oldCount > newCount {
            for i in newCount..<oldCount {
                itemListViewList[i].removeFromSuperview()
            }
            itemListViewList.removeLast(oldCount - newCount)
        }
        
        // Update existing views or create new views
        for (index, pageInfo) in pageList.enumerated() {
            if index < itemListViewList.count {
                itemListViewList[index].updatePageInfo(pageInfo)
            } else {
                let itemListView = ItemListView(pageIndex: index, pageInfo: pageInfo)
                itemListView.onSelectedChanged = { [weak self] pageIndex, itemIndex in
                    self?.onSelectedChanged(pageIndex: pageIndex, itemIndex: itemIndex)
                }
                itemListView.onItemClick = { [weak self] pageIndex, itemIndex in
                    self?.onItemClick(pageIndex: pageIndex, itemIndex: itemIndex)
                }
                
                scrollView.addSubview(itemListView)
                itemListViewList.append(itemListView)
            }
        }
        
        layoutItemListViews()
        scrollToPage(at: selectedPageIndex, animated: false)
        updateSelectedItemForPage(at: selectedPageIndex)
    }
    
    /// Refresh UI: Only refresh data (called when pageList count remains unchanged)
    /// Only updates existing ItemListView data, does not recreate views, does not change current selected page
    private func refreshPageListUI() {
        // Update segmentView titles (data may have changed)
        segmentView.titles = pageList.map { $0.name.localized }
        
        // Only refresh data: update all existing ItemListView data
        for (index, pageInfo) in pageList.enumerated() {
            if index < itemListViewList.count {
                itemListViewList[index].updatePageInfo(pageInfo)
            }
        }
        
        // Update selected item for current page
        updateSelectedItemForPage(at: currentPageIndex)
    }
    
    /// Layout all item list views in scroll view using constraints
    private func layoutItemListViews() {
        guard !itemListViewList.isEmpty else { return }
        NSLayoutConstraint.deactivate(itemListViewLayoutConstraints)
        itemListViewLayoutConstraints.removeAll()
        for (index, itemListView) in itemListViewList.enumerated() {
            itemListView.translatesAutoresizingMaskIntoConstraints = false
            var list: [NSLayoutConstraint] = [
                itemListView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                itemListView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                itemListView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ]
            if index == 0 {
                list.append(itemListView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor))
            } else {
                list.append(itemListView.leadingAnchor.constraint(equalTo: itemListViewList[index - 1].trailingAnchor))
            }
            if index == itemListViewList.count - 1 {
                list.append(itemListView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor))
            }
            itemListViewLayoutConstraints.append(contentsOf: list)
        }
        NSLayoutConstraint.activate(itemListViewLayoutConstraints)
    }
    
    /// Scroll to specific page
    /// - Parameters:
    ///   - index: Page index
    ///   - animated: Whether to animate the scroll
    private func scrollToPage(at index: Int, animated: Bool) {
        let targetOffsetX = CGFloat(index) * scrollView.bounds.width
        scrollView.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
    }
    
    /// Update page selection state internally
    /// - Parameter index: Index of the page to select
    private func updatePageSelectionState(to index: Int) {
        for i in 0..<pageList.count {
            pageList[i].isSelected = (i == index)
        }
        
        currentPageIndex = index
    }
    
    private func updateSelectedItem() {
        updateSelectedItemForPage(at: currentPageIndex)
    }
    
    private func updateSelectedItemForPage(at pageIndex: Int) {
        let pageInfo = pageList[pageIndex]
        
        if let selectedItemIndex = pageInfo.itemList.firstIndex(where: { $0.isSelected }) {
            currentItemIndex = selectedItemIndex
            if pageIndex == currentPageIndex {
                onSelectedChanged(pageIndex: pageIndex, itemIndex: currentItemIndex)
            }
        } else {
            if pageIndex == currentPageIndex {
                slider.isHidden = true
            }
        }
    }
    
    private func onTabSelected(_ index: Int) {
        updatePageSelectionState(to: index)
        segmentView.selectedIndex = index
        scrollToPage(at: index, animated: true)
        currentPageIndex = index
        updateSelectedItemForPage(at: index)
    }
}


