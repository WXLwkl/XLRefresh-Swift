//
//  XLRefreshNormalRight.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/10.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

public class XLRefreshNormalRight: XLRefreshRight {

    
    override public var pullingPercent: CGFloat {
        didSet {
            //这里可以根据百分比 绘制进度效果
            NSLog("%f", pullingPercent)
            self.backgroundColor = UIColor.red.withAlphaComponent(pullingPercent)
        }
    }
    
    // 刷新状态的label
    private var _stateLabel: UILabel?
    public var stateLabel: UILabel! {
        if _stateLabel == nil {
            _stateLabel = UILabel.xl_label()
            _stateLabel!.autoresizingMask = [.flexibleHeight]
            _stateLabel!.numberOfLines = 0
            self.addSubview(_stateLabel!)
        }
        return _stateLabel
    }
    /// 状态对应的问题
    private var stateTitles: [XLRefreshState: String] = [XLRefreshState: String]()
    /// 设置state状态的文字
    public func set(title: String?, for state: XLRefreshState) {
        if title == nil { return }
        self.stateTitles[state] = title
        self.stateLabel.text = self.stateTitles[state]
    }
    
    private var _loadingView: UIActivityIndicatorView?
    public var activityStyle: UIActivityIndicatorView.Style = .gray {
        didSet {
            self._loadingView = nil
            self.setNeedsLayout()
        }
    }
    /// 箭头
    private var _arrowView: UIImageView?
    public var arrowView: UIImageView! {
        if _arrowView == nil {
            let image = UIImage(named: "arrow_left")
            _arrowView = UIImageView(image: image)
            self.addSubview(_arrowView!)
        }
        return _arrowView
    }
    public var loadingView: UIActivityIndicatorView! {
        if _loadingView == nil {
            _loadingView = UIActivityIndicatorView(style: activityStyle)
            self.addSubview(_loadingView!)
        }
        return _loadingView
    }
    
    // MARK: - 重写父类方法
    public override func prepare() {
        super.prepare()
        self.activityStyle = .gray

        /// 初始化文字
        self.set(title: "左拉加载更多", for: .idle)
        self.set(title: "松开立即加载更多", for: .pulling)
        self.set(title: "正在加载更多的数据", for: .refreshing)
        self.set(title: "已经全部加载完毕", for: .nomoreData)
    }
    
    
    public override func placeSubViews() {
        super.placeSubViews()
        
        
        let stateLabelH: CGFloat = self.xl_height * 0.5
        
        self.stateLabel.xl_width = 20
        self.stateLabel.xl_height = stateLabelH
        let stateCenterX = self.xl_width * 0.5 + 10
        let stateCenterY = self.xl_height * 0.5
        self.stateLabel.center = CGPoint(x: stateCenterX, y: stateCenterY)
        
        let arrowCenterX = self.xl_width * 0.5 - 10
        let arrowCenterY = self.xl_height * 0.5
        let center = CGPoint(x: arrowCenterX, y: arrowCenterY)
        
        if arrowView.constraints.count == 0, let image = self.arrowView.image {
            self.arrowView.xl_size = image.size
            self.arrowView.center = center
        }
        if self.loadingView.constraints.count == 0 {
            self.loadingView.center = center
        }
        self.arrowView.tintColor = self.stateLabel.tintColor
    }
    
    public override var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            /// 根据状态做事情
            guard let oldState = check(newState: newValue, oldState: state) else { return }
            super.state = newValue
            self.stateLabel.text = self.stateTitles[newValue]
            
            if newValue == .idle {
                if oldState == .refreshing {
                    self.arrowView.transform = CGAffineTransform.identity
                    UIView.animate(withDuration: XLRefreshKeys.slowAnimateDuration, animations: {
                        self.loadingView.alpha = 0.0
                    }) { (finished) in
                        self.loadingView.alpha = 1.0
                        self.loadingView.stopAnimating()
                        self.arrowView.isHidden = false
                    }
                } else {
                    self.arrowView.isHidden = false
                    self.loadingView.stopAnimating()
                    UIView.animate(withDuration: XLRefreshKeys.fastAnimateDuration) {
                        self.arrowView.transform = CGAffineTransform.identity
                    }
                }
            } else if newValue == .pulling {
                self.arrowView.isHidden = false
                self.loadingView.stopAnimating()
                UIView.animate(withDuration: XLRefreshKeys.fastAnimateDuration) {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
                }
            } else if newValue == .refreshing {
                self.arrowView.isHidden = true
                self.loadingView.startAnimating()
            } else if newValue == .nomoreData {
                self.arrowView.isHidden = true
                self.loadingView.stopAnimating()
            }
        }
    }
}
