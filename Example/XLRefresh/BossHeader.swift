//
//  BossHeader.swift
//  XLRefresh
//
//  Created by xingl on 2018/12/12.
//  Copyright © 2018 xingl. All rights reserved.
//

import UIKit
import XLRefresh

class BossHeader: XLRefreshHeader {
    
    fileprivate var lineLayer = CAShapeLayer()
    fileprivate var topPointLayer = CAShapeLayer()
    fileprivate var bottomPointLayer = CAShapeLayer()
    fileprivate var leftPointLayer = CAShapeLayer()
    fileprivate var rightPointLayer = CAShapeLayer()
    
    let topPointColor = UIColor(red: 90 / 255.0, green: 200 / 255.0, blue: 200 / 255.0, alpha: 1.0)
    let leftPointColor = UIColor(red: 250 / 255.0, green: 85 / 255.0, blue: 78 / 255.0, alpha: 1.0)
    let bottomPointColor = UIColor(red: 92 / 255.0, green: 201 / 255.0, blue: 105 / 255.0, alpha: 1.0)
    let rightPointColor = UIColor(red: 253 / 255.0, green: 175 / 255.0, blue: 75 / 255.0, alpha: 1.0)
    
    let pointRadius: CGFloat = 5.0
    
    fileprivate var aniView = UIView()
    var aniViewWidth: CGFloat = 0.0
    
    // MARK: - 重写父类方法
    public override func prepare() {
        super.prepare()
        self.backgroundColor = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)
        
        self.automaticallyChangeAlpha = true
        self.clipsToBounds = true
        
        self.xl_width = 55
        
        self.addSubview(aniView)
    
        aniViewWidth = self.xl_height - 10.0 * 2.0
        
        let centerLine: CGFloat = aniViewWidth / 2.0
        /// top
        let topPoint = CGPoint(x: centerLine, y: pointRadius)
        topPointLayer = layer(center: topPoint, color: topPointColor)
        topPointLayer.isHidden = false
        topPointLayer.opacity = 0.0
        aniView.layer.addSublayer(topPointLayer)
        /// left
        let leftPoint = CGPoint(x: pointRadius, y: centerLine)
        leftPointLayer = layer(center: leftPoint, color: leftPointColor)
        aniView.layer.addSublayer(leftPointLayer)
        /// bottom
        let bottomPoint = CGPoint(x: centerLine, y: aniViewWidth - pointRadius)
        bottomPointLayer = layer(center: bottomPoint, color: bottomPointColor)
        aniView.layer.addSublayer(bottomPointLayer)
        /// right
        let rightPoint = CGPoint(x: aniViewWidth - pointRadius, y: centerLine)
        rightPointLayer = layer(center: rightPoint, color: rightPointColor)
        aniView.layer.addSublayer(rightPointLayer)
        
        lineLayer = CAShapeLayer()
        lineLayer.frame = self.bounds
        lineLayer.lineWidth = pointRadius * 2
        lineLayer.lineCap = CAShapeLayerLineCap.round
        lineLayer.lineJoin = CAShapeLayerLineJoin.round
        lineLayer.fillColor = topPointColor.cgColor
        lineLayer.strokeColor = topPointColor.cgColor
        
        let path = UIBezierPath()
        
        path.move(to: topPoint)
        path.addLine(to: leftPoint)
        
        path.move(to: leftPoint)
        path.addLine(to: bottomPoint)
        
        path.move(to: bottomPoint)
        path.addLine(to: rightPoint)
        
        path.move(to: rightPoint)
        path.addLine(to: topPoint)
        
