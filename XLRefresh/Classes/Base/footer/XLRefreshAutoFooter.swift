//
//  XLRefreshAutoFooter.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/6.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
/// 会自动刷新的上拉刷新控件
open class XLRefreshAutoFooter: XLRefreshFooter {

    /// 是否自动刷新，默认为true
    public var autoMaticallyRefresh: Bool = true
    
    /// 当底部控件出现多少时就会自动h刷新（默认为1.0）
    public var triggerAtuomaticallyRefreshPercent: CGFloat = 1.0
    
    /// 是否每次拖拽一次 只发起一次请求默认为false
    public var onlyRefreshPerDray: Bool = false
    
    /// 一个新的拖拽时间
    private var oneNewPan: Bool?
    
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let indeedScrollView = self.scrollView else { return }
        /// 新的父控件
        if newSuperview != nil {
            if !self.isHidden {
                indeedScrollView.xl_insertB += self.xl_height
            }
            /// 设置位置
            self.xl_y = indeedScrollView.xl_contentH
        } else {
            /// 被移除
            if !self.isHidden {
                /// 恢复到原始状态
                indeedScrollView.xl_insertB -= self.xl_height
            }
        }
    }
    
    open override func prepare() {
        super.prepare()
        /// 默认底部控件完全出现时才会自动刷新
        self.triggerAtuomaticallyRefreshPercent = 1.0
        self.autoMaticallyRefresh = true
        /// 默认是offSet达到d条件就发送请求(可连续)
        self.onlyRefreshPerDray = false
    }
    open override func scrollViewContentSizeDid(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDid(change: change)
        /// 设置位置
        guard let indeedScrollView = self.scrollView else { return }
        self.xl_y = indeedScrollView.xl_contentH
    }
    
    open override func scrollViewContentOffsetDid(change: [NSKeyValueChangeKey : Any]) {
        super.scrollViewContentOffsetDid(change: change)
        
        guard let indeedScrollView = self.scrollView else { return }
        
        if self.state != .idle || !self.autoMaticallyRefresh || self.xl_y == 0 { return }
        
        /// 内容超过一个屏幕
        if indeedScrollView.xl_insertT + indeedScrollView.xl_contentH > indeedScrollView.xl_height {// 这里的_scrollView.mj_contentH替换掉self.mj_y更为合理
            let condition = indeedScrollView.xl_offsetY >= indeedScrollView.xl_contentH - indeedScrollView.xl_height + self.xl_height * self.triggerAtuomaticallyRefreshPercent + indeedScrollView.xl_insertB - self.xl_height
            if condition {
                if let old = change[.oldKey] as? CGPoint, let new = change[.newKey] as? CGPoint {
                    // 防止手松开时连续调用
                    if new.y < old.y { return }
                    // 当底部刷新控件完全出现时，才刷新
                    self.beginRefreshing()
                }
            }
        }
    }
    
    open override func scrollViewPanStateDid(change: [NSKeyValueChangeKey : Any]) {
        super.scrollViewPanStateDid(change: change)
        guard let indeedScrollView = self.scrollView else { return }
        if self.state != .idle { return }
        let state = indeedScrollView.panGestureRecognizer.state
        
        if state == .ended {
            if indeedScrollView.xl_insertT + indeedScrollView.xl_contentH <= indeedScrollView.xl_height {
                if indeedScrollView.xl_offsetY >= -indeedScrollView.xl_insertT {
                    self.beginRefreshing()
                }
            } else {
                /// 超出一个屏幕
                if indeedScrollView.xl_offsetY >= indeedScrollView.xl_contentH + indeedScrollView.xl_insertB - indeedScrollView.xl_height {
                    self.beginRefreshing()
                }
            }
        } else if state == .began {
            self.oneNewPan = true
        }
    }
    
    public override func beginRefreshing() {
        guard let newPan = self.oneNewPan else { return }
        if !newPan && self.onlyRefreshPerDray { return }
        super.beginRefreshing()
        self.oneNewPan = false
    }
    
    open override var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            guard let oldState = check(newState: newValue, oldState: state) else { return }
            super.state = newValue
            if newValue == .refreshing {
                self.executeRefreshingCallBack()
            } else if newValue == .nomoreData || newValue == .idle {
                if oldState == .refreshing {
                    if let endRefreshBlock = self.endRefreshingCompletionBlock {
                        endRefreshBlock()
                    }
                }
            }
        }
    }
    
    override open var isHidden: Bool {
        didSet {
            guard let indeedScrollView = self.scrollView else { return }
            if isHidden && !oldValue {
                self.state = .idle
                indeedScrollView.xl_insertB -= self.xl_height
            } else if !isHidden && oldValue {
                indeedScrollView.xl_insertB += self.xl_height
                /// 设置位置
                self.xl_y = indeedScrollView.xl_contentH
            }
        }
    }
}
