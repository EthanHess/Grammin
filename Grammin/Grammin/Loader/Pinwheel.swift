//
//  Pinwheel.swift
//  LoadingView
//
//  Created by Ethan Hess on 6/28/22.
//

import UIKit

class Pinwheel: UIView {
    
    var circleLayer: CAShapeLayer!
    let π = Double.pi
    var currentAmt: CGFloat = 0
    var animationColor: UIColor? //One color
    var animationColorArray: [UIColor]? //Pie animation with multiple colors
    
    //Will be superimposed over pie animation,
    lazy var gradientContainer : GradientContainer = {
        let gc = GradientContainer()
        return gc
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //this will match center gradient to create border effect
        
    }
    
    func cornerRadius() {
        let halfWidth = frame.size.width / 2
        layer.cornerRadius = halfWidth
        clipsToBounds = true
        addGradient([UIColor.white.cgColor, UIColor.green.cgColor], lineWidth: 3, radius: halfWidth)
    }
    
    //MARK: Private / internal
    
    //MARK: Where pie slice will start/stop
    fileprivate func endAngleArray() -> [CGFloat] {
        
        let angleOne = CGFloat(π * 2)
        let angleTwo = CGFloat(π * 2)
        let angleThree = CGFloat((π / 3) * 6)
        let angleFour = CGFloat(2 * π)
        let angleFive = CGFloat((π / 2.5) * 5)
        let angleSix = CGFloat((π / 1.5) * 3)
        let angleSeven = CGFloat((π / 3.5) * 7)
        let angleEight = CGFloat((π / 4) * 8)
        let angleNine = CGFloat((π / 4.5) * 9)
        let angleTen = CGFloat((π / 5) * 10)
        
        return [angleOne, angleTwo, angleThree, angleFour, angleFive, angleSix, angleSeven, angleEight, angleNine, angleTen]
    }
    
    func animatedCircleConfiguration(countIndex: Int, totalCount: Int) {
        let circleCenter = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let radius: CGFloat = max(bounds.width, bounds.height)

        if totalCount > endAngleArray().count {
            print("Add more end angles!")
            return
        }
        
        let startAngle = CGFloat(-(π / 2))
        let endAngle = endAngleArray()[totalCount - 1]
            
        let lineWidth = (radius / 2) - 1
        let path2 = UIBezierPath(arcCenter: circleCenter,
                                     radius: ((radius/2) - 1) - lineWidth/2,
                                     startAngle: startAngle,
                                     endAngle: endAngle,
                                     clockwise: true)
        circleLayer = CAShapeLayer()
        circleLayer.path = path2.cgPath
        circleLayer.strokeColor = animationColor != nil ? animationColor!.cgColor : UIColor.blue.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeEnd = currentAmt
        layer.addSublayer(circleLayer)
        
        //TEST
        addGradientContainer()
    }
    
    fileprivate func customColors() -> [UIColor] {
        //return [UIColor.random(), UIColor.random(), UIColor.random(), UIColor.random()]
        return [UIColor.blue, UIColor.green, UIColor.red, UIColor.lightGray]
    }
    
    //MARK: Public
    func animateCircle(_ duration: TimeInterval, toAmount: CGFloat) {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = currentAmt
        animation.toValue = toAmount
        
        currentAmt = toAmount
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        if circleLayer != nil {
            circleLayer.strokeEnd = toAmount
            circleLayer.add(animation, forKey: "animateCircle")
        }
    }
    
    func addGradientContainer() {
        gradientContainer.frame = CGRect(x: 10, y: 10, width: frame.width - 20, height: frame.height - 20)
        gradientContainer.addGradient()
        gradientContainer.delegate = self
        gradientContainer.layer.cornerRadius = gradientContainer.frame.size.width / 2
        gradientContainer.layer.masksToBounds = true
        addSubview(gradientContainer) //Does the below add this? If so, don't need
        bringSubview(toFront: gradientContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Pinwheel: DidFinishGradientAnimation {
    func finishedAnimation() {
        
    }
}

extension UIView {
    func addGradient(_ colors: [CGColor], lineWidth: CGFloat, radius: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors = colors

        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        self.layer.addSublayer(gradient)
    }
}
