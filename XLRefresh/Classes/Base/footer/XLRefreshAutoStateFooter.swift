//
//  XLRefreshAutoStateFooter.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/6.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
/// 带有状态文字的上拉刷新控件
public class XLRefreshAutoStateFooter: XLRefreshAutoFooter {

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
    /// 隐藏刷新状态的文字
    public var refreshingTitleHidden: Bool = false
    /// 设置state状态下的文字
    public func set(title: String, for state: XLRefreshState) {
        self.stateTitles[state] = title
        self.stateLable.text = self.stateTitles[state]
    }

    
    // MARK: - override
    
    override public func prepare() {
        super.prepare()
        /// 初始化间距
        self.lableLeftInset = XLRefreshKeys.labelLeftInset
        self.set(title: "点击或上拉加载更多", for: .idle)
        self.set(title: "正在加载更多的数据...", for: .refreshing)
        self.set(title: "已经全部加载完毕", for: .nomoreData)
        /// 监听lable
        self.stateLable.isUserInteractionEnabled = true
        self.stateLable.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateLableClick)))
    }
    @objc private func stateLableClick() {
        if self.state == .idle {
            self.beginRefreshing()
        }
    }
    
    override public func placeSubViews() {
        super.placeSubViews()
        if self.stateLable.constraints.count == 0 {
            /// 设置状态标签frame
            self.stateLable.frame = self.bounds
        }
    }
    
    override public var state: XLRefreshState {
        /// 根据状态做事情
        get {
            return super.state
        }
        set {
            guard check(newState: newValue, oldState: state) != nil else { return }
            super.state = newValue
            if self.refreshingTitleHidden && newValue == .refreshing {
                self.stateLable.text = nil
            } else {
                self.stateLable.text = self.stateTitles[newValue]
            }
        }
    }
}
