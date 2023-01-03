//
//  SignUpContainerView.swift
//  Grammin
//
//  Created by Ethan Hess on 6/13/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

protocol SignUpContainerDelegate : class {
    
    func handleSignUpWithCritera()
    func monitorTextInput()
    func userDidCancelSignUp() //Go back to login
    func popCamera()
}

class SignUpContainerView: UIView {
    
    //MARK: Properties
    
    weak var delegate : SignUpContainerDelegate?
    
    //MARK: 'self' refers to the method 'SignUpContainerView.self', which may be unexpected << Add target outside of self
    
    let addPhotoButton: UIButton = {
        let image = UIImage(named: "mainCamera")
        let button = UIButton(type: .system)
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(popCameraWrapper), for: .touchUpInside)
        
        return button
    }()
    
    let emailTextField: UITextField = {
        let eField = UITextField()
        eField.placeholder = "Email"
        eField.backgroundColor = Colors().lightWhiteBlue
        eField.borderStyle = .roundedRect
        eField.font = UIFont.systemFont(ofSize: 14)
        
        eField.addTarget(self, action: #selector(monitorTextWrapper), for: .editingChanged)
        
        return eField
    }()
    
    let usernameTextField: UITextField = {
        let utf = UITextField()
        utf.placeholder = "Username"
        utf.backgroundColor = Colors().lightWhiteBlue
        utf.borderStyle = .roundedRect
        utf.font = UIFont.systemFont(ofSize: 14)
        utf.addTarget(self, action: #selector(monitorTextWrapper), for: .editingChanged)
        
        return utf
    }()
    
    let passwordTextField: UITextField = {
        let ptf = UITextField()
        ptf.placeholder = "Password"
        ptf.isSecureTextEntry = true
        ptf.backgroundColor = Colors().lightWhiteBlue
        ptf.borderStyle = .roundedRect
        ptf.font = UIFont.systemFont(ofSize: 14)
        ptf.addTarget(self, action: #selector(monitorTextWrapper), for: .editingChanged)
        
        return ptf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.fromRGB(red: 149, green: 204, blue: 244)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleUserSignUpWrapper), for: .touchUpInside)
        
        button.isEnabled = false
        
        return button
    }()
    
    //Rename "dismiss" button
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = UIColor.darkGray
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    
    //Buttons for FB/GGL auth
    //Font awesome perhaps?
    
    let facebookGoogleContainerView: UIView = {
        let theView = UIView()
        theView.layer.cornerRadius = 5
        theView.layer.borderColor = UIColor.white.cgColor
        theView.layer.borderWidth = 1
        return theView
    }()
    
//    let facebookButton: FBSDKLoginButton = {
//
//    }()
//
//    let googleButton: GIDSignInButton = {
//
//    }()
//
//    let facebookLoginContainerButton: UIButton = { //To customize
//
//    }()

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //self.backgroundColor = UIColor.fromRGB(red: 0, green: 142, blue: 170)
        
        setUpViews()
        
        perform(#selector(backgroundImage), with: nil, afterDelay: 0.25)
    }
    
    // When frame is set
    @objc fileprivate func backgroundImage() {
        let image = UIImage(named: "spacePurple")
        let bgIV = UIImageView(frame: self.bounds)
        bgIV.image = image
        addSubview(bgIV)
        sendSubview(toBack: bgIV)
    }
    
    fileprivate func setUpViews() {
        
        //Add photo button
        
        self.addSubview(cancelButton)
        
        cancelButton.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        cancelButton.addTarget(self, action: #selector(hideSelf), for: .touchUpInside)
        
        self.addSubview(addPhotoButton)
        
        addPhotoButton.anchor(top: self.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        
        addPhotoButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        self.addSubview(stackView)
        
        stackView.anchor(top: addPhotoButton.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
        
        //Other auth options
        facebookGoogleContainerSetup()
    }
    
    fileprivate func facebookGoogleContainerSetup() {
        self.addSubview(facebookGoogleContainerView)
        facebookGoogleContainerView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 50, paddingBottom: 70, paddingRight: 50, width: 0, height: 80)
        
        //Add buttons
    }
    
    @objc func hideSelf() {
        self.delegate?.userDidCancelSignUp()
    }
    
    @objc func monitorTextWrapper() {
        self.delegate?.monitorTextInput()
    }
    
    @objc func handleUserSignUpWrapper() {
        self.delegate?.handleSignUpWithCritera()
    }
    
    @objc func popCameraWrapper() {
        self.delegate?.popCamera()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
