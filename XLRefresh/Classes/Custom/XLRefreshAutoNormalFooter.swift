//
//  XLRefreshAutoNormalFooter.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/6.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit

public class XLRefreshAutoNormalFooter: XLRefreshAutoStateFooter {

    /// 菊花
    private var _loadingView: UIActivityIndicatorView?
    /// 默认`.gray`
    public var activityStyle: UIActivityIndicatorView.Style = .gray {
        didSet {
            self._loadingView = nil
            self.setNeedsLayout()
        }
    }
    /// 菊花
    private var loadingView: UIActivityIndicatorView! {
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
        if self.loadingView.constraints.count == 0 {
            var loadingCenterX = self.xl_width * 0.5
            if !self.refreshingTitleHidden {
                loadingCenterX -= self.lableLeftInset + self.stateLable.xl_textWidth
            }
            let loadingCenterY = self.xl_height * 0.5
            self.loadingView.center = CGPoint(x: loadingCenterX, y: loadingCenterY)
        }
    }
    
    override public var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            guard check(newState: newValue, oldState: state) != nil else { return }
            super.state = newValue
            if newValue == .nomoreData || newValue == .idle {
                self.loadingView.stopAnimating()
            } else if state == .refreshing {
                self.loadingView.startAnimating()
            }
        }
    }
}
