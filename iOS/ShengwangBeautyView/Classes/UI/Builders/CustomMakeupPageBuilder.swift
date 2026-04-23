//
//  CustomMakeupPageBuilder.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import UIKit

/// Custom makeup module page builder
/// Responsible for building page information for custom makeup module
/// with a two-level hierarchical menu structure:
/// - Level 1: Categories (lipstick, blush, contour, eyeshadow, eyebrow, pupil)
/// - Level 2: Sub-options for each category
///
/// Note: This builder is an internal implementation, not exposed externally
internal class CustomMakeupPageBuilder: IPageBuilder {
    
    private let beautyConfig: ShengwangBeautySDK.BeautyConfig
    
    init(beautyConfig: ShengwangBeautySDK.BeautyConfig) {
        self.beautyConfig = beautyConfig
    }
    
    func buildPage() -> BeautyPageInfo {
        var items: [BeautyItemInfo] = []
        
        // Toggle item: enable/disable all custom makeup
        let isEnabled = beautyConfig.customMakeupEnable
        items.append(
            BeautyItemInfo(
                name: "beauty_effect_enable",
                icon: nil,
                isSelected: beautyConfig.customMakeupEnable,
                showSlider: false,
                type: .toggle(isEnabled),
                onItemClick: { [weak self] _ in
                    guard let self = self else { return }
                    self.beautyConfig.customMakeupEnable = !self.beautyConfig.customMakeupEnable
                }
            )
        )
        
        // Level 1 category items, each with sub-items
        // 1. Lipstick (口红)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_lipstick",
            subItems: buildLipstickItems()
        ))
        
        // 2. Blush (腮红)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_blush",
            subItems: buildBlushItems()
        ))
        
        // 3. Contour (修容)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_contour",
            subItems: buildContourItems()
        ))
        
        // 4. Eyeshadow (眼影)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_eyeshadow",
            subItems: buildEyeshadowItems()
        ))
        
        // 5. Eyebrow (修眉)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_eyebrow",
            subItems: buildEyebrowItems()
        ))
        
        return BeautyPageInfo(
            name: "beauty_group_custom_makeup",
            itemList: items,
            type: .styleMakeup
        )
    }
    
    // MARK: - Category Item Builder
    
    /// Build a first-level category entry item
    /// All categories share the same placeholder icon until individual category icons are designed
    private func buildCategoryItem(name: String, subItems: [BeautyItemInfo]) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_category"),
            showSlider: false,
            type: .subMenu,
            subItems: subItems
        )
    }
    
    /// Build a second-level sub-option item
    /// - Parameters:
    ///   - name: Localization key
    ///   - icon: Item icon
    ///   - onValueChanged: Called when slider value changes (nil = no slider interaction needed)
    ///   - onItemClick: Called when item is tapped (nil = no tap action needed)
    private func buildSubLipStickItem(
        name: String,
        icon: UIImage?,
        style: Int32,
        color: Int32
    ) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: icon,
            value: beautyConfig.customLipstickStrength,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customLipstickStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.makeupName = ""
                self.beautyConfig.customLipstickStyle = itemInfo.subItemStyle
                self.beautyConfig.customLipstickColor = itemInfo.subItemColor
                // 所有style共享强度，防止UI跳变
                itemInfo.value = self.beautyConfig.customLipstickStrength
            },
            itemStyle: style,
            itemColor: color
        )
    }
    
    private func buildSubBlushItem(
        name: String,
        icon: UIImage?,
        onValueChanged: ((Float) -> Void)? = nil,
        onItemClick: ((BeautyItemInfo) -> Void)? = nil,
        style: Int32
    ) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: icon,
            value: beautyConfig.customBlushStrength,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customBlushStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.makeupName = ""
                self.beautyConfig.customBlushStyle = itemInfo.subItemStyle
                itemInfo.value = self.beautyConfig.customBlushStrength
            },
            itemStyle: style
        )
    }
    
    private func buildSubFacialItem(
        name: String,
        icon: UIImage?,
        onValueChanged: ((Float) -> Void)? = nil,
        onItemClick: ((BeautyItemInfo) -> Void)? = nil,
        style: Int32
    ) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: icon,
            value: beautyConfig.customFacialStrength,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customFacialStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.makeupName = ""
                self.beautyConfig.customFacialStyle = itemInfo.subItemStyle
                itemInfo.value = self.beautyConfig.customFacialStrength
            },
            itemStyle: style
        )
    }
    
    private func buildSubShadowItem(
        name: String,
        icon: UIImage?,
        onValueChanged: ((Float) -> Void)? = nil,
        onItemClick: ((BeautyItemInfo) -> Void)? = nil,
        style: Int32
    ) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: icon,
            value: beautyConfig.customEyeshadowStrength,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customEyeshadowStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.makeupName = ""
                self.beautyConfig.customEyeshadowStyle = itemInfo.subItemStyle
                itemInfo.value = self.beautyConfig.customEyeshadowStrength
            },
            itemStyle: style
        )
    }
    
    private func buildSubEyebrowItem(
        name: String,
        icon: UIImage?,
        onValueChanged: ((Float) -> Void)? = nil,
        onItemClick: ((BeautyItemInfo) -> Void)? = nil,
        style: Int32
    ) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: icon,
            value: beautyConfig.customEyebrowStrength,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customEyebrowStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.makeupName = ""
                self.beautyConfig.customEyebrowStyle = itemInfo.subItemStyle
                itemInfo.value = self.beautyConfig.customEyebrowStrength
            },
            itemStyle: style
        )
    }
    
    // MARK: - Sub-item Builders
    
    /// Build lipstick sub-items (口红)
    private func buildLipstickItems() -> [BeautyItemInfo] {
        return [
            // 复古红
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_vintage_red",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_vintage_red"),
                                   style: 1,
                                   color: 2),
            // 少女粉
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_girl_pink",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_girl_pink"),
                                   style: 1,
                                   color: 5),
            // 元气橘
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_vitality_orange",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_vitality_orange"),
                                   style: 1,
                                   color: 9),
            // 西柚色
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_grapefruit",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_grapefruit"),
                                   style: 1,
                                   color: 8),
            // 西瓜红
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_watermelon_red",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_watermelon_red"),
                                   style: 1,
                                   color: 7),
            // 丝绒红
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_velvet_red",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_velvet_red"),
                                   style: 1,
                                   color: 6),
            // 脏橘色
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_dirty_orange",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_dirty_orange"),
                                   style: 1,
                                   color: 10),
            // 梅子色
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_plum",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_plum"),
                                   style: 1,
                                   color: 3),
            // 豆沙粉
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_bean_paste_pink",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_bean_paste_pink"),
                                   style: 1,
                                   color: 1),
        ]
    }
    
    /// Build blush sub-items (腮红)
    private func buildBlushItems() -> [BeautyItemInfo] {
        return [
            // 微醺
            buildSubBlushItem(name: "beauty_custom_makeup_blush_tipsy",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_tipsy"),
                              style: 10),
            // 日常
            buildSubBlushItem(name: "beauty_custom_makeup_blush_daily",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_daily"),
                              style: 7),
            // 蜜桃
            buildSubBlushItem(name: "beauty_custom_makeup_blush_peach",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_peach"),
                              style: 5),
            // 甜橙
            buildSubBlushItem(name: "beauty_custom_makeup_blush_sweet_orange",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_sweet_orange"),
                              style: 9),
            // 俏皮
            buildSubBlushItem(name: "beauty_custom_makeup_blush_playful",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_playful"),
                              style: 6),
            // 心机
            buildSubBlushItem(name: "beauty_custom_makeup_blush_scheming",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_scheming"),
                              style: 11),
            // 晒伤
            buildSubBlushItem(name: "beauty_custom_makeup_blush_sunburn",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_sunburn"),
                              style: 8),
        ]
    }
    
    /// Build contour sub-items (修容)
    private func buildContourItems() -> [BeautyItemInfo] {
        return [
            // 修容01
            buildSubFacialItem(name: "beauty_custom_makeup_contour_01",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_contour_01"),
                              style: 1),
        ]
    }
    
    /// Build eyeshadow sub-items (眼影)
    private func buildEyeshadowItems() -> [BeautyItemInfo] {
        return [
            // 晚霞红
            buildSubShadowItem(name: "beauty_custom_makeup_eyeshadow_sunset_red",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_sunset_red"),
                              style: 9),
            // 少女粉
            buildSubShadowItem(name: "beauty_custom_makeup_eyeshadow_girl_pink",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_girl_pink"),
                              style: 2),
            // 气质粉
            buildSubShadowItem(name: "beauty_custom_makeup_eyeshadow_elegant_pink",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_elegant_pink"),
                              style: 13),
            // 梅子红
            buildSubShadowItem(name: "beauty_custom_makeup_eyeshadow_plum_red",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_plum_red"),
                              style: 12),
            // 焦糖棕
            buildSubShadowItem(name: "beauty_custom_makeup_eyeshadow_caramel_brown",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_caramel_brown"),
                              style: 8),
            // 元气橘
            buildSubShadowItem(name: "beauty_custom_makeup_eyeshadow_vitality_orange",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_vitality_orange"),
                              style: 14),
            // 奶茶色
            buildSubShadowItem(name: "beauty_custom_makeup_eyeshadow_milk_tea",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_milk_tea"),
                              style: 11),
        ]
    }
    
    /// Build eyebrow sub-items (修眉)
    private func buildEyebrowItems() -> [BeautyItemInfo] {
        return [
            // 淑女
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_lady",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_lady"),
                              style: 1),
            // 温润
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_gentle",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_gentle"),
                              style: 2),
            // 标准
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_standard",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_standard"),
                              style: 3),
            // 柳叶
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_willow",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_willow"),
                              style: 4),
            // 茸茸
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_fluffy",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_fluffy"),
                              style: 5),
            // 野生
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_wild",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_wild"),
                              style: 6),
            // 细眉
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_thin",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_thin"),
                              style: 7),
            // 英朗
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_heroic",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_heroic"),
                              style: 8),
            // 挺拔
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_upright",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_upright"),
                              style: 9),
            // 平锋
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_flat",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_flat"),
                              style: 10),
        ]
    }
}
