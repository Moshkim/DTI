//
//  AnimatedUILogoView.swift
//  E-Bike App
//
//  Created by KWANIL KIM on 5/30/17.
//  Copyright © 2017 DTI Holdings Inc. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore



/*
open class AnimatedUILogoView: UIView {


    fileprivate let strokeEndTimingfunction = CAMediaTimingFunction(controlPoints: 1.00, 0.0, 0.35, 1.0)
    fileprivate let fadeInSquareTimingFunction = CAMediaTimingFunction(controlPoints: 0.15, 0.0, 0.85, 1.0)
    fileprivate let circleLayerTimingFunction = CAMediaTimingFunction(controlPoints: 0.65, 0.0, 0.4, 1.0)
    fileprivate let squareLayerTimingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.0, 0.20, 1.0)
    
    
    fileprivate let radius: CGFloat = 37.5
    fileprivate let squareLayerLength = 21.0
    fileprivate let starTimeOffset = 0.7 * kAnimationDuration
    
    fileprivate var circleLayer: CAShapeLayer!
    fileprivate var squareLayer: CAShapeLayer!
    fileprivate var lineLayer: CAShapeLayer!
    fileprivate var maskLayer: CAShapeLayer!
    
    var beginTime: CFTimeInterval = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        circleLayer = generateCircleLayer()
        lineLayer = generateLineLayer()
        squareLayer = generateSquareLayer()
        maskLayer = generateMaskLayer()
        //lineLayer = gener
        
        layer.addSublayer(circleLayer)
    
    }
    
    
    open func startAnimating() {
        beginTime = CACurrentMediaTime()
        layer.anchorPoint = CGPoint.zero
        
        animateCircleLayer()
        animateMaskLayer()
        animateLineLayer()
        animateSquareLayer()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}


extension AnimatedUILogoView {
    
    fileprivate func generateMaskLayer()->CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: -radius, y: -radius, width: radius * 2.0, height: radius * 2.0)
        layer.allowsGroupOpacity = true
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }

    fileprivate func generateCircleLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        
        layer.lineWidth = radius
        layer.path = UIBezierPath(arcCenter: CGPoint.zero, radius: radius/2, startAngle: -CGFloat(M_PI_2), endAngle: CGFloat(3*M_PI_2), clockwise: true).cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }

    fileprivate func generateLineLayer()->CAShapeLayer {
        let layer = CAShapeLayer()
        layer.position = CGPoint.zero
        layer.frame = CGRect.zero
        layer.allowsGroupOpacity = true
        layer.lineWidth = 5.0
        layer.strokeColor = UIColor.DTIBlue().cgColor
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint.zero)
        bezierPath.addLine(to: CGPoint(x: 0.0, y: -radius))
        
        layer.path = bezierPath.cgPath
        return layer
    }
    
    fileprivate func generateSquareLayer()->CAShapeLayer {
        let layer = CAShapeLayer()
        layer.position = CGPoint.zero
        layer.frame = CGRect(x: -squareLayerLength / 2.0, y: -squareLayerLength / 2.0, width: squareLayerLength, height: squareLayerLength)
        layer.cornerRadius = 1.5
        layer.allowsGroupOpacity = true
        layer.backgroundColor = UIColor.DTIBlue().cgColor
        
        return layer
    }
}


extension AnimatedUILogoView {
    
    fileprivate func animateMaskLayer() {
    }
    
    fileprivate func animateCircleLayer() {
        
        //strokeEnd - filled the circle with white background color in clockwise
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.timingFunction = strokeEndTimingfunction
        strokeEndAnimation.duration = kAnimationDuration - kAnimationDurationDelay
        strokeEndAnimation.values = [0.0, 1.0]
        strokeEndAnimation.keyTimes = [0.0, 1.0]
        
        
        //transform
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.timingFunction = strokeEndTimingfunction
        transformAnimation.duration = kAnimationDuration - kAnimationDurationDelay
        
        var startingTransform = CATransform3DMakeRotation(CGFloat(M_PI_4), 0, 0, 1)
        startingTransform = CATransform3DScale(startingTransform, 0.25, 0.25, 1)
        transformAnimation.fromValue = NSValue(caTransform3D: startingTransform)
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        
        //Group
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [strokeEndAnimation,transformAnimation]
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.duration = kAnimationDuration
        groupAnimation.beginTime = beginTime
        groupAnimation.timeOffset = starTimeOffset
        
        circleLayer.add(groupAnimation, forKey: "looping")
        
        
    }
    
    fileprivate func animateLineLayer() {
    }
    
    fileprivate func animateSquareLayer() {
    }
}

 */

