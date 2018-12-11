//
//  XLRefreshStateHeader.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/6.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

public typealias lastUpdatedTimeTextBlock = (Date) -> String

/// 带有状态文字的下拉刷新控件
public class XLRefreshStateHeader: XLRefreshHeader {

    public var lastUpdatedTimeTextBlock: lastUpdatedTimeTextBlock?
    
    // 上次刷新的时间label
    private var _lastUpdatedTimeLabel: UILabel?
    public var lastUpdatedTimeLabel: UILabel! {
        if _lastUpdatedTimeLabel == nil {
            _lastUpdatedTimeLabel = UILabel.xl_label()
            self.addSubview(_lastUpdatedTimeLabel!)
        }
        return _lastUpdatedTimeLabel
    }
    
    // 刷新状态的label
    private var _stateLabel: UILabel?
    public var stateLabel: UILabel! {
        if _stateLabel == nil {
            _stateLabel = UILabel.xl_label()
            self.addSubview(_stateLabel!)
        }
        return _stateLabel
    }
    
    /// 文字距离圈圈 箭头的距离
    public var labelLeftInset: CGFloat = 0.0
    /// 状态对应的问题
    private var stateTitles: [XLRefreshState: String] = [XLRefreshState: String]()
    
    /// 设置state状态的文字
    public func set(title: String?, for state: XLRefreshState) {
        if title == nil { return }
        self.stateTitles[state] = title
        self.stateLabel.text = self.stateTitles[state]
    }

    public override var lastUpdatedTimeKey: String {
        didSet {
            super.lastUpdatedTimeKey = lastUpdatedTimeKey
            if self.lastUpdatedTimeLabel.isHidden { return }
            if let time = self.lastUpdatedTime {
                /// 如果有block 回调block并return
                if let lastUpdatedTextBlock = self.lastUpdatedTimeTextBlock {
                    self.lastUpdatedTimeLabel.text = lastUpdatedTextBlock(time)
                    return
                }
                let calender = currentCalendar()
                /// 存储的时间
                let cmp1 = calender.dateComponents([.year, .month, .day, .hour, .minute], from: time)
                /// 当前时间
                let cmp2 = calender.dateComponents([.year, .month, .day, .hour, .minute], from: time)
                /// 格式化日期
                let formatter = DateFormatter()
                var isToday = false
                /// 今天
                if cmp1.day == cmp2.day {
                    formatter.dateFormat = " HH:mm"
                    isToday = true
                } else if cmp1.year == cmp2.year {
                    /// 今年
                    formatter.dateFormat = "MM-dd HH:mm"
                } else {
                    formatter.dateFormat = "yyyy-MM-dd HH:mm"
                }
                let timeStr = formatter.string(from: time)
                
                /// 显示日期
                let desc: String = isToday ? "今天" : ""
                self.lastUpdatedTimeLabel.text = String(format: "%@%@%@", arguments: ["最后更新：", desc, timeStr])
            } else {
                self.lastUpdatedTimeLabel.text = String(format: "%@%@", arguments: ["最后更新：", "无记录"])
            }
        }
    }
    
    // MARK: - 重写父类方法
    public override func prepare() {
        super.prepare()
        
        self.labelLeftInset = XLRefreshKeys.labelLeftInset
        self.set(title: "下拉可以刷新", for: .idle)
        self.set(title: "松开立即刷新", for: .pulling)
        self.set(title: "正在刷新数据中...", for: .refreshing)
    }
    public override func placeSubViews() {
        super.placeSubViews()
        let noConstraintOnStatusLabel:Bool = self.stateLabel.constraints.count == 0
        if self.lastUpdatedTimeLabel.isHidden {
            // 状态
            if noConstraintOnStatusLabel {
                self.stateLabel.frame = self.bounds
            }
        } else {
            let stateLabelH: CGFloat = self.xl_height * 0.5
            /// 状态
            if noConstraintOnStatusLabel {
                self.stateLabel.xl_x = 0
                self.stateLabel.xl_y = 0
                self.stateLabel.xl_width = self.xl_width
                self.stateLabel.xl_height = stateLabelH
            }
            /// 更新时间
            if self.lastUpdatedTimeLabel.constraints.count == 0 {
                self.lastUpdatedTimeLabel.xl_x = 0
                self.lastUpdatedTimeLabel.xl_y = stateLabelH
                self.lastUpdatedTimeLabel.xl_width = self.xl_width
                self.lastUpdatedTimeLabel.xl_height = self.xl_height - stateLabelH
            }
        }
    }
    
    public override var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            guard check(newState: newValue, oldState: state) != nil else { return }
            super.state = newValue
            // 设置状态文字
            self.stateLabel.text = self.stateTitles[newValue]
            /// 重新设置key
            self.lastUpdatedTimeKey = XLRefreshKeys.headerLastUpdatedTimeKey
        }
    }
    
    
    
    // MARK: - 日历获取方法
    
    private func currentCalendar() -> Calendar {
        return Calendar.current
    }

}
