//
//  XLRefreshComponent.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/5.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

public enum XLRefreshState {
    /** 闲置 */
    case idle
    /** 松开就可以刷新 */
    case pulling
    /** 刷新中 */
    case refreshing
    /** 即将刷新 */
    case willRefresh
    /** 所有数据加载完毕 没有更过数据 */
    case nomoreData
    /** 初始状态 刚创建的时候 状态会从none--->idle */
    case none
}
/// 正在刷新的回调
public typealias XLRefreshComponentRefreshingBlock = () -> Void
/// 开始刷新后的回调（进入刷新状态后的回调）
public typealias XLRefreshComponentBeginRefreshingCompletionBlock = () -> Void
/// 结束刷新后的回调
public typealias XLRefreshComponentEndRefreshingCompletionBlock = () -> Void


open class XLRefreshComponent: UIView {
    
    // MARK: - 属性
    public var refreshingBlock: XLRefreshComponentRefreshingBlock?
    public var beginRefreshingCompletionBlock: XLRefreshComponentBeginRefreshingCompletionBlock?
    public var endRefreshingCompletionBlock: XLRefreshComponentEndRefreshingCompletionBlock?
    
    // 回调对象
    private weak var refreshTarget: AnyObject?
    // 回调方法
    private var refreshAction: Selector?
    // 手势
    private var pan: UIPanGestureRecognizer?
    
    /// 记录scrollview刚开始的inset
    var _scrollViewOriginalInset: UIEdgeInsets = UIEdgeInsets.zero
    public var scrollViewOriginalInset: UIEdgeInsets {
        return _scrollViewOriginalInset
    }
    // 父控件
    private weak var _scrollView: UIScrollView? {
        didSet {
            self.state = .idle
        }
    }
    public var scrollView: UIScrollView? {
        return _scrollView
    }
    /// 拖拽百分比
    open var pullingPercent: CGFloat = 0.0 {
        didSet {
            if self.isRefreshing() { return }
            if self.automaticallyChangeAlpha {
                self.alpha = pullingPercent
            }
        }
    }

    /// 根据拖拽比例自动切换透明度, 默认是false
    public var automaticallyChangeAlpha: Bool = false {
        didSet {
            if self.isRefreshing() { return }
            if automaticallyChangeAlpha {
                self.alpha = self.pullingPercent
            } else {
                self.alpha = 1.0
            }
        }
    }
    
    /// 内部维护的状态
    private var _state: XLRefreshState = .none
    /// 刷新状态, 一般交给子类内部实现, 默认是普通状态 (通过该方式模拟oc的set and get)
    open var state: XLRefreshState {
        get {
            return _state
        }
        set {
            _state = newValue
            // 加入主队列的目的是等setState: 方法调用完毕后, 设置完文字后再去布局子控件
            DispatchQueue.main.async {
                self.setNeedsLayout()
            }
        }
    }
    // MARK: - 子类调用
    /// 设置回调对象和回调方法
    public func setRefreshing(target: AnyObject, action: Selector) {
        self.refreshTarget = target
        self.refreshAction = action
    }
    
    /// // 回调正在刷新的block 触发回调（交给子类去处理）
    public func executeRefreshingCallBack() {
        DispatchQueue.main.async {
            if let refreshBlock = self.refreshingBlock {
                refreshBlock()
            }
            if let target = self.refreshTarget, let action = self.refreshAction, target.responds(to: action) {
                target.perform(action, with: self, afterDelay: 0)
            }
            if let beginRefreshBlock = self.beginRefreshingCompletionBlock {
                beginRefreshBlock()
            }
        }
    }
    // MARK: - 刷新状态控制
    public func beginRefreshing() {
        UIView.animate(withDuration: XLRefreshKeys.fastAnimateDuration) {
            self.alpha = 1.0
        }
        self.pullingPercent = 1.0
        // 只要正在刷新 就完全显示
        if self.window != nil {
            self.state = .refreshing
        } else {
            self.state = .willRefresh
            /// 预防从另一个控制器回到这个控制器，回来要重新刷新一下
            self.setNeedsDisplay()
        }
    }
    /// 开始刷新的回调
    public func beginRefreshingWithCompletionBlock(completionBlock: @escaping () -> Void) {
        self.beginRefreshingCompletionBlock = completionBlock;
        self.beginRefreshing()
    }
    
