//
//  MakeupPageBuilder.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import UIKit

/// Style makeup module page builder
/// Responsible for building page information for style makeup module
internal class MakeupPageBuilder: IPageBuilder {
    
    private let beautyConfig: ShengwangBeautySDK.BeautyConfig
    
    init(beautyConfig: ShengwangBeautySDK.BeautyConfig) {
        self.beautyConfig = beautyConfig
    }
    
    func buildPage() -> BeautyPageInfo {
        var makeupItems: [BeautyItemInfo] = []
        
        // None effect item
        makeupItems.append(
            BeautyItemInfo(
                name: "beauty_effect_none",
                icon: UIImage.beautyIcon(named: "beauty_ic_none"),
                isSelected: beautyConfig.makeupName == nil,
                showSlider: false,
                type: .none,
                onItemClick: { [weak self] _ in
                    self?.beautyConfig.makeupName = nil
                }
            )
        )
        
        // Style makeup options (only templates present in the material package)
        // Makeup-Young ✓
        addMakeupItem(&makeupItems, name: "beauty_makeup_young", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_young"), makeupName: MakeupNames.young)
        // Makeup-Mature — not in material package, commented out
//        addMakeupItem(&makeupItems, name: "beauty_makeup_mature", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_mature"), makeupName: MakeupNames.mature)
        // Makeup-Aura — not in material package, commented out
//        addMakeupItem(&makeupItems, name: "beauty_makeup_aura", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_aura"), makeupName: MakeupNames.aura)
        // Makeup-Natural ✓
        addMakeupItem(&makeupItems, name: "beauty_makeup_natural", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_natural"), makeupName: MakeupNames.natural)
        // Makeup-Graceful — not in material package, commented out
//        addMakeupItem(&makeupItems, name: "beauty_makeup_graceful", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_graceful"), makeupName: MakeupNames.graceful)
        // Makeup-Charm — not in material package, commented out
//        addMakeupItem(&makeupItems, name: "beauty_makeup_charm", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_charm"), makeupName: MakeupNames.charm)
        // Makeup-Perkey ✓
        addMakeupItem(&makeupItems, name: "beauty_makeup_perky", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_perky"), makeupName: MakeupNames.perky)
        // Makeup-Maiden — not in material package, commented out
//        addMakeupItem(&makeupItems, name: "beauty_makeup_maiden", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_maiden"), makeupName: MakeupNames.maiden)
        // Makeup-Insight — not in material package, commented out
//        addMakeupItem(&makeupItems, name: "beauty_makeup_insight", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_insight"), makeupName: MakeupNames.insight)
        // Makeup-Misty — not in material package, commented out
//        addMakeupItem(&makeupItems, name: "beauty_makeup_misty", icon: UIImage.beautyIcon(named: "beauty_ic_makeup_misty"), makeupName: MakeupNames.misty)
        
        return BeautyPageInfo(
            name: "beauty_group_makeup",
            itemList: makeupItems,
            type: .styleMakeup
        )
    }
    
    /// Add makeup option
    ///
    /// 1. On initialization:
    ///    - If currently selected is this template, use beautyConfig.makeupIntensity (will read from cache)
    ///    - If currently selected is not this template, read intensity value from cache for this template (if not found, display 0f)
    /// 2. When user drags slider: Update current template's intensity value (will sync update cache)
    /// 3. When user clicks to switch template:
    ///    - First get cached intensity value for this makeup (if user set it before)
    ///    - Switch makeup (makeupName), this will trigger SDK to set default intensity
    ///    - If cache has intensity value for this makeup (whether 0 or not), override SDK's default with cached value
    ///    - Update UI displayed intensity value to ensure UI matches SDK state
    ///
    /// Benefits of this design:
    /// - Each template's intensity value will be cached, maintaining user-set intensity when switching back
    /// - API layer manages cache uniformly, UI layer logic is simple and clear
    /// - Easy to maintain and understand
    private func addMakeupItem(
        _ items: inout [BeautyItemInfo],
        name: String,
        icon: UIImage?,
        makeupName: String
    ) {
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: beautyConfig.makeupIntensity * 100.0,  // 0.0~1.0 → 0~100
                isSelected: beautyConfig.makeupName == makeupName,
                valueRange: 0.0...100.0,
                // User drags slider: update intensity value (will sync update cache)
                onValueChanged: { [weak self] uiVal in
                    self?.beautyConfig.makeupIntensity = uiVal / 100.0  // 0~100 → 0.0~1.0
                },
                // User clicks to switch makeup
                onItemClick: { [weak self] itemInfo in
                    guard let self = self else { return }
                    
                    // 1. First get cached intensity value for this makeup (if user set it before)
                    let cachedIntensity = beautyConfig.getMakeupIntensityForTemplate(makeupName)
                    
                    // 2. Switch makeup (this will trigger SDK to set default intensity)
                    self.beautyConfig.makeupName = makeupName
                    
                    // 3. If cache has intensity value for this makeup (whether 0 or not), override SDK's default with cached value
                    //    This way when user switches back to previous makeup, it maintains previously set intensity value (including when user set to 0)
                    if let cached = cachedIntensity {
                        self.beautyConfig.makeupIntensity = cached
                    }
                    
                    // 4. Update UI displayed intensity value to ensure UI matches SDK state (convert to UI value)
                    itemInfo.value = self.beautyConfig.makeupIntensity * 100.0  // 0.0~1.0 → 0~100
                }
            )
        )
    }
}
