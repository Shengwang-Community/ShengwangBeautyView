package cn.shengwang.beauty.ui.contract

import cn.shengwang.beauty.ui.model.BeautyPageInfo

/**
 * 页面构建器接口
 * 用于构建不同模块的页面信息
 * 
 * 注意：此接口为内部实现，不对外暴露
 */
internal interface IPageBuilder {
    /**
     * 构建页面信息
     * @return BeautyPageInfo 页面信息
     */
    fun buildPage(): BeautyPageInfo
}
