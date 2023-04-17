//
//  LoadingView.swift
//  LoadingView
//
//  Created by Ethan Hess on 6/28/22.
//

import UIKit

//Should import FontAwesome for these ? (Yes!)
//Eventually move to different file but can keep here for now
enum LoadingLabelFont {
    
}

enum LoadingLabelBackgroundColor {
    
}

enum LoadingLabelTextColor {
    
}

enum LoadingAnimationStyle {
    
}

enum PinwheelAnimationStyle {
    
}

class LoadingView: UIView {

    //MARK: Subviews
    
    //W/O individual letter animation
    var loadingLabel : UILabel = {
        let ll = UILabel()
        ll.textAlignment = .center
        return ll
    }()
    
    var labelsSubviewArray : [UILabel]?
    
    var pinWheel : Pinwheel = {
        let pinwheel = Pinwheel()
        return pinwheel
    }()
    
    lazy var dotsContainer : DotsContainer = {
        let dc = DotsContainer()
        return dc
    }()
    
    var isAnimating = false
    
    //MARK: UI Properties (settable)
    var loadingLabelColor : UIColor = .lightGray {
        didSet {
            
        }
    }
    
    var loadingBackgroundColor : UIColor = .darkGray {
        didSet {
            
        }
    }
    
    var loadingLabelFont : UIFont = .systemFont(ofSize: 14) {
        didSet {
            
        }
    }
    
    var loadingLabelText : String = "Loading" {
        didSet {
            
        }
    }
    
    var shouldPulsateWheel : Bool = false {
        didSet {
            
        }
    }
    
    var shouldPulsateLabel : Bool = false {
        didSet {
            
        }
    }
    
    //MARK: Life begins
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //TODO assert frame limits
        //assert(frame === something, "")
        
        self.perform(#selector(configureViews), with: nil, afterDelay: 0.25)
    }
    
    //MARK: View configure
    @objc fileprivate func configureViews() {
        pinWheel.frame = pinwheelStartFrame()
        pinWheel.cornerRadius()
        addSubview(pinWheel)
        
        loadingLabel.frame = loadingLabelFrame()
        addSubview(loadingLabel)
        
        //All tests, eventually remove / be able to customize
        loadingLabel.textColor = .white
        loadingLabel.text = loadingLabelText
        loadingLabel.isHidden = true //Test, want to see other sublabels, remove initialization of loading label if label letter aninmation turned on
        
        setupIndividualLabels()
        addDotContainer()
        
        pinWheel.animationColor = .white
        pinWheel.animatedCircleConfiguration(countIndex: 0, totalCount: 10)
        
        //First param should be how long loader stays on screen so it disappears right as circle finishes animation (when whatever data is loaded)
        pinWheel.animateCircle(3, toAmount: 0.8)
        
        self.backgroundColor = .darkGray //TODO customize, have option to do so
        self.layer.cornerRadius = 5
        //self.layer.masksToBounds = true //Also can customize these
        
        //MARK: maskToBounds prevents shadow from rendering
        
        self.layer.insertSublayer(gradientForBackground(), at: 0)
    }
    
    fileprivate func gradientForBackground() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.lightGray, UIColor.darkGray]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        return gradientLayer
    }
    
    fileprivate func pinwheelStartFrame() -> CGRect {
        let viewWidth = self.frame.size.width
        let viewHeight = self.frame.size.height
        let pwWH = viewHeight / 4
        return CGRect(x: (viewWidth / 2) - (pwWH / 2), y: (viewHeight / 2) - (pwWH * 1.5), width: pwWH, height: pwWH)
    }
    
    fileprivate func loadingLabelFrame() -> CGRect {
        let viewWidth = self.frame.size.width
        let viewHeight = self.frame.size.height
        return CGRect(x: 10, y: viewHeight / 2, width: viewWidth - 20, height: viewHeight / 2)
    }
    
    //MARK: Functionality
    func startAnimation() {
        
    }
    
    func stopAnimation() {
        
    }
    
    //MARK, try dots but also ovals / elongated could be cool
    func addDotContainer() {
        //In this config, loading labels start offscreen then animate up to y: 60, this container will sit right above the final coords of loading labels

        let yCoord = frame.size.height - 120
        let height = 50
        let xCoord = frame.size.width / 4
        
        dotsContainer = DotsContainer(frame: CGRectMake(xCoord, yCoord, xCoord * 2, CGFloat(height)))
        addSubview(dotsContainer)
        
        dotsContainer.addDots(3, oval: false)
    }
    
    //TODO limit text length
    func setupIndividualLabels() {
        if labelsSubviewArray == nil {
            labelsSubviewArray = []
        } else {
            labelsSubviewArray!.removeAll()
        }
        let curLabelText = self.loadingLabelText
        let textArr = Array(curLabelText)
        let labelWidth = 30
        var xCoord = (Int(self.frame.size.width) / 2) - ((textArr.count * labelWidth) / 2) //place in center
        let yCoord = Int(self.frame.size.height) //place offscreen / bottom
        for i in 0..<textArr.count {
            let curStr = textArr[i]
            let label = UILabel(frame: CGRect(x: xCoord, y: yCoord, width: labelWidth, height: labelWidth))
            label.backgroundColor = .clear
            label.textColor = .white
            label.textAlignment = .center
            label.text = String(curStr)
            label.alpha = 0
            addSubview(label)
            labelsSubviewArray!.append(label)
            xCoord += labelWidth
        }
        
        animateInvidualLabels()
    }
    
    //If we want to animate text, best to have a label for each char
    fileprivate func animateInvidualLabels() {
        guard let labelArr = labelsSubviewArray else {
            return
        }
        var animationLaunchDelay = 0.0 //Hardcode for test
        let duration = 3.0 / Double(labelArr.count) //3 seconds is current timer but is just hardcoded (update this)
        for label in labelArr {
            UIView.animate(withDuration: duration, delay: animationLaunchDelay) {
                label.alpha = 1
                label.frame = CGRect(x: label.frame.origin.x, y: label.frame.origin.y - 60, width: label.frame.size.width, height: label.frame.size.height)
                animationLaunchDelay += duration
            }
        }
    }
    
    //Changing colors, orbit etc.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