        lineLayer.path = path.cgPath
        lineLayer.strokeStart = 0.0
        lineLayer.strokeEnd = 0.0
        aniView.layer.insertSublayer(lineLayer, above: topPointLayer)
    }
    
    public override func placeSubViews() {
        super.placeSubViews()
        
        aniView.xl_size = CGSize(width: aniViewWidth, height: aniViewWidth)
        aniView.center = CGPoint(x: self.xl_width * 0.5, y: self.xl_height * 0.5)
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
                    // 结束刷新动画
                    removeAnimation()
                } else {

                }
            } else if newValue == .pulling {

            } else if newValue == .refreshing {
                // 开启刷新动画
                startAnimation()
                
            }
        }
    }

    override public var pullingPercent: CGFloat {
        didSet {
            //这里可以根据百分比获取偏移量 绘制进度效果
            let adjustPercent = pullingPercent * self.xl_height
            
            if adjustPercent > self.xl_height {
                aniView.xl_y = (self.xl_height - aniViewWidth) / 2.0
            } else {
                if adjustPercent <= aniViewWidth {
                    aniView.xl_y = self.xl_height - adjustPercent
                } else {
                    aniView.xl_y = self.xl_height - (aniViewWidth + (adjustPercent - aniViewWidth) / 2.0)
                }
            }
            updateProgress(adjustPercent)
        }
    }
    
    func updateProgress(_ progress: CGFloat) {
        var startProgress: CGFloat = 0.0
        var endProgress: CGFloat = 0.0
        let margin: CGFloat = (self.xl_height - aniViewWidth) * 0.5 + pointRadius
        
        if progress < 0 {
            topPointLayer.opacity = 0.0
            adjustPointState(index: 0)
        } else if progress >= 0 && progress < margin {
            topPointLayer.opacity = Float(progress / 20.0)
            adjustPointState(index: 0)
        } else if progress >= margin && progress < self.xl_height {
            topPointLayer.opacity = 1.0
            // 大阶段 0 ~ 3
            let stage: NSInteger = NSInteger((progress - margin) / 10)
            // 大阶段的前半段
            let subProgress: CGFloat = (progress - margin) - CGFloat(stage) * 10.0
            if subProgress >= 0 && subProgress <= 5 {
                adjustPointState(index: stage * 2)
                startProgress = CGFloat(stage) / 4.0
                endProgress = CGFloat(stage) / 4.0 + subProgress / 40.0 * 2
                
            }
            /// 大阶段的后半段
            if subProgress > 5 && subProgress < 10 {
                adjustPointState(index: stage * 2 + 1)
                startProgress = CGFloat(stage) / 4.0 + (subProgress - 5) / 40.0 * 2
                if startProgress < CGFloat(stage + 1) / 4.0 - 0.1 {
                    startProgress = CGFloat(stage + 1) / 4.0 - 0.1
                }
                endProgress = CGFloat(stage + 1) / 4.0
            }
        } else {
            topPointLayer.opacity = 1.0
            adjustPointState(index: Int.max)
            startProgress = 1.0
            endProgress = 1.0
        }
        lineLayer.strokeStart = startProgress
        lineLayer.strokeEnd = endProgress
    }
    
    func adjustPointState(index: NSInteger) {
        leftPointLayer.isHidden = index > 1 ? false : true
        bottomPointLayer.isHidden = index > 3 ? false : true
        rightPointLayer.isHidden = index > 5 ? false : true
        
        lineLayer.strokeColor = index > 5 ? rightPointColor.cgColor : index > 3 ? bottomPointColor.cgColor : index > 1 ? leftPointColor.cgColor : topPointColor.cgColor
    }
    
    func startAnimation() {
        
        let translatLen: CGFloat = 5.0
        
        addTransLationAni(toLayer: topPointLayer, xValue: 0, yValue: translatLen)
        addTransLationAni(toLayer: leftPointLayer, xValue: translatLen, yValue: 0)
        addTransLationAni(toLayer: bottomPointLayer, xValue: 0, yValue: -translatLen)
        addTransLationAni(toLayer: rightPointLayer, xValue: -translatLen, yValue: 0)
        
        addRotationAnimation(toLayer: aniView.layer)
    }
    func removeAnimation() {
        topPointLayer.removeAllAnimations()
        leftPointLayer.removeAllAnimations()
        bottomPointLayer.removeAllAnimations()
        rightPointLayer.removeAllAnimations()
        aniView.layer.removeAllAnimations()
        adjustPointState(index: 0)
    }
    /// 圆点动画
    func addTransLationAni(toLayer layer: CALayer, xValue: CGFloat, yValue: CGFloat) {
        let translationKeyFrameAni = CAKeyframeAnimation(keyPath: "transform")
        translationKeyFrameAni.duration = 1.0
        translationKeyFrameAni.repeatCount = Float(Int.max)
        translationKeyFrameAni.isRemovedOnCompletion = false
        translationKeyFrameAni.fillMode = CAMediaTimingFillMode.forwards
        translationKeyFrameAni.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        let fromValue: NSValue = NSValue(caTransform3D: CATransform3DMakeTranslation(0, 0, 0))
        let toValue: NSValue = NSValue(caTransform3D: CATransform3DMakeTranslation(xValue, yValue, 0))
        translationKeyFrameAni.values = [fromValue, toValue, fromValue, toValue, fromValue]
        layer.add(translationKeyFrameAni, forKey: "translationKeyframeAni")
    }
    /// view旋转动画
    func addRotationAnimation(toLayer layer: CALayer) {
        let rotationAni = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAni.fromValue = 0
        rotationAni.toValue = CGFloat.pi * 2
        rotationAni.duration = 1.0
        rotationAni.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        rotationAni.repeatCount = Float(Int.max)
        rotationAni.fillMode = CAMediaTimingFillMode.forwards
        rotationAni.isRemovedOnCompletion = false
        layer.add(rotationAni, forKey: "rotationAni")
    }
    
    /// layer
    func layer(center: CGPoint, color: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: center.x - pointRadius, y: center.y - pointRadius, width: pointRadius * 2, height: pointRadius * 2)
        layer.fillColor = color.cgColor
        layer.path = UIBezierPath(arcCenter: CGPoint(x: pointRadius, y: pointRadius), radius: pointRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        layer.isHidden = true
        return layer
    }
}
