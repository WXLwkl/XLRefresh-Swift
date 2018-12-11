//
//  XLRefreshKeys.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/5.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

public struct XLRefreshKeys {
    
    public static let contentOffset = "contentOffset"
    public static let contentInSet = "contentInset"
    public static let contentSize = "contentSize"
    public static let panState = "state"
    
    /// animate duration
    public static let fastAnimateDuration: TimeInterval = 0.25
    public static let slowAnimateDuration: TimeInterval = 0.4
    
    /// 最后一次下拉刷新存储时间对应的key
    public static let headerLastUpdatedTimeKey = "headerLastUpdatedTimeKey"
    
    /// 刷新控件的高度
    public static let headerHeight: CGFloat = 54.0
    public static let footerHeight: CGFloat = 44.0
    public static let leftWidth: CGFloat = 60.0
    public static let rightWidth: CGFloat = 60.0
    
    public static let labelLeftInset: CGFloat = 25.0
}
