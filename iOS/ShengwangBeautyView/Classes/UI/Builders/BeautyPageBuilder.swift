//
//  BeautyPageBuilder.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import UIKit

/// Beauty module page builder
/// Responsible for building page information for the beauty (skin beautification + face shape) module
internal class BeautyPageBuilder: IPageBuilder {
    
    private let beautyConfig: ShengwangBeautySDK.BeautyConfig
    
    init(beautyConfig: ShengwangBeautySDK.BeautyConfig) {
        self.beautyConfig = beautyConfig
    }
    
    func buildPage() -> BeautyPageInfo {
        var beautyItems: [BeautyItemInfo] = []
        
        // Basic function items (always displayed)
        // 1. Toggle item (selected means enabled)
        let isBeautyEnabled = beautyConfig.beautyEnable || beautyConfig.faceShapeEnable
        beautyItems.append(
            BeautyItemInfo(
                name: "beauty_effect_enable",
                icon: nil,
                isSelected: false,
                showSlider: false,
                type: .toggle(isBeautyEnabled),
                onItemClick: { [weak self] _ in
                    guard let self = self else { return }
                    self.beautyConfig.beautyEnable = !self.beautyConfig.beautyEnable
                    self.beautyConfig.faceShapeEnable = !self.beautyConfig.faceShapeEnable
                }
            )
        )
        
        // 2. Reset button
        beautyItems.append(
            BeautyItemInfo(
                name: "beauty_effect_reset",
                icon: UIImage.beautyIcon(named: "beauty_ic_effect_reset"),
                showSlider: false,
                type: .reset
            )
        )
        
        // Skin beautification parameters
        addSkinBeautyItems(&beautyItems)
        
        // Face shape parameters
        addFaceShapeItems(&beautyItems)

        return BeautyPageInfo(
            name: "beauty_group_beauty",
            itemList: beautyItems,
            type: .beauty
        )
    }
    
    // MARK: - Private Methods
    
    /// Add skin beautification parameters
    private func addSkinBeautyItems(_ items: inout [BeautyItemInfo]) {
        // Smoothness
        addSkinBeautyItem(&items, name: "beauty_effect_smoothness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_smoothness"), value: beautyConfig.smoothness, isSelected: beautyConfig.beautyEnable) { [weak self] value in
            self?.beautyConfig.smoothness = value
        }
        
