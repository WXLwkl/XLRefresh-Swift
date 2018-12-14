//
//  XLRefreshHeader.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/5.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

open class XLRefreshHeader: XLRefreshComponent {
    // 插入的偏移量
    private var insertDelta: CGFloat = 0.0
    var lastUpdatedTimeKey: String = XLRefreshKeys.headerLastUpdatedTimeKey
    
    public var lastUpdatedTime: Date? {
        return UserDefaults.standard.object(forKey: self.lastUpdatedTimeKey) as? Date
    }
    
    /// 忽略多少scrollView的contentInset的top
    public var ignoredScrollViewContentInsetTop:CGFloat = 0.0 {
        didSet {
            self.xl_y = -self.xl_y - ignoredScrollViewContentInsetTop
        }
    }
    // MARK: - 重写状态
    open override var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            guard let oldState = check(newState: newValue, oldState: state), let indeedScrollView = self.scrollView else { return }
            super.state = newValue
            
            if newValue == .idle {
                if oldState != .refreshing { return }
                /// save
                UserDefaults.standard.setValue(Date(), forKey: self.lastUpdatedTimeKey)
                UserDefaults.standard.synchronize()
                
                
                UIView.animate(withDuration: XLRefreshKeys.slowAnimateDuration, animations: {
                    indeedScrollView.xl_insertT += self.insertDelta
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
                        let top = self.scrollViewOriginalInset.top + self.xl_height
                        // 增加滚动区域top
                        indeedScrollView.xl_insertT = top
                        // 设置滚动位置
                        var offset = indeedScrollView.contentOffset
                        offset.y = -top
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
    public static func headerWithRefreshing(block: @escaping XLRefreshComponentRefreshingBlock) -> XLRefreshHeader {
        let header = self.init()
        header.refreshingBlock = block
        return header
    }
    /// 类方法, 快速的创建下拉刷新控件
    public static func headerWithRefresing(target: AnyObject, action: Selector) -> XLRefreshHeader {
        let header = self.init()
        header.setRefreshing(target: target, action: action)
        return header
    }
    
    // MARK: - 重写父类方法
    override open func prepare() {
        super.prepare()
        self.xl_height = XLRefreshKeys.headerHeight
    }
    open override func placeSubViews() {
        super.placeSubViews()
        // 设置y值，（当自己高度发生变化了，肯定要重新调整y值，所以放到placeSubViews中调整y值）
        self.xl_y = -self.xl_height - self.ignoredScrollViewContentInsetTop
    }
    
    open override func scrollViewContentOffsetDid(change: [NSKeyValueChangeKey : Any]) {
        super.scrollViewContentOffsetDid(change: change)
        guard let indeedScrollView = self.scrollView else { return }
        // 在刷新的refreshing状态
        if self.state == .refreshing {
            // 暂时保留
            if self.window == nil { return }
            // sectionheader停留解决
            var inserT = -indeedScrollView.xl_offsetY > _scrollViewOriginalInset.top ? -indeedScrollView.xl_offsetY : _scrollViewOriginalInset.top
            inserT = inserT > self.xl_height + _scrollViewOriginalInset.top ? self.xl_height + _scrollViewOriginalInset.top : inserT
            indeedScrollView.xl_insertT = inserT
            self.insertDelta = _scrollViewOriginalInset.top - inserT
            return
        }
        // 跳转到下一个控制器， contentInset可能会变
        _scrollViewOriginalInset = indeedScrollView.xl_inset
        // 当前contentOffset
        let offsetY = indeedScrollView.xl_offsetY
        // 头部控件刚好出现的offsetY
        let happenOffsetY = -self.scrollViewOriginalInset.top
        // 如果向上滚动到看不到头部控件 直接返回
        if offsetY > happenOffsetY { return }
        // 普通和即将刷新的临界点
        let normalPullingOffsetY = happenOffsetY - self.xl_height
        let pullingPercent = (happenOffsetY - offsetY) / self.xl_height
        // 如果正在拖拽
        if indeedScrollView.isDragging {
            self.pullingPercent = pullingPercent
            if self.state == .idle && offsetY < normalPullingOffsetY {
                /// 转换为即将刷新状态
                self.state = .pulling
            } else if self.state == .pulling && offsetY >= normalPullingOffsetY {
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
