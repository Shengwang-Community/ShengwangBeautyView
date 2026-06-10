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
/// - Level 1: Categories (lipstick, blush, contour, eyeshadow, eyebrow, lash, pupil)
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
        let toggleItem = BeautyItemInfo(
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
        items.append(toggleItem)
        
        // Level 1 category items, each with sub-items
        // 1. Lipstick (口红)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_lipstick",
            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_category_lipstick"),
            subItems: buildLipstickItems()
        ))
        
        // 2. Blush (腮红)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_blush",
            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_category_blush"),
            subItems: buildBlushItems()
        ))
        
        // 3. Contour (修容)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_contour",
            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_category_contour"),
            subItems: buildContourItems()
        ))
        
        // 4. Eyeshadow (眼影)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_eyeshadow",
            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_category_shadow"),
            subItems: buildEyeshadowItems()
        ))
        
        // 5. Eyebrow (修眉)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_eyebrow",
            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_category_eyebrow"),
            subItems: buildEyebrowItems()
        ))
        
        // 6. Lash (睫毛)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_lash",
            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_category_lash"),
            subItems: buildLashItems()
        ))
        
        // 7. Pupil (美瞳)
        items.append(buildCategoryItem(
            name: "beauty_custom_makeup_pupil",
            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_category_pupil"),
            subItems: buildPupilItems()
        ))
        
        return BeautyPageInfo(
            name: "beauty_group_custom_makeup",
            itemList: items,
            type: .styleMakeup
        )
    }
    
    // MARK: - Category Item Builder
    
    /// Build a first-level category entry item
    /// Each category uses its own specific icon from beauty_ic_makeup_category_xxx
    private func buildCategoryItem(name: String, icon: UIImage?, subItems: [BeautyItemInfo]) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: icon,
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
            isSelected: beautyConfig.customLipstickStyle == style,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customLipstickStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.setCustomMakeupEnableInternal(true)
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
        style: Int32,
        color: Int32
    ) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: icon,
            value: beautyConfig.customBlushStrength,
            isSelected: beautyConfig.customBlushStyle == style,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customBlushStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.setCustomMakeupEnableInternal(true)
                self.beautyConfig.customBlushStyle = itemInfo.subItemStyle
                self.beautyConfig.customBlushColor = itemInfo.subItemColor
                itemInfo.value = self.beautyConfig.customBlushStrength
            },
            itemStyle: style,
            itemColor: color
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
            isSelected: beautyConfig.customFacialStyle == style,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customFacialStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.setCustomMakeupEnableInternal(true)
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
            isSelected: beautyConfig.customEyeshadowStyle == style,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customEyeshadowStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.setCustomMakeupEnableInternal(true)
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
            isSelected: beautyConfig.customEyebrowStyle == style,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customEyebrowStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.setCustomMakeupEnableInternal(true)
                self.beautyConfig.customEyebrowStyle = itemInfo.subItemStyle
                itemInfo.value = self.beautyConfig.customEyebrowStrength
            },
            itemStyle: style
        )
    }
    
    private func buildSubLashItem(
        name: String,
        icon: UIImage?,
        style: Int32,
        color: Int32
    ) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: icon,
            value: beautyConfig.customLashStrength,
            isSelected: beautyConfig.customLashStyle == style,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customLashStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.setCustomMakeupEnableInternal(true)
                self.beautyConfig.customLashStyle = itemInfo.subItemStyle
                self.beautyConfig.customLashColor = itemInfo.subItemColor
                itemInfo.value = self.beautyConfig.customLashStrength
            },
            itemStyle: style,
            itemColor: color
        )
    }
    
    private func buildSubPupilItem(
        name: String,
        icon: UIImage?,
        style: Int32
    ) -> BeautyItemInfo {
        return BeautyItemInfo(
            name: name,
            icon: icon,
            value: beautyConfig.customPupilStrength,
            isSelected: beautyConfig.customPupilStyle == style,
            valueRange: 0.0...1.0,
            onValueChanged: { [weak self] value in
                self?.beautyConfig.customPupilStrength = value
            },
            onItemClick: { [weak self] itemInfo in
                guard let self = self else { return }
                self.beautyConfig.setCustomMakeupEnableInternal(true)
                self.beautyConfig.customPupilStyle = itemInfo.subItemStyle
                itemInfo.value = self.beautyConfig.customPupilStrength
            },
            itemStyle: style
        )
    }
    
    // MARK: - Sub-item Builders
    
    /// Build lipstick sub-items (口红)
    private func buildLipstickItems() -> [BeautyItemInfo] {
        return [
            BeautyItemInfo(
              name: "beauty_effect_none",
              icon: UIImage.beautyIcon(named: "beauty_ic_none"),
              isSelected: beautyConfig.customLipstickStyle == 0,
              showSlider: false,
              type: .none,
              onItemClick: { [weak self] _ in
                self?.beautyConfig.customLipstickStyle = 0
              }
            ),
            // 元气橘
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_vibrant_orange",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_001"),
                                   style: 1,
                                   color: 9),
            // 丝绒红
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_velvet_red",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_003"),
                                   style: 1,
                                   color: 6),
            // 梅子
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_plum",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_004"),
                                   style: 1,
                                   color: 3),
            // 少女粉
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_pink",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_005"),
                                   style: 1,
                                   color: 5),
            // 西柚色
            buildSubLipStickItem(name: "beauty_custom_makeup_lipstick_grapefruit",
                                   icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lipstick_006"),
                                   style: 1,
                                   color: 8),
        ]
    }
    
    /// Build blush sub-items (腮红)
    private func buildBlushItems() -> [BeautyItemInfo] {
        return [
            BeautyItemInfo(
              name: "beauty_effect_none",
              icon: UIImage.beautyIcon(named: "beauty_ic_none"),
              isSelected: beautyConfig.customBlushStyle == 0,
              showSlider: false,
              type: .none,
              onItemClick: { [weak self] _ in
                self?.beautyConfig.customBlushStyle = 0
              }
            ),
            // 粉黛
            buildSubBlushItem(name: "beauty_custom_makeup_blush_powder",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_001"),
                              style: 1,
                              color: 0),
            // 蜜桃
            buildSubBlushItem(name: "beauty_custom_makeup_blush_peach",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_003"),
                              style: 3,
                              color: 2),
            // 微醺
            buildSubBlushItem(name: "beauty_custom_makeup_blush_tipsy",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_004"),
                              style: 2,
                              color: 0),
            // 素醉
            buildSubBlushItem(name: "beauty_custom_makeup_blush_enchanted",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_008"),
                              style: 8,
                              color: 3),
            // 彩云
            buildSubBlushItem(name: "beauty_custom_makeup_blush_cloud",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_blush_010"),
                              style: 10,
                              color: 0),
        ]
    }
    
    /// Build contour sub-items (修容)
    private func buildContourItems() -> [BeautyItemInfo] {
        return [
            BeautyItemInfo(
              name: "beauty_effect_none",
              icon: UIImage.beautyIcon(named: "beauty_ic_none"),
              isSelected: beautyConfig.customFacialStyle == 0,
              showSlider: false,
              type: .none,
              onItemClick: { [weak self] _ in
                self?.beautyConfig.customFacialStyle = 0
              }
            ),
            // 立体
            buildSubFacialItem(name: "beauty_custom_makeup_contour_sculpt",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_contour_001"),
                              style: 1),
            // 均匀
            buildSubFacialItem(name: "beauty_custom_makeup_contour_even",
                               icon: UIImage.beautyIcon(named: "beauty_ic_makeup_contour_009"),
                               style: 9),
            // 丰满
            buildSubFacialItem(name: "beauty_custom_makeup_contour_plump",
                               icon: UIImage.beautyIcon(named: "beauty_ic_makeup_contour_003"),
                               style: 3),
            // 阴影
            buildSubFacialItem(name: "beauty_custom_makeup_contour_contour",
                               icon: UIImage.beautyIcon(named: "beauty_ic_makeup_contour_006"),
                               style: 6),
            // 高亮
            buildSubFacialItem(name: "beauty_custom_makeup_contour_highlight",
                               icon: UIImage.beautyIcon(named: "beauty_ic_makeup_contour_008"),
                               style: 8),
        ]
    }
    
    /// Build eyeshadow sub-items (眼影)
    private func buildEyeshadowItems() -> [BeautyItemInfo] {
        return [
            BeautyItemInfo(
              name: "beauty_effect_none",
              icon: UIImage.beautyIcon(named: "beauty_ic_none"),
              isSelected: beautyConfig.customEyeshadowStyle == 0,
              showSlider: false,
              type: .none,
              onItemClick: { [weak self] _ in
                self?.beautyConfig.customEyeshadowStyle = 0
              }
            ),
            // 艳紫
            buildSubShadowItem(
                name: "beauty_custom_makeup_eyeshadow_violet",
                icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_001"),
                style: 2
            ),
            // 深粉
            buildSubShadowItem(
                name: "beauty_custom_makeup_eyeshadow_rose",
                icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_009"),
                style: 9
            ),
            // 冰糖山楂
            buildSubShadowItem(
                name: "beauty_custom_makeup_eyeshadow_berry",
                icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_003"),
                style: 11
            ),
            // 大地棕
            buildSubShadowItem(
                name: "beauty_custom_makeup_eyeshadow_earth",
                icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_004"),
                style: 4
            ),
            // 韩系
            buildSubShadowItem(
                name: "beauty_custom_makeup_eyeshadow_korean",
                icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_005"),
                style: 5
            ),
            // 杏子
            buildSubShadowItem(
                name: "beauty_custom_makeup_eyeshadow_apricot",
                icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyeshadow_007"),
                style: 7
            ),
        ]
    }
    
    /// Build eyebrow sub-items (修眉)
    private func buildEyebrowItems() -> [BeautyItemInfo] {
        return [
            BeautyItemInfo(
              name: "beauty_effect_none",
              icon: UIImage.beautyIcon(named: "beauty_ic_none"),
              isSelected: beautyConfig.customEyebrowStyle == 0,
              showSlider: false,
              type: .none,
              onItemClick: { [weak self] _ in
                self?.beautyConfig.customEyebrowStyle = 0
              }
            ),
            // 淑女
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_lady",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_001"),
                              style: 1),
            // 温润
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_gentle",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_002"),
                              style: 2),
            // 标准
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_standard",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_003"),
                              style: 3),
            // 柳叶
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_willow",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_004"),
                              style: 4),
            // 茸茸
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_fluffy",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_005"),
                              style: 5),
            // 野生
            buildSubEyebrowItem(name: "beauty_custom_makeup_eyebrow_wild",
                              icon: UIImage.beautyIcon(named: "beauty_ic_makeup_eyebrow_006"),
                              style: 6),
        ]
    }
    
    /// Build lash sub-items (睫毛)
    private func buildLashItems() -> [BeautyItemInfo] {
        return [
            BeautyItemInfo(
              name: "beauty_effect_none",
              icon: UIImage.beautyIcon(named: "beauty_ic_none"),
              isSelected: beautyConfig.customLashStyle == 0,
              showSlider: false,
              type: .none,
              onItemClick: { [weak self] _ in
                self?.beautyConfig.customLashStyle = 0
              }
            ),
            // 细腻
            buildSubLashItem(name: "beauty_custom_makeup_lash_delicate",
                            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lash_002"),
                            style: 2,
                            color: 1),
            // 翅膀
            buildSubLashItem(name: "beauty_custom_makeup_lash_wing",
                            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lash_003"),
                            style: 3,
                            color: 0),
            // 卷翘
            buildSubLashItem(name: "beauty_custom_makeup_lash_curly",
                            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lash_004"),
                            style: 4,
                            color: 1),
            // 漫画
            buildSubLashItem(name: "beauty_custom_makeup_lash_comic",
                            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lash_005"),
                            style: 5,
                            color: 0),
            // 边翘
            buildSubLashItem(name: "beauty_custom_makeup_lash_rise",
                            icon: UIImage.beautyIcon(named: "beauty_ic_makeup_lash_009"),
                            style: 9,
                            color: 1),
        ]
    }
    
    /// Build pupil sub-items (美瞳)
    private func buildPupilItems() -> [BeautyItemInfo] {
        return [
            BeautyItemInfo(
              name: "beauty_effect_none",
              icon: UIImage.beautyIcon(named: "beauty_ic_none"),
              isSelected: beautyConfig.customPupilStyle == 0,
              showSlider: false,
              type: .none,
              onItemClick: { [weak self] _ in
                self?.beautyConfig.customPupilStyle = 0
              }
            ),
            // 灰褐
            buildSubPupilItem(name: "beauty_custom_makeup_pupil_hazel",
                             icon: UIImage.beautyIcon(named: "beauty_ic_makeup_pupil_001"),
                             style: 1),
            // 浅蓝
            buildSubPupilItem(name: "beauty_custom_makeup_pupil_skyblue",
                             icon: UIImage.beautyIcon(named: "beauty_ic_makeup_pupil_002"),
                             style: 2),
            // 灰绿
            buildSubPupilItem(name: "beauty_custom_makeup_pupil_green",
                             icon: UIImage.beautyIcon(named: "beauty_ic_makeup_pupil_003"),
                             style: 3),
            // 灰瞳
            buildSubPupilItem(name: "beauty_custom_makeup_pupil_gray",
                             icon: UIImage.beautyIcon(named: "beauty_ic_makeup_pupil_004"),
                             style: 4),
            // 火星
            buildSubPupilItem(name: "beauty_custom_makeup_pupil_mars",
                             icon: UIImage.beautyIcon(named: "beauty_ic_makeup_pupil_005"),
                             style: 5),
            // 原生
            buildSubPupilItem(name: "beauty_custom_makeup_pupil_natural",
                             icon: UIImage.beautyIcon(named: "beauty_ic_makeup_pupil_007"),
                             style: 7),
        ]
    }
}
