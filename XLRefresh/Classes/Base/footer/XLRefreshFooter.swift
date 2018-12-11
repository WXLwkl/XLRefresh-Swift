//
//  XLRefreshFooter.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/5.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

open class XLRefreshFooter: XLRefreshComponent {
    
    /// 忽略scrollview contentInset的bottom
    public var ignoredScrollViewContentInsetBottom: CGFloat = 0.0
    
    // MARK: - 构造方法
    
    static public func footerWithRefreshing(block: @escaping XLRefreshComponentRefreshingBlock) -> XLRefreshFooter {
        let footer = self.init()
        footer.refreshingBlock = block
        return footer
    }
    static public func footerWithRefreshing(target: AnyObject, action: Selector) -> XLRefreshFooter {
        let footer = self.init()
        footer.setRefreshing(target: target, action: action)
        return footer
    }
    
    // MARK: - 重写父类
    open override func prepare() {
        super.prepare()
        self.xl_height = XLRefreshKeys.footerHeight
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard newSuperview != nil, let indeedScrollView = self.scrollView  else { return }
        /// 监听scrollview的数据变化
        if indeedScrollView.isKind(of: UITableView.self) || indeedScrollView.isKind(of: UICollectionView.self) {
            indeedScrollView.xl_reloadDataHandler = { totalCount in
                    /// 保留属性
                // 这里可以根据totalCount的数量 做一些处理 eg:隐藏footer
            }
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
