//
//  HomeViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 5/23/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

private let reuseIdentifier = "Cell"

//May eventually just want a UIVC for more versatilty

//MARK: Main feed
class HomeViewController: UICollectionViewController {
    
    var refreshControl : UIRefreshControl = {
        let rc = UIRefreshControl()
        return rc
    }()
    
    //Pops from side
    var optionsContainer : MainFeedOptionsToggleView = {
        let oc = MainFeedOptionsToggleView()
        return oc
    }()
    
    //When you click on post
    var postPopup : PostPopupView = {
        let pView = PostPopupView()
        return pView
    }()
    
    var backgroundImageView : UIImageView = {
        let bgView = UIImageView()
        let imageName = "mainCollectionBG"
        let image = UIImage(named: imageName)
        bgView.image = image
        return bgView
    }()
    
    //var optionsToggled = false
    
    var posts = [Post]()
    var currentUser : User?
    var following : [User] = [] //array of UIDs may be better/cleaner (don't really need both?)
    var followingUIDs : [String] = []
    
    //Cell configuration helpers
    var expandedIndexPaths : [IndexPath] = [] //For more text / larger images
    var likedPostIDs : [String] = []
    
    //If post has multiple images / videos, keep track of which index they're on, post won't go into "seen" table (node) until all images / videos have been seen
    
    var seenSegments : [[String: String]] = [] //[PostID: SegID / index]
    
    var gridMode = false

    //Lifecycle VDL
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(StoriesHeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        self.navigationController?.navigationBar.barTintColor = .black
        
        setUpChatNavigationButton()
        setUpGridNavigationButton()
        
        self.setUp()
        //self.fetchAll()
        self.fetchCurrentUser() // Move to VWA? Could also fire a did update following function
    }
    
