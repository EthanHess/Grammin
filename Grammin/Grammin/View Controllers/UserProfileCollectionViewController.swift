//
//  UserProfileCollectionViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 5/23/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class UserProfileCollectionViewController: UICollectionViewController {
    
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    
    enum ViewType { //Add type?
        case Grid
        case List
    }
    
    var profileUser: User?
    var viewType = ViewType.Grid
    
    //Pagination, load what we need, we'll want to do this in the main feed as well
    var isFinishedPaging = false
    var posts = [Post]()
    
    var themeView: ThemePickerView = {
        //TODO delegate
        let thv = ThemePickerView()
        return thv
    }()
    
    //TODO add stories, tagged posts ect.
    
    fileprivate func refreshCollection() {
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        register()
    }
    
    fileprivate func register() {
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCollectionView()
        setupLogOutButton()
    }
    
    fileprivate func setupLogOutButton() {
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.cyan]
        self.navigationController?.navigationBar.barTintColor = .black //todo custom
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settingsGear")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
        
        //For scheme, TODO pop custom view
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "scheme")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSchemeChange))
    }
    
    //For now 180 W 220 H
    fileprivate func themeViewSetup() {
        let halfWidth = self.view.frame.size.width / 2
        let halfHeight = self.view.frame.size.height / 2
        let frame = CGRect(x: halfWidth - 90, y: halfHeight - 110, width: 180, height: 220)
        themeView.frame = frame
        themeView.isHidden = true
        view.addSubview(themeView)
    }
    
    @objc fileprivate func handleSchemeChange() {
        //TODO imp.
        themeView.isHidden = !themeView.isHidden
    }
    
    fileprivate func configureCollectionView() {
    
        //TODO this is for circular layout, but top cells need to stay the same
        
        //Don't override, use setCollectionViewLayout
        //collectionView = UICollectionView(frame: view.frame, collectionViewLayout: CircularLayout())
        
        collectionView?.backgroundColor = .black
        collectionView?.register(MyProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(MyProfileMediaCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: homePostCellId)

        themeViewSetup()
        setupLogOutButton()
        fetchUser()
    }
    
    // Data fetch
    
    fileprivate func fetchUser() { //Should just store in global data
        //Current user
        guard let theUID = Auth.auth().currentUser?.uid else {
            Logger.log("No UID")
            return
        }
        
        //This will fetch the user whose profile it is, current user or not, TODO pass in their ID
        FirebaseController.fetchUserWithUID(userID: theUID) { (user) in
            if user != nil {
                self.profileUser = user
                self.navigationItem.title = self.profileUser?.username
                self.refreshCollection() //why is this before?
                self.paginatePosts()
            } else {
                Logger.log("No user")
            }
        }
    }
    
    //TODO move outside of VC ?
    fileprivate func paginatePosts() {
        guard let uid = self.profileUser?.uid else { return }
        let queryKeyString = "creationDate" //timestamp
        var query = self.postsReference(uid: uid).queryOrdered(byChild: queryKeyString)
        
        if posts.count > 0 {
            let value = posts.last?.timestamp.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                Logger.log("Doesn't exist")
                return
            }
            allObjects.reverse()
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            guard let user = self.profileUser else {
                Logger.log("No user")
                return
            }
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                var post = Post(user: user, postDict: dictionary)
                post.postID = snapshot.key
                self.posts.append(post)
            })
            self.posts.forEach({ (post) in
                Logger.log(post.postID ?? "")
            })
            self.refreshCollection() //main queue?
        }
        //Add error handling
    }
    
    fileprivate func fetchOrdered() {
        guard let uid = self.profileUser?.uid else { return }
        let ref = postsReference(uid: uid)
        
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let user = self.profileUser else { return }
            let post = Post(user: user, postDict: dictionary)
            self.posts.insert(post, at: 0)
            self.refreshCollection()
        }
        //TODO error handling
    }
    
    //MARK: References
    
    fileprivate func postsReference(uid: String) -> DatabaseReference {
        return fDatabase.child(PostsReference).child(uid)
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Data write
    
    fileprivate func writeImageDataForProfilePic(chosenImage: UIImage) {
        let imageData = NSData(data: UIImageJPEGRepresentation(chosenImage, 1.0)!) as Data
        //Delete last profile URL if exists
        guard let userID = Auth.auth().currentUser?.uid else {
            Logger.log("")
            return
        }
        fDatabase.child(UsersReference).child(userID).child(profileURLKey).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                //Remove old
                let oldString = snapshot.value as! String
                fStorage.child(oldString).delete { (error) in
                    self.uploadWrapper(imageData: imageData, userID: userID)
                }
            } else {
                self.uploadWrapper(imageData: imageData, userID: userID)
            }
        }
    }
    
    fileprivate func uploadWrapper(imageData: Data, userID: String) {
        FirebaseController.uploadImageDataToFirebase(data: imageData, path: userID) { (downloadURL) in
            if downloadURL != nil {
                fDatabase.child(UsersReference).child(userID).child(profileURLKey).setValue(downloadURL) { (error, ref) in
                    if error != nil {
                        Logger.log("")
                        return
                    }
                    self.fetchUser()
                }
            } else {
                Logger.log("")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // TODO external?

    // MARK: UICollectionViewDataSource

//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            print("Paginating for posts")
            paginatePosts()
        }
        
        if self.viewType == .Grid {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MyProfileMediaCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCollectionViewCell
            cell.applyCardLayout = false
            cell.post = posts[indexPath.item]
            return cell
        }
    }

    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.viewType == .Grid {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 //username userprofileimageview
            height += view.frame.width
            height += 50
            height += 60
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! MyProfileHeaderCell
        //TODO assign
        header.user = self.profileUser
        header.delegate = self
        //Add chosen image?
        return header
    }


}

