//
//  BeautyPageBuilder.swift
//  BeautyView
//
//  Created by HeZhengQing on 2026/1/22.
//

import Foundation
import UIKit

/// Beauty module page builder
/// Responsible for building page information for beauty (skin beautification + face shape + image quality) module
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
                type: .toggle(isBeautyEnabled)
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
        
        // Image quality parameters
        addQualityItems(&beautyItems)
        
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
    
    /// Add face shape parameters (all 32 items)
    private func addFaceShapeItems(_ items: inout [BeautyItemInfo]) {
        // Face contour group
        // 1. Face contour (slim face)
        addFaceShapeItem(&items, name: "beauty_face_shape_face_contour", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_contour"), value: Float(beautyConfig.faceContour), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.faceContour = Int32(value)
        }
        
        // 2. Mandible (V-shaped face)
        addFaceShapeItem(&items, name: "beauty_face_shape_mandible", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mandible"), value: Float(beautyConfig.mandible), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.mandible = Int32(value)
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
        addFaceShapeItem(&items, name: "beauty_face_shape_face_length", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_length"), value: Float(beautyConfig.faceLength), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.faceLength = Int32(value)
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
        
        // 11. Nose root (nose bridge root)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_root", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_root"), value: Float(beautyConfig.noseRoot), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.noseRoot = Int32(value)
        }
        
        // 12. Nose bridge (nose bridge)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_bridge", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_bridge"), value: Float(beautyConfig.noseBridge), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.noseBridge = Int32(value)
        }
        
        // 13. Nose tip (nose tip)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_tip", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_tip"), value: Float(beautyConfig.noseTip), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.noseTip = Int32(value)
        }
        
        // 14. Nose wing (nose wing)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_wing", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_wing"), value: Float(beautyConfig.noseWing), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.noseWing = Int32(value)
        }
        
        // 15. Nose length (lengthen nose)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_length", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_length"), value: Float(beautyConfig.noseLength), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.noseLength = Int32(value)
        }
        
        // 16. Nose general (nose comprehensive)
        addFaceShapeItem(&items, name: "beauty_face_shape_nose_general", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_general"), value: Float(beautyConfig.noseGeneral), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.noseGeneral = Int32(value)
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
        
        // 19. Eye lid (lower eyelid)
        addFaceShapeItem(&items, name: "beauty_face_shape_eye_lid", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_lid"), value: Float(beautyConfig.eyeLid), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeLid = Int32(value)
        }
        
        // 20. Eye inner corner (inner eye corner)
        addFaceShapeItem(&items, name: "beauty_face_shape_inner_corner", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_inner_corner"), value: Float(beautyConfig.eyeInnerCorner), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeInnerCorner = Int32(value)
        }
        
        // 21. Eye outer corner (outer eye corner)
        addFaceShapeItem(&items, name: "beauty_face_shape_outer_corner", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_outer_corner"), value: Float(beautyConfig.eyeOuterCorner), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeOuterCorner = Int32(value)
        }
        
        // 22. Eye position (eye position)
        addFaceShapeItem(&items, name: "beauty_face_shape_eye_position", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_position"), value: Float(beautyConfig.eyePosition), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyePosition = Int32(value)
        }
        
        // 23. Eye pupils (eye pupils)
        addFaceShapeItem(&items, name: "beauty_face_shape_eye_pupils", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_pupils"), value: Float(beautyConfig.eyePupils), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.eyePupils = Int32(value)
        }
        
        // Mouth group
        // 24. Mouth smile (smile lips)
        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_smile", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_smile"), value: Float(beautyConfig.mouthSmile), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.mouthSmile = Int32(value)
        }
        
        // 25. Mouth lip (fuller lips)
        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_lip", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_lip"), value: Float(beautyConfig.mouthLip), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.mouthLip = Int32(value)
        }
        
        // 26. Mouth scale (mouth shape)
        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_scale", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_scale"), value: Float(beautyConfig.mouthScale), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.mouthScale = Int32(value)
        }
        
        // 27. Mouth position (philtrum)
        addFaceShapeItem(&items, name: "beauty_face_shape_mouth_position", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_position"), value: Float(beautyConfig.mouthPosition), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.mouthPosition = Int32(value)
        }
        
        // Eyebrow group
        // 28. Eyebrow thickness (eyebrow thickness)
        addFaceShapeItem(&items, name: "beauty_face_shape_eyebrow_thickness", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eyebrow_thickness"), value: Float(beautyConfig.eyebrowThickness), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyebrowThickness = Int32(value)
        }
        
        // 29. Eyebrow position (eyebrow position)
        addFaceShapeItem(&items, name: "beauty_face_shape_eyebrow_position", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eyebrow_position"), value: Float(beautyConfig.eyebrowPosition), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyebrowPosition = Int32(value)
        }
    }
    
    /// Add image quality parameters
    private func addQualityItems(_ items: inout [BeautyItemInfo]) {
        // Color temperature
        addQualityItem(&items, name: "beauty_effect_temperature", icon: UIImage.beautyIcon(named: "beauty_ic_effect_temperature"), value: beautyConfig.temperature) { [weak self] value in
            self?.beautyConfig.temperature = value
        }
        
        // Hue
        addQualityItem(&items, name: "beauty_effect_hue", icon: UIImage.beautyIcon(named: "beauty_ic_effect_hue"), value: beautyConfig.hue) { [weak self] value in
            self?.beautyConfig.hue = value
        }
        
        // Saturation
        addQualityItem(&items, name: "beauty_effect_saturation", icon: UIImage.beautyIcon(named: "beauty_ic_effect_saturation"), value: beautyConfig.saturation) { [weak self] value in
            self?.beautyConfig.saturation = value
        }
        
        // Brightness
        addQualityItem(&items, name: "beauty_effect_brightness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_brightness"), value: beautyConfig.brightness) { [weak self] value in
            self?.beautyConfig.brightness = value
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
        items.append(
            BeautyItemInfo(
                name: name,
                icon: icon,
                value: value,
                isSelected: isSelected,
                valueRange: valueRange,
                onValueChanged: onValueChanged
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
