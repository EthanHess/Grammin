//
//  Colors.swift
//  Grammin
//
//  Created by Ethan Hess on 5/23/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import Foundation
import UIKit

//Can just make extension, should move these there
class Colors {
    
    var awesomeBlack : UIColor {
        get {
            return RGB(r: 11, 43, 61)
        }
    }
    
    var neptuneBlue : UIColor {
        get {
            return RGB(r: 37, 167, 196)
        }
    }
    
    var limeGreen : UIColor {
        get {
            return RGB(r: 204, 239, 45)
        }
    }
    
    var lightWhiteBlue : UIColor {
        get {
            return RGB(r: 204, 249, 249)
        }
    }
    
    var searchBackgroundBlue : UIColor {
        get {
            return RGB(r: 121, 173, 248)
        }
    }
    
    var searchBarBlue : UIColor {
        get {
            return RGB(r: 59, 107, 241)
        }
    }
    
    var customGray : UIColor {
        get {
            return RGB(r: 20, 20, 20)
        }
    }
    
    var coolBlue : UIColor {
        get {
            return RGB(r: 100, 178, 221)
        }
    }
    
    var coolGreen : UIColor {
        get {
            return RGB(r: 100, 221, 136)
        }
    }
    
    var coolPink : UIColor {
        get {
            return RGB(r: 223, 98, 171)
        }
    }
    
    var aquarium : UIColor {
        get {
            return RGB(r: 98, 136, 223)
        }
    }
    
    private func RGB(r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