open class AnimatedULogoView: UIView {
    fileprivate let strokeEndTimingFunction   = CAMediaTimingFunction(controlPoints: 1.00, 0.0, 0.35, 1.0)
    fileprivate let squareLayerTimingFunction      = CAMediaTimingFunction(controlPoints: 0.25, 0.0, 0.20, 1.0)
    fileprivate let circleLayerTimingFunction   = CAMediaTimingFunction(controlPoints: 0.65, 0.0, 0.40, 1.0)
    fileprivate let fadeInSquareTimingFunction = CAMediaTimingFunction(controlPoints: 0.15, 0, 0.85, 1.0)
    
    fileprivate let radius: CGFloat = 37.5
    fileprivate let squareLayerLength = 21.0
    fileprivate let startTimeOffset = 0.7 * kAnimationDuration
    
    fileprivate var circleLayer: CAShapeLayer!
    fileprivate var squareLayer: CAShapeLayer!
    fileprivate var lineLayer: CAShapeLayer!
    fileprivate var maskLayer: CAShapeLayer!
    
    var beginTime: CFTimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        circleLayer = generateCircleLayer()
        lineLayer = generateLineLayer()
        squareLayer = generateSquareLayer()
        maskLayer = generateMaskLayer()
        
        //    layer.mask = maskLayer
        layer.addSublayer(circleLayer)
        //    layer.addSublayer(lineLayer)
        //    layer.addSublayer(squareLayer)
    }
    
    open func startAnimating() {
        beginTime = CACurrentMediaTime()
        layer.anchorPoint = CGPoint.zero
        
        animateMaskLayer()
        animateCircleLayer()
        animateLineLayer()
        animateSquareLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension AnimatedULogoView {
    
    fileprivate func generateMaskLayer()->CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: -radius, y: -radius, width: radius * 2.0, height: radius * 2.0)
        layer.allowsGroupOpacity = true
        layer.backgroundColor = UIColor.white.cgColor
        return layer
    }
    
    fileprivate func generateCircleLayer()->CAShapeLayer {
        let layer = CAShapeLayer()
        layer.lineWidth = radius
        layer.path = UIBezierPath(arcCenter: CGPoint.zero, radius: radius/2, startAngle: -CGFloat(M_PI_2), endAngle: CGFloat(3*M_PI_2), clockwise: true).cgPath
        layer.strokeColor = UIColor.white.cgColor
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }
    
    fileprivate func generateLineLayer()->CAShapeLayer {
        let layer = CAShapeLayer()
        layer.position = CGPoint.zero
        layer.frame = CGRect.zero
        layer.allowsGroupOpacity = true
        layer.lineWidth = 5.0
        layer.strokeColor = UIColor.DTIBlue().cgColor
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint.zero)
        bezierPath.addLine(to: CGPoint(x: 0.0, y: -radius))
        
        layer.path = bezierPath.cgPath
        return layer
    }
    
    fileprivate func generateSquareLayer()->CAShapeLayer {
        let layer = CAShapeLayer()
        layer.position = CGPoint.zero
        layer.frame = CGRect(x: -squareLayerLength / 2.0, y: -squareLayerLength / 2.0, width: squareLayerLength, height: squareLayerLength)
        layer.cornerRadius = 1.5
        layer.allowsGroupOpacity = true
        layer.backgroundColor = UIColor.DTIBlue().cgColor
        
        return layer
    }
}

extension AnimatedULogoView {
    
    fileprivate func animateMaskLayer() {
    }
    
    fileprivate func animateCircleLayer() {
        
        
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.timingFunction = strokeEndTimingFunction
        strokeEndAnimation.duration = kAnimationDuration - kAnimationDurationDelay
        strokeEndAnimation.values = [0.0, 1.0]
        strokeEndAnimation.keyTimes = [0.0, 1.0]
        
        
        //transform
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.timingFunction = strokeEndTimingFunction
        transformAnimation.duration = kAnimationDuration - kAnimationDurationDelay
        
        var startingTransform = CATransform3DMakeRotation(CGFloat(M_PI_4), 0, 0, 1)
        startingTransform = CATransform3DScale(startingTransform, 0.25, 0.25, 1)
        transformAnimation.fromValue = NSValue(caTransform3D: startingTransform)
        transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        
        //Group
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [strokeEndAnimation,transformAnimation]
        groupAnimation.repeatCount = Float.infinity
        groupAnimation.duration = kAnimationDuration
        groupAnimation.beginTime = beginTime
        groupAnimation.timeOffset = startTimeOffset
        
        circleLayer.add(groupAnimation, forKey: "looping")
    }
    
    fileprivate func animateLineLayer() {
    }
    
    fileprivate func animateSquareLayer() {
    }
}


 
