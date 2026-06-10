package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule
import cn.shengwang.beauty.ui.model.BeautyPageInfo

/**
 * 画质模块页面构建器
 * 负责构建画质（色温、色调、饱和度、亮度）模块的页面信息
 */
internal class QualityPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val qualityItems = mutableListOf<BeautyItemInfo>()

        val isEnabled = beautyConfig.qualityEnable
        val toggleItem = BeautyItemInfo(
            name = if (isEnabled) R.string.beauty_effect_enable else R.string.beauty_effect_disable,
            icon = if (isEnabled) R.drawable.beauty_switcher_on else R.drawable.beauty_switcher_off,
            isSelected = isEnabled,
            showSlider = false,
            type = BeautyItemType.TOGGLE,
            onItemClick = {
                beautyConfig.qualityEnable = !beautyConfig.qualityEnable
            }
        )
        qualityItems.add(toggleItem)

        // 色温
        addQualityItem(qualityItems, R.string.beauty_effect_temperature, R.drawable.beauty_ic_effect_temperature, beautyConfig.temperature, toggleItem) { value ->
            beautyConfig.temperature = value
        }
        // 色调
        addQualityItem(qualityItems, R.string.beauty_effect_hue, R.drawable.beauty_ic_effect_hue, beautyConfig.hue, toggleItem) { value ->
            beautyConfig.hue = value
        }
        // 亮度
        addQualityItem(qualityItems, R.string.beauty_effect_brightness, R.drawable.beauty_ic_effect_brightness, beautyConfig.brightness, toggleItem) { value ->
            beautyConfig.brightness = value
        }
        // 饱和度
        addQualityItem(qualityItems, R.string.beauty_effect_saturation, R.drawable.beauty_ic_effect_saturation, beautyConfig.saturation, toggleItem) { value ->
            beautyConfig.saturation = value
        }

        return BeautyPageInfo(
            R.string.beauty_group_quality,
            qualityItems,
            type = BeautyModule.BEAUTY
        )
    }

    private fun addQualityItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        currentValue: Float,
        toggleItem: BeautyItemInfo,
        onValueChanged: (Float) -> Unit
    ) {
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                currentValue * 50f,  // -1.0~1.0 → -50~50
                valueRange = -50f..50f,
                onValueChanged = { uiVal ->
                    onValueChanged(uiVal / 50f)  // -50~50 → -1.0~1.0
                },
                onItemClick = { _ ->
                    beautyConfig.setQualityEnableInternal(true)
                    // Update toggle item so cell renders as "on"
                    toggleItem.name = R.string.beauty_effect_enable
                    toggleItem.icon = R.drawable.beauty_switcher_on
                    toggleItem.isSelected = true
                }
            )
        )
    }
}
