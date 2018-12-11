//
//  XLRefreshLeft.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/7.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

open class XLRefreshLeft: XLRefreshComponent {
    // 插入的偏移量
    private var insertDelta: CGFloat = 0.0
    
    /// 忽略多少scrollView的contentInset的left
    public var ignoredScrollViewContentInsetLeft:CGFloat = 0.0 {
        didSet {
            self.xl_x = -self.xl_x - ignoredScrollViewContentInsetLeft
        }
    }
    
    open override var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            guard let oldState = check(newState: newValue, oldState: state), let indeedScrollView = self.scrollView else { return }
            super.state = newValue
            
            if newValue == .idle {
                if oldState != .refreshing { return }
                
                UIView.animate(withDuration: XLRefreshKeys.slowAnimateDuration, animations: {
                    indeedScrollView.xl_insertL += self.insertDelta
                    /// 自动调整透明度
                    if self.automaticallyChangeAlpha { self.alpha = 0.0 }
                }) { (finished) in
                    self.pullingPercent = 0.0
                    if let block = self.endRefreshingCompletionBlock {
                        block()
                    }
                }
            } else if newValue == .refreshing {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: XLRefreshKeys.fastAnimateDuration, animations: {
                        let left = self.scrollViewOriginalInset.left + self.xl_width
                        // 增加滚动区域top
                        indeedScrollView.xl_insertL = left
                        // 设置滚动位置
                        var offset = indeedScrollView.contentOffset
                        offset.x = -left
                        indeedScrollView.setContentOffset(offset, animated: false)
                    }) { (finished) in
                        // 回调正在刷新的block
                        self.executeRefreshingCallBack()
                    }
                }
            }
        }
    }
    

    // MARK: - 构造方法
    public static func leftWithRefreshing(block: @escaping XLRefreshComponentRefreshingBlock) -> XLRefreshLeft {
        let left = self.init()
        left.refreshingBlock = block
        return left
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        guard let superView = newSuperview as? UIScrollView else { return }
        
        self.xl_height = superView.xl_height
        self.xl_width = XLRefreshKeys.leftWidth
        // 位置
        self.xl_y = 0

        scrollView?.alwaysBounceVertical = false
        scrollView?.alwaysBounceHorizontal = true
    }
    
    // MARK: - 重写父类方法
    override open func prepare() {
        super.prepare()
        self.xl_width = XLRefreshKeys.leftWidth
    }
    open override func placeSubViews() {
        super.placeSubViews()
        // 设置y值，（当自己高度发生变化了，肯定要重新调整y值，所以放到placeSubViews中调整y值）
        self.xl_x = -self.xl_width - self.ignoredScrollViewContentInsetLeft
    }
    
    open override func scrollViewContentOffsetDid(change: [NSKeyValueChangeKey : Any]) {
        super.scrollViewContentOffsetDid(change: change)
        guard let indeedScrollView = self.scrollView else { return }
        
        if self.state == .refreshing {
            if self.window == nil { return }
            var inserL = -indeedScrollView.xl_offsetX > _scrollViewOriginalInset.left ? -indeedScrollView.xl_offsetX : _scrollViewOriginalInset.left
            inserL = inserL > self.xl_width + _scrollViewOriginalInset.left ? self.xl_width + _scrollViewOriginalInset.left : inserL
            indeedScrollView.xl_insertL = inserL
            self.insertDelta = _scrollViewOriginalInset.left - inserL
            return
        }
        // 跳转到下一个控制器， contentInset可能会变
        _scrollViewOriginalInset = indeedScrollView.xl_inset
        // 当前contentOffset
        let offsetX = indeedScrollView.xl_offsetX
        // 头部控件刚好出现的offsetY
        let happenOffsetX = -self.scrollViewOriginalInset.left
        // 如果向上滚动到看不到头部控件 直接返回
        if offsetX > happenOffsetX { return }
        // 普通和即将刷新的临界点
        // 偏移量加上自身高度
        let normalPullingOffsetX = happenOffsetX - self.xl_width
        let pullingPercent = (happenOffsetX - offsetX) / self.xl_width
        NSLog("--->>%.2f", pullingPercent)
        // 如果正在拖拽
        if indeedScrollView.isDragging {
            self.pullingPercent = pullingPercent
            if self.state == .idle && offsetX < normalPullingOffsetX {
                /// 转换为即将刷新状态
                self.state = .pulling
            } else if self.state == .pulling && offsetX >= normalPullingOffsetX {
                /// 转换为普通状态
                self.state = .idle
            }
        } else if self.state == .pulling {
            /// 即将刷新 && 手松开
            self.beginRefreshing()
        } else if pullingPercent < 1 {
            self.pullingPercent = pullingPercent
        }
    }
}
