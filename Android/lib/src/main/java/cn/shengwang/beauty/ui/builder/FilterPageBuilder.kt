package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.core.FilterNames
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyPageInfo
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule

/**
 * 滤镜模块页面构建器
 * 负责构建滤镜模块的页面信息
 * 
 * 注意：此构建器为内部实现，不对外暴露
 */
internal class FilterPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val filterItems = mutableListOf<BeautyItemInfo>()

        filterItems.add(
            BeautyItemInfo(
                R.string.beauty_effect_none,
                R.drawable.beauty_ic_none,
                isSelected = beautyConfig.filterName == null,
                showSlider = false,
                type = BeautyItemType.NONE,
                onItemClick = {
                    beautyConfig.filterName = null
                }
            )
        )

        // 滤镜选项
        // 暖色系
        // 沉稳
        addFilterItem(
            filterItems,
            R.string.beauty_filter_serene,
            R.drawable.beauty_ic_filter_serene,
            FilterNames.SERENE
        )
        // 都市
        addFilterItem(
            filterItems,
            R.string.beauty_filter_urban,
            R.drawable.beauty_ic_filter_urban,
            FilterNames.URBAN
        )
        // 流光
        addFilterItem(
            filterItems,
            R.string.beauty_filter_glow,
            R.drawable.beauty_ic_filter_glow,
            FilterNames.GLOW
        )
        // 流金
        addFilterItem(
            filterItems,
            R.string.beauty_filter_gilt,
            R.drawable.beauty_ic_filter_gilt,
            FilterNames.GILT
        )
        // 奶油
        addFilterItem(
            filterItems,
            R.string.beauty_filter_cream,
            R.drawable.beauty_ic_filter_cream,
            FilterNames.CREAM
        )
        // 拿铁
        addFilterItem(
            filterItems,
            R.string.beauty_filter_latte,
            R.drawable.beauty_ic_filter_latte,
            FilterNames.LATTE
        )
        // 柠夏
        addFilterItem(
            filterItems,
            R.string.beauty_filter_summer,
            R.drawable.beauty_ic_filter_summer,
            FilterNames.SUMMER
        )
        // 日常
        addFilterItem(
            filterItems,
            R.string.beauty_filter_daily,
            R.drawable.beauty_ic_filter_daily,
            FilterNames.DAILY
        )
        // 绅士
        addFilterItem(
            filterItems,
            R.string.beauty_filter_gentleman,
            R.drawable.beauty_ic_filter_genyleman,
            FilterNames.GENTLEMAN
        )
        // 香草
        addFilterItem(
            filterItems,
            R.string.beauty_filter_vanilla,
            R.drawable.beauty_ic_filter_vanila,
            FilterNames.VANILLA
        )

        // 冷/白色系
        // 白瓷
        addFilterItem(
            filterItems,
            R.string.beauty_filter_bright,
            R.drawable.beauty_ic_filter_bright,
            FilterNames.BRIGHT
        )
        // 白桃
        addFilterItem(
            filterItems,
            R.string.beauty_filter_peach,
            R.drawable.beauty_ic_filter_peach,
            FilterNames.PEACH
        )
        // 苍墨
        addFilterItem(
            filterItems,
            R.string.beauty_filter_ink,
            R.drawable.beauty_ic_filter_ink,
            FilterNames.INK
        )
        // 胶片
        addFilterItem(
            filterItems,
            R.string.beauty_filter_film,
            R.drawable.beauty_ic_filter_film,
            FilterNames.FILM
        )
        // 霁晴
        addFilterItem(
            filterItems,
            R.string.beauty_filter_sunny,
            R.drawable.beauty_ic_filter_sunny,
            FilterNames.SUNNY
        )
        // 漫画
        addFilterItem(
            filterItems,
            R.string.beauty_filter_comic,
            R.drawable.beauty_ic_filter_comic,
            FilterNames.COMIC
        )
        // 梦幻
        addFilterItem(
            filterItems,
            R.string.beauty_filter_dreamy,
            R.drawable.beauty_ic_filter_dreamy,
            FilterNames.DREAMY
        )
        // 棉绒
        addFilterItem(
            filterItems,
            R.string.beauty_filter_cotton,
            R.drawable.beauty_ic_filter_cotton,
            FilterNames.COTTON
        )
        // 苏打
        addFilterItem(
            filterItems,
            R.string.beauty_filter_soda,
            R.drawable.beauty_ic_filter_soda,
            FilterNames.SODA
        )
        // 月白
        addFilterItem(
            filterItems,
            R.string.beauty_filter_moonlight,
            R.drawable.beauty_ic_filter_moonlight,
            FilterNames.MOONLIGHT
        )

        // 氛围系
        // 白茶
        addFilterItem(
            filterItems,
            R.string.beauty_filter_white_tea,
            R.drawable.beauty_ic_filter_whitetea,
            FilterNames.WHITE_TEA
        )
        // 沉谧
        addFilterItem(
            filterItems,
            R.string.beauty_filter_tranquil,
            R.drawable.beauty_ic_filter_tranquil,
            FilterNames.TRANQUIL
        )
        // ins风
        addFilterItem(
            filterItems, 
            R.string.beauty_filter_insta_style, 
            R.drawable.beauty_ic_filter_ins,
            FilterNames.INSTA_STYLE
        )
        // 老街
        addFilterItem(
            filterItems,
            R.string.beauty_filter_street,
            R.drawable.beauty_ic_filter_street,
            FilterNames.STREET
        )
        // 泡芙
        addFilterItem(
            filterItems,
            R.string.beauty_filter_puff,
            R.drawable.beauty_ic_filter_puff,
            FilterNames.PUFF
        )
         // 私藏
         addFilterItem(
            filterItems,
            R.string.beauty_filter_collection,
            R.drawable.beauty_ic_filter_collection,
            FilterNames.COLLECTION
        )
        // 盐汽水
        addFilterItem(
            filterItems,
            R.string.beauty_filter_salty,
            R.drawable.beauty_ic_filter_salty,
            FilterNames.SALTY
        )
        // 质感
        addFilterItem(
            filterItems,
            R.string.beauty_filter_texture,
            R.drawable.beauty_ic_filter_texture,
            FilterNames.TEXTURE
        )
        // 气色
        addFilterItem(
            filterItems,
            R.string.beauty_filter_colorful,
            R.drawable.beauty_ic_filter_colorful,
            FilterNames.COLORFUL
        )

        // 环境系
        // 初雪
        addFilterItem(
            filterItems,
            R.string.beauty_filter_snow,
            R.drawable.beauty_ic_filter_snow,
            FilterNames.SNOW
        )
        // 粉霞
        addFilterItem(
            filterItems,
            R.string.beauty_filter_blush,
            R.drawable.beauty_ic_filter_blush,
            FilterNames.BLUSH
        )
        // 怀旧
        addFilterItem(
            filterItems,
            R.string.beauty_filter_nostalgia,
            R.drawable.beauty_ic_filter_nostalgia,
            FilterNames.NOSTALGIA
        )
        // 焦糖
        addFilterItem(
            filterItems,
            R.string.beauty_filter_caramel,
            R.drawable.beauty_ic_filter_caramel,
            FilterNames.CARAMEL
        )
        // 微醺
        addFilterItem(
            filterItems,
            R.string.beauty_filter_tipsy,
            R.drawable.beauty_ic_filter_tipsy,
            FilterNames.TIPSY
        )
        // 薰衣草
        addFilterItem(
            filterItems,
            R.string.beauty_filter_lavender,
            R.drawable.beauty_ic_filter_lavender,
            FilterNames.LAVENDER
        )
        // 胭脂
        addFilterItem(
            filterItems,
            R.string.beauty_filter_rouge,
            R.drawable.beauty_ic_filter_rouge,
            FilterNames.ROUGE
        )
        // 氤氲
        addFilterItem(
            filterItems,
            R.string.beauty_filter_misty,
            R.drawable.beauty_ic_filter_misty,
            FilterNames.MISTY
        )
       

        return BeautyPageInfo(
            R.string.beauty_group_filter,
            filterItems,
            type = BeautyModule.FILTER
        )
    }

    /**
     * 添加滤镜选项
     * 
     * 1. 初始化时：使用当前选中滤镜的强度值（会从缓存读取）
     * 2. 用户拖动滑块时：更新当前滤镜的强度值（会同步更新缓存）
     * 3. 用户点击切换滤镜时：
     *    - 先获取缓存中该滤镜的强度值（如果用户之前设置过）
     *    - 切换滤镜（filterName），这会触发 SDK 设置默认强度
     *    - 如果缓存中有该滤镜的强度值（无论是否为 0），用缓存的强度值覆盖 SDK 设置的默认值
     *    - 更新 UI 显示的强度值，确保 UI 与 SDK 状态一致
     * 
     * 这样设计的好处：
     * - 每个滤镜的强度值都会被缓存，切换回来时保持用户之前设置的强度
     * - API 层统一管理缓存，UI 层逻辑简单清晰
     * - 易于维护和理解
     */
    private fun addFilterItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        filterName: String
    ) {
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                beautyConfig.filterStrength,
                isSelected = beautyConfig.filterName == filterName,
                valueRange = 0f..1.0f,
                // 用户拖动滑块时，更新强度值（会同步更新缓存）
                onValueChanged = { value ->
                    beautyConfig.filterStrength = value
                },
                // 用户点击切换滤镜时
                onItemClick = { itemInfo ->
                    // 1. 先获取缓存中该滤镜的强度值（如果用户之前设置过）
                    val cachedStrength = beautyConfig.getFilterStrengthForTemplate(filterName)
                    
                    // 2. 切换滤镜（这会触发 SDK 设置默认强度）
                    beautyConfig.filterName = filterName
                    
                    // 3. 如果缓存中有该滤镜的强度值（无论是否为 0），用缓存的强度值覆盖 SDK 设置的默认值
                    //    这样用户切换回之前的滤镜时，会保持之前设置的强度值（包括用户设置为 0 的情况）
                    cachedStrength?.let {
                        beautyConfig.filterStrength = it
                    }
                    
                    // 4. 更新 UI 显示的强度值，确保与 SDK 状态一致
                    itemInfo.value = beautyConfig.filterStrength
                }
            )
        )
    }
}
