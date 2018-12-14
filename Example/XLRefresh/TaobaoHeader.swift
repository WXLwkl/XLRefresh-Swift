//
//  TaobaoHeader.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/10.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
import XLRefresh

class TaobaoHeader: XLRefreshHeader {

    fileprivate let circleLayer = CAShapeLayer()
    fileprivate let arrowLayer = CAShapeLayer()
    fileprivate let strokeColor = UIColor(red: 135.0/255.0, green: 136.0/255.0, blue: 137.0/255.0, alpha: 1.0)
    
    override public var pullingPercent: CGFloat {
        didSet {
            //这里可以根据百分比 绘制进度效果
            let adjustPercent = max(min(1.0, pullingPercent),0.0)
            self.circleLayer.strokeEnd = 0.05 + 0.9 * adjustPercent
        }
    }
    // 刷新状态的label
    private lazy var stateLabel: UILabel =  {
        let stateLabel = UILabel.xl_label()
        self.addSubview(stateLabel)
        return stateLabel
    }()
    // logo
    private lazy var imageView: UIImageView =  {
        let imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 230, height: 35))
        imageView.image = UIImage(named: "taobaoLogo")
        self.addSubview(imageView)
        return imageView
    }()
    /// 状态对应的问题
    private var stateTitles: [XLRefreshState: String] = [XLRefreshState: String]()
    
    /// 设置state状态的文字
    public func set(title: String?, for state: XLRefreshState) {
        if title == nil { return }
        self.stateTitles[state] = title
        self.stateLabel.text = self.stateTitles[state]
    }
    
    // MARK: - 重写父类方法
    public override func prepare() {
        super.prepare()

        self.set(title: "下拉可以刷新", for: .idle)
        self.set(title: "松开立即刷新", for: .pulling)
        self.set(title: "刷新中...", for: .refreshing)
        
        setUpCircleLayer()
        setUpArrowLayer()
    }
    
    public override func placeSubViews() {
        super.placeSubViews()
        
        //放置Views和Layer
        imageView.center = CGPoint(x: self.frame.width/2, y: self.frame.height - 60 - 18)
        self.arrowLayer.position = CGPoint(x: self.frame.width/2 - 70, y: self.frame.height/2)
        self.circleLayer.position = CGPoint(x: self.frame.width/2 - 70, y: self.frame.height/2)
        
        let stateLabelH: CGFloat = self.xl_height * 0.5
        self.stateLabel.xl_x = 0
        self.stateLabel.xl_y = stateLabelH * 0.5
        self.stateLabel.xl_width = self.xl_width
        self.stateLabel.xl_height = self.xl_height - stateLabelH
        
    }
    
    public override var state: XLRefreshState {
        get {
            return super.state
        }
        set {
            guard let oldState = check(newState: newValue, oldState: state) else { return }
            super.state = newValue
            // 设置状态文字
            self.stateLabel.text = self.stateTitles[newValue]
            
            if newValue == .idle {
                if oldState == .refreshing {
                    didCompleteHideAnimation()
                } else {

                }
            } else if newValue == .pulling {

            } else if newValue == .refreshing {
                didBeginRefreshingState()
            }
        }
    }

    
    func setUpCircleLayer() {
        let bezierPath = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 12.0, startAngle: -.pi / 2, endAngle: .pi/2.0 * 3.0, clockwise: true)
        self.circleLayer.path = bezierPath.cgPath
        self.circleLayer.strokeColor = UIColor.lightGray.cgColor
        self.circleLayer.fillColor = UIColor.clear.cgColor
        self.circleLayer.strokeStart = 0.05
        self.circleLayer.strokeEnd = 0.05
        self.circleLayer.lineWidth = 1.0
        self.circleLayer.lineCap = CAShapeLayerLineCap.round
        self.circleLayer.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer.addSublayer(self.circleLayer)
    }
    
    func setUpArrowLayer(){
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 20, y: 15))
        bezierPath.addLine(to: CGPoint(x: 20, y: 25))
        bezierPath.addLine(to: CGPoint(x: 25,y: 20))
        bezierPath.move(to: CGPoint(x: 20, y: 25))
        bezierPath.addLine(to: CGPoint(x: 15, y: 20))
        self.arrowLayer.path = bezierPath.cgPath
        self.arrowLayer.strokeColor = UIColor.lightGray.cgColor
        self.arrowLayer.fillColor = UIColor.clear.cgColor
        self.arrowLayer.lineWidth = 1.0
        self.arrowLayer.lineCap = CAShapeLayerLineCap.round
        self.arrowLayer.bounds = CGRect(x: 0, y: 0,width: 40, height: 40)
        self.arrowLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer.addSublayer(self.arrowLayer)
    }
    
    func didBeginRefreshingState(){
        self.circleLayer.strokeEnd = 0.95
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotateAnimation.toValue = NSNumber(value: .pi * 2.0)
        rotateAnimation.duration = 0.6
        rotateAnimation.isCumulative = true
        rotateAnimation.repeatCount = 10000000
        self.circleLayer.add(rotateAnimation, forKey: "rotate")
        self.arrowLayer.isHidden = true
    }

    func didCompleteHideAnimation(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.circleLayer.strokeEnd = 0.05
        CATransaction.commit()
        
        self.circleLayer.removeAllAnimations()
        self.arrowLayer.isHidden = false
    }
}
