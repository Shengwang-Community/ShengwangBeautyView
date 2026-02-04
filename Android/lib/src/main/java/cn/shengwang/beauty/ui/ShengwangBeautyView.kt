package cn.shengwang.beauty.ui

import android.content.Context
import android.content.res.Resources
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.ViewGroup
import android.view.WindowManager
import android.os.Build
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.tabs.TabLayout
import com.google.android.material.tabs.TabLayoutMediator
import cn.shengwang.beauty.R
import cn.shengwang.beauty.core.ShengwangBeautyManager
import cn.shengwang.beauty.databinding.ShengwangBeautyViewBinding
import cn.shengwang.beauty.databinding.ShengwangBeautyControlPageBinding
import cn.shengwang.beauty.databinding.ShengwangBeautyControlItemBinding
import cn.shengwang.beauty.ui.builder.BeautyPageBuilder
import cn.shengwang.beauty.ui.model.BeautyPageInfo
import cn.shengwang.beauty.ui.model.BeautyItemInfo
import cn.shengwang.beauty.ui.builder.MakeupPageBuilder
import cn.shengwang.beauty.ui.builder.FilterPageBuilder
import cn.shengwang.beauty.ui.builder.StickerPageBuilder
import cn.shengwang.beauty.ui.model.BeautyItemType
import cn.shengwang.beauty.ui.model.BeautyModule

private val Int.dp
    get() = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP,
        this.toFloat(),
        Resources.getSystem().displayMetrics
    ).toInt()

/**
 * 声网美颜控制视图
 * 专门用于声网美颜的控制界面
 *
 * 支持：
 * - 模块级开关：快速删除整个一级菜单模块
 * - 原子能力级精简：隐藏模块内的特定参数
 *
 * 设计原则：
 * - UI 组件与 SDK API 建立 1:1 映射，避免中间层二次封装
 * - 值转换在 UI 层完成，传递给 SDK 的值是 SDK 期望的原始值范围
 * - 确保 UI 表现与算法效果完全同步
 */
class ShengwangBeautyView : android.widget.FrameLayout {

    private val viewBinding by lazy {
        ShengwangBeautyViewBinding.inflate(LayoutInflater.from(context))
    }

    // 使用 ShengwangBeautyManager.beautyConfig 直接访问配置
    private val beautyConfig: ShengwangBeautyManager.BeautyConfig get() = ShengwangBeautyManager.beautyConfig

    private val itemAdapterList = mutableListOf<ItemAdapter?>()

    // TabLayoutMediator 实例，用于管理 TabLayout 和 ViewPager 的同步
    private var tabLayoutMediator: TabLayoutMediator? = null

    // ViewPager2 页面切换回调，用于在页面切换时更新滑动条
    private var pageChangeCallback: androidx.viewpager2.widget.ViewPager2.OnPageChangeCallback? = null

    // 防止重复更新滑动条的标志位
    private var isUpdatingSlider = false

    private val pageAdapter by lazy {
        object : RecyclerView.Adapter<PageViewHolder>() {
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): PageViewHolder {
                val binding = ShengwangBeautyControlPageBinding.inflate(
                    LayoutInflater.from(parent.context),
                    parent,
                    false
                )
                binding.root.layoutParams = ViewGroup.LayoutParams(
                    LayoutParams.MATCH_PARENT,
                    LayoutParams.MATCH_PARENT
                )
                return PageViewHolder(binding)
            }

            override fun onBindViewHolder(holder: PageViewHolder, position: Int) {
                val pageInfo = pageList.getOrNull(position) ?: return
                val itemAdapter = createItemAdapter(position)
                itemAdapter.updateItems(pageInfo.itemList)
                // Ensure the list is large enough before adding at the specified position
                while (itemAdapterList.size <= position) {
                    itemAdapterList.add(null)
                }
                itemAdapterList[position] = itemAdapter

                // 使用新的 API 获取屏幕宽度
                val screenWidth = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    val windowMetrics = context.getSystemService(WindowManager::class.java)
                        .currentWindowMetrics
                    windowMetrics.bounds.width()
                } else {
                    @Suppress("DEPRECATION")
                    val displayMetrics = Resources.getSystem().displayMetrics
                    displayMetrics.widthPixels
                }
                holder.binding.recycleView.layoutParams =
                    holder.binding.recycleView.layoutParams.apply {
                        width = screenWidth
                    }
                holder.binding.recycleView.adapter = itemAdapter
            }

