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
                type: .toggle(isBeautyEnabled),
                onItemClick: { [weak self] _ in
                    guard let self = self else { return }
                    self.beautyConfig.beautyEnable = !self.beautyConfig.beautyEnable
                    self.beautyConfig.faceShapeEnable = !self.beautyConfig.faceShapeEnable
                }
            )
        )
        
        // 磨皮
        addSkinBeautyItem(&beautyItems, name: "beauty_effect_smoothness", icon: UIImage.beautyIcon(named: "beauty_ic_effect_smoothness"), value: beautyConfig.smoothness, isSelected: beautyConfig.beautyEnable) { [weak self] value in
            self?.beautyConfig.smoothness = value
        }
        
        // 美白（二级菜单入口）
        let whitenSubItems: [BeautyItemInfo] = [
            // 无
            BeautyItemInfo(
                name: "beauty_effect_none",
                icon: UIImage.beautyIcon(named: "beauty_ic_none"),
                isSelected: false,
                showSlider: false,
                onItemClick: { [weak self] itemInfo in
                    guard let self = self else { return }
                    self.beautyConfig.whitenStength = 0.0
                    self.beautyConfig.whitenLut = ""
                }
            ),
            // 自然
            BeautyItemInfo(
                name: "beauty_effect_lightness_natural",
                icon: UIImage.beautyIcon(named: "beauty_ic_effect_lightness"),
                value: beautyConfig.whitenStength,
                onValueChanged: { [weak self] value in
                    self?.beautyConfig.whitenStength = value
                },
                onItemClick: { [weak self] itemInfo in
                    guard let self = self else { return }
                    self.beautyConfig.whitenLut = ""
                    itemInfo.value = beautyConfig.whitenStength
                }
            ),
            // 白皙
            BeautyItemInfo(
                name: "beauty_effect_lightness_fair",
                icon: UIImage.beautyIcon(named: "beauty_ic_effect_lightness"),
                value: beautyConfig.whitenStength,
                onValueChanged: { [weak self] value in
                    self?.beautyConfig.whitenStength = value
                },
                onItemClick: { [weak self] itemInfo in
                    guard let self = self else { return }
                    self.beautyConfig.whitenLut = "../resource/whiten/lengbai.png"
                    itemInfo.value = beautyConfig.whitenStength
                }
            ),
            // 粉白
            BeautyItemInfo(
                name: "beauty_effect_lightness_pink",
                icon: UIImage.beautyIcon(named: "beauty_ic_effect_lightness"),
                value: beautyConfig.whitenStength,
                onValueChanged: { [weak self] value in
                    self?.beautyConfig.whitenStength = value
                },
                onItemClick: { [weak self] itemInfo in
                    guard let self = self else { return }
                    self.beautyConfig.whitenLut = "../resource/whiten/fenbai.png"
                    itemInfo.value = beautyConfig.whitenStength
                }
            ),
            // 超白
            BeautyItemInfo(
                name: "beauty_effect_lightness_ultra",
                icon: UIImage.beautyIcon(named: "beauty_ic_effect_lightness"),
                value: beautyConfig.whitenStength,
                onValueChanged: { [weak self] value in
                    self?.beautyConfig.whitenStength = value
                },
                onItemClick: { [weak self] itemInfo in
                    guard let self = self else { return }
                    self.beautyConfig.whitenLut = "../resource/whiten/chaobai.png"
                    itemInfo.value = beautyConfig.whitenStength
                }
            ),
        ]
        beautyItems.append(
            BeautyItemInfo(
                name: "beauty_effect_lightness",
                icon: UIImage.beautyIcon(named: "beauty_ic_effect_lightness"),
                showSlider: false,
                type: .subMenu,
                subItems: whitenSubItems
            )
        )
        
        // 清晰
        addSkinBeautyItem(&beautyItems, name: "beauty_effect_contrast_strength", icon: UIImage.beautyIcon(named: "beauty_ic_effect_contrast_strength"), value: beautyConfig.contrastStrength, valueRange: -1.0...1.0) { [weak self] value in
            self?.beautyConfig.contrastStrength = value
        }

        // 瘦脸（二级菜单入口）
        let faceSlimSubItems: [BeautyItemInfo] = [
            // 瘦脸（原子参数）
            BeautyItemInfo(
                name: "beauty_face_shape_face_contour",
                icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_contour"),
                value: Float(beautyConfig.faceContour),
                valueRange: 0.0...100.0,
                onValueChanged: { [weak self] value in
                    self?.beautyConfig.faceContour = Int32(value)
                },
                onItemClick: { [weak self] _ in
                    self?.beautyConfig.faceShapeStyle = -1
                }
            ),
            // 女神
            BeautyItemInfo(
                name: "beauty_face_shape_face_slim_goddess",
                icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_contour"),
                value: Float(beautyConfig.faceShapeStyleIntensity),
                valueRange: 0.0...100.0,
                onValueChanged: { [weak self] value in
                    self?.beautyConfig.faceContour = Int32(value)
                    self?.beautyConfig.faceShapeStyleIntensity = Int32(value)
                },
                onItemClick: { [weak self] _ in
                    self?.beautyConfig.faceShapeStyle = 0
                }
            ),
            // 男神
            BeautyItemInfo(
                name: "beauty_face_shape_face_slim_god",
                icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_contour"),
                value: Float(beautyConfig.faceShapeStyleIntensity),
                valueRange: 0.0...100.0,
                onValueChanged: { [weak self] value in
                    self?.beautyConfig.faceContour = Int32(value)
                    self?.beautyConfig.faceShapeStyleIntensity = Int32(value)
                },
                onItemClick: { [weak self] _ in
                    self?.beautyConfig.faceShapeStyle = 1
                }
            ),
            // 自然
            BeautyItemInfo(
                name: "beauty_face_shape_face_slim_natural",
                icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_contour"),
                value: Float(beautyConfig.faceShapeStyleIntensity),
                valueRange: 0.0...100.0,
                onValueChanged: { [weak self] value in
                    self?.beautyConfig.faceContour = Int32(value)
                    self?.beautyConfig.faceShapeStyleIntensity = Int32(value)
                },
                onItemClick: { [weak self] _ in
                    self?.beautyConfig.faceShapeStyle = 2
                }
            ),
        ]
        beautyItems.append(
            BeautyItemInfo(
                name: "beauty_face_shape_face_contour",
                icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_contour"),
                showSlider: false,
                type: .subMenu,
                subItems: faceSlimSubItems
            )
        )
        
        // 小脸
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_face_small", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_contour"), value: Float(beautyConfig.faceShort), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.faceShort = Int32(value)
        }

        // 窄脸
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_face_width", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_face_width"), value: Float(beautyConfig.faceWidth), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.faceWidth = Int32(value)
        }

        // 瘦颧骨 
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_cheekbone", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_cheekbone"), value: Float(beautyConfig.cheekbone), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.cheekbone = Int32(value)
        }

        // 瘦下颌骨 
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_cheek", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_cheek"), value: Float(beautyConfig.cheek), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.cheek = Int32(value)
        }

        // 下巴
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_chin", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_chin"), value: Float(beautyConfig.chin), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.chin = Int32(value)
        }

        // 额头
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_fore_head", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_fore_head"), value: Float(beautyConfig.foreHead), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.foreHead = Int32(value)
        }

        // 法令纹
        addSkinBeautyItem(&beautyItems, name: "beauty_effect_nasolabial_fold", icon: UIImage.beautyIcon(named: "beauty_ic_effect_nasolabial_fold"), value: beautyConfig.nasolabialFold) { [weak self] value in
            self?.beautyConfig.nasolabialFold = value
        }

        // 大眼
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_eye_scale", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_scale"), value: Float(beautyConfig.eyeScale), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeScale = Int32(value)
        }

        // 眼移动
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_eye_position", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_position"), value: Float(beautyConfig.eyePosition), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyePosition = Int32(value)
        }

        // 眼距
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_eye_distance", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_distance"), value: Float(beautyConfig.eyeDistance), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeDistance = Int32(value)
        }

        // 眼角度
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_eye_angle", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_eye_position"), value: Float(beautyConfig.eyeAngle), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.eyeAngle = Int32(value)
        }

        // 亮眼
        addSkinBeautyItem(&beautyItems, name: "beauty_effect_brighten_eye", icon: UIImage.beautyIcon(named: "beauty_ic_effect_brighten_eye"), value: beautyConfig.brightenEye) { [weak self] value in
            self?.beautyConfig.brightenEye = value
        }

        // 黑眼圈 
        addSkinBeautyItem(&beautyItems, name: "beauty_effect_eye_pouch", icon: UIImage.beautyIcon(named: "beauty_ic_effect_eye_pouch"), value: beautyConfig.eyePouch) { [weak self] value in
            self?.beautyConfig.eyePouch = value
        }

        // 瘦鼻
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_nose_width", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_width"), value: Float(beautyConfig.noseWidth), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.noseWidth = Int32(value)
        }

        // 长鼻
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_nose_length", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_nose_length"), value: Float(beautyConfig.noseLength), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.noseLength = Int32(value)
        }
        
        // 嘴巴
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_mouth_scale", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_scale"), value: Float(beautyConfig.mouthScale), valueRange: -100.0...100.0) { [weak self] value in
            self?.beautyConfig.mouthScale = Int32(value)
        }

        // 缩人中
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_mouth_position", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_position"), value: Float(beautyConfig.mouthPosition), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.mouthPosition = Int32(value)
        }
        
        // 微笑嘴角
        addFaceShapeItem(&beautyItems, name: "beauty_face_shape_mouth_smile", icon: UIImage.beautyIcon(named: "beauty_ic_face_shape_mouth_smile"), value: Float(beautyConfig.mouthSmile), valueRange: 0.0...100.0) { [weak self] value in
            self?.beautyConfig.mouthSmile = Int32(value)
        }

        // 美牙
        addSkinBeautyItem(&beautyItems, name: "beauty_effect_whiten_teeth", icon: UIImage.beautyIcon(named: "beauty_ic_effect_whiten_teeth"), value: beautyConfig.whitenTeeth) { [weak self] value in
            self?.beautyConfig.whitenTeeth = value
        }
        
        return BeautyPageInfo(
            name: "beauty_group_beauty",
            itemList: beautyItems,
            type: .beauty
        )
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
    
}
