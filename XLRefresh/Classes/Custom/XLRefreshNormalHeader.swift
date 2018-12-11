//
//  XLRefreshNormalHeader.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/6.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

public class XLRefreshNormalHeader: XLRefreshStateHeader {

    private var _arrowView: UIImageView?
    private var _loadingView: UIActivityIndicatorView?
    
    public var activityStyle: UIActivityIndicatorView.Style = .gray {
        didSet {
            self._loadingView = nil
            self.setNeedsLayout()
        }
    }
    /// 箭头
    public var arrowView: UIImageView! {
        if _arrowView == nil {
            let image = UIImage(named: "arrow")
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
    override public var pullingPercent: CGFloat {
        didSet {
            //这里可以根据百分比 绘制进度效果
            NSLog("%f", pullingPercent)
            self.backgroundColor = UIColor.red.withAlphaComponent(pullingPercent)
        }
    }
    // MARK: - 重写父类方法
    public override func prepare() {
        super.prepare()
        self.activityStyle = .gray
    }
    public override func placeSubViews() {
        super.placeSubViews()
        var arrowCenterX = self.xl_width * 0.5
        if !self.stateLabel.isHidden  {
            let stateWidth = self.stateLabel.xl_textWidth
            var timeWidth: CGFloat = 0.0
            if !self.lastUpdatedTimeLabel.isHidden {
                timeWidth = self.lastUpdatedTimeLabel.xl_textWidth
            }
            let textWidth = max(stateWidth, timeWidth)
            arrowCenterX -= textWidth / 2.0 + self.labelLeftInset
        }
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
            guard let oldState = check(newState: newValue, oldState: state) else { return }
            super.state = newValue
            if newValue == .idle {
                if oldState == .refreshing {
                    self.arrowView.transform = CGAffineTransform.identity
                    UIView.animate(withDuration: XLRefreshKeys.slowAnimateDuration, animations: {
                        self.loadingView.alpha = 0.0
                    }) { (finished) in
                        /// 如果执行完动画发现不是 idle状态 就直接返回
                        if self.state != .idle { return }
                        self.loadingView.alpha = 1.0
                        self.loadingView.stopAnimating()
                        self.arrowView.isHidden = false
                    }
                } else {
                    self.loadingView.stopAnimating()
                    self.arrowView.isHidden = false
                    UIView.animate(withDuration: XLRefreshKeys.fastAnimateDuration, animations: {
                        self.arrowView.transform = CGAffineTransform.identity
                    })
                }
            } else if newValue == .pulling {
                self.loadingView.stopAnimating()
                self.arrowView.isHidden = false
                UIView.animate(withDuration: XLRefreshKeys.fastAnimateDuration) {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
                }
            } else if newValue == .refreshing {
                self.loadingView.alpha = 1.0
                self.loadingView.startAnimating()
                self.arrowView.isHidden = true
            }
        }
    }
}
