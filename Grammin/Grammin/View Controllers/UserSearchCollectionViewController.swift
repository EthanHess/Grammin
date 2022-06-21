//
//  UserSearchCollectionViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 5/23/18.
//  Copyright © 2018 EthanHess. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

private let reuseIdentifier = "Cell"

//Works well as collection view but maybe Table View would be better

class UserSearchCollectionViewController: UICollectionViewController {

    //Properties
    lazy var searchBar: UISearchBar = {
        let theSearchBar = UISearchBar()
        theSearchBar.placeholder = "Search Username"
        theSearchBar.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .gray
        theSearchBar.delegate = self
        return theSearchBar
    }()
    
    lazy var followOptions: FollowDisplayTypeContainer = {
        let fdtc = FollowDisplayTypeContainer()
        return fdtc
    }()
    
    var allUserArray : [User] = []
    var filteredUsers : [User] = []
    var following : [User] = []
    var followingUIDS : [String] = [] //better than user because they'll have different memory address
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    fileprivate func collectionViewConfig() {

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(FollowDisplayTypeContainer.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionReusableView")
        self.view.backgroundColor = UIColor.fromRGB(red: 7.0, green: 16.0, blue: 57.0)
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navBar = navigationController?.navigationBar
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        collectionViewExtras()
    }
    
    fileprivate func collectionViewExtras() {
        collectionView?.backgroundColor = .clear
        collectionView?.register(SearchUserCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        getAllUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
        collectionViewConfig()
    }
    
    fileprivate func getAllUsers() { //also remove yourself ;)
        self.allUserArray.removeAll()
        fDatabase.child(UsersReference).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.exists() {
                for babySnap in snapshot.children.allObjects as! [DataSnapshot] {
                    let userToAdd = User(uid: babySnap.key, dictionary: babySnap.value as! [String : Any])
                    self.allUserArray.append(userToAdd)
                }
                self.allUserArray.sort(by: { (userOne, userTwo) -> Bool in
                    return userOne.username.compare(userTwo.username) == .orderedAscending
                })
                self.fetchWhoIFollow()
                self.refresh()
            } else {
                Logger.log(" --- No snapshot --- ")
            }
        }) { (error) in
            Logger.log(" --- Error fetching users --- \(error.localizedDescription)")
        }
    }
    
    //This wouldn't scale well, may cause latency if you're following a few thousand users, other option is to paginate table and just check snapshot at index path
    
    fileprivate func fetchWhoIFollow() {
        guard let uid = Auth.auth().currentUser?.uid else {
            Logger.log("No UID")
            return
        }
        following.removeAll()
        followingUIDS.removeAll() //Better, remove other one
        fDatabase.child(FollowingReference).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for babySnap in snapshot.children.allObjects as! [DataSnapshot] {
                    self.followingUIDS.append(babySnap.key)
                }
                self.refresh()
            } else {
                Logger.log("No following snapshot")
            }
        }
    }
    
    fileprivate func refresh() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // NOTE: Much more versatility in normal UIVC with a collection view added vs. collectionVC
    
    // MARK: Collection View Header + Sizing
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionElementKindSectionHeader:
                let followOptions = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionReusableView", for: indexPath) as! FollowDisplayTypeContainer
                followOptions.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width, height: 60)
                followOptions.delegate = self
                
                return followOptions
                default:  fatalError("Unexpected element kind")
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return filteredUsers.count
        return allUserArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        //cell.user = filteredUsers[indexPath.item]
        let user = allUserArray[indexPath.item]
        cell.user = user
        cell.delegate = self
        let isFollowing = followingUIDS.contains(where: { $0 == user.uid })
        
        cell.followButton.setTitle(isFollowing ? "Unfollow" : "Follow", for: .normal)
        
        return cell
    }
    
    fileprivate func checkFollowingWithCell(cell: SearchUserCell) {
        //
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
}

// MARK: UICollectionViewDelegate

extension UserSearchCollectionViewController: UISearchControllerDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, SearchUserCellDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = allUserArray
        } else {
            filteredUsers = self.allUserArray.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        refresh()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
    // MARK: Cell delegate
    
    
    func followTapped(user: User) {
        guard let theCurrentUID = Auth.auth().currentUser?.uid else {
            Logger.log("")
            return
        }
        if theCurrentUID == user.uid {
            GlobalFunctions.presentAlert(title: "This is you!", text: "", fromVC: self)
            return;
        }
        FollowingController.followUnfollowUser(followerUID: theCurrentUID, followeeUID: user.uid) { (success) in
            if success == true {
                self.fetchWhoIFollow() //May just want to change button text, this could be a bit much at scale
            }
        }
    }
}

extension UserSearchCollectionViewController : FollowDisplayDelegate {
    func optionsTappedAtIndex(index: Int) {
        //TODO imp.
    }
}




