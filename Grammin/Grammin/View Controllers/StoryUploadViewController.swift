//
//  StoryUploadViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 2/5/19.
//  Copyright © 2019 EthanHess. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase
import FontAwesome_swift

//TODO will add speech functionality
//Also can upload filtered drafts unlike IG
//TODO come up with list of features IG doesn't have
//Images animation + collage

class StoryUploadViewController: UIViewController {
    //Containers
    let buttonContainer: UIView = {
        let theView = UIView()
        return theView
    }()
    
    //TODO add zoom/pinch functionality?
    let storyContainer: StoryContainer = {
        let theIV = StoryContainer()
        return theIV
    }()
    
    //Subclass
    var customNavBar : UIView = {
        let cnb = UIView()
        cnb.backgroundColor = Colors().customGray
        return cnb
    }()
    
    var fontAwesomeContainer : UIImageView = {
        let fac = UIImageView()
        return fac
    }()
       
    
    //Add font awesome
    var customNavBarLeftTapGestureView : UIView = {
        let cnb = UIView()
        cnb.isUserInteractionEnabled = true
        cnb.backgroundColor = .clear
        return cnb
    }()
    
    //Buttons (should subclass)
    
    //TODO just one media button? Also check button frames
    //TODO have scroll view with text, colors etc. for options
    
    let mediaButton: UIButton = {
        let vButton = UIButton(type: .system)
        vButton.addTarget(self, action: #selector(handleVideo), for: .touchUpInside)
        vButton.setTitle("Add Photo/Video", for: .normal)
        vButton.setTitleColor(.white, for: .normal)
        return vButton
    }()
    
    let optionsScrollContainer: StoryScrollOptionsContainer = {
        let ssoc = StoryScrollOptionsContainer()
        //Delegate
        return ssoc
    }()
    
    var totalVideoSeconds: Int = 0
    
    //Download URLs from Firebase, post upload
    var imageDownloadURL : String?
    var videoDownloadURL : String?

    //Pre upload
    var videoURL : URL?
    var chosenData : Data?
    var mediaType : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .black
        viewConfiguration()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //TODO Check nav
        //self.dismiss(animated: true, completion: nil)
    }

    fileprivate func viewConfiguration() {
        view.addSubview(storyContainer)
        storyContainer.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: view.frame.size.width - 20, height: (view.frame.size.height / 2) + 30)
        viewStylizer(theView: storyContainer, radius: 10, backgroundColor: .black)
        storyContainer.layer.borderColor = UIColor.white.cgColor
        storyContainer.layer.borderWidth = 1
    