            override fun getItemCount() = pageList.size
        }
    }

    var pageList = listOf<BeautyPageInfo>()
        set(value) {
            field = value
            pageAdapter.notifyDataSetChanged()
            itemAdapterList.clear()

            // 先分离 TabLayoutMediator，再手动管理 tabs
            tabLayoutMediator?.detach()
            viewBinding.tabLayout.removeAllTabs()

            value.forEach {
                val tab = viewBinding.tabLayout.newTab().setText(it.name)
                viewBinding.tabLayout.addTab(tab)
                if (it.isSelected) {
                    tab.select()
                }
            }

            // 重新附加 TabLayoutMediator
            tabLayoutMediator?.attach()

            // 修复：更新当前页面的滑动条，确保刷新后滑动条显示正确
            // 只在 tabLayoutMediator 已初始化且 ViewPager 已设置 adapter 时更新
            if (tabLayoutMediator != null && viewBinding.viewPager.adapter != null) {
                val currentPageIndex = viewBinding.viewPager.currentItem
                if (currentPageIndex >= 0 && currentPageIndex < value.size) {
                    updateSliderForCurrentPage(currentPageIndex)
                }
            }
        }

    constructor(context: Context) : this(context, null)
    constructor(context: Context, attrs: android.util.AttributeSet?) : this(context, attrs, 0)
    constructor(context: Context, attrs: android.util.AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        initView(context)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        // 使用 WeakReference 或检查是否已有监听器
        // 注意：由于 beautyStateListener 是静态变量，多个实例会有冲突
        // 建议在 SDK 层面改为支持多个监听器或使用观察者模式
        ShengwangBeautyManager.beautyStateListener = {
            safeRefreshPageList()
        }
        
        // 第一次附加到窗口时，如果美颜 SDK 已经初始化，需要手动刷新一次 UI
        // 因为监听器设置时可能已经错过了初始化完成的通知
        if (ShengwangBeautyManager.isInitialized()) {
            safeRefreshPageList()
        }
    }
    
    /**
     * 安全地刷新页面列表
     * 在 UI 线程中检查 View 是否仍然 attached，然后刷新
     */
    private fun safeRefreshPageList() {
        if (!isAttachedToWindow) {
            return
        }
        post {
            if (isAttachedToWindow) {
                refreshPageList()
            }
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        // 只清除当前实例设置的监听器
        // 注意：如果有多个实例，这可能会错误地清除其他实例的监听器
        if (ShengwangBeautyManager.beautyStateListener != null) {
            ShengwangBeautyManager.beautyStateListener = null
        }
        // 清理 TabLayoutMediator
        tabLayoutMediator?.detach()
        tabLayoutMediator = null
        // 清理 ViewPager2 页面切换回调
        pageChangeCallback?.let {
            viewBinding.viewPager.unregisterOnPageChangeCallback(it)
        }
        pageChangeCallback = null
    }

    private fun initView(context: Context) {
        addView(viewBinding.root)
        viewBinding.viewPager.isUserInputEnabled = false
        pageList = onPageListCreate()
        viewBinding.viewPager.adapter = pageAdapter

        viewBinding.tabLayout.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab?) {
                // 注意：不在这里更新 pageInfo.isSelected，因为 TabLayoutMediator 会自动同步 ViewPager，
                // 会触发 onPageSelected，在那里统一更新 pageInfo.isSelected 和滑动条，避免重复调用
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {
            }

            override fun onTabReselected(tab: TabLayout.Tab?) {
            }
        })

        // 添加 ViewPager 页面切换监听，确保页面切换时滑动条也更新
        // 这是唯一更新滑动条的地方，避免与 onTabSelected 重复调用
        pageChangeCallback = object : androidx.viewpager2.widget.ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)
                // 更新页面选中状态
                pageList.forEachIndexed { index, pageInfo ->
                    pageInfo.isSelected = index == position
                }
                // 更新滑动条为新页面选中项的值
                updateSliderForCurrentPage(position)
            }
        }
        pageChangeCallback?.let {
            viewBinding.viewPager.registerOnPageChangeCallback(it)
        }

        // 保存 TabLayoutMediator 引用，以便后续管理
        tabLayoutMediator = TabLayoutMediator(viewBinding.tabLayout, viewBinding.viewPager) { tab, position ->
            tab.text = context.getString(pageList[position].name)
        }
        tabLayoutMediator?.attach()
    }

    private fun createItemAdapter(pageIndex: Int) =
        ItemAdapter(pageIndex) { position ->
            // 安全获取当前页面和选中项
            val currentPage = pageList.getOrNull(pageIndex) ?: return@ItemAdapter
            val itemInfo = currentPage.itemList.getOrNull(position) ?: return@ItemAdapter
            val previouslySelectedItem = currentPage.itemList.firstOrNull { it.isSelected }
            previouslySelectedItem?.isSelected = false
            itemInfo.isSelected = true
            onSelectedChanged(pageIndex, position)
        }

    protected fun onPageListCreate(): List<BeautyPageInfo> {
        // 构建页面列表，使用独立的构建器类
        val pageList = mutableListOf<BeautyPageInfo>()

        // 1. BEAUTY 模块（美颜：美肤+美型+画质）
        val beautyBuilder = BeautyPageBuilder(
            beautyConfig = beautyConfig,
            refreshPageList = {
                refreshPageList()
            }
        )
        pageList.add(beautyBuilder.buildPage())

        // 2. STYLE_MAKEUP 模块（风格妆）
        val makeupBuilder = MakeupPageBuilder(beautyConfig)
        pageList.add(makeupBuilder.buildPage())

        // 3. FILTER 模块（滤镜）
        val filterBuilder = FilterPageBuilder(beautyConfig)
        pageList.add(filterBuilder.buildPage())

        // 4. STICKER 模块（贴纸）
        val stickerBuilder = StickerPageBuilder(beautyConfig)
        pageList.add(stickerBuilder.buildPage())

        return pageList
    }

    /**
     * 刷新页面列表
     * 重新调用 onPageListCreate() 生成页面列表，并更新UI显示
     *
     * 注意：此方法会触发页面列表的重新构建，可能导致当前选中状态丢失
     * 建议在配置变化时调用，而不是频繁调用
     */
    fun refreshPageList() {
        // 检查是否 attached
        if (!isAttachedToWindow) {
            return
        }
        // 保存当前选中的页面索引
        val currentPageIndex = viewBinding.viewPager.currentItem
        pageList = onPageListCreate()
        // 修复：刷新后恢复 ViewPager 到之前的页面位置
        if (currentPageIndex >= 0 && currentPageIndex < pageList.size) {
            viewBinding.viewPager.setCurrentItem(currentPageIndex, false)
            // 更新滑动条为新页面的选中项
            updateSliderForCurrentPage(currentPageIndex)
        }
    }

    /**
     * 更新当前页面的滑动条
     * 找到当前页面的选中项，并更新滑动条显示
     *
     * @param pageIndex 页面索引
     *
     * 注意：此方法通过 isUpdatingSlider 标志位防止在快速切换时的重复调用
     */
    private fun updateSliderForCurrentPage(pageIndex: Int) {
        // 防止重复调用：如果正在更新，直接返回
        if (isUpdatingSlider) {
            return
        }

        val currentPage = pageList.getOrNull(pageIndex) ?: return
        // 找到当前页面的选中项
        val selectedItemIndex = currentPage.itemList.indexOfFirst { it.isSelected }

        isUpdatingSlider = true
        try {
            if (selectedItemIndex >= 0) {
                onSelectedChanged(pageIndex, selectedItemIndex)
            } else {
                // 如果没有选中项，隐藏滑动条容器和 label
                viewBinding.slider.labelBehavior = com.google.android.material.slider.LabelFormatter.LABEL_GONE
                viewBinding.sliderContainer.visibility = GONE
            }
        } finally {
            // 重置标志位，允许下次更新
            isUpdatingSlider = false
        }
    }

    /**
     * 选中项变化时的回调
     *
     * @param pageIndex 页面索引
     * @param itemIndex 功能项索引
     */
    protected fun onSelectedChanged(pageIndex: Int, itemIndex: Int) {
        // 安全获取页面和功能项信息
        val pageInfo = pageList.getOrNull(pageIndex) ?: return
        val itemInfo = pageInfo.itemList.getOrNull(itemIndex) ?: return

        // 先清除所有监听器
        viewBinding.slider.clearOnChangeListeners()
        viewBinding.slider.clearOnSliderTouchListeners()

        // 根据是否需要显示滑动条来设置UI
        if (itemInfo.showSlider) {
            setupSlider(itemInfo)
            viewBinding.sliderContainer.visibility = VISIBLE
            viewBinding.slider.labelBehavior = com.google.android.material.slider.LabelFormatter.LABEL_VISIBLE
        } else {
            viewBinding.slider.labelBehavior = com.google.android.material.slider.LabelFormatter.LABEL_GONE
            viewBinding.sliderContainer.visibility = GONE
        }
    }

    /**
     * 设置滑动条的参数和监听器
     *
     * @param itemInfo 功能项信息，包含值范围、当前值等
     *
     * 注意：
     * - 会先清除所有监听器，避免设置值时触发回调
     * - 值变化监听器只在滑动过程中更新UI，不触发业务回调
     * - 业务回调只在用户释放滑动条时触发（onStopTrackingTouch）
     */
    private fun setupSlider(itemInfo: BeautyItemInfo) {
        // 先清除所有监听器，避免设置值时触发回调
        viewBinding.slider.clearOnChangeListeners()
        viewBinding.slider.clearOnSliderTouchListeners()

        // 设置范围
        viewBinding.slider.valueFrom = itemInfo.valueRange.start
        viewBinding.slider.valueTo = itemInfo.valueRange.endInclusive

        // 更准确地判断值类型
        // 如果范围的最大值大于1且范围跨度是整数，则认为是整数类型
        val isIntegerType = itemInfo.valueRange.endInclusive > 1.0f &&
                (itemInfo.valueRange.endInclusive - itemInfo.valueRange.start) % 1.0f == 0.0f &&
                itemInfo.valueRange.start % 1.0f == 0.0f

        // 设置值（此时没有监听器，不会触发回调）
        // 注意：由于在 onSelectedChanged 中已经先调用了回调，所以这里设置值不会触发循环
        if (isIntegerType) {
            viewBinding.slider.value = itemInfo.value.toInt().toFloat()
        } else {
            viewBinding.slider.value = itemInfo.value
        }

        // 设置格式化器
        viewBinding.slider.setLabelFormatter { value ->
            if (isIntegerType) {
                value.toInt().toString()
            } else {
                // float 类型保留两位小数，例如 0.99
                String.format("%.2f", value)
            }
        }

        // 设置值后再添加监听器，避免初始化时触发回调
        viewBinding.slider.addOnChangeListener { _, value, _ ->
            // Only update itemInfo.value during sliding, don't call callback
            if (isIntegerType) {
                itemInfo.value = value.toInt().toFloat()
            } else {
                itemInfo.value = value
            }
        }

        viewBinding.slider.addOnSliderTouchListener(object :
            com.google.android.material.slider.Slider.OnSliderTouchListener {
            override fun onStartTrackingTouch(slider: com.google.android.material.slider.Slider) {
                // Do nothing when start tracking
            }

            override fun onStopTrackingTouch(slider: com.google.android.material.slider.Slider) {
                // Call callback only when user releases the slider
                val value = slider.value
                if (isIntegerType) {
                    val intValue = value.toInt()
                    itemInfo.value = intValue.toFloat()
                    itemInfo.onValueChanged?.invoke(intValue.toFloat())
                } else {
                    itemInfo.value = value
                    itemInfo.onValueChanged?.invoke(value)
                }
            }
        })
    }

    /**
     * 更新功能项信息
     *
     * @param updater 更新函数，返回true表示找到并更新了目标项
     *
     * 注意：此方法会遍历所有页面和功能项，找到第一个匹配的项并更新
     * 更新后会触发该功能项的值变化回调
     */
    fun updateItemInfo(updater: (itemInfo: BeautyItemInfo) -> Boolean) {
        pageList.forEach { pageInfo ->
            pageInfo.itemList.forEach { itemInfo ->
                if (updater(itemInfo)) {
                    itemInfo.onValueChanged?.invoke(itemInfo.value)
                    return
                }
            }
        }
    }

    /**
     * 重置操作：
     * 重置恢复为出厂时模板内的参数值。
     *
     * 注意；保存与重置操作后，下次addOrUpdate加载节点时会自动生效
     *
     * @param type 页面类型（对应 SDK VIDEO_EFFECT_NODE_ID）
     */
    fun resetBeauty(type: BeautyModule = BeautyModule.BEAUTY) {
        beautyConfig.resetBeauty(type)
        // 刷新整个页面列表以更新开关状态和其他参数值
        refreshPageList()
    }

    /**
     * 保存操作：
     * 将主播调完参后的参数直播保存到本地，下次addOrUpdate加载节点时会自动调用之前保存好的参数。
     *
     * 注意；保存与重置操作后，下次addOrUpdate加载节点时会自动生效
     *
     * @param type 页面类型（对应 SDK VIDEO_EFFECT_NODE_ID）
     */
    fun saveBeauty(type: BeautyModule = BeautyModule.BEAUTY) {
        beautyConfig.saveBeauty(type)
    }

    // ViewHolder classes
    private class PageViewHolder(val binding: ShengwangBeautyControlPageBinding) :
        RecyclerView.ViewHolder(binding.root)

    private class ItemViewHolder(val binding: ShengwangBeautyControlItemBinding) :
        RecyclerView.ViewHolder(binding.root)

    // ItemAdapter
    private inner class ItemAdapter(
        private val pageIndex: Int,
        private val onItemClick: (Int) -> Unit
    ) : RecyclerView.Adapter<ItemViewHolder>() {

        private var items = listOf<BeautyItemInfo>()

        // 使用 position 而不是 ViewHolder 引用，避免 ViewHolder 复用问题
        private var selectedPosition: Int = -1

        fun updateItems(newItems: List<BeautyItemInfo>) {
            items = newItems
            // 更新选中位置
            selectedPosition = items.indexOfFirst { it.isSelected }
            notifyDataSetChanged()
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ItemViewHolder {
            val binding = ShengwangBeautyControlItemBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return ItemViewHolder(binding)
        }

        override fun onBindViewHolder(holder: ItemViewHolder, position: Int) {
            val itemInfo = items.getOrNull(position) ?: return
            holder.binding.ivIcon.setImageResource(itemInfo.icon)
            // 使用 position 比较而不是 ViewHolder 引用
            holder.binding.ivIcon.isActivated = position == selectedPosition && itemInfo.isSelected
            holder.binding.tvName.setText(itemInfo.name)

            val currentPage = pageList.getOrNull(pageIndex)
            if ((currentPage?.type == BeautyModule.FILTER ||
                        currentPage?.type == BeautyModule.STICKER ||
                        currentPage?.type == BeautyModule.STYLE_MAKEUP) && itemInfo.type == BeautyItemType.NORMAL
            ) {
                val padding2dp = 2.dp
                holder.binding.ivIcon.setPadding(padding2dp, padding2dp, padding2dp, padding2dp)
            } else {
                val padding8dp = 8.dp
                holder.binding.ivIcon.setPadding(padding8dp, padding8dp, padding8dp, padding8dp)
            }

            if (itemInfo.type == BeautyItemType.TOGGLE) {
                holder.binding.ivIcon.background = null
            } else {
                holder.binding.ivIcon.setBackgroundResource(R.drawable.beauty_item_bg)
            }

            if (itemInfo.isSelected && currentPage?.isSelected == true) {
                // 更新选中位置
                selectedPosition = position
                // Initialize UI (onValueChanged will be called in onSelectedChanged before setting slider)
                onSelectedChanged(pageIndex, position)
            }

            holder.binding.ivIcon.setOnClickListener {
                // 调用 item 特定的 onClick 回调（更新配置和 itemInfo 属性）
                itemInfo.onItemClick?.invoke(itemInfo)

                // 重置项：刷新整个列表
                if (itemInfo.type == BeautyItemType.RESET) {
                    // 逻辑已经在 onItemClick 中处理（包括 refreshPageList），这里只需要确保 UI 响应
                    // 由于 onItemClick 中调用了 refreshPageList，这里其实不需要做太多
                    return@setOnClickListener
                }

                // 普通参数项：更新选中状态并触发选中变化回调
                val previouslySelectedItem = currentPage?.itemList?.firstOrNull { it.isSelected }
                previouslySelectedItem?.isSelected = false
                itemInfo.isSelected = true
                // 更新选中位置并通知适配器
                val previousSelectedPos = selectedPosition
                selectedPosition = position
                if (previousSelectedPos >= 0 && previousSelectedPos < items.size) {
                    notifyItemChanged(previousSelectedPos)
                }
                notifyItemChanged(position)
                onItemClick.invoke(position)
            }
        }

        override fun getItemCount() = items.size
    }

}
