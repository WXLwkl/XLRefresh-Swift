//
//  XLRefreshRight.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/7.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

open class XLRefreshRight: XLRefreshComponent {
    
//    /// 是否自动刷新，默认为true
//    public var autoMaticallyRefresh: Bool = true
//
//    /// 当底部控件出现多少时就会自动h刷新（默认为1.0）
//    public var triggerAtuomaticallyRefreshPercent: CGFloat = 1.0
//
//    /// 是否每次拖拽一次 只发起一次请求默认为false
//    public var onlyRefreshPerDray: Bool = false
//
//    /// 一个新的拖拽时间
//    private var oneNewPan: Bool?
//
//
//
//
//
//
//
//
//
//    // MARK: - 重写父类方法
//    override open func prepare() {
//        super.prepare()
//        backgroundColor = .red
//        self.xl_width = XLRefreshKeys.footerHeight
//
//        /// 默认底部控件完全出现时才会自动刷新
//        self.triggerAtuomaticallyRefreshPercent = 1.0
//        self.autoMaticallyRefresh = true
//        /// 默认是offSet达到d条件就发送请求(可连续)
//        self.onlyRefreshPerDray = false
//    }
//
//    open override func scrollViewContentOffsetDid(change: [NSKeyValueChangeKey : Any]) {
//        super.scrollViewContentOffsetDid(change: change)
//
//        guard let indeedScrollView = self.scrollView else { return }
//
//        if self.state != .idle || !self.autoMaticallyRefresh || self.xl_x == 0 { return }
//
//        /// 内容超过一个屏幕
//        if indeedScrollView.xl_insertL + indeedScrollView.xl_contentW > indeedScrollView.xl_width {
//            let condition = indeedScrollView.xl_offsetX >= indeedScrollView.xl_contentW - indeedScrollView.xl_width + self.xl_width * self.triggerAtuomaticallyRefreshPercent + indeedScrollView.xl_insertR - self.xl_width
//            if condition {
//                if let old = change[.oldKey] as? CGPoint, let new = change[.newKey] as? CGPoint {
//                    // 防止手松开时连续调用
//                    if new.x < old.x { return }
//                    // 当底部刷新控件完全出现时，才刷新
//                    self.beginRefreshing()
//                }
//            }
//        }
//    }
//
//    open override func scrollViewPanStateDid(change: [NSKeyValueChangeKey : Any]) {
//        super.scrollViewPanStateDid(change: change)
//        guard let indeedScrollView = self.scrollView else { return }
//        if self.state != .idle { return }
//        let state = indeedScrollView.panGestureRecognizer.state
//
//        if state == .ended {
//            if indeedScrollView.xl_insertL + indeedScrollView.xl_contentW <= indeedScrollView.xl_width {
//                if indeedScrollView.xl_offsetX >= -indeedScrollView.xl_insertL {
//                    self.beginRefreshing()
//                }
//            } else {
//                /// 超出一个屏幕
//                if indeedScrollView.xl_offsetX >= indeedScrollView.xl_contentW + indeedScrollView.xl_insertR - indeedScrollView.xl_width {
//                    self.beginRefreshing()
//                }
//            }
//        } else if state == .began {
//            self.oneNewPan = true
//        }
//    }
//
//    public override func beginRefreshing() {
//        guard let newPan = self.oneNewPan else { return }
//        if !newPan && self.onlyRefreshPerDray { return }
//        super.beginRefreshing()
//        self.oneNewPan = false
//    }
//
//    open override var state: XLRefreshState {
//        get {
//            return super.state
//        }
//        set {
//            guard let oldState = check(newState: newValue, oldState: state) else { return }
//            super.state = newValue
//            if newValue == .refreshing {
//                self.executeRefreshingCallBack()
//            } else if newValue == .nomoreData || newValue == .idle {
//                if oldState == .refreshing {
//                    if let endRefreshBlock = self.endRefreshingCompletionBlock {
//                        endRefreshBlock()
//                    }
//                }
//            }
//        }
//    }
    
    /// 忽略scrollview contentInset的right
    public var ignoredScrollViewContentInsetRight: CGFloat = 0.0
    
    private var lastRefreshCount: Int = 0
    private var lastBottomDelta: CGFloat = 0.0
    
    
    // MARK: - 构造方法
    public static func rightWithRefreshing(block: @escaping XLRefreshComponentRefreshingBlock) -> XLRefreshRight {
        let right = self.init()
        right.refreshingBlock = block
        return right
    }
    
    // MARK: - 重写父类
    open override func prepare() {
        super.prepare()
        self.xl_height = XLRefreshKeys.footerHeight
    }
    override open var isHidden: Bool {
        didSet {
            guard let indeedScrollView = self.scrollView else { return }
            if isHidden && !oldValue {
                self.state = .idle
                indeedScrollView.xl_insertR -= self.xl_width
            } else if !isHidden && oldValue {
                indeedScrollView.xl_insertR += self.xl_width
                /// 设置位置
                self.xl_x = indeedScrollView.xl_contentW
            }
        }
    }

    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let indeedScrollView = self.scrollView else { return }
        
