//
//  ItemListView.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import UIKit

/// Item list view component
/// Encapsulates UICollectionView to display items for a single page
class ItemListView: UIView {
    
    // MARK: - Properties
    
    /// Page index
    let pageIndex: Int
    
    /// Page information
    private var pageInfo: BeautyPageInfo
    
    /// Callback when selected item changes
    var onSelectedChanged: ((Int, Int) -> Void)? // pageIndex, itemIndex
    
    /// Callback when item is clicked
    var onItemClick: ((Int, Int) -> Void)? // pageIndex, itemIndex
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        // Register different cell types based on item type and module type
        collectionView.register(BeautyItemCell.self, forCellWithReuseIdentifier: "BeautyItemCell")
        collectionView.register(BeautyImageItemCell.self, forCellWithReuseIdentifier: "BeautyImageItemCell")
        collectionView.register(BeautyToggleCell.self, forCellWithReuseIdentifier: "BeautyToggleCell")
        return collectionView
    }()
    
    // MARK: - Initialization
    
    init(pageIndex: Int, pageInfo: BeautyPageInfo) {
        self.pageIndex = pageIndex
        self.pageInfo = pageInfo
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .clear
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Update selected item on first load
        updateSelectedItem()
    }
    
    // MARK: - Public Methods
    
    /// Update page information
    /// - Parameter pageInfo: New page information
    func updatePageInfo(_ pageInfo: BeautyPageInfo) {
        self.pageInfo = pageInfo
        collectionView.reloadData()
        updateSelectedItem()
    }
    
    /// Update a specific item at the given index
    /// - Parameters:
    ///   - index: Item index
    ///   - itemInfo: Updated item info (optional, if nil will use current itemInfo from pageInfo)
    func updateItem(at index: Int, with itemInfo: BeautyItemInfo? = nil) {
        guard index < pageInfo.itemList.count else { return }
        let indexPath = IndexPath(item: index, section: 0)
        let updatedItemInfo = itemInfo ?? pageInfo.itemList[index]
        
        // Update pageInfo if itemInfo is provided
        if let itemInfo = itemInfo {
            let updatedPageInfo = pageInfo
            updatedPageInfo.itemList[index] = itemInfo
            pageInfo = updatedPageInfo
        }
        
        // Try to get the visible cell and update it directly
        if let cell = collectionView.cellForItem(at: indexPath) {
            if let toggleCell = cell as? BeautyToggleCell {
                toggleCell.configure(with: updatedItemInfo)
            } else if let imageCell = cell as? BeautyImageItemCell {
                imageCell.configure(with: updatedItemInfo)
            } else if let normalCell = cell as? BeautyItemCell {
                normalCell.configure(with: updatedItemInfo)
            }
        } else {
            // If cell is not visible, reload it
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    /// Update selected item and scroll to it
    private func updateSelectedItem() {
        // Find selected item index
        if let selectedItemIndex = pageInfo.itemList.firstIndex(where: { $0.isSelected }) {
            // Scroll to selected item
            let indexPath = IndexPath(item: selectedItemIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            // Trigger selected changed callback
            onSelectedChanged?(pageIndex, selectedItemIndex)
        } else if !pageInfo.itemList.isEmpty {
            // If no item is selected, select the first one
            pageInfo.itemList[0].isSelected = true
            collectionView.reloadData()
            
            let indexPath = IndexPath(item: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            // Trigger selected changed callback
            onSelectedChanged?(pageIndex, 0)
        }
    }
    
    /// Handle item click
    /// - Parameters:
    ///   - itemIndex: Item index
    private func onItemClickInternal(itemIndex: Int) {
        // Just forward the click to the parent view controller
        // The parent will handle state updates and callbacks
        onItemClick?(pageIndex, itemIndex)
    }
}

// MARK: - UICollectionViewDataSource

extension ItemListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageInfo.itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < pageInfo.itemList.count else {
            // Fallback to default cell
            return collectionView.dequeueReusableCell(withReuseIdentifier: "BeautyItemCell", for: indexPath)
        }
        
        let itemInfo = pageInfo.itemList[indexPath.item]
        
        // Use different cell types based on item type and module type
        if itemInfo.type.isToggle {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautyToggleCell", for: indexPath) as! BeautyToggleCell
            cell.configure(with: itemInfo)
            cell.onItemClick = { [weak self] in
                self?.onItemClickInternal(itemIndex: indexPath.item)
            }
            return cell
        } else if (pageInfo.type == .filter || pageInfo.type == .sticker || pageInfo.type == .styleMakeup) && itemInfo.type == .normal {
            // Use image item cell for Filter/Sticker/Makeup modules with normal items
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautyImageItemCell", for: indexPath) as! BeautyImageItemCell
            cell.configure(with: itemInfo)
            cell.onItemClick = { [weak self] in
                self?.onItemClickInternal(itemIndex: indexPath.item)
            }
            return cell
        } else {
            // Use standard cell for beauty module and other cases
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeautyItemCell", for: indexPath) as! BeautyItemCell
            cell.configure(with: itemInfo)
            cell.onItemClick = { [weak self] in
                self?.onItemClickInternal(itemIndex: indexPath.item)
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ItemListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.item < pageInfo.itemList.count else {
            return CGSize(width: 52, height: 70)
        }
        
        let itemInfo = pageInfo.itemList[indexPath.item]
        let text = itemInfo.name.localized
        let nsString = text as NSString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
        let size = nsString.size(withAttributes: attributes)
        let width = max(68, size.width + 8)
        return CGSize(width: width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    }
}

