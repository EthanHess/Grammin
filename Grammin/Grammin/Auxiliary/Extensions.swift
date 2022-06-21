//
//  Extensions.swift
//  Grammin
//
//  Created by Ethan Hess on 5/24/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import Foundation
import UIKit

//UIView
extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        //Autoresizing mask controls how view resizes itself when (superview) bounds change
        //We don't want system to automatically create contraints so we'll set to false
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        return "" //TODO imp.
    }
}

//Colors
extension UIColor {
    
    static func fromRGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func mainBlue() -> UIColor {
        return UIColor.fromRGB(red: 17, green: 154, blue: 327) //327? Is that possible?
    }
    
    //For theme 1 (SPACE)
    
    static func spaceThemeOne() -> UIColor {
        return UIColor.fromRGB(red: 97, green: 246, blue: 104)
    }
    
    static func spaceThemeTwo() -> UIColor {
        return UIColor.fromRGB(red: 155, green: 253, blue: 219)
    }
    
    static func spaceThemeThree() -> UIColor {
        return UIColor.fromRGB(red: 199, green: 81, blue: 243)
    }
    
    static func spaceThemeFour() -> UIColor {
        return UIColor.fromRGB(red: 12, green: 31, blue: 54)
    }
    
    //For theme 2 (WHITE)
    
    static func whiteThemeOne() -> UIColor {
        return UIColor.fromRGB(red: 247, green: 247, blue: 255)
    }
    
    static func whiteThemeTwo() -> UIColor {
        return UIColor.fromRGB(red: 80, green: 70, blue: 78)
    }
    
    static func whiteThemeThree() -> UIColor {
        return UIColor.fromRGB(red: 172, green: 180, blue: 184)
    }
    
    static func whiteThemeFour() -> UIColor {
        return UIColor.fromRGB(red: 89, green: 95, blue: 98)
    }
    
    //For theme 3 (AQUA)
    
    static func aquaThemeOne() -> UIColor {
        return UIColor.fromRGB(red: 31, green: 157, blue: 234)
    }
    
    static func aquaThemeTwo() -> UIColor {
        return UIColor.fromRGB(red: 105, green: 192, blue: 245)
    }
    
    static func aquaThemeThree() -> UIColor {
        return UIColor.fromRGB(red: 169, green: 217, blue: 246)
    }
    
    static func aquaThemeFour() -> UIColor {
        return UIColor.fromRGB(red: 14, green: 111, blue: 171)
    }
}

//Thread, checking if main or background (first will pring thread then second will print -com.apple.main-thread- for example

extension Thread {
    class func printCurrentThread() {
        Logger.log("Current Thread: \(Thread.current)\r" + "Queue Label: \(OperationQueue.current?.underlyingQueue?.label ?? "No Label")")
    }
}

//https://stackoverflow.com/questions/30014241/uiimageview-pinch-zoom-swift

extension UIImageView {
    func enableZoom() {
      let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
    }
    @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
      let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
      guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
      sender.view?.transform = scale
      sender.scale = 1
    }
}