extension UserProfileCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

extension UserProfileCollectionViewController: UserProfileHeaderDelegate {
    func didTapImage() { //If current user update profile image, if not, view large
        guard let profileUser = self.profileUser else {
            Logger.log("No Profile User")
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            Logger.log("No Current User")
            return
        }
        let isCurrentUser = profileUser.uid == currentUser.uid
        if isCurrentUser == true {
            let imagePicker = UIImagePickerController() //Property/lazy?
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            //TODO: view image of other person large with likes/comments?
        }
    }
    func didChangeToGridView() {
        self.viewType = .Grid
        refreshCollection()
    }
    
    func didChangeToListView() {
        self.viewType = .List
        refreshCollection()
    }
    
    func didChangeToBookmark() {
        guard let navCon = self.navigationController else {
            Logger.log("")
            return
        }
        let savedVC = SavedItemsCollectionViewController()
        //This is just a test, also present full screen? 
        savedVC.posts = posts
        savedVC.modalPresentationStyle = .fullScreen
        navCon.present(savedVC, animated: true, completion: nil)
    }
}

//if mediaType  == "public.image" { then .movie for video

extension UserProfileCollectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let editedImageKey = "UIImagePickerControllerEditedImage"
        let originalImageKey = "UIImagePickerControllerOriginalImage"

        if let editedImage = info[editedImageKey] as? UIImage {
            Logger.log("\(editedImage)")
        } else if let originalImage =
            info[originalImageKey] as? UIImage {
                Logger.log("\(originalImage)")
            
            //Set chosen image
            
            //Pop alert to see if they want to add then write to firebase
            
            //TODO have options for GIF. / Video / Series of images / Filters?
            let deadlineTime = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                GlobalFunctions.presentAddProfilePicAlertWithCompletion(title: "Use this picture as your profile pic?", text: "", fromVC: self) { (choseYes) in
                    if choseYes == true {
                        self.writeImageDataForProfilePic(chosenImage: originalImage)
                    } else {
                        //Clear image
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

//Can discard

//    // Uncomment this method to specify if the specified item should be highlighted during tracking
//    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    // Uncomment this method to specify if the specified item should be selected
//    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }

//    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
//    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
//        return false
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
//
//    }
