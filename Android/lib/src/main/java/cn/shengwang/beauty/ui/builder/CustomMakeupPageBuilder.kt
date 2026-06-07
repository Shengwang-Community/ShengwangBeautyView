package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule
import cn.shengwang.beauty.ui.model.BeautyPageInfo

/**
 * 自定义美妆模块页面构建器
 * 负责构建自定义美妆模块的页面信息，采用二级菜单结构：
 * - 一级：分类入口（口红、腮红、修容、眼影、修眉、睫毛、美瞳）
 * - 二级：每个分类下的具体选项
 */
internal class CustomMakeupPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val items = mutableListOf<BeautyItemInfo>()

        val isEnabled = beautyConfig.customMakeupEnable
        items.add(
            BeautyItemInfo(
                name = if (isEnabled) R.string.beauty_effect_enable else R.string.beauty_effect_disable,
                icon = if (isEnabled) R.drawable.beauty_switcher_on else R.drawable.beauty_switcher_off,
                isSelected = isEnabled,
                showSlider = false,
                type = BeautyItemType.TOGGLE,
                onItemClick = {
                    beautyConfig.customMakeupEnable = !beautyConfig.customMakeupEnable
                }
            )
        )

        items.add(buildCategoryItem(R.string.beauty_custom_makeup_lipstick, R.drawable.beauty_ic_makeup_category_lipstick, buildLipstickItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_blush, R.drawable.beauty_ic_makeup_category_blush, buildBlushItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_contour, R.drawable.beauty_ic_makeup_category_contour, buildContourItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_eyeshadow, R.drawable.beauty_ic_makeup_category_shadow, buildEyeshadowItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_eyebrow, R.drawable.beauty_ic_makeup_category_eyebrow, buildEyebrowItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_lash, R.drawable.beauty_ic_makeup_category_lash, buildLashItems()))
        items.add(buildCategoryItem(R.string.beauty_custom_makeup_pupil, R.drawable.beauty_ic_makeup_category_pupil, buildPupilItems()))

        return BeautyPageInfo(
            R.string.beauty_group_custom_makeup,
            items,
            type = BeautyModule.STYLE_MAKEUP
        )
    }

    private fun buildCategoryItem(nameRes: Int, iconRes: Int, subItems: List<BeautyItemInfo>) = BeautyItemInfo(
        name = nameRes,
        icon = iconRes,
        showSlider = false,
        type = BeautyItemType.SUB_MENU,
        subItems = subItems
    )

    // ==================== 二级子项构建辅助方法 ====================

    private fun buildSubLipstickItem(nameRes: Int, iconRes: Int, style: Int, color: Int) =
        BeautyItemInfo(
            name = nameRes, icon = iconRes,
            value = beautyConfig.customLipstickStrength,
            isSelected = beautyConfig.customLipstickStyle == style,
            valueRange = 0f..1.0f, itemStyle = style, itemColor = color,
            onValueChanged = { value -> beautyConfig.customLipstickStrength = value },
            onItemClick = { itemInfo ->
                beautyConfig.setCustomMakeupEnableInternal(true)
                beautyConfig.customLipstickStyle = itemInfo.itemStyle
                beautyConfig.customLipstickColor = itemInfo.itemColor
                itemInfo.value = beautyConfig.customLipstickStrength
            }
        )

    private fun buildSubBlushItem(nameRes: Int, iconRes: Int, style: Int, color: Int) =
        BeautyItemInfo(
            name = nameRes, icon = iconRes,
            value = beautyConfig.customBlushStrength,
            isSelected = beautyConfig.customBlushStyle == style,
            valueRange = 0f..1.0f, itemStyle = style, itemColor = color,
            onValueChanged = { value -> beautyConfig.customBlushStrength = value },
            onItemClick = { itemInfo ->
                beautyConfig.setCustomMakeupEnableInternal(true)
                beautyConfig.customBlushStyle = itemInfo.itemStyle
                beautyConfig.customBlushColor = itemInfo.itemColor
                itemInfo.value = beautyConfig.customBlushStrength
            }
        )

    private fun buildSubFacialItem(nameRes: Int, iconRes: Int, style: Int) =
        BeautyItemInfo(
            name = nameRes, icon = iconRes,
            value = beautyConfig.customFacialStrength,
            isSelected = beautyConfig.customFacialStyle == style,
            valueRange = 0f..1.0f, itemStyle = style,
            onValueChanged = { value -> beautyConfig.customFacialStrength = value },
            onItemClick = { itemInfo ->
                beautyConfig.setCustomMakeupEnableInternal(true)
                beautyConfig.customFacialStyle = itemInfo.itemStyle
                itemInfo.value = beautyConfig.customFacialStrength
            }
        )

    private fun buildSubShadowItem(nameRes: Int, iconRes: Int, style: Int) =
        BeautyItemInfo(
            name = nameRes, icon = iconRes,
            value = beautyConfig.customEyeshadowStrength,
            isSelected = beautyConfig.customEyeshadowStyle == style,
            valueRange = 0f..1.0f, itemStyle = style,
            onValueChanged = { value -> beautyConfig.customEyeshadowStrength = value },
            onItemClick = { itemInfo ->
                beautyConfig.setCustomMakeupEnableInternal(true)
                beautyConfig.customEyeshadowStyle = itemInfo.itemStyle
                itemInfo.value = beautyConfig.customEyeshadowStrength
            }
        )

    private fun buildSubEyebrowItem(nameRes: Int, iconRes: Int, style: Int) =
        BeautyItemInfo(
            name = nameRes, icon = iconRes,
            value = beautyConfig.customEyebrowStrength,
            isSelected = beautyConfig.customEyebrowStyle == style,
            valueRange = 0f..1.0f, itemStyle = style,
            onValueChanged = { value -> beautyConfig.customEyebrowStrength = value },
            onItemClick = { itemInfo ->
                beautyConfig.setCustomMakeupEnableInternal(true)
                beautyConfig.customEyebrowStyle = itemInfo.itemStyle
                itemInfo.value = beautyConfig.customEyebrowStrength
            }
        )

    private fun buildSubLashItem(nameRes: Int, iconRes: Int, style: Int, color: Int) =
        BeautyItemInfo(
            name = nameRes, icon = iconRes,
            value = beautyConfig.customLashStrength,
            isSelected = beautyConfig.customLashStyle == style,
            valueRange = 0f..1.0f, itemStyle = style, itemColor = color,
            onValueChanged = { value -> beautyConfig.customLashStrength = value },
            onItemClick = { itemInfo ->
                beautyConfig.setCustomMakeupEnableInternal(true)
                beautyConfig.customLashStyle = itemInfo.itemStyle
                beautyConfig.customLashColor = itemInfo.itemColor
                itemInfo.value = beautyConfig.customLashStrength
            }
        )

    private fun buildSubPupilItem(nameRes: Int, iconRes: Int, style: Int) =
        BeautyItemInfo(
            name = nameRes, icon = iconRes,
            value = beautyConfig.customPupilStrength,
            isSelected = beautyConfig.customPupilStyle == style,
            valueRange = 0f..1.0f, itemStyle = style,
            onValueChanged = { value -> beautyConfig.customPupilStrength = value },
            onItemClick = { itemInfo ->
                beautyConfig.setCustomMakeupEnableInternal(true)
                beautyConfig.customPupilStyle = itemInfo.itemStyle
                itemInfo.value = beautyConfig.customPupilStrength
            }
        )

    // ==================== 各分类子项列表 ====================

    private fun buildLipstickItems() = listOf(
        BeautyItemInfo(R.string.beauty_effect_none, R.drawable.beauty_ic_none, isSelected = beautyConfig.customLipstickStyle == 0, showSlider = false, type = BeautyItemType.NONE, onItemClick = { beautyConfig.customLipstickStyle = 0 }),
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_cherry, R.drawable.beauty_ic_makeup_lipstick_001, style = 1, color = 0),
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_glossy, R.drawable.beauty_ic_makeup_lipstick_003, style = 3, color = 7),
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_matte, R.drawable.beauty_ic_makeup_lipstick_004, style = 4, color = 9),
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_bitten, R.drawable.beauty_ic_makeup_lipstick_005, style = 5, color = 0),
        buildSubLipstickItem(R.string.beauty_custom_makeup_lipstick_ombre, R.drawable.beauty_ic_makeup_lipstick_006, style = 6, color = 0)
    )

    private fun buildBlushItems() = listOf(
        BeautyItemInfo(R.string.beauty_effect_none, R.drawable.beauty_ic_none, isSelected = beautyConfig.customBlushStyle == 0, showSlider = false, type = BeautyItemType.NONE, onItemClick = { beautyConfig.customBlushStyle = 0 }),
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_powder, R.drawable.beauty_ic_makeup_blush_001, style = 1, color = 0),
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_peach, R.drawable.beauty_ic_makeup_blush_003, style = 3, color = 2),
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_tipsy, R.drawable.beauty_ic_makeup_blush_004, style = 2, color = 0),
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_enchanted, R.drawable.beauty_ic_makeup_blush_008, style = 8, color = 3),
        buildSubBlushItem(R.string.beauty_custom_makeup_blush_cloud, R.drawable.beauty_ic_makeup_blush_010, style = 10, color = 0)
    )

    private fun buildContourItems() = listOf(
        BeautyItemInfo(R.string.beauty_effect_none, R.drawable.beauty_ic_none, isSelected = beautyConfig.customFacialStyle == 0, showSlider = false, type = BeautyItemType.NONE, onItemClick = { beautyConfig.customFacialStyle = 0 }),
        buildSubFacialItem(R.string.beauty_custom_makeup_contour_sculpt, R.drawable.beauty_ic_makeup_contour_001, style = 1),
        buildSubFacialItem(R.string.beauty_custom_makeup_contour_even, R.drawable.beauty_ic_makeup_contour_009, style = 9),
        buildSubFacialItem(R.string.beauty_custom_makeup_contour_plump, R.drawable.beauty_ic_makeup_contour_003, style = 3),
        buildSubFacialItem(R.string.beauty_custom_makeup_contour_contour, R.drawable.beauty_ic_makeup_contour_006, style = 6),
        buildSubFacialItem(R.string.beauty_custom_makeup_contour_highlight, R.drawable.beauty_ic_makeup_contour_008, style = 8)
    )

    private fun buildEyeshadowItems() = listOf(
        BeautyItemInfo(R.string.beauty_effect_none, R.drawable.beauty_ic_none, isSelected = beautyConfig.customEyeshadowStyle == 0, showSlider = false, type = BeautyItemType.NONE, onItemClick = { beautyConfig.customEyeshadowStyle = 0 }),
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_violet, R.drawable.beauty_ic_makeup_eyeshadow_001, style = 2),
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_rose, R.drawable.beauty_ic_makeup_eyeshadow_009, style = 9),
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_berry, R.drawable.beauty_ic_makeup_eyeshadow_003, style = 11),
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_earth, R.drawable.beauty_ic_makeup_eyeshadow_004, style = 4),
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_korean, R.drawable.beauty_ic_makeup_eyeshadow_005, style = 5),
        buildSubShadowItem(R.string.beauty_custom_makeup_eyeshadow_apricot, R.drawable.beauty_ic_makeup_eyeshadow_007, style = 7)
    )

    private fun buildEyebrowItems() = listOf(
        BeautyItemInfo(R.string.beauty_effect_none, R.drawable.beauty_ic_none, isSelected = beautyConfig.customEyebrowStyle == 0, showSlider = false, type = BeautyItemType.NONE, onItemClick = { beautyConfig.customEyebrowStyle = 0 }),
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_lady, R.drawable.beauty_ic_makeup_eyebrow_001, style = 1),
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_gentle, R.drawable.beauty_ic_makeup_eyebrow_002, style = 2),
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_standard, R.drawable.beauty_ic_makeup_eyebrow_003, style = 3),
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_willow, R.drawable.beauty_ic_makeup_eyebrow_004, style = 4),
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_fluffy, R.drawable.beauty_ic_makeup_eyebrow_005, style = 5),
        buildSubEyebrowItem(R.string.beauty_custom_makeup_eyebrow_wild, R.drawable.beauty_ic_makeup_eyebrow_006, style = 6)
    )

    private fun buildLashItems() = listOf(
        BeautyItemInfo(R.string.beauty_effect_none, R.drawable.beauty_ic_none, isSelected = beautyConfig.customLashStyle == 0, showSlider = false, type = BeautyItemType.NONE, onItemClick = { beautyConfig.customLashStyle = 0 }),
        buildSubLashItem(R.string.beauty_custom_makeup_lash_delicate, R.drawable.beauty_ic_makeup_lash_002, style = 2, color = 1),
        buildSubLashItem(R.string.beauty_custom_makeup_lash_wing, R.drawable.beauty_ic_makeup_lash_003, style = 3, color = 0),
        buildSubLashItem(R.string.beauty_custom_makeup_lash_curly, R.drawable.beauty_ic_makeup_lash_004, style = 4, color = 1),
        buildSubLashItem(R.string.beauty_custom_makeup_lash_comic, R.drawable.beauty_ic_makeup_lash_005, style = 5, color = 0),
        buildSubLashItem(R.string.beauty_custom_makeup_lash_rise, R.drawable.beauty_ic_makeup_lash_009, style = 9, color = 1)
    )

    private fun buildPupilItems() = listOf(
        BeautyItemInfo(R.string.beauty_effect_none, R.drawable.beauty_ic_none, isSelected = beautyConfig.customPupilStyle == 0, showSlider = false, type = BeautyItemType.NONE, onItemClick = { beautyConfig.customPupilStyle = 0 }),
        buildSubPupilItem(R.string.beauty_custom_makeup_pupil_hazel, R.drawable.beauty_ic_makeup_pupil_001, style = 1),
        buildSubPupilItem(R.string.beauty_custom_makeup_pupil_skyblue, R.drawable.beauty_ic_makeup_pupil_002, style = 2),
        buildSubPupilItem(R.string.beauty_custom_makeup_pupil_green, R.drawable.beauty_ic_makeup_pupil_003, style = 3),
        buildSubPupilItem(R.string.beauty_custom_makeup_pupil_gray, R.drawable.beauty_ic_makeup_pupil_004, style = 4),
        buildSubPupilItem(R.string.beauty_custom_makeup_pupil_mars, R.drawable.beauty_ic_makeup_pupil_005, style = 5),
        buildSubPupilItem(R.string.beauty_custom_makeup_pupil_natural, R.drawable.beauty_ic_makeup_pupil_007, style = 7)
    )
}
