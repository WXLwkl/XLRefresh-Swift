//
//  XLRefreshBackStateFooter.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/6.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
/// 带有状态文字的上拉刷新控件
open class XLRefreshBackStateFooter: XLRefreshBackFooter {

    /// 文字距离圈圈, 箭头的距离
    public var lableLeftInset: CGFloat = 0.0
    private var _stateLbale: UILabel?
    private var stateTitles: [XLRefreshState: String] = [XLRefreshState: String]()
    /// 显示刷新状态的lable
    public var stateLable: UILabel! {
        if _stateLbale == nil {
            _stateLbale = UILabel.xl_label()
            self.addSubview(_stateLbale!)
        }
        return _stateLbale
    }
    /// 设置state状态下的文字
    public func set(title: String, for state: XLRefreshState) {
        self.stateTitles[state] = title
        self.stateLable.text = self.stateTitles[state]
    }
    
    /// 获取state状态下的的title
    public func titlelFor(state: XLRefreshState) -> String? {
        return self.stateTitles[state]
    }

    // MARK: - override
    override open func prepare() {
        super.prepare()
        /// 初始化间剧
        self.lableLeftInset = XLRefreshKeys.labelLeftInset
        /// 初始化文字
        self.set(title: "上拉可以加载更多", for: .idle)
        self.set(title: "松开立即加载更多", for: .pulling)
        self.set(title: "正在加载更多的数据...", for: .refreshing)
        self.set(title: "已经全部加载完毕", for: .nomoreData)
        
    }
    
    override open func placeSubViews() {
        super.placeSubViews()
        if self.stateLable.constraints.count > 0 { return }
        /// 状态标签
        self.stateLable.frame = self.bounds
    }
    
    override open var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            guard check(newState: newValue, oldState: state) != nil else { return }
            super.state = newValue
            self.stateLable.text = self.stateTitles[newValue]
        }
    }
}
