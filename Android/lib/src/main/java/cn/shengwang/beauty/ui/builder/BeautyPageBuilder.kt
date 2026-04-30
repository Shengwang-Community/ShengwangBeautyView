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

        // 磨皮
        addSkinBeautyItem(
            beautyItems,
            R.string.beauty_effect_smoothness,
            R.drawable.beauty_ic_effect_smoothness,
            beautyConfig.smoothness,
            isSelected = beautyConfig.beautyEnable
        ) { value ->
            beautyConfig.smoothness = value
        }
        // 美白（二级菜单入口）
        val whitenSubItems = listOf(
            // 无
            BeautyItemInfo(
                name = R.string.beauty_effect_none,
                icon = R.drawable.beauty_ic_none,
                showSlider = false,
                onItemClick = { _ ->
                    beautyConfig.whitenNatural = 0f
                    beautyConfig.whitenLut = ""
                }
            ),
            // 自然
            BeautyItemInfo(
                name = R.string.beauty_effect_lightness_natural,
                icon = R.drawable.beauty_ic_effect_lightness,
                value = beautyConfig.whitenNatural,
                valueRange = 0f..1.0f,
                onValueChanged = { value ->
                    beautyConfig.whitenNatural = value
                },
                onItemClick = { itemInfo ->
                    beautyConfig.whitenLut = ""
                    itemInfo.value = beautyConfig.whitenNatural
                }
            ),
            // 白皙
            BeautyItemInfo(
                name = R.string.beauty_effect_lightness_fair,
                icon = R.drawable.beauty_ic_effect_lightness,
                value = beautyConfig.whitenNatural,
                valueRange = 0f..1.0f,
                onValueChanged = { value ->
                    beautyConfig.whitenNatural = value
                },
                onItemClick = { itemInfo ->
                    beautyConfig.whitenLut = "../resource/whiten/lengbai.png"
                    itemInfo.value = beautyConfig.whitenNatural
                }
            ),
            // 粉白
            BeautyItemInfo(
                name = R.string.beauty_effect_lightness_pink,
                icon = R.drawable.beauty_ic_effect_lightness,
                value = beautyConfig.whitenNatural,
                valueRange = 0f..1.0f,
                onValueChanged = { value ->
                    beautyConfig.whitenNatural = value
                },
                onItemClick = { itemInfo ->
                    beautyConfig.whitenLut = "../resource/whiten/fenbai.png"
                    itemInfo.value = beautyConfig.whitenNatural
                }
            ),
            // 超白
            BeautyItemInfo(
                name = R.string.beauty_effect_lightness_ultra,
                icon = R.drawable.beauty_ic_effect_lightness,
                value = beautyConfig.whitenNatural,
                valueRange = 0f..1.0f,
                onValueChanged = { value ->
                    beautyConfig.whitenNatural = value
                },
                onItemClick = { itemInfo ->
                    beautyConfig.whitenLut = "../resource/whiten/chaobai.png"
                    itemInfo.value = beautyConfig.whitenNatural
                }
            )
        )
        beautyItems.add(
            BeautyItemInfo(
                name = R.string.beauty_effect_lightness,
                icon = R.drawable.beauty_ic_effect_lightness,
                showSlider = false,
                type = BeautyItemType.SUB_MENU,
                subItems = whitenSubItems
            )
        )

        // 清晰
        addSkinBeautyItem(
            beautyItems,
            R.string.beauty_effect_contrast_strength,
            R.drawable.beauty_ic_effect_contrast_strength,
            beautyConfig.contrastStrength,
            valueRange = -1.0f..1.0f
        ) { value ->
            beautyConfig.contrastStrength = value
        }

        // 瘦脸（二级菜单入口）
        val faceSlimSubItems = listOf(
            // 瘦脸（原子参数）
            BeautyItemInfo(
                name = R.string.beauty_face_shape_face_contour,
                icon = R.drawable.beauty_ic_face_shape_face_contour,
                value = beautyConfig.faceContour.toFloat(),
                valueRange = 0f..100f,
                onValueChanged = { value ->
                    beautyConfig.faceContour = value.toInt()
                },
                onItemClick = {
                    beautyConfig.faceShapeStyle = -1
                }
            ),
            // 女神
            BeautyItemInfo(
                name = R.string.beauty_face_shape_face_slim_goddess,
                icon = R.drawable.beauty_ic_face_shape_face_contour,
                value = beautyConfig.faceShapeIntensity.toFloat(),
                valueRange = 0f..100f,
                onValueChanged = { value ->
                    beautyConfig.faceContour = value.toInt()
                    beautyConfig.faceShapeIntensity = value.toInt()
                },
                onItemClick = {
                    beautyConfig.faceShapeStyle = 0
                }
            ),
            // 男神
            BeautyItemInfo(
                name = R.string.beauty_face_shape_face_slim_god,
                icon = R.drawable.beauty_ic_face_shape_face_contour,
                value = beautyConfig.faceShapeIntensity.toFloat(),
                valueRange = 0f..100f,
                onValueChanged = { value ->
                    beautyConfig.faceContour = value.toInt()
                    beautyConfig.faceShapeIntensity = value.toInt()
                },
                onItemClick = {
                    beautyConfig.faceShapeStyle = 1
                }
            ),
            // 自然
            BeautyItemInfo(
                name = R.string.beauty_face_shape_face_slim_natural,
                icon = R.drawable.beauty_ic_face_shape_face_contour,
                value = beautyConfig.faceShapeIntensity.toFloat(),
                valueRange = 0f..100f,
                onValueChanged = { value ->
                    beautyConfig.faceContour = value.toInt()
                    beautyConfig.faceShapeIntensity = value.toInt()
                },
                onItemClick = {
                    beautyConfig.faceShapeStyle = 2
                }
            )
        )
        beautyItems.add(
            BeautyItemInfo(
                name = R.string.beauty_face_shape_face_contour,
                icon = R.drawable.beauty_ic_face_shape_face_contour,
                showSlider = false,
                type = BeautyItemType.SUB_MENU,
                subItems = faceSlimSubItems
            )
        )

        // 小脸
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_face_small,
            R.drawable.beauty_ic_face_shape_face_length,
            beautyConfig.faceShort
        ) { value ->
            beautyConfig.faceShort = value
        }

        // 窄脸
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_face_width,
            R.drawable.beauty_ic_face_shape_face_width,
            beautyConfig.faceWidth
        ) { value ->
            beautyConfig.faceWidth = value
        }

        // 瘦颧骨
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_cheekbone,
            R.drawable.beauty_ic_face_shape_cheekbone,
            beautyConfig.cheekbone
        ) { value ->
            beautyConfig.cheekbone = value
        }

        // 瘦下颌骨
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_cheek,
            R.drawable.beauty_ic_face_shape_cheek,
            beautyConfig.cheek
        ) { value ->
            beautyConfig.cheek = value
        }

        // 瘦下巴
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_chin,
            R.drawable.beauty_ic_face_shape_chin,
            beautyConfig.chin,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.chin = value
        }

        // 额头
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_fore_head,
            R.drawable.beauty_ic_face_shape_fore_head,
            beautyConfig.foreHead
        ) { value ->
            beautyConfig.foreHead = value
        }

        // 去法令纹
        addSkinBeautyItem(
            beautyItems,
            R.string.beauty_effect_nasolabial_fold,
            R.drawable.beauty_ic_effect_nasolabial_fold,
            beautyConfig.nasolabialFold
        ) { value ->
            beautyConfig.nasolabialFold = value
        }

        // 大眼
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_eye_scale,
            R.drawable.beauty_ic_face_shape_eye_scale,
            beautyConfig.eyeScale
        ) { value ->
            beautyConfig.eyeScale = value
        }

        // 眼移动
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_eye_position,
            R.drawable.beauty_ic_face_shape_eye_position,
            beautyConfig.eyePosition,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.eyePosition = value
        }

        // 眼距
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_eye_distance,
            R.drawable.beauty_ic_face_shape_eye_distance,
            beautyConfig.eyeDistance,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.eyeDistance = value
        }

        // 眼角度
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_eye_angle,
            R.drawable.beauty_ic_face_shape_eye_scale,
            beautyConfig.eyeAngle,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.eyeAngle = value
        }

        // 亮眼
        addSkinBeautyItem(
            beautyItems,
            R.string.beauty_effect_brighten_eye,
            R.drawable.beauty_ic_effect_brighten_eye,
            beautyConfig.brightenEye
        ) { value ->
            beautyConfig.brightenEye = value
        }

        // 去黑眼圈
        addSkinBeautyItem(
            beautyItems,
            R.string.beauty_effect_eye_pouch,
            R.drawable.beauty_ic_effect_eye_pouch,
            beautyConfig.eyePouch
        ) { value ->
            beautyConfig.eyePouch = value
        }

        // 瘦鼻
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_nose_width,
            R.drawable.beauty_ic_face_shape_nose_width,
            beautyConfig.noseWidth
        ) { value ->
            beautyConfig.noseWidth = value
        }

        // 长鼻
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_nose_length,
            R.drawable.beauty_ic_face_shape_nose_length,
            beautyConfig.noseLength,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.noseLength = value
        }

        // 嘴巴
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_mouth_scale,
            R.drawable.beauty_ic_face_shape_mouth_scale,
            beautyConfig.mouthScale,
            valueRange = -100f..100f
        ) { value ->
            beautyConfig.mouthScale = value
        }

        // 缩人中
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_mouth_position,
            R.drawable.beauty_ic_face_shape_mouth_position,
            beautyConfig.mouthPosition
        ) { value ->
            beautyConfig.mouthPosition = value
        }

        // 微笑唇
        addFaceShapeItem(
            beautyItems,
            R.string.beauty_face_shape_mouth_smile,
            R.drawable.beauty_ic_face_shape_mouth_smile,
            beautyConfig.mouthSmile
        ) { value ->
            beautyConfig.mouthSmile = value
        }

        // 美牙
        addSkinBeautyItem(
            beautyItems,
            R.string.beauty_effect_whiten_teeth,
            R.drawable.beauty_ic_effect_whiten_teeth,
            beautyConfig.whitenTeeth
        ) { value ->
            beautyConfig.whitenTeeth = value
        }

        return BeautyPageInfo(
            R.string.beauty_group_beauty,
            beautyItems,
            type = BeautyModule.BEAUTY
        )
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

}