package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule
import cn.shengwang.beauty.ui.model.BeautyPageInfo

/**
 * 美颜模块页面构建器
 * 负责构建美颜（美肤+美型+画质）模块的页面信息
 *
 * 注意：此构建器为内部实现，不对外暴露
 */
internal class BeautyPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig,
    private val refreshPageList: () -> Unit
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val beautyItems = mutableListOf<BeautyItemInfo>()

        // 基础功能项（始终显示）
        // 1. 开关项（选中表示开启）
        val isBeautyEnabled = beautyConfig.beautyEnable || beautyConfig.faceShapeEnable
        beautyItems.add(
            BeautyItemInfo(
                name = if (isBeautyEnabled) R.string.beauty_effect_enable else R.string.beauty_effect_disable,
                icon = if (isBeautyEnabled) R.drawable.beauty_switcher_on else R.drawable.beauty_switcher_off,
                showSlider = false,
                type = BeautyItemType.TOGGLE,
                onItemClick = { itemInfo ->
                    // 切换美颜和美型状态
                    val isCurrentlyEnabled = beautyConfig.beautyEnable || beautyConfig.faceShapeEnable
                    val newEnabledState = !isCurrentlyEnabled

                    if (isCurrentlyEnabled) {
                        // 当前是开启状态（选中），点击后关闭（取消选中）
                        beautyConfig.beautyEnable = false
                        beautyConfig.faceShapeEnable = false
                    } else {
                        // 当前是关闭状态（未选中），点击后开启（选中）
                        beautyConfig.beautyEnable = true
                        beautyConfig.faceShapeEnable = true
                    }
                    // 更新 itemInfo 的属性，View 层会通过 notifyItemChanged 触发 UI 更新
                    itemInfo.name =
                        if (newEnabledState) R.string.beauty_effect_enable else R.string.beauty_effect_disable
                    itemInfo.icon =
                        if (newEnabledState) R.drawable.beauty_switcher_on else R.drawable.beauty_switcher_off
                    // 刷新整个页面列表以更新开关状态和其他参数值
                    refreshPageList.invoke()
                }
            )
        )

        // 2. 重置按钮
        beautyItems.add(
            BeautyItemInfo(
                R.string.beauty_effect_reset,
                R.drawable.beauty_ic_effect_reset,
                showSlider = false,
                type = BeautyItemType.RESET,
                onItemClick = {
                    // 调用重置功能
                    beautyConfig.resetBeauty()
                    // 刷新整个页面列表以更新开关状态和其他参数值
                    refreshPageList.invoke()
                }
            )
        )

        // 美肤参数
        addSkinBeautyItems(beautyItems)

        // 美型参数
        addFaceShapeItems(beautyItems)

        // 画质参数
        addQualityItems(beautyItems)

        return BeautyPageInfo(
            R.string.beauty_group_beauty,
            beautyItems,
            type = BeautyModule.BEAUTY
        )
    }

    /**
     * 添加美肤参数
     */
    private fun addSkinBeautyItems(items: MutableList<BeautyItemInfo>) {
        // 磨皮
        addSkinBeautyItem(
            items,
            R.string.beauty_effect_smoothness,
            R.drawable.beauty_ic_effect_smoothness,
            beautyConfig.smoothness,
            isSelected = beautyConfig.beautyEnable
        ) { value ->
            beautyConfig.smoothness = value
        }
        // 美白
        addSkinBeautyItem(
            items,
            R.string.beauty_effect_lightness,
            R.drawable.beauty_ic_effect_lightness,
            beautyConfig.whitenNatural
        ) { value ->
            beautyConfig.whitenNatural = value
        }
        // 红润
        addSkinBeautyItem(
            items,
            R.string.beauty_effect_redness,
            R.drawable.beauty_ic_effect_redness,
            beautyConfig.redness
        ) { value ->
            beautyConfig.redness = value
        }
        // 清晰度
        addSkinBeautyItem(
            items,
            R.string.beauty_effect_contrast_strength,
            R.drawable.beauty_ic_effect_contrast_strength,
            beautyConfig.contrastStrength,
            valueRange = -1.0f..1.0f
        ) { value ->
            beautyConfig.contrastStrength = value
        }
        // 锐化
        addSkinBeautyItem(
            items,
            R.string.beauty_effect_sharpness,
            R.drawable.beauty_ic_effect_sharpness,
            beautyConfig.sharpness
        ) { value ->
            beautyConfig.sharpness = value
        }
        // 去黑眼圈
        addSkinBeautyItem(
            items,
            R.string.beauty_effect_eye_pouch,
            R.drawable.beauty_ic_effect_eye_pouch,
            beautyConfig.eyePouch
        ) { value ->
            beautyConfig.eyePouch = value
        }
        // 亮眼
        addSkinBeautyItem(
            items,
            R.string.beauty_effect_brighten_eye,
            R.drawable.beauty_ic_effect_brighten_eye,
            beautyConfig.brightenEye
        ) { value ->
            beautyConfig.brightenEye = value
        }
        // 白牙
        addSkinBeautyItem(
            items,
            R.string.beauty_effect_whiten_teeth,
            R.drawable.beauty_ic_effect_whiten_teeth,
            beautyConfig.whitenTeeth
        ) { value ->
            beautyConfig.whitenTeeth = value
        }
        // 去法令纹
        addSkinBeautyItem(
            items,
            R.string.beauty_effect_nasolabial_fold,
            R.drawable.beauty_ic_effect_nasolabial_fold,
            beautyConfig.nasolabialFold
        ) { value ->
            beautyConfig.nasolabialFold = value
        }
    }

    /**
     * 添加单个美肤参数项
     *
     * @param items 功能项列表
     * @param nameRes 参数名称资源ID
     * @param iconRes 图标资源ID
     * @param currentValue 当前值
     * @param isSelected 是否选中（默认false）
     * @param valueRange 值范围（默认0.0f..1.0f）
     * @param onValueChanged 值变化回调
     */
    private fun addSkinBeautyItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        currentValue: Float,
        isSelected: Boolean = false,
        valueRange: ClosedFloatingPointRange<Float> = 0.0f..1.0f,
        onValueChanged: (Float) -> Unit
    ) {
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                currentValue,
                isSelected = isSelected,
                valueRange = valueRange,
                onValueChanged = onValueChanged
            )
        )
    }

    /**
     * 添加美型参数
     */
    private fun addFaceShapeItems(items: MutableList<BeautyItemInfo>) {
        // 脸部轮廓
        // 瘦脸
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_face_contour,
            R.drawable.beauty_ic_face_shape_face_contour,
            beautyConfig.faceContour
        ) { value ->
            beautyConfig.faceContour = value
        }
        // v脸
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_mandible,
            R.drawable.beauty_ic_face_shape_mandible,
            beautyConfig.mandible
        ) { value ->
            beautyConfig.mandible = value
        }
        // 瘦下巴
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_chin,
            R.drawable.beauty_ic_face_shape_chin,
            beautyConfig.chin,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.chin = value
        }
        // 下颌线
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_cheek,
            R.drawable.beauty_ic_face_shape_cheek,
            beautyConfig.cheek
        ) { value ->
            beautyConfig.cheek = value
        }
        // 瘦颧骨
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_cheekbone,
            R.drawable.beauty_ic_face_shape_cheekbone,
            beautyConfig.cheekbone
        ) { value ->
            beautyConfig.cheekbone = value
        }
        // 长脸
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_face_length,
            R.drawable.beauty_ic_face_shape_face_length,
            beautyConfig.faceLength,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.faceLength = value
        }
        // 窄脸
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_face_width,
            R.drawable.beauty_ic_face_shape_face_width,
            beautyConfig.faceWidth
        ) { value ->
            beautyConfig.faceWidth = value
        }
        // 发际线
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_fore_head,
            R.drawable.beauty_ic_face_shape_fore_head,
            beautyConfig.foreHead
        ) { value ->
            beautyConfig.foreHead = value
        }
        // 小头
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_head_scale,
            R.drawable.beauty_ic_face_shape_head_scale,
            beautyConfig.headScale
        ) { value ->
            beautyConfig.headScale = value
        }

        // 鼻子
        // 瘦鼻
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_nose_width,
            R.drawable.beauty_ic_face_shape_nose_width,
            beautyConfig.noseWidth
        ) { value ->
            beautyConfig.noseWidth = value
        }
        // 山根
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_nose_root,
            R.drawable.beauty_ic_face_shape_nose_root,
            beautyConfig.noseRoot
        ) { value ->
            beautyConfig.noseRoot = value
        }
        // 鼻梁
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_nose_bridge,
            R.drawable.beauty_ic_face_shape_nose_bridge,
            beautyConfig.noseBridge
        ) { value ->
            beautyConfig.noseBridge = value
        }
        // 鼻尖
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_nose_tip,
            R.drawable.beauty_ic_face_shape_nose_tip,
            beautyConfig.noseTip
        ) { value ->
            beautyConfig.noseTip = value
        }
        // 鼻翼
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_nose_wing,
            R.drawable.beauty_ic_face_shape_nose_wing,
            beautyConfig.noseWing
        ) { value ->
            beautyConfig.noseWing = value
        }
        // 长鼻
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_nose_length,
            R.drawable.beauty_ic_face_shape_nose_length,
            beautyConfig.noseLength,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.noseLength = value
        }
        // 鼻综合
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_nose_general,
            R.drawable.beauty_ic_face_shape_nose_general,
            beautyConfig.noseGeneral,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.noseGeneral = value
        }

        // 眼睛
        // 大眼
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_eye_scale,
            R.drawable.beauty_ic_face_shape_eye_scale,
            beautyConfig.eyeScale
        ) { value ->
            beautyConfig.eyeScale = value
        }
        // 眼距
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_eye_distance,
            R.drawable.beauty_ic_face_shape_eye_distance,
            beautyConfig.eyeDistance,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.eyeDistance = value
        }
        // 眼睑下至
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_eye_lid,
            R.drawable.beauty_ic_face_shape_eye_lid,
            beautyConfig.eyeLid
        ) { value ->
            beautyConfig.eyeLid = value
        }
        // 内眼角
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_inner_corner,
            R.drawable.beauty_ic_face_shape_inner_corner,
            beautyConfig.eyeInnerCorner,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.eyeInnerCorner = value
        }
        // 外眼角
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_outer_corner,
            R.drawable.beauty_ic_face_shape_outer_corner,
            beautyConfig.eyeOuterCorner,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.eyeOuterCorner = value
        }
        // 眼移动
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_eye_position,
            R.drawable.beauty_ic_face_shape_eye_position,
            beautyConfig.eyePosition,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.eyePosition = value
        }
        // 瞳孔
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_eye_pupils,
            R.drawable.beauty_ic_face_shape_eye_pupils,
            beautyConfig.eyePupils
        ) { value ->
            beautyConfig.eyePupils = value
        }

        // 嘴巴
        // 微笑唇
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_mouth_smile,
            R.drawable.beauty_ic_face_shape_mouth_smile,
            beautyConfig.mouthSmile
        ) { value ->
            beautyConfig.mouthSmile = value
        }
        // 丰唇
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_mouth_lip,
            R.drawable.beauty_ic_face_shape_mouth_lip,
            beautyConfig.mouthLip
        ) { value ->
            beautyConfig.mouthLip = value
        }
        // 嘴型
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_mouth_scale,
            R.drawable.beauty_ic_face_shape_mouth_scale,
            beautyConfig.mouthScale,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.mouthScale = value
        }
        // 缩人中
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_mouth_position,
            R.drawable.beauty_ic_face_shape_mouth_position,
            beautyConfig.mouthPosition
        ) { value ->
            beautyConfig.mouthPosition = value
        }

        // 眉毛
        // 眉粗细
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_eyebrow_thickness,
            R.drawable.beauty_ic_face_shape_eyebrow_thickness,
            beautyConfig.eyebrowThickness,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.eyebrowThickness = value
        }
        // 眉上下
        addFaceShapeItem(
            items,
            R.string.beauty_face_shape_eyebrow_position,
            R.drawable.beauty_ic_face_shape_eyebrow_position,
            beautyConfig.eyebrowPosition,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.eyebrowPosition = value
        }
    }

    /**
     * 添加单个美型参数项
     *
     * @param items 功能项列表
     * @param nameRes 参数名称资源ID
     * @param iconRes 图标资源ID
     * @param currentValue 当前值（Int类型，会自动转换为Float显示）
     * @param valueRange 值范围（默认0f..100f）
     * @param onValueChanged 值变化回调（接收Int值）
     */
    private fun addFaceShapeItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        currentValue: Int,
        valueRange: ClosedFloatingPointRange<Float> = 0f..100f,
        onValueChanged: (Int) -> Unit
    ) {
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                currentValue.toFloat(),
                valueRange = valueRange,
                onValueChanged = { value ->
                    onValueChanged(value.toInt())
                }
            )
        )
    }

    /**
     * 添加画质参数
     * 顺序：色调、色温、饱和度、亮度
     */
    private fun addQualityItems(items: MutableList<BeautyItemInfo>) {
        // 色温
        addQualityItem(
            items,
            R.string.beauty_effect_temperature,
            R.drawable.beauty_ic_effect_temperature,
            beautyConfig.temperature
        ) { value ->
            beautyConfig.temperature = value
        }
        // 色调
        addQualityItem(
            items,
            R.string.beauty_effect_hue,
            R.drawable.beauty_ic_effect_hue,
            beautyConfig.hue
        ) { value ->
            beautyConfig.hue = value
        }
        // 饱和度
        addQualityItem(
            items,
            R.string.beauty_effect_saturation,
            R.drawable.beauty_ic_effect_saturation,
            beautyConfig.saturation
        ) { value ->
            beautyConfig.saturation = value
        }
        // 亮度
        addQualityItem(
            items,
            R.string.beauty_effect_brightness,
            R.drawable.beauty_ic_effect_brightness,
            beautyConfig.brightness
        ) { value ->
            beautyConfig.brightness = value
        }
    }

    /**
     * 添加单个画质参数项
     *
     * @param items 功能项列表
     * @param nameRes 参数名称资源ID
     * @param iconRes 图标资源ID
     * @param currentValue 当前值
     * @param onValueChanged 值变化回调
     */
    private fun addQualityItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        currentValue: Float,
        onValueChanged: (Float) -> Unit
    ) {
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                currentValue,
                valueRange = -1.0f..1.0f,
                onValueChanged = onValueChanged
            )
        )
    }
}