        view.addSubview(buttonContainer)
        buttonContainer.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 70, paddingRight: 10, width: view.frame.size.width - 20, height: 80)
        viewStylizer(theView: buttonContainer, radius: 10, backgroundColor: .black)
        buttonContainer.layer.borderColor = UIColor.white.cgColor
        buttonContainer.layer.borderWidth = 1
        
        view.addSubview(optionsScrollContainer)
        optionsScrollContainer.anchor(top: storyContainer.bottomAnchor, left: view.leftAnchor, bottom: buttonContainer.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10, width: 0, height: 0)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.size.width, height: 50)
        
        buttonContainer.addSubview(mediaButton)
        mediaButton.anchor(top: buttonContainer.topAnchor, left: buttonContainer.leftAnchor, bottom: buttonContainer.bottomAnchor, right: buttonContainer.rightAnchor, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 5, width: 0, height: 0)
        viewStylizer(theView: mediaButton, radius: 5, backgroundColor: Colors().neptuneBlue)
        mediaButton.layer.borderColor = UIColor.white.cgColor
        mediaButton.layer.borderWidth = 1
        
        self.perform(#selector(subviewsForNavBar), with: nil, afterDelay: 0.25)
    }
        
    @objc fileprivate func subviewsForNavBar() {
        //Left --- Right
        let navWH = customNavBar.frame.size.width / 2
        let navH = customNavBar.frame.size.height
            
        customNavBarLeftTapGestureView.frame = CGRect(x: 0, y: 0, width: navWH, height: navH)
        customNavBar.addSubview(customNavBarLeftTapGestureView)
        
        let navGestureLeft = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        customNavBarLeftTapGestureView.addGestureRecognizer(navGestureLeft)
        
        fontAwesomeContainer.frame = CGRect(x: 10, y: 0, width: 50, height: 50)
        customNavBarLeftTapGestureView.addSubview(fontAwesomeContainer)
        
        fontAwesomeContainer.image = UIImage.fontAwesomeIcon(name: .github, style: .brands, textColor: .white, size: CGSize(width: 40, height: 40))
        
        //And scroll view / story view
        optionsScrollContainer.scrollSetupWrapper()
        storyContainer.viewSetup()
    }
    
    fileprivate func viewStylizer(theView: UIView, radius: CGFloat, backgroundColor: UIColor) {
        theView.layer.masksToBounds = true
        theView.layer.cornerRadius = radius
        theView.backgroundColor = backgroundColor
    }
    
    //Handlers
    @objc fileprivate func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleVideo() {
        presentMediaWithType(video: true)
    }
    
    @objc fileprivate func handlePhoto() {
        presentMediaWithType(video: false)
    }
    
    //Scroll to text subview in options container
    @objc fileprivate func handleText() {
        
    }
    
    //Scroll to color subview in options container
    @objc fileprivate func handleColor() {
        
    }

    fileprivate func presentMediaWithType(video: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        //TODO video only in Swift? Will eventually change to custom frameworks like in WH so we can upload multiple for collages etc.
        
        imagePicker.sourceType = video == true ? .savedPhotosAlbum : .photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //TODO subclass main container for story preview
    
    fileprivate func setUpStoryPreviewWithMediaImage(image: UIImage) {
        
    }
    
    fileprivate func setUpStoryPreviewWithMediaVideo(url: URL) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

//    func observe<Value>(_ keyPath: KeyPath<StoryUploadViewController, Value>, options: NSKeyValueObservingOptions = [], changeHandler: @escaping (StoryUploadViewController, NSKeyValueObservedChange<Value>) -> Void) -> NSKeyValueObservation {
//
//    }
}


extension StoryUploadViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //TODO check media type
        //move to constants
        
        let editedImageKey = "UIImagePickerControllerEditedImage"
        let originalImageKey = "UIImagePickerControllerOriginalImage"
        
        if let editedImage = info[editedImageKey] as? UIImage {
            setUpStoryPreviewWithMediaImage(image: editedImage)
        } else if let originalImage =
            info[originalImageKey] as? UIImage {
            setUpStoryPreviewWithMediaImage(image: originalImage)
        }
        
        dismiss(animated: true, completion: nil)
        
        
        //NEW CODE, discard above
        guard let mediaType = info[UIImagePickerControllerMediaType] as? String else {
            Logger.log("")
            return
        }
        
        self.totalVideoSeconds = 0 //clear out in case they choose again, then write total video seconds when they upload
        
        if mediaType  == "public.image" {
            Logger.log("Image Selected")
            if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.videoURL = nil
                self.mediaType = "Image"
                
//                let resizedImage = GlobalFunctions.resizeImage(image: chosenImage, newHeight: self.view.frame.size.height)
                self.chosenData = NSData(data: UIImageJPEGRepresentation(chosenImage, 1.0)!) as Data
                storyContainer.addImage(image: chosenImage)
            }
        }
        if mediaType == "public.movie" {
            Logger.log("Video Selected")
            if let chosenURL = info[UIImagePickerControllerMediaURL] as? URL {
                //To check video length of user
                guard let uid = Auth.auth().currentUser?.uid else {
                    Logger.log("No Auth")
                    return
                }
                Logger.log(uid)
                
                self.totalVideoSeconds = 0
                self.chosenData = nil
                self.mediaType = "Video"
                self.videoURL = chosenURL
                storyContainer.videoSetup(url: chosenURL)
            }
        }
    }
}
