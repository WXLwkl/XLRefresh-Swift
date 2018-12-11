//
//  XLRefreshBackNormalFooter.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/6.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
/// 默认的上拉加载更多控件
public class XLRefreshBackNormalFooter: XLRefreshBackStateFooter {

    /// 箭头
    private var _arrowView: UIImageView?
    /// 菊花
    private var _loadingView: UIActivityIndicatorView?
    /// 默认`.gray`
    public var activityStyle: UIActivityIndicatorView.Style = .gray {
        didSet {
            self._loadingView = nil
            self.setNeedsLayout()
        }
    }
    /// 不允许子类重写
    public final var arrowView: UIImageView! {
        if _arrowView == nil {
            let image = UIImage(named: "arrow")
            _arrowView = UIImageView(image: image)
            self.addSubview(_arrowView!)
        }
        return _arrowView
    }
    /// 菊花
    final var loadingView: UIActivityIndicatorView! {
        if _loadingView == nil {
            _loadingView = UIActivityIndicatorView(style: activityStyle)
            self.addSubview(_loadingView!)
        }
        return _loadingView
    }
    
    // MARK: - override
    
    override public func prepare() {
        super.prepare()
        self.activityStyle = .gray
    }
    
    override public func placeSubViews() {
        super.placeSubViews()
        var arrowCenterX = self.xl_width * 0.5
        if  !self.stateLable.isHidden {
            arrowCenterX -= self.lableLeftInset + self.stateLable.xl_textWidth * 0.5
        }
        let arrowCenterY = self.xl_height * 0.5
        let arrowCenter = CGPoint(x: arrowCenterX, y: arrowCenterY)
        /// 箭头
        if self.arrowView.constraints.count == 0 {
            if let image = self.arrowView.image {
                self.arrowView.xl_size = image.size
                self.arrowView.center = arrowCenter
            }
        }
        /// 圆圈
        if self.loadingView.constraints.count == 0 {
            self.loadingView.center = arrowCenter
        }
        self.arrowView.tintColor = self.stateLable.tintColor
    }
    
    override public var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            /// 根据状态做事情
            guard let oldState = check(newState: newValue, oldState: state) else { return }
            super.state = newValue
            if newValue == .idle {
                if oldState == .refreshing {
                    self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
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
                        self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
                    }
                }
            } else if newValue == .pulling {
                self.arrowView.isHidden = false
                self.loadingView.stopAnimating()
                UIView.animate(withDuration: XLRefreshKeys.fastAnimateDuration) {
                    self.arrowView.transform = CGAffineTransform.identity
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