    // 结束刷新
    public func endRefreshing() {
        DispatchQueue.main.async {
            self.state = .idle
        }
    }
    /// 结束刷新的回调
    public func endRefreshingWithCompletionBlock(completionBlock: @escaping () -> Void) {
        self.endRefreshingCompletionBlock = completionBlock
        self.endRefreshing()
    }
    
    /// 是否正在刷新
    public func isRefreshing() -> Bool {
        return self.state == .refreshing || self.state == .willRefresh
    }
    
    // MARK: - 初始化 生命周期
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.prepare()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /// 布局
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.placeSubViews()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        /// 移除旧控件的监听
        removeObservers()
        /// 判断是否存在 并且属于UIScrollView
        guard let superView = newSuperview as? UIScrollView else { return }
        
        // 新父控件
        // 宽
        self.xl_width = superView.xl_width
        // 位置
        self.xl_x = 0
        _scrollView = superView
        // 设置永远支持垂直弹簧效果 否则不会触发delegate方法，kvo失效
        _scrollView?.alwaysBounceVertical = true
        // 记录最开始的icontentInset
        _scrollViewOriginalInset = superView.contentInset
        // 添加监听
        addObservers()
    }

    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.state == .willRefresh {
            /// 预防view还未完全显示就调用了beginRefreshing
            self.state = .refreshing
        }
    }
    
    // MARK: - observers
    /// 添加监听
    func addObservers() {
        let options: NSKeyValueObservingOptions = [.new, .old]
        scrollView?.addObserver(self, forKeyPath: XLRefreshKeys.contentOffset , options: options, context: nil)
        scrollView?.addObserver(self, forKeyPath: XLRefreshKeys.contentSize, options: options, context: nil)
        pan = self.scrollView?.panGestureRecognizer
        pan?.addObserver(self, forKeyPath: XLRefreshKeys.panState, options: options, context: nil)
    }
    /// 移除监听
    func removeObservers() {
        guard superview is UIScrollView else { return }
        superview?.removeObserver(self, forKeyPath: XLRefreshKeys.contentOffset)
        superview?.removeObserver(self, forKeyPath: XLRefreshKeys.contentSize)
        pan?.removeObserver(self, forKeyPath: XLRefreshKeys.panState)
        pan = nil
    }
    
    /// kvo
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if !self.isUserInteractionEnabled || self.isHidden { return }
        guard let path = keyPath as NSString? else { return }
        
        if let change = change, path.isEqual(to: XLRefreshKeys.contentOffset) {
            self.scrollViewContentOffsetDid(change: change)
        } else if let change = change, path.isEqual(to: XLRefreshKeys.contentSize) {
            self.scrollViewContentSizeDid(change: change)
        } else if let change = change, path.isEqual(to: XLRefreshKeys.panState) {
            self.scrollViewPanStateDid(change: change)
        }
    }
    // MARK: - 检测状态
    /// 检测状态
    /// - parameter newState: 新状态
    /// - parameter oldState: 旧状态
    
    /// - return: 如果两者相同 返回nil, 如果两者不相同, 返回旧的状态
    public func check(newState: XLRefreshState, oldState: XLRefreshState) -> XLRefreshState? {
        return newState == oldState ? nil : oldState
    }
    
    // MARK: - 交给子类们去实现
    /// 初始化
    open func prepare() {
        /// 基本属性
        autoresizingMask = [.flexibleWidth]
        backgroundColor = UIColor.clear
    }
    /// 摆放子控件的frame
    open func placeSubViews() {}
    /// 当scrollView的contentOffset发生改变的时候调用
    open func scrollViewContentOffsetDid(change: [NSKeyValueChangeKey: Any]) {}
    /// 当scrollView的contentSize发生改变的时候调用
    open func scrollViewContentSizeDid(change: [NSKeyValueChangeKey: Any]?) {}
    /// 当scrollView的拖拽状态发生改变的时候调用
    open func scrollViewPanStateDid(change: [NSKeyValueChangeKey: Any]) {}
    
}
