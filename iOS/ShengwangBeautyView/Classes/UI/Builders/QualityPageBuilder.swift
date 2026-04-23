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
        qualityItems.append(
            BeautyItemInfo(
                name: "beauty_effect_enable",
                icon: nil,
                isSelected: isEnabled,
                showSlider: false,
                type: .toggle(isEnabled),
                onItemClick: { [weak self] _ in
                    guard let self = self else { return }
                    self.beautyConfig.qualityEnable = !self.beautyConfig.qualityEnable
                }
            )
        )
        
        // 色温
        addQualityItem(&qualityItems, name: "beauty_effect_temperature", icon: UIImage.beautyIcon(named: "beauty_ic_effect_temperature"), value: beautyConfig.temperature) { [weak self] value in
            self?.beautyConfig.temperature = value
        }
        
        // 色调
        addQualityItem(&qualityItems, name: "beauty_effect_hue", icon: UIImage.beautyIcon(named: "beauty_ic_effect_hue"), value: beautyConfig.hue) { [weak self] value in
            self?.beautyConfig.hue = value
        }

        // 亮度
        addQualityItem(&qualityItems, name: "beauty_effect_brightness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_brightness"), value: beautyConfig.brightness) { [weak self] value in
            self?.beautyConfig.brightness = value
        }
        
        // 饱和度
        addQualityItem(&qualityItems, name: "beauty_effect_saturation", icon: UIImage.beautyIcon(named: "beauty_ic_effect_saturation"), value: beautyConfig.saturation) { [weak self] value in
            self?.beautyConfig.saturation = value
        }

        // 对比度
        addQualityItem(&qualityItems, name: "beauty_effect_contrast_factor", icon: UIImage.beautyIcon(named: "beauty_ic_effect_contrast_strength"), value: beautyConfig.contrastFactor) { [weak self] value in
            self?.beautyConfig.contrastFactor = value
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
        onValueChanged: @escaping (Float) -> Void
    ) {
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: value,
                valueRange: valueRange,
                onValueChanged: onValueChanged
            )
        )
    }
}
