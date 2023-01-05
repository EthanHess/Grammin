//
//  LoginViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 5/23/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    //Properties
    
    var isLogin = true //will change to false for sign up
    
    //Add UIBlur effect? Or is faded alpha of background enough?
    
    var signUpContainerView: SignUpContainerView = {
        let theView = SignUpContainerView()
    
        return theView
    }()
    
    let logoContainerView: UIView = {
        let container = UIView()
        
        let image = UIImage(named: "GramminMainScreenPic")
        let logoImageView = UIImageView(image: image)
        logoImageView.contentMode = .scaleAspectFill
        
        container.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        
        container.backgroundColor = UIColor.fromRGB(red: 0, green: 120, blue: 175)
        return container
    }()
    
    let emailTextField: UITextField = {
        let etf = UITextField()
        etf.placeholder = "Email"
        //etf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        etf.backgroundColor = Colors().lightWhiteBlue
        etf.borderStyle = .roundedRect
        etf.font = UIFont.systemFont(ofSize: 14)
        
        return etf
    }()
    
    let passwordTextField: UITextField = {
        let ptf = UITextField()
        ptf.placeholder = "Password"
        ptf.isSecureTextEntry = true
        //ptf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        ptf.backgroundColor = Colors().lightWhiteBlue
        ptf.borderStyle = .roundedRect
        ptf.font = UIFont.systemFont(ofSize: 14)
        
        return ptf
    }()
    
    let loginButton: UIButton = {
        let lb = UIButton(type: .system)
        lb.setTitle("Login", for: .normal)
        lb.backgroundColor = UIColor.fromRGB(red: 149, green: 204, blue: 244)
        
        lb.layer.cornerRadius = 5
        lb.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        lb.setTitleColor(.white, for: .normal)
        
        lb.isEnabled = false
    
        return lb
    }()
    
    let dontHaveAccountButton: UIButton = {
        let dhab = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.fromRGB(red: 17, green: 154, blue: 237)
            ]))
        
        dhab.setAttributedTitle(attributedTitle, for: .normal)
    
        return dhab
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        
        return button
    }()
    
    //Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewConfig()
        customViewConfig()
    }
    
    fileprivate func checkAuthThenProceed() {
        //If there's already a user/auth then we can just go into the app
        
    }
    
    //Functions
    
    fileprivate func customViewConfig() { //Sign up view
        
        let width = self.view.frame.size.width - 20
        let height = self.view.frame.size.height - 160
        let yCoord = CGFloat(80)
        let frame = CGRect(x: 10.0, y: yCoord, width: width, height: height)
        signUpContainerView.frame = frame
        
        view.addSubview(signUpContainerView)
        view.bringSubview(toFront: signUpContainerView)
        
        signUpContainerView.delegate = self
        signUpContainerView.layer.cornerRadius = 10
        signUpContainerView.layer.masksToBounds = true
        signUpContainerView.layer.borderColor = UIColor.white.cgColor //Some custom blue would be better?
        signUpContainerView.layer.borderWidth = 1
        
        signUpContainerView.isHidden = true
    }
    
    fileprivate func viewConfig() {
        
        view.addSubview(logoContainerView)
        view.addSubview(dontHaveAccountButton)
        
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = Colors().awesomeBlack //TODO image instead
        
        //Make property?
        let image = UIImage(named: "spaceBlue")
        let bgIV = UIImageView(frame: self.view.bounds)
        bgIV.image = image
        view.addSubview(bgIV)
        view.sendSubview(toBack: bgIV)

        setupInputFields()
    }
    
    fileprivate func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 30)
        
        
        addTargets()
    }
    
    fileprivate func addTargets() {
        emailTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        dontHaveAccountButton.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
    }
    
    //Called by buttons
    
    @objc func handleShowSignUp() {
        //let signUpVC = SignUpViewController()
        //navigationController?.pushViewController(signUpVC, animated: true)
        
        isLogin = !isLogin
        
        if isLogin == false {
            signUpContainerView.isHidden = false
            alphaController()
        } else {
            signUpContainerView.isHidden = true
            alphaController()
        }
    }
    
    fileprivate func alphaController() {
        if isLogin == false {
            for tView in self.view.subviews {
                if tView != signUpContainerView {
                    tView.alpha = 0.5
                }
            }
        } else {
            for tView in self.view.subviews {
                if tView != signUpContainerView {
                    tView.alpha = 1
                }
            }
        }
    }
    
    @objc func handleTextInputChange() {
        
        var isFormValid = false
        
        if isLogin {
            isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        } else {
            isFormValid = signUpContainerView.emailTextField.text?.count ?? 0 > 0 && signUpContainerView.usernameTextField.text?.count ?? 0 > 0 && signUpContainerView.passwordTextField.text?.count ?? 0 > 0
        }
        
        if isFormValid {
            if isLogin == true {
                loginButton.isEnabled = true
                loginButton.backgroundColor = .mainBlue()
            } else {
                signUpContainerView.signUpButton.isEnabled = true
                signUpContainerView.signUpButton.backgroundColor = .mainBlue()
            }
        } else {
            if isLogin == true {
                loginButton.isEnabled = false
                loginButton.backgroundColor = UIColor.fromRGB(red: 149, green: 204, blue: 244)
            } else {
                signUpContainerView.signUpButton.isEnabled = false
                signUpContainerView.signUpButton.backgroundColor = UIColor.fromRGB(red: 149, green: 204, blue: 244)
            }
        }
    }
    
    @objc func handleLogin() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let tError = error {
                Logger.log("Error signing in \(tError.localizedDescription)")
                GlobalFunctions.presentAlert(title: tError.localizedDescription, text: "", fromVC: self)
                return
            }
            
            Logger.log("Success signing in \(user?.uid ?? "")")
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            
            mainTabBarController.setUpVCs()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleForgotPassword() {
        let alertController = UIAlertController(title: "Please enter email", message: "Your password will be sent to you", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.delegate = self
            //Add tag?
        }
        
        let alertActionOkay = UIAlertAction(title: "Okay", style: .default) { (action) in
            guard let email = alertController.textFields?[0].text else {
                return
            }
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if error != nil {
                    GlobalFunctions.presentAlert(title: "There was an error sending your password", text: error!.localizedDescription, fromVC: self)
                } else {
                    GlobalFunctions.presentAlert(title: "Please check your email", text: "A reset password link was succesfully sent", fromVC: self)
                }
            }
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(alertActionOkay)
        alertController.addAction(alertActionCancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Will want this dark eventually because space theme, because space is awesome
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        Logger.log("Memory warning in \(self)")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController : SignUpContainerDelegate {
    
    func handleSignUpWithCritera() {
        
        //Button won't be enabled unless these values exist, so perhaps no need for guard/if let
        let email = signUpContainerView.emailTextField.text!
        let username = signUpContainerView.usernameTextField.text!
        let password = signUpContainerView.passwordTextField.text!
        
        //TODO, check if image exists before creating user, don't just add the button's image
        guard let uploadData = UIImageJPEGRepresentation((self.signUpContainerView.addPhotoButton.imageView?.image)!, 0.3) else {
            Logger.log("--- NO UPLOAD DATA ---")
            GlobalFunctions.presentAlert(title: "Please add a photo", text: "", fromVC: self)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                GlobalFunctions.presentAlert(title: "There seems to be an error", text: "\(String(describing: error?.localizedDescription))", fromVC: self)
                
                //UNWRAP OPTIONAL
                return
            }
            
            Logger.log("--- SUCCESS ---")
            
            let filename = "\(String(describing: user?.email)) \(NSUUID().uuidString)"
            //TODO UNWRAP OPTIONAL, ALSO PROFILE PICS > UID IMAGE
            
            FirebaseController.uploadImageDataToFirebase(data: uploadData, path: filename, completionString: { (downloadURL) in
                
                //Don't return, assign "" values so we can still store
                if downloadURL == nil {
                    Logger.log("--- NO DOWNLOAD URL ---")
                    return
                }
                guard let uid = user?.uid else {
                    Logger.log("NO UID")
                    return
                }
                guard let fcmToken = Messaging.messaging().fcmToken else {
                    Logger.log("NO TOKEN")
                    return
                }
                
                let userDictionary = [usernameKey: username, profileURLKey: downloadURL, fcmKey: fcmToken, emailKey: user?.email ?? ""]
                let toWrite = [uid: userDictionary]
                
                fDatabase.child(UsersReference).updateChildValues(toWrite, withCompletionBlock: { (error, reference) in
                    if error != nil {
                        Logger.log("--- UPLOAD ERROR ---")
                        return
                    }
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {
                        Logger.log("No main VC")
                        return
                    }
                    Thread.printCurrentThread()
                    mainTabBarController.setUpVCs()
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    func userDidCancelSignUp() {
        handleShowSignUp()
    }
    
    func monitorTextInput() {
        handleTextInputChange()
    }
    
    func popCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension LoginViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let editedImageKey = "UIImagePickerControllerEditedImage"
        let originalImageKey = "UIImagePickerControllerOriginalImage"
        
        //Main thread? If not will need to Dispatch main queue for UIUpdates
        Thread.printCurrentThread()
        
        if let editedImage = info[editedImageKey] as? UIImage {
            signUpContainerView.addPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage =
            info[originalImageKey] as? UIImage {
            signUpContainerView.addPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        DispatchQueue.main.async {
            self.roundAddButton()
        }
    
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func roundAddButton() {
        signUpContainerView.addPhotoButton.layer.cornerRadius = signUpContainerView.addPhotoButton.frame.width / 2
        signUpContainerView.addPhotoButton.layer.masksToBounds = true
        signUpContainerView.addPhotoButton.layer.borderColor = UIColor.black.cgColor
        signUpContainerView.addPhotoButton.layer.borderWidth = 3
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
