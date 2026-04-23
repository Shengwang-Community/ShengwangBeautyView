//
//  FilterPageBuilder.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import UIKit

/// Filter module page builder
/// Responsible for building page information for filter module
internal class FilterPageBuilder: IPageBuilder {
    
    private let beautyConfig: ShengwangBeautySDK.BeautyConfig
    
    init(beautyConfig: ShengwangBeautySDK.BeautyConfig) {
        self.beautyConfig = beautyConfig
    }
    
    func buildPage() -> BeautyPageInfo {
        var filterItems: [BeautyItemInfo] = []
        
        // None effect item
        filterItems.append(
            BeautyItemInfo(
                name: "beauty_effect_none",
                icon: UIImage.beautyIcon(named: "beauty_ic_none"),
                isSelected: beautyConfig.filterName == nil,
                showSlider: false,
                type: .none,
                onItemClick: { [weak self] _ in
                    self?.beautyConfig.filterName = nil
                }
            )
        )
        
        // Filter options
        addFilterItem(&filterItems, name: "beauty_filter_ct", icon: UIImage.beautyIcon(named: "beauty_ic_filter_serene"), filterName: FilterNames.ct)
        addFilterItem(&filterItems, name: "beauty_filter_nuanhuang", icon: UIImage.beautyIcon(named: "beauty_ic_filter_urban"), filterName: FilterNames.nuanhuang)
        addFilterItem(&filterItems, name: "beauty_filter_lvtu", icon: UIImage.beautyIcon(named: "beauty_ic_filter_glow"), filterName: FilterNames.lvtu)
        addFilterItem(&filterItems, name: "beauty_filter_meishijiaopian", icon: UIImage.beautyIcon(named: "beauty_ic_filter_gilt"), filterName: FilterNames.meishijiaopian)
        addFilterItem(&filterItems, name: "beauty_filter_landiaojiaopian", icon: UIImage.beautyIcon(named: "beauty_ic_filter_cream"), filterName: FilterNames.landiaojiaopian)
        addFilterItem(&filterItems, name: "beauty_filter_riza", icon: UIImage.beautyIcon(named: "beauty_ic_filter_latte"), filterName: FilterNames.riza)
        addFilterItem(&filterItems, name: "beauty_filter_jingdu", icon: UIImage.beautyIcon(named: "beauty_ic_filter_summer"), filterName: FilterNames.jingdu)
        addFilterItem(&filterItems, name: "beauty_filter_aizhicheng", icon: UIImage.beautyIcon(named: "beauty_ic_filter_daily"), filterName: FilterNames.aizhicheng)
        addFilterItem(&filterItems, name: "beauty_filter_mitao", icon: UIImage.beautyIcon(named: "beauty_ic_filter_genyleman"), filterName: FilterNames.mitao)
        addFilterItem(&filterItems, name: "beauty_filter_heijin", icon: UIImage.beautyIcon(named: "beauty_ic_filter_vanila"), filterName: FilterNames.heijin)
        addFilterItem(&filterItems, name: "beauty_filter_luolita", icon: UIImage.beautyIcon(named: "beauty_ic_filter_bright"), filterName: FilterNames.luolita)
        
        return BeautyPageInfo(
            name: "beauty_group_filter",
            itemList: filterItems,
            type: .filter
        )
    }
    
    /// Add filter option
    ///
    /// 1. On initialization: Use current selected filter's strength value (will read from cache)
    /// 2. When user drags slider: Update current filter's strength value (will sync update cache)
    /// 3. When user clicks to switch filter:
    ///    - First get cached strength value for this filter (if user set it before)
    ///    - Switch filter (filterName), this will trigger SDK to set default strength
    ///    - If cache has strength value for this filter (whether 0 or not), override SDK's default with cached value
    ///    - Update UI displayed strength value to ensure UI matches SDK state
    ///
    /// Benefits of this design:
    /// - Each filter's strength value will be cached, maintaining user-set strength when switching back
    /// - API layer manages cache uniformly, UI layer logic is simple and clear
    /// - Easy to maintain and understand
    private func addFilterItem(
        _ items: inout [BeautyItemInfo],
        name: String,
        icon: UIImage?,
        filterName: String
    ) {
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: beautyConfig.filterStrength,
                isSelected: beautyConfig.filterName == filterName,
                valueRange: 0.0...1.0,
                // User drags slider: update strength value (will sync update cache)
                onValueChanged: { [weak self] value in
                    self?.beautyConfig.filterStrength = value
                },
                // User clicks to switch filter
                onItemClick: { [weak self] itemInfo in
                    guard let self = self else { return }
                    
                    // 1. First get cached strength value for this filter (if user set it before)
                    let cachedStrength = beautyConfig.getFilterStrengthForTemplate(filterName)
                    
                    // 2. Switch filter (this will trigger SDK to set default strength)
                    self.beautyConfig.filterName = filterName
                    
                    // 3. If cache has strength value for this filter (whether 0 or not), override SDK's default with cached value
                    //    This way when user switches back to previous filter, it maintains previously set strength value (including when user set to 0)
                    if let cached = cachedStrength {
                        self.beautyConfig.filterStrength = cached
                    }
                    
                    // 4. Update UI displayed strength value to ensure UI matches SDK state
                    itemInfo.value = self.beautyConfig.filterStrength
                }
            )
        )
    }
}
