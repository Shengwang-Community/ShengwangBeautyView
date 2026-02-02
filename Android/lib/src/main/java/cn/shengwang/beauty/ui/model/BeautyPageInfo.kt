package cn.shengwang.beauty.ui.model

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes

import io.agora.rtc2.IVideoEffectObject

/**
 * 美颜页面信息
 *
 * @param name 页面名称资源ID
 * @param itemList 功能项列表
 * @param isSelected 是否选中（用于TabLayout）
 * @param type 页面类型（对应 SDK VIDEO_EFFECT_NODE_ID）
 */
data class BeautyPageInfo constructor(
    @StringRes val name: Int,
    val itemList: List<BeautyItemInfo>,
    var isSelected: Boolean = false,
    val type: BeautyModule = BeautyModule.BEAUTY
)

/**
 * 美颜功能项类型
 */
enum class BeautyItemType {
    /** 普通参数项（默认） */
    NORMAL,
    /** 开关项（如美颜总开关） */
    TOGGLE,
    /** 重置项 */
    RESET,
    /** 无效果项（如取消贴纸/美妆） */
    NONE
}

/**
 * 美颜功能项信息
 *
 * @param name 功能项名称资源ID
 * @param icon 功能项图标资源ID
 * @param value 当前值（会根据valueRange自动转换显示）
 * @param isSelected 是否选中
 * @param valueRange 值范围（用于滑动条）
 * @param onValueChanged 值变化回调（滑动条释放时触发）
 * @param onItemClick 点击回调（点击功能项图标时触发）
 * @param showSlider 是否显示滑动条（默认为true，对于不需要调节参数的功能项应设置为false）
 * @param type 功能项类型
 */
data class BeautyItemInfo constructor(
    @StringRes var name: Int,
    @DrawableRes var icon: Int,
    var value: Float = 0.0f,
    var isSelected: Boolean = false,
    val valueRange: ClosedFloatingPointRange<Float> = 0.0f..1.0f,
    val onValueChanged: ((value: Float) -> Unit)? = null,
    val onItemClick: ((itemInfo: BeautyItemInfo) -> Unit)? = null,
    val showSlider: Boolean = true,
    val type: BeautyItemType = BeautyItemType.NORMAL
)

/**
 * 美颜模块类型别名
 * 直接使用 SDK 的 VIDEO_EFFECT_NODE_ID
 *
 * 模块分类说明：
 * - BEAUTY: 美肤 + 画质 + 美型（VIDEO_EFFECT_NODE_ID.BEAUTY，值为1）
 *   - 美肤：磨皮、美白、红润等
 *   - 画质：色调、色温、饱和度、亮度（美颜的原子能力）
 *   - 美型：脸部轮廓、眼睛、鼻子、嘴巴、眉毛等（通过 rtcEngine.setFaceShapeAreaOptions）
 * - STYLE_MAKEUP: 风格妆（VIDEO_EFFECT_NODE_ID.STYLE_MAKEUP，值为2）
 * - FILTER: 滤镜（VIDEO_EFFECT_NODE_ID.FILTER，值为4）
 * - STICKER: 贴纸（VIDEO_EFFECT_NODE_ID.STICKER，值为8）
 */
typealias BeautyModule = IVideoEffectObject.VIDEO_EFFECT_NODE_ID