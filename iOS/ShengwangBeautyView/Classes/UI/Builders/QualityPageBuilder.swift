//
//  QualityPageBuilder.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import UIKit

/// Image quality module page builder
/// Responsible for building page information for image quality (temperature, hue, saturation, brightness) module
internal class QualityPageBuilder: IPageBuilder {
    
    private let beautyConfig: ShengwangBeautySDK.BeautyConfig
    
    init(beautyConfig: ShengwangBeautySDK.BeautyConfig) {
        self.beautyConfig = beautyConfig
    }
    
    func buildPage() -> BeautyPageInfo {
        var qualityItems: [BeautyItemInfo] = []

        let isEnabled = beautyConfig.qualityEnable
        let toggleItem = BeautyItemInfo(
            name: "beauty_effect_enable",
            icon: nil,
            isSelected: beautyConfig.qualityEnable,
            showSlider: false,
            type: .toggle(isEnabled),
            onItemClick: { [weak self] _ in
                guard let self = self else { return }
                self.beautyConfig.qualityEnable = !self.beautyConfig.qualityEnable
            }
        )
        qualityItems.append(toggleItem)
        
        // 色温
        addQualityItem(&qualityItems, name: "beauty_effect_temperature", icon: UIImage.beautyIcon(named: "beauty_ic_effect_temperature"), value: beautyConfig.temperature, toggleItem: toggleItem) { [weak self] value in
            self?.beautyConfig.temperature = value
        }
        
        // 色调
        addQualityItem(&qualityItems, name: "beauty_effect_hue", icon: UIImage.beautyIcon(named: "beauty_ic_effect_hue"), value: beautyConfig.hue, toggleItem: toggleItem) { [weak self] value in
            self?.beautyConfig.hue = value
        }

        // 亮度
        addQualityItem(&qualityItems, name: "beauty_effect_brightness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_brightness"), value: beautyConfig.brightness, toggleItem: toggleItem) { [weak self] value in
            self?.beautyConfig.brightness = value
        }
        
        // 饱和度
        addQualityItem(&qualityItems, name: "beauty_effect_saturation", icon: UIImage.beautyIcon(named: "beauty_ic_effect_saturation"), value: beautyConfig.saturation, toggleItem: toggleItem) { [weak self] value in
            self?.beautyConfig.saturation = value
        }
        
        return BeautyPageInfo(
            name: "beauty_group_quality",
            itemList: qualityItems,
            type: .beauty
        )
    }
    
    // MARK: - Helper Methods
    
    private func addQualityItem(
        _ items: inout [BeautyItemInfo],
        name: String,
        icon: UIImage?,
        value: Float,
        valueRange: ClosedRange<Float> = -1.0...1.0,
        toggleItem: BeautyItemInfo,
        onValueChanged: @escaping (Float) -> Void
    ) {
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: value * 50.0,  // -1.0~1.0 → -50~50
                valueRange: -50.0...50.0,
                onValueChanged: { uiVal in
                    onValueChanged(uiVal / 50.0)  // -50~50 → -1.0~1.0
                },
                onItemClick: { [weak self] itemInfo in
                    guard let self = self else { return }
                    self.beautyConfig.setQualityEnableInternal(true)
                    // Update toggle item's type so the cell renders as "on"
                    toggleItem.type = .toggle(true)
                }
            )
        )
    }
}
