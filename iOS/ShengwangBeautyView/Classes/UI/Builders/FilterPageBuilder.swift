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
        addFilterItem(&filterItems, name: "beauty_filter_serene", icon: UIImage.beautyIcon(named: "beauty_ic_filter_serene"), filterName: FilterNames.serene)
        addFilterItem(&filterItems, name: "beauty_filter_urban", icon: UIImage.beautyIcon(named: "beauty_ic_filter_urban"), filterName: FilterNames.urban)
        addFilterItem(&filterItems, name: "beauty_filter_glow", icon: UIImage.beautyIcon(named: "beauty_ic_filter_glow"), filterName: FilterNames.glow)
        addFilterItem(&filterItems, name: "beauty_filter_gilt", icon: UIImage.beautyIcon(named: "beauty_ic_filter_gilt"), filterName: FilterNames.gilt)
        addFilterItem(&filterItems, name: "beauty_filter_cream", icon: UIImage.beautyIcon(named: "beauty_ic_filter_cream"), filterName: FilterNames.cream)
        addFilterItem(&filterItems, name: "beauty_filter_latte", icon: UIImage.beautyIcon(named: "beauty_ic_filter_latte"), filterName: FilterNames.latte)
        addFilterItem(&filterItems, name: "beauty_filter_summer", icon: UIImage.beautyIcon(named: "beauty_ic_filter_summer"), filterName: FilterNames.summer)
        addFilterItem(&filterItems, name: "beauty_filter_daily", icon: UIImage.beautyIcon(named: "beauty_ic_filter_daily"), filterName: FilterNames.daily)
        addFilterItem(&filterItems, name: "beauty_filter_gentleman", icon: UIImage.beautyIcon(named: "beauty_ic_filter_genyleman"), filterName: FilterNames.gentleman)
        addFilterItem(&filterItems, name: "beauty_filter_vanilla", icon: UIImage.beautyIcon(named: "beauty_ic_filter_vanila"), filterName: FilterNames.vanilla)
        addFilterItem(&filterItems, name: "beauty_filter_bright", icon: UIImage.beautyIcon(named: "beauty_ic_filter_bright"), filterName: FilterNames.bright)
        addFilterItem(&filterItems, name: "beauty_filter_peach", icon: UIImage.beautyIcon(named: "beauty_ic_filter_peach"), filterName: FilterNames.peach)
        addFilterItem(&filterItems, name: "beauty_filter_ink", icon: UIImage.beautyIcon(named: "beauty_ic_filter_ink"), filterName: FilterNames.ink)
        addFilterItem(&filterItems, name: "beauty_filter_film", icon: UIImage.beautyIcon(named: "beauty_ic_filter_film"), filterName: FilterNames.film)
        addFilterItem(&filterItems, name: "beauty_filter_sunny", icon: UIImage.beautyIcon(named: "beauty_ic_filter_sunny"), filterName: FilterNames.sunny)
        addFilterItem(&filterItems, name: "beauty_filter_comic", icon: UIImage.beautyIcon(named: "beauty_ic_filter_comic"), filterName: FilterNames.comic)
        addFilterItem(&filterItems, name: "beauty_filter_dreamy", icon: UIImage.beautyIcon(named: "beauty_ic_filter_dreamy"), filterName: FilterNames.dreamy)
        addFilterItem(&filterItems, name: "beauty_filter_cotton", icon: UIImage.beautyIcon(named: "beauty_ic_filter_cotton"), filterName: FilterNames.cotton)
        addFilterItem(&filterItems, name: "beauty_filter_soda", icon: UIImage.beautyIcon(named: "beauty_ic_filter_soda"), filterName: FilterNames.soda)
        addFilterItem(&filterItems, name: "beauty_filter_moonlight", icon: UIImage.beautyIcon(named: "beauty_ic_filter_moonlight"), filterName: FilterNames.moonlight)
        addFilterItem(&filterItems, name: "beauty_filter_white_tea", icon: UIImage.beautyIcon(named: "beauty_ic_filter_whitetea"), filterName: FilterNames.whiteTea)
        addFilterItem(&filterItems, name: "beauty_filter_tranquil", icon: UIImage.beautyIcon(named: "beauty_ic_filter_tranquil"), filterName: FilterNames.tranquil)
        addFilterItem(&filterItems, name: "beauty_filter_insta_style", icon: UIImage.beautyIcon(named: "beauty_ic_filter_ins"), filterName: FilterNames.instaStyle)
        addFilterItem(&filterItems, name: "beauty_filter_street", icon: UIImage.beautyIcon(named: "beauty_ic_filter_street"), filterName: FilterNames.street)
        addFilterItem(&filterItems, name: "beauty_filter_puff", icon: UIImage.beautyIcon(named: "beauty_ic_filter_puff"), filterName: FilterNames.puff)
        addFilterItem(&filterItems, name: "beauty_filter_collection", icon: UIImage.beautyIcon(named: "beauty_ic_filter_collection"), filterName: FilterNames.collection)
        addFilterItem(&filterItems, name: "beauty_filter_salty", icon: UIImage.beautyIcon(named: "beauty_ic_filter_salty"), filterName: FilterNames.salty)
        addFilterItem(&filterItems, name: "beauty_filter_texture", icon: UIImage.beautyIcon(named: "beauty_ic_filter_texture"), filterName: FilterNames.texture)
        addFilterItem(&filterItems, name: "beauty_filter_colorful", icon: UIImage.beautyIcon(named: "beauty_ic_filter_colorful"), filterName: FilterNames.colorful)
        addFilterItem(&filterItems, name: "beauty_filter_snow", icon: UIImage.beautyIcon(named: "beauty_ic_filter_snow"), filterName: FilterNames.snow)
        addFilterItem(&filterItems, name: "beauty_filter_blush", icon: UIImage.beautyIcon(named: "beauty_ic_filter_blush"), filterName: FilterNames.blush)
        addFilterItem(&filterItems, name: "beauty_filter_nostalgia", icon: UIImage.beautyIcon(named: "beauty_ic_filter_nostalgia"), filterName: FilterNames.nostalgia)
        addFilterItem(&filterItems, name: "beauty_filter_caramel", icon: UIImage.beautyIcon(named: "beauty_ic_filter_caramel"), filterName: FilterNames.caramel)
        addFilterItem(&filterItems, name: "beauty_filter_tipsy", icon: UIImage.beautyIcon(named: "beauty_ic_filter_tipsy"), filterName: FilterNames.tipsy)
        addFilterItem(&filterItems, name: "beauty_filter_lavender", icon: UIImage.beautyIcon(named: "beauty_ic_filter_lavender"), filterName: FilterNames.lavender)
        addFilterItem(&filterItems, name: "beauty_filter_rouge", icon: UIImage.beautyIcon(named: "beauty_ic_filter_rouge"), filterName: FilterNames.rouge)
        addFilterItem(&filterItems, name: "beauty_filter_misty", icon: UIImage.beautyIcon(named: "beauty_ic_filter_misty"), filterName: FilterNames.misty)
        
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
