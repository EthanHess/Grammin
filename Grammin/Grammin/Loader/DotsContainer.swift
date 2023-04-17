//
//  DotsContainer.swift
//  LoadingView
//
//  Created by Ethan Hess on 2/4/23.
//

import UIKit

class DotsContainer: UIView {
    
    var dotArray : [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    func addDots(_ count: Int, oval: Bool) {
        //Default to 3 and circle, TODO factor in above variable(s)
        let numSpaces = count + 1 //If 3, there will be four spaces, on each side + 2 between dots
        var xCoord = frame.size.width / CGFloat(count + numSpaces)
        let originalXCoord = xCoord //For reference as above variable increments / mutates
        let frameHeight = frame.size.height
        for i in 0..<count {
            //Dots will start at zero
            let dotFrame = CGRectMake(xCoord + (frameHeight / 2), frameHeight / 2, 0, 0)
            let dotView = UIView(frame: dotFrame)
            dotView.backgroundColor = .systemGreen // TODO gradient
            dotView.addShadow(.white)
            addSubview(dotView)
            dotArray.append(dotView)
            
            //Factor in 0, 2 are on top of each other
            if i == 0 {
                xCoord += (CGFloat(2 * originalXCoord))
            } else {
                xCoord += CGFloat(originalXCoord * 2)
            }
        }
        
        animateDots(count)
    }
    
    private func animateDots(_ count: Int) {
        let numSpaces = count + 1 //Repetative, fix
        let xCoord = frame.size.width / CGFloat(count + numSpaces)
        var delay = TimeInterval(0) //typealias for double
        for dot in dotArray {
            let originalX = dot.frame.origin.x
            UIView.animate(withDuration: delay) {
                dot.frame = CGRect(x: originalX - 25, y: 0, width: xCoord, height: xCoord)
                dot.layer.cornerRadius = dot.frame.size.width / 2
                delay += 1
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