        self.xl_height = indeedScrollView.xl_height
        self.xl_width = XLRefreshKeys.rightWidth
        // 位置
        self.xl_x = indeedScrollView.xl_contentW
        
        scrollView?.alwaysBounceVertical = false
        scrollView?.alwaysBounceHorizontal = true
        
        self.scrollViewContentSizeDid(change: nil)
    }
    open override func scrollViewContentSizeDid(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDid(change: change)
        guard let indeedScrollView = self.scrollView else { return }
        /// 内容高度
        let contentWidth = indeedScrollView.xl_contentW + self.ignoredScrollViewContentInsetRight
        
        let scrollWidth = indeedScrollView.xl_width - self.scrollViewOriginalInset.left - self.scrollViewOriginalInset.right + self.ignoredScrollViewContentInsetRight
        
        self.xl_x = max(contentWidth, scrollWidth)
    }

    open override func scrollViewContentOffsetDid(change: [NSKeyValueChangeKey : Any]) {
        super.scrollViewContentOffsetDid(change: change)
        
        guard let indeedScrollView = self.scrollView else { return }
        /// 如果正在刷新，直接返回
        if self.state == .refreshing { return }
        _scrollViewOriginalInset = indeedScrollView.xl_inset
        /// 当前的contentOffSet
        let currentOffSetX = indeedScrollView.xl_offsetX
        /// 尾部控件刚好出现的offsetY
        let happenOffSetX = self.happenOffSetX()
        /// 如果是向下滚动到看不到尾部控件，直接返回
        if currentOffSetX <= happenOffSetX { return }
        let pullingPercent = (currentOffSetX - happenOffSetX) / self.xl_width
        /// 如果是全部加载完毕
        if self.state == .nomoreData {
            self.pullingPercent = pullingPercent
            return
        }
        if indeedScrollView.isDragging {
            self.pullingPercent = pullingPercent
            /// 普通和即将刷新的临界点
            let normalPullingOffSetX = happenOffSetX + self.xl_width
            if self.state == .idle && currentOffSetX > normalPullingOffSetX {
                /// 转为即将刷新状态
                self.state = .pulling
            } else if self.state == .pulling && currentOffSetX <= normalPullingOffSetX {
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
                        indeedScrollView.xl_insertR -= self.lastBottomDelta
                        if self.automaticallyChangeAlpha { self.alpha = 0.0}
                    }) { (finished) in
                        self.pullingPercent = 0.0
                        if let endRefreshBlock = self.endRefreshingCompletionBlock {
                            endRefreshBlock()
                        }
                    }
                }
                let deltaW = self.widthForContentBreakView()
                /// 刚刷新完毕
                if oldState == .refreshing && deltaW > 0 && indeedScrollView.xl_totalDataCount != self.lastRefreshCount {
                    let tempOffSetX = indeedScrollView.xl_offsetX
                    indeedScrollView.xl_offsetX = tempOffSetX
                }
            } else if newValue == .refreshing {
                self.lastRefreshCount = indeedScrollView.xl_totalDataCount
                UIView.animate(withDuration: XLRefreshKeys.fastAnimateDuration, animations: {
                    var right = self.xl_width + self.scrollViewOriginalInset.right
                    let deltaW = self.widthForContentBreakView()
                    /// 如果内容高度小于view的高度
                    if deltaW < 0 {
                        right -= deltaW
                    }
                    self.lastBottomDelta = right - indeedScrollView.xl_insertR
                    indeedScrollView.xl_insertR = right
                    indeedScrollView.xl_offsetX = self.happenOffSetX() + self.xl_width
                }) { (finished) in
                    self.executeRefreshingCallBack()
                }
            }
        }
    }
    
    
    private func happenOffSetX() -> CGFloat {
        let deltaW = self.widthForContentBreakView()
        if  deltaW > 0 {
            /// 上拉加载更多的控件在可视区域内
            return deltaW - self.scrollViewOriginalInset.left
        } else {
            return -self.scrollViewOriginalInset.left
        }
    }
    /// 获得scrollView的内容超出view的高度
    private func widthForContentBreakView() -> CGFloat {
        if let indeedScrollView = self.scrollView {
            let width = indeedScrollView.frame.size.width - self.scrollViewOriginalInset.left - self.scrollViewOriginalInset.right
            return indeedScrollView.contentSize.width - width
        } else {
            return 0
        }
    }
    
    
    
    /// 提示没有更多数据
    public func endRefreshingWithNoMoreData() {
        DispatchQueue.main.async {
            self.state = .nomoreData
        }
    }
    /// 重复没有更多数据
    public func resetNoMoreData() {
        DispatchQueue.main.async {
            self.state = .idle
        }
    }
}