        // Whitening
        addSkinBeautyItem(&items, name: "beauty_effect_lightness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_lightness"), value: beautyConfig.whitenNatural) { [weak self] value in
            self?.beautyConfig.whitenNatural = value
        }
        
        // Redness
        addSkinBeautyItem(&items, name: "beauty_effect_redness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_redness"), value: beautyConfig.redness) { [weak self] value in
            self?.beautyConfig.redness = value
        }
        
        // Contrast strength
        addSkinBeautyItem(&items, name: "beauty_effect_contrast_strength", icon: UIImage.beautyIcon(named: "beauty_ic_effect_contrast_strength"), value: beautyConfig.contrastStrength, valueRange: -1.0...1.0) { [weak self] value in
            self?.beautyConfig.contrastStrength = value
        }
        
        // Sharpness
        addSkinBeautyItem(&items, name: "beauty_effect_sharpness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_sharpness"), value: beautyConfig.sharpness) { [weak self] value in
            self?.beautyConfig.sharpness = value
        }
        
        // Eye bag removal
        addSkinBeautyItem(&items, name: "beauty_effect_eye_pouch", icon: UIImage.beautyIcon(named: "beauty_ic_effect_eye_pouch"), value: beautyConfig.eyePouch) { [weak self] value in
            self?.beautyConfig.eyePouch = value
        }
        
        // Eye brightening
        addSkinBeautyItem(&items, name: "beauty_effect_brighten_eye", icon: UIImage.beautyIcon(named: "beauty_ic_effect_brighten_eye"), value: beautyConfig.brightenEye) { [weak self] value in
            self?.beautyConfig.brightenEye = value
        }
        
        // Teeth whitening
        addSkinBeautyItem(&items, name: "beauty_effect_whiten_teeth", icon: UIImage.beautyIcon(named: "beauty_ic_effect_whiten_teeth"), value: beautyConfig.whitenTeeth) { [weak self] value in
            self?.beautyConfig.whitenTeeth = value
        }
        
        // Nasolabial fold removal
        addSkinBeautyItem(&items, name: "beauty_effect_nasolabial_fold", icon: UIImage.beautyIcon(named: "beauty_ic_effect_nasolabial_fold"), value: beautyConfig.nasolabialFold) { [weak self] value in
            self?.beautyConfig.nasolabialFold = value
        }
    }
    
    /// Add the requested face shape parameters
    private func addFaceShapeItems(_ items: inout [BeautyItemInfo]) {
        // Face contour group
        // 1. Face contour (slim face)
        addFaceShapeItem(&items, name: "beauty_face_shape_face_contour", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_contour"), value: Float(beautyConfig.faceContour), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.faceContour = Int32(value)
        }

        // 3. Chin (slim chin)
        addFaceShapeItem(&items, name: "beauty_face_shape_chin", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_chin"), value: Float(beautyConfig.chin), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.chin = Int32(value)
        }
        
        // 4. Cheek (jawline)
        addFaceShapeItem(&items, name: "beauty_face_shape_cheek", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_cheek"), value: Float(beautyConfig.cheek), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.cheek = Int32(value)
        }
        
        // 5. Cheekbone (slim cheekbone)
        addFaceShapeItem(&items, name: "beauty_face_shape_cheekbone", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_cheekbone"), value: Float(beautyConfig.cheekbone), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.cheekbone = Int32(value)
        }
        
        // 6. Face length (lengthen face)
        addFaceShapeItem(&items, name: "beauty_face_shape_face_length", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_length"), value: Float(beautyConfig.faceShort), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.faceShort = Int32(value)
        }
        
        // 7. Face width (narrow face)
        addFaceShapeItem(&items, name: "beauty_face_shape_face_width", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_width"), value: Float(beautyConfig.faceWidth), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.faceWidth = Int32(value)
        }
        
        // 8. Forehead (hairline)
        addFaceShapeItem(&items, name: "beauty_face_shape_fore_head", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_fore_head"), value: Float(beautyConfig.foreHead), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.foreHead = Int32(value)
        }
        
        // 9. Head scale (small head)
        addFaceShapeItem(&items, name: "beauty_face_shape_head_scale", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_head_scale"), value: Float(beautyConfig.headScale), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.headScale = Int32(value)
        }
        
        // Nose group
        // 10. Nose width (slim nose)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_width", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_width"), value: Float(beautyConfig.noseWidth), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.noseWidth = Int32(value)
        }

        
        
        // 14. Nose wing (nose wing)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_wing", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_wing"), value: Float(beautyConfig.noseWing), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.noseWing = Int32(value)
        }
        
        // 15. Nose length (lengthen nose)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_length", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_length"), value: Float(beautyConfig.noseLength), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.noseLength = Int32(value)
        }

        // Eye group
        // 17. Eye scale (enlarge eyes)
        addFaceShapeItem(&items, name: "beauty_face_shape_eye_scale", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_scale"), value: Float(beautyConfig.eyeScale), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeScale = Int32(value)
        }
        
        // 18. Eye distance (eye distance)
        addFaceShapeItem(&items, name: "beauty_face_shape_eye_distance", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_distance"), value: Float(beautyConfig.eyeDistance), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeDistance = Int32(value)
        }
        
        // Eye Angle
        addFaceShapeItem(&items, name: "beauty_face_shape_eye_angle", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_angle"), value: Float(beautyConfig.eyeAngle), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeAngle = Int32(value)
        }

        // 20. Eye inner corner (inner eye corner)
        addFaceShapeItem(&items, name: "beauty_face_shape_inner_corner", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_inner_corner"), value: Float(beautyConfig.eyeInnerCorner), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeInnerCorner = Int32(value)
        }
        
        // 21. Eye outer corner (outer eye corner)
        addFaceShapeItem(&items, name: "beauty_face_shape_outer_corner", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_outer_corner"), value: Float(beautyConfig.eyeOuterCorner), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeOuterCorner = Int32(value)
        }

        
        // Mouth group

        // 26. Mouth scale (mouth shape)
        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_scale", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_scale"), value: Float(beautyConfig.mouthScale), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.mouthScale = Int32(value)
        }
        
        // 27. Mouth position (philtrum)
        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_position", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_position"), value: Float(beautyConfig.mouthPosition), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.mouthPosition = Int32(value)
        }

    }
    
    // MARK: - Helper Methods
    
    private func addSkinBeautyItem(
        _ items: inout [BeautyItemInfo],
        name: String,
        icon: UIImage?,
        value: Float,
        isSelected: Bool = false,
        valueRange: ClosedRange<Float> = 0.0...1.0,
        onValueChanged: @escaping (Float) -> Void
    ) {
        let isBipolar = valueRange.lowerBound < 0
        // UI 显示范围和换算
        let uiRange: ClosedRange<Float> = isBipolar ? -50.0...50.0 : 0.0...100.0
        let uiValue: Float = isBipolar ? value * 50.0 : value * 100.0
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: uiValue,
                isSelected: isSelected,
                valueRange: uiRange,
                onValueChanged: { uiVal in
                    let sdkValue = isBipolar ? uiVal / 50.0 : uiVal / 100.0
                    onValueChanged(sdkValue)
                }
            )
        )
    }
    
    private func addFaceShapeItem(
        _ items: inout [BeautyItemInfo],
        name: String,
        icon: UIImage?,
        value: Float,
        valueRange: ClosedRange<Float> = 0.0...100.0,
        onValueChanged: @escaping (Float) -> Void
    ) {
        let isBipolar = valueRange.lowerBound < 0
        // UI display conversion: SDK -100~100 → UI -50~50; 0~100 unchanged
        let uiRange: ClosedRange<Float> = isBipolar ? -50.0...50.0 : valueRange
        let uiValue: Float = isBipolar ? value / 2.0 : value
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: uiValue,
                valueRange: uiRange,
                onValueChanged: { uiVal in
                    let sdkValue = isBipolar ? uiVal * 2.0 : uiVal
                    onValueChanged(sdkValue)
                }
            )
        )
    }
    
}
