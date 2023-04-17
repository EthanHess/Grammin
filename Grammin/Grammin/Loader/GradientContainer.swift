//
//  GradientContainer.swift
//  LoadingView
//
//  Created by Ethan Hess on 1/9/23.
//

import UIKit

protocol DidFinishGradientAnimation: AnyObject {
    func finishedAnimation()
}

class GradientContainer: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    weak var delegate : DidFinishGradientAnimation?
    
    var gradientColors : [CGColor] = []
    
    var gradient : CAGradientLayer = {
        let gr = CAGradientLayer()
        return gr
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    //MARK: gradient colors need to be .cgColor otherwise they won't show, there's no type conflict error of any kind to tell you UIColor won't work (so add extension with type check)
    
    //CGColor = A set of components that define a color, with a color space specifying how to interpret them.
    
    func addGradient() {
        self.gradientColors = [UIColor.white.cgColor, UIColor.green.cgColor]
        self.gradient.frame = self.bounds
        self.gradient.colors = self.gradientColors
        gradient.startPoint = CGPoint(x:0, y:0) //TODO, eventually can pass in as properties
        gradient.endPoint = CGPoint(x:1, y:1)
//        gradient.locations = [0,0.1]
        self.layer.addSublayer(gradient)
        
        //Test
        self.beginGradientColorChangeAnimation(3, newColors: [UIColor.lightGray.cgColor, UIColor.cyan.cgColor])
    }
    
    //NOTE: A CFTimeInterval is a typealias for a double
    func beginGradientColorChangeAnimation(_ duration: CFTimeInterval, newColors: [CGColor]) {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = duration
        animation.toValue = newColors
        animation.fillMode = kCAFillModeForwards //default is .removed, so animate forward
//        animation.isRemovedOnCompletion = false //defaults to true
        self.gradient.add(animation, forKey: "colorChange")
    }
    
    func beginGradientCoordinateChangeAnimation(_ duration: CFTimeInterval, newCoordinates: [CGPoint]) {
        
    }
    
    fileprivate func finishHandler() {
        //Could guard but assume delegate will always be assigned by parent (i.e. won't be nil)
        self.delegate?.finishedAnimation()
    }
    
    //MARK: TODO clean up and implement this, can return different animations without writing code in both functions
    
//    fileprivate func returnCABasicAnimationWithKeyPath(_ keyPath: String) -> CABasicAnimation {
//
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