    fileprivate func setUpChatNavigationButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "navBarChat")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleChatTap))
    }
    
    fileprivate func setUpGridNavigationButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navBarGridUnselected")!.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleGridTap))
    }
    
    @objc fileprivate func handleChatTap() {
        guard let navCon = self.navigationController else {
            Logger.log("")
            return
        }
        let chatVC = MainChatsListViewController()
        chatVC.modalPresentationStyle = .fullScreen
        navCon.present(chatVC, animated: true, completion: nil)
        //navCon.pushViewController(chatVC, animated: true)
    }
    
    @objc fileprivate func handleGridTap() {
        gridMode = !gridMode
        let imageName = gridMode == true ? "navBarGridSelected" : "navBarGridUnselected"
        navigationItem.leftBarButtonItem?.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        
        //TODO refresh
        refresh()
    }
    
    //Lifecycle VWA
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //guard statement to see if CV exists?
        let swipeGestureMenu = UISwipeGestureRecognizer(target: self, action: #selector(toggleOptions))
        swipeGestureMenu.direction = .right
        self.collectionView!.addGestureRecognizer(swipeGestureMenu)
        
        let swipeGestureMenuBack = UISwipeGestureRecognizer(target: self, action: #selector(toggleBack))
        swipeGestureMenuBack.direction = .left
        self.collectionView!.addGestureRecognizer(swipeGestureMenuBack)
        
        optionsSetup()
        popupForPostSetup()
        
        guard let clv = collectionView else {
            return
        }
        backgroundImageView.frame = view.bounds
        backgroundImageView.isHidden = true
        view.insertSubview(backgroundImageView, belowSubview: clv)
    }
    
    //Offscreen subviews
    fileprivate func optionsSetup() {
        let oneThird = self.view.frame.size.width / 3
        let height = self.view.frame.size.height - (oneThird * 2)
        let frameOffscreen = CGRect(x: -oneThird, y: oneThird, width: oneThird, height: height)
        optionsContainer.frame = frameOffscreen
        optionsContainer.delegate = self
        view.addSubview(optionsContainer)
    }
    
    fileprivate func popupForPostSetup() {
        let bounds = UIScreen.main.bounds
        postPopup.frame = bounds
        postPopup.isHidden = true
        view.addSubview(postPopup)
    }
    
    @objc fileprivate func toggleBack() {
        let oneThird = self.view.frame.size.width / 3
        let height = self.view.frame.size.height - (oneThird * 2)
        if optionsContainer.frame.origin.x == 0 {
            optionsContainer.frame = CGRect(x: -oneThird, y: oneThird, width: oneThird, height: height)
            dimSubviewsAndShrinkCollection(dim: false)
        } else {
            //?
        }
    }
    
    //TODO, dim screen alpha and maybe animate collection view (smaller)
    @objc fileprivate func toggleOptions() {
        let oneThird = self.view.frame.size.width / 3
        let height = self.view.frame.size.height - (oneThird * 2)
        if optionsContainer.frame.origin.x == -oneThird {
            optionsContainer.frame = CGRect(x: 0, y: oneThird, width: oneThird, height: height)
            dimSubviewsAndShrinkCollection(dim: true)
        } else {
            //Do nothing?
        }
    }
    
    fileprivate func dimSubviewsAndShrinkCollection(dim: Bool) {
        for theView in self.view.subviews {
            if theView is MainFeedOptionsToggleView {
                
            } else {
                theView.alpha = dim == true ? 0.5 : 1
            }
        }
        shrinkSubviews(shrink: dim)
    }
    
    //TODO make sure to pop everything back on view dismiss
    
    //TODO add timer to CGAffineTransform for smoother transition
    fileprivate func shrinkSubviews(shrink: Bool) {
        guard let theCollection = collectionView else {
            return //would this ever be nil?
        }
        if shrink == true {
            theCollection.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } else {
            theCollection.transform = CGAffineTransform.identity //reset
        }
        backgroundImageView.isHidden = !shrink
    }
    
    //TODO will need to fetch new posts
    @objc fileprivate func refresh() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            if self.collectionView?.refreshControl?.isRefreshing == true {
                self.endRefresh()
            }
        }
    }
    
    fileprivate func setUp() {
        self.collectionView?.refreshControl = self.refreshControl
        //Observe (TODO add name)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFirebaseData), name: NSNotification.Name(rawValue: updateFeedAfterPostingNotification), object: nil)
        
        //Navigation + Refresh
        self.view.backgroundColor = UIColor.fromRGB(red: 7.0, green: 16.0, blue: 57.0)
        
        collectionView?.backgroundColor = .clear //change to custom
        collectionView?.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView?.refreshControl = self.refreshControl
        
        //TODO imp.
        let image = UIImage(named: "")
        
        navigationItem.titleView = UIImageView(image: image)
        
        //Should be move this?
        
        //navigationItem.leftBarButtonItem = UIBarButtonItem(image: image?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    fileprivate func fetchCurrentUser() {
        if let id = Auth.auth().currentUser?.uid {
            FirebaseController.fetchUserWithUID(userID: id) { (user) in
                guard let theUser = user else { return }
                self.currentUser = theUser
                self.fetchAll()
            }
        }
    }
    
    fileprivate func fetchAll() { //Posts for current user and those who they follow
        //guard let theUser = self.currentUser else { return }
        //self.fetchPostsWithUser(user: theUser)
        self.fetchFirebaseData()
    }
    
    @objc fileprivate func fetchFirebaseData() {
        
        self.following.removeAll()
        self.followingUIDs.removeAll()
        
        //Pass ID, via current user object or FIRAuth?
        
        //Will use this array in more than one place, have global storage somewhere?
        FirebaseController.fetchWhoCurrentUserFollows(idString: self.currentUser!.uid) { (userIdsDictionary) in
            
            guard let theDict = userIdsDictionary else {
                self.postFetchWrapper() //getting posts if you're following no one
                return
            }
            
            theDict.forEach({ (key, value) in
                self.followingUIDs.append(key)
                FirebaseController.fetchUserWithUID(userID: key, completion: { (user) in
                    if let theUser = user {
                        //self.fetchPostsWithUser(user: theUser)
                        self.following.append(theUser)
                    } else {
                        Logger.log("")
                    }
                })
            })
            self.postFetchWrapper()
        }
    }
    
    fileprivate func postFetchWrapper() {
        self.getPostsWithFriendsArray(friendUIDS: self.followingUIDs)
    }
    
    fileprivate func getPostsWithFriendsArray(friendUIDS: [String]) {
        PostsController.fetchPostsOfThoseIFollow(myUID: self.currentUser!.uid, arrayOfWhoIFollow: friendUIDS) { (posts) in
            if posts != nil {
                self.posts = posts!
                self.posts.sort(by: { (p1, p2) -> Bool in
                    return p1.timestamp.compare(p2.timestamp) == .orderedDescending
                })
                self.refresh()
            }
        }
    }
    
    //Old function, can discard, need to sync posts with corresponding author UIDs
    fileprivate func fetchPostsWithUser(user: User) {
        postsReference().observeSingleEvent(of: .value) { (snapshot) in
            self.endRefresh()
            guard let dictionaries = snapshot.value as? [String: Any] else {
                Logger.log("--- No post dicts ---")
                return
            }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                var post = Post(user: user, postDict: dictionary)
                post.postID = key
                
                self.likesReference(key: key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1 {
                        post.liked = true
                    } else {
                        post.liked = false
                    }
                    self.posts.append(post)
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.timestamp.compare(p2.timestamp) == .orderedDescending
                    })
                    
                    self.refresh()
                })
            })
        }
    }
    
    fileprivate func endRefresh() {
        DispatchQueue.main.async {
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func postsReference() -> DatabaseReference {
        return fDatabase.child(PostsReference).child(self.currentUser!.uid)
    }
    
    fileprivate func likesReference(key: String) -> DatabaseReference {
        return fDatabase.child(LikesReference).child(key).child(self.currentUser!.uid)
    }
    
    //MARK: LIFECYCLE: END
    deinit {
        //Remove observer
        NotificationCenter.default.removeObserver(self)
        Logger.log("Observer removed")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Think of edge cases, what if it's halfway, maybe just have boolean?
        if optionsContainer.frame.origin.x == 0 {
            toggleBack()
        }
    }

    @objc fileprivate func handleCamera() {
        //TODO go to camera
    }
    
    @objc fileprivate func logout() {
        do {
            try! Auth.auth().signOut()
            returnToMain()
        } catch let error {
            Logger.log("error \(error.localizedDescription)")
        }
    }
    
    func returnToMain() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: handlers for options (side toggle from left)
    
    fileprivate func toFindMyFriends() {
        guard let navCon = self.navigationController else {
            return
        }
        
        let friendFinderVC = FindMyFriendsViewController()
        //Pass anything?
        navCon.pushViewController(friendFinderVC, animated: true)
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

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomePostCollectionViewCell
        
        cell.gridMode = gridMode
        cell.post = posts[indexPath.item]
        cell.delegate = self
        
        return cell
    }
    
    let testArray : [Story] = [Story(storyDict: ["" : ""]), Story(storyDict: ["" : ""])]
    var storyArray : [Story] = [] //TODO set (stories of friends, not self)
    
    //Testing
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! StoriesHeaderCollectionViewCell
            header.populateScrollView(array: testArray)
            header.delegate = self
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 100)
    }
    //End test
    
    fileprivate func itemSize() -> CGSize {
        var height: CGFloat = 40 + 8 + 8 //username userprofileimageview
        height += view.frame.width
        height += 50
        height += 60
        
        let standard = CGSize(width: view.frame.width - 20, height: height)
        let grid = CGSize(width: (view.frame.width - 20) / 3, height: height / 3)
        
        return gridMode == true ? grid : standard
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension HomeViewController: MainFeedOptionsHomeDelegate {
    func viewTappedWithTagForHome(_ tag: Int) {
        switch tag {
        case 0:
            Logger.log("")
        case 1:
            toFindMyFriends()
        default:
            Logger.log("WTF")
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout, HomePostCellDelegate, StoriesCellDelegate {
    
    func postPopupWithImage(image: UIImage) {
        postPopup.isHidden = false
        postPopup.showImageDetail(image: image)
    }
    
    //Stories cell delegate
    func mainImageTapped() { //Add your own story (option to view if they have one)
        guard let theNavVC = self.navigationController else {
            Logger.log("No Nav")
            return
        }
        //MARK: Move this to utils to not repeat code (DRY)
        guard let uid = Auth.auth().currentUser?.uid else {
            Logger.log("No UID")
            return
        }
        
        StoryController.userHasStory(uid) { exists in
            if exists == true {
                let storyWatchVC = StoryWatchViewController()
                storyWatchVC.curUID = uid
                storyWatchVC.modalPresentationStyle = .fullScreen
                theNavVC.present(storyWatchVC, animated: true, completion: nil)
            } else {
                let storyUploadVC = StoryUploadViewController()
                storyUploadVC.modalPresentationStyle = .fullScreen
                theNavVC.present(storyUploadVC, animated: true, completion: nil)
            }
        }

        //Test for going to friend profile
        
//        let userLayout = UICollectionViewFlowLayout()
//        let otherPersonVC = UserProfileCollectionViewController(collectionViewLayout: userLayout)
//        theNavVC.pushViewController(otherPersonVC, animated: true)
    }
    
    func storyViewTappedWithStory(story: Story) { //View someone elses
        
    }
    
    //Main cell delegate
    func commentTapped(post: Post) {
        //Go to comments VC
    }
    
    //TODO add like count and display (i.e. call this)
    func likeTapped(for cell: HomePostCollectionViewCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        //Can also just pass post via delegate function
        var post = self.posts[indexPath.item]
        
        if self.currentUser != nil { //If posts exist, won't be so maybe take away?
            let likeToWrite = [self.currentUser!.uid: post.liked == true ? 0 : 1]
            fDatabase.child(LikesReference).child(post.postID!).onDisconnectUpdateChildValues(likeToWrite) { (error, ref) in
                
                if error != nil {
                    Logger.log((error?.localizedDescription)!)
                    return
                }
                
                post.liked = !post.liked
                self.posts[indexPath.item] = post
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }
    }
    
    //Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize()
    }
}
