package cn.shengwang.beauty.ui.builder

import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.core.MakeupNames
import cn.shengwang.beauty.ui.contract.IPageBuilder
import cn.shengwang.beauty.ui.model.BeautyPageInfo
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule

/**
 * 风格妆模块页面构建器
 * 负责构建风格妆模块的页面信息
 * 
 * 注意：此构建器为内部实现，不对外暴露
 */
internal class MakeupPageBuilder(
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig
) : IPageBuilder {

    override fun buildPage(): BeautyPageInfo {
        val makeupItems = mutableListOf<BeautyItemInfo>()
        
        makeupItems.add(
            BeautyItemInfo(
                R.string.beauty_effect_none,
                R.drawable.beauty_ic_none,
                isSelected = beautyConfig.makeupName == null,
                showSlider = false,
                type = BeautyItemType.NONE,
                onItemClick = {
                    beautyConfig.makeupName = null
                }
            )
        )

        // 美妆选项
        // 学妹妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_young,
            R.drawable.beauty_ic_makeup_young,
            MakeupNames.YOUNG
        )
        // 学姐妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_mature,
            R.drawable.beauty_ic_makeup_mature,
            MakeupNames.MATURE
        )
        // 气质妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_aura,
            R.drawable.beauty_ic_makeup_aura,
            MakeupNames.AURA
        )
        // 白皙妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_natural,
            R.drawable.beauty_ic_makeup_natural,
            MakeupNames.NATURAL
        )
        // 优雅妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_graceful,
            R.drawable.beauty_ic_makeup_graceful,
            MakeupNames.GRACEFUL
        )
        // 粉晕妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_charm,
            R.drawable.beauty_ic_makeup_charm,
            MakeupNames.CHARM
        )
        // 俏皮妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_perky,
            R.drawable.beauty_ic_makeup_perky,
            MakeupNames.PERKY
        )
        // 少女妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_maiden,
            R.drawable.beauty_ic_makeup_maiden,
            MakeupNames.MAIDEN
        )
        // 深邃妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_insight,
            R.drawable.beauty_ic_makeup_insight,
            MakeupNames.INSIGHT
        )
        // 氤氲妆
        addMakeupItem(
            makeupItems,
            R.string.beauty_makeup_misty,
            R.drawable.beauty_ic_makeup_misty,
            MakeupNames.MISTY
        )

        return BeautyPageInfo(
            R.string.beauty_group_makeup,
            makeupItems,
            type = BeautyModule.STYLE_MAKEUP
        )
    }

    /**
     * 添加美妆选项
     * 
     * 1. 初始化时：
     *    - 如果当前选中的是这个模板，使用 beautyConfig.makeupIntensity（会从缓存读取）
     *    - 如果当前选中的不是这个模板，从缓存读取该模板的强度值（如果没有则显示 0f）
     * 2. 用户拖动滑块时：更新当前模板的强度值（会同步更新缓存）
     * 3. 用户点击切换模板时：
     *    - 先切换模板（makeupName），这会触发 getter 从缓存读取该模板的强度值
     *    - 然后更新 UI 显示的强度值，确保 UI 与 SDK 状态一致
     * 
     * 这样设计的好处：
     * - 每个模板的强度值都会被缓存，切换回来时保持用户之前设置的强度
     * - API 层统一管理缓存，UI 层逻辑简单清晰
     * - 易于维护和理解
     */
    private fun addMakeupItem(
        items: MutableList<BeautyItemInfo>,
        nameRes: Int,
        iconRes: Int,
        makeupName: String
    ) {
        items.add(
            BeautyItemInfo(
                nameRes,
                iconRes,
                beautyConfig.makeupIntensity,
                isSelected = beautyConfig.makeupName == makeupName,
                valueRange = 0f..1.0f,
                // 用户拖动滑块时，更新强度值（会同步更新缓存）
                onValueChanged = { value ->
                    beautyConfig.makeupIntensity = value
                },
                // 用户点击切换模板时
                onItemClick = { itemInfo ->
                    // 1. 先获取缓存中该模板的强度值（如果用户之前设置过）
                    val cachedIntensity = beautyConfig.getMakeupIntensityForTemplate(makeupName)
                    
                    // 2. 切换模板（这会触发 SDK 设置默认强度）
                    beautyConfig.makeupName = makeupName
                    
                    // 3. 如果缓存中有该模板的强度值（无论是否为 0），用缓存的强度值覆盖 SDK 设置的默认值
                    //    这样用户切换回之前的模板时，会保持之前设置的强度值（包括用户设置为 0 的情况）
                    cachedIntensity?.let {
                        beautyConfig.makeupIntensity = it
                    }
                    
                    // 4. 更新 UI 显示的强度值，确保与 SDK 状态一致
                    itemInfo.value = beautyConfig.makeupIntensity
                }
            )
        )
    }
}
