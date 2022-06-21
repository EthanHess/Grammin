//
//  SignUpViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 5/25/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase

//Now a subview, can delete this class

class SignUpViewController: UIViewController {
    
    //Properties (TODO: subclass/customize?)
    
    let addPhotoButton: UIButton = {
        let image = UIImage(named: "mainCamera")
        let button = UIButton(type: .system)
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleAddPhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let eField = UITextField()
        eField.placeholder = "Email"
        eField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        eField.borderStyle = .roundedRect
        eField.font = UIFont.systemFont(ofSize: 14)
        
        eField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return eField
    }()
    
    let usernameTextField: UITextField = {
        let utf = UITextField()
        utf.placeholder = "Username"
        utf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        utf.borderStyle = .roundedRect
        utf.font = UIFont.systemFont(ofSize: 14)
        utf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return utf
    }()
    
    let passwordTextField: UITextField = {
        let ptf = UITextField()
        ptf.placeholder = "Password"
        ptf.isSecureTextEntry = true
        ptf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        ptf.borderStyle = .roundedRect
        ptf.font = UIFont.systemFont(ofSize: 14)
        ptf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return ptf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.fromRGB(red: 149, green: 204, blue: 244)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        
        button.isEnabled = false
        
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.fromRGB(red: 17, green: 154, blue: 237)
            ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    //Functions
    
    @objc func handleAddPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //TODO: Hide username for login
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainBlue()
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.fromRGB(red: 149, green: 204, blue: 244)
        }
    }
    
    @objc func handleAlreadyHaveAccount() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        
        if canProceed() == true {
            
            let email = emailTextField.text!
            let username = usernameTextField.text!
            let password = passwordTextField.text!
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    GlobalFunctions.presentAlert(title: "There seems to be an error", text: "\(String(describing: error?.localizedDescription))", fromVC: self)
                    return
                }
                
                Logger.log("--- SUCCESS ---")
                
                //TODO, check if image exists before creating user
                guard let uploadData = UIImageJPEGRepresentation((self.addPhotoButton.imageView?.image)!, 0.3) else {
                    Logger.log("--- NO UPLOAD DATA ---")
                    return
                }
                
                let filename = "\(String(describing: user?.email)) \(NSUUID().uuidString)"
                //TODO UNWRAP OPTIONAL, ALSO PROFILE PICS > UID IMAGE
                
                FirebaseController.uploadImageDataToFirebase(data: uploadData, path: filename, completionString: { (downloadURL) in
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
        } else {
            GlobalFunctions.presentAlert(title: "You seem to be missing some criteria", text: "Please fill in the fields", fromVC: self)
        }
    }
    
    //TODO: check download URL? Or it will be optional
    
    fileprivate func canProceed() -> Bool {
        if let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text, let image = self.addPhotoButton.imageView?.image {
            Logger.log("\((email, username, password, image))")
            return true
        } else {
            return false
        }
    }
    
    fileprivate func setupInputFields() {
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signUpButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: addPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
    
    fileprivate func addViews() {
        
        view.addSubview(alreadyHaveAccountButton)
        
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        view.backgroundColor = .white
        
        view.addSubview(addPhotoButton)
        
        addPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        
        addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        addViews()
        setupInputFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let editedImageKey = "UIImagePickerControllerEditedImage"
        let originalImageKey = "UIImagePickerControllerOriginalImage"
        
        //Main thread? If not will need to Dispatch main queue for UIUpdates
        Thread.printCurrentThread()
        
        if let editedImage = info[editedImageKey] as? UIImage {
            addPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage =
            info[originalImageKey] as? UIImage {
            addPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        roundAddButton()
        
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func roundAddButton() {
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.width / 2
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.layer.borderColor = UIColor.black.cgColor
        addPhotoButton.layer.borderWidth = 3
    }
}
