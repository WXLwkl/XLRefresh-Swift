//
//  XLRefreshBackFooter.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/6.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

/// 会回弹到底部的上拉刷新控件
open class XLRefreshBackFooter: XLRefreshFooter {

    private var lastRefreshCount: Int = 0
    private var lastBottomDelta: CGFloat = 0.0
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.scrollViewContentSizeDid(change: nil)
    }
    open override func scrollViewContentOffsetDid(change: [NSKeyValueChangeKey : Any]) {
        super.scrollViewContentOffsetDid(change: change)
        
        guard let indeedScrollView = self.scrollView else { return }
        /// 如果正在刷新，直接返回
        if self.state == .refreshing { return }
        _scrollViewOriginalInset = indeedScrollView.xl_inset
        /// 当前的contentOffSet
        let currentOffSetY = indeedScrollView.xl_offsetY
        /// 尾部控件刚好出现的offsetY
        let happenOffSetY = self.happenOffSetY()
        /// 如果是向下滚动到看不到尾部控件，直接返回
        if currentOffSetY <= happenOffSetY { return }
        let pullingPercent = (currentOffSetY - happenOffSetY) / self.xl_height
        /// 如果是全部加载完毕
        if self.state == .nomoreData {
            self.pullingPercent = pullingPercent
            return
        }
        if indeedScrollView.isDragging {
            self.pullingPercent = pullingPercent
            /// 普通和即将刷新的临界点
            let normalPullingOffSetY = happenOffSetY + self.xl_height
            if self.state == .idle && currentOffSetY > normalPullingOffSetY {
                /// 转为即将刷新状态
                self.state = .pulling
            } else if self.state == .pulling && currentOffSetY <= normalPullingOffSetY {
                /// 转为普通状态
                self.state = .idle
            }
        } else if self.state == .pulling {
            /// 开始刷新
            self.beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }
    
    open override func scrollViewContentSizeDid(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDid(change: change)
        guard let indeedScrollView = self.scrollView else { return }
        /// 内容高度
        let contentHeight = indeedScrollView.xl_contentH + self.ignoredScrollViewContentInsetBottom
        
        let scrollHeight = indeedScrollView.xl_height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom + self.ignoredScrollViewContentInsetBottom
        
        self.xl_y = max(contentHeight, scrollHeight)
    }
    
    open override var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            guard let oldState = check(newState: newValue, oldState: state), let indeedScrollView = self.scrollView else { return }
            super.state = newValue
            if newValue == .nomoreData || state == .idle {
                /// 刷新完毕
                if oldState == .refreshing {
                    UIView.animate(withDuration: XLRefreshKeys.slowAnimateDuration, animations: {
                        indeedScrollView.xl_insertB -= self.lastBottomDelta
                        if self.automaticallyChangeAlpha { self.alpha = 0.0}
                    }) { (finished) in
                        self.pullingPercent = 0.0
                        if let endRefreshBlock = self.endRefreshingCompletionBlock {
                            endRefreshBlock()
                        }
                    }
                }
                let deltaH = self.heightForContentBreakView()
                /// 刚刷新完毕
                if oldState == .refreshing && deltaH > 0 && indeedScrollView.xl_totalDataCount != self.lastRefreshCount {
                    let tempOffSetY = indeedScrollView.xl_offsetY
                    indeedScrollView.xl_offsetY = tempOffSetY
                }
            } else if newValue == .refreshing {
                self.lastRefreshCount = indeedScrollView.xl_totalDataCount
                UIView.animate(withDuration: XLRefreshKeys.fastAnimateDuration, animations: {
                    var bottom = self.xl_height + self.scrollViewOriginalInset.bottom
                    let deltaH = self.heightForContentBreakView()
                    /// 如果内容高度小于view的高度
                    if deltaH < 0 {
                        bottom -= deltaH
                    }
                    self.lastBottomDelta = bottom - indeedScrollView.xl_insertB
                    indeedScrollView.xl_insertB = bottom
                    indeedScrollView.xl_offsetY = self.happenOffSetY() + self.xl_height
                }) { (finished) in
                    self.executeRefreshingCallBack()
                }
            }
        }
    }
    

    private func happenOffSetY() -> CGFloat {
        let deltaH = self.heightForContentBreakView()
        if  deltaH > 0 {
            /// 上拉加载更多的控件在可视区域内
            return deltaH - self.scrollViewOriginalInset.top
        } else {
            return -self.scrollViewOriginalInset.top
        }
    }
    /// 获得scrollView的内容超出view的高度
    private func heightForContentBreakView() -> CGFloat {
        if let indeedScrollView = self.scrollView {
            let height = indeedScrollView.frame.size.height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom
            return indeedScrollView.contentSize.height - height
        } else {
            return 0
        }
    }
}
