//
//  MainChatsListViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 11/16/19.
//  Copyright © 2019 EthanHess. All rights reserved.
//

import UIKit
import Firebase

//Could make this a UICollectionViewController but view is more versatile with UIVC since we'll want to add other subviews
class MainChatsListViewController: UIViewController, ChatChoiceDelegate {

    //TODO add search popup table to find users
    var mainCollectionView : UICollectionView = {
        let theCV = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        return theCV
    }()
    
    //Better for adding SVGs/Font Awesome
    
    //TODO subclass this because we'll use it a lot
    var customNavBar : UIView = {
        let cnb = UIView()
        cnb.backgroundColor = Colors().customGray
        return cnb
    }()
    
    var customNavBarLeftTapGestureView : UIView = {
        let cnb = UIView()
        cnb.isUserInteractionEnabled = true
        cnb.backgroundColor = .clear
        return cnb
    }()
    
    var customNavBarRightTapGestureView : UIView = {
        let cnb = UIView()
        cnb.isUserInteractionEnabled = true
        cnb.backgroundColor = .clear
        return cnb
    }()
    
    //TODO subclass and append Search Bar
    var searchHeaderView : UIView = {
        let sHeader = UIView()
        return sHeader
    }()
    
    //TODO animate like contacts app
    var searchBar : UISearchBar = {
        let sBar = UISearchBar()
        return sBar
    }()
    
    //Hidden at first but this is to compose a new chat
    var chatOptionsView : ChatUserRequestChoiceView = {
        let chatView = ChatUserRequestChoiceView()
        return chatView
    }()
    
    var allChats : [Chat] = [] //If count is zero, show a cell with a create icon? + a "You have no chats right now" banner?
    var chatToPass : Chat?
    var detailShouldCheckForExistingChat = false //They can either select existing chat,
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = true
    }
    
    //Chat picker delegate
    func usersChosenForChat(users: [User]) {
        if users.count == 0 {
            GlobalFunctions.presentAlert(title: "Please add at least one user to chat with", text: "", fromVC: self)
            return
        }

        let chatDetail = ChatDetailViewController()
        chatDetail.participants = users
        chatDetail.shouldCheckForExistingChat = true
        self.present(chatDetail, animated: true, completion: nil)
        //TODO no nav because this is present VC, push or add new nav
        //theNavController.pushViewController(chatDetail, animated: true)
    }
    
    //No users chosen, old chat
    fileprivate func presentFromSelection() {
        guard let theChat = self.chatToPass else {
            Logger.log("--- NO CHAT TO PASS ---")
            return
        }
        let chatDetail = ChatDetailViewController()
        chatDetail.chat = theChat
        chatDetail.shouldCheckForExistingChat = false
        self.present(chatDetail, animated: true, completion: nil)
    }
    
    fileprivate func newNavController(rvc: UIViewController) -> UINavigationController {
        return UINavigationController(rootViewController: rvc)
    }
    
    func cancelTapped() {
        hideShowChatPrompt()
    }
    //End delegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .black
        headerConfig()
        fetchChats()
    }
    
    //Data fetch
    fileprivate func fetchChats() {
        guard let uid = Auth.auth().currentUser?.uid else {
            Logger.log("--- NO UID ---") //internet alert?
            return
        }
        ChatsController.fetchChatsForUser(userID: uid) { (chats) in
            guard let chatArray = chats else {
                Logger.log("--- NO CHATS ---")
                return
            }
            self.allChats = chatArray
            self.refresh()
        }
    }
    
    fileprivate func refresh() {
        DispatchQueue.main.async {
            self.mainCollectionView.reloadData()
        }
    }
    
    //Subviews
    fileprivate func headerConfig() {
        view.addSubview(searchHeaderView)
        searchHeaderView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: view.frame.size.width - 40, height: 100)
        searchHeaderView.backgroundColor = Colors().searchBackgroundBlue
        radiusForView(radius: 5, view: searchHeaderView, mask: true)
        searchHeaderView.layer.borderColor = UIColor.white.cgColor
        searchHeaderView.layer.borderWidth = 1
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: searchHeaderView.topAnchor, right: view.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: view.frame.size.width, height: 50)
        
        view.addSubview(chatOptionsView)
        chatOptionsView.isHidden = true
        chatOptionsView.delegate = self
        chatOptionsView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 50, paddingBottom: 100, paddingRight: 50, width: 0, height: 0)
        radiusForView(radius: 10, view: chatOptionsView, mask: true)
        chatOptionsView.layer.borderColor = UIColor.white.cgColor
        chatOptionsView.layer.borderWidth = 1
        
        collectionSetup()
        
        self.perform(#selector(searchBarConfig), with: nil, afterDelay: 0.25)
        self.perform(#selector(subviewsForNavBar), with: nil, afterDelay: 0.25)
    }
    
    //Nav handlers
    @objc func dismissTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //TODO, nice custom animation here
    @objc func hideShowChatPrompt() {
        self.chatOptionsView.isHidden = !self.chatOptionsView.isHidden
    }
    
    @objc fileprivate func subviewsForNavBar() {
        //Left --- Right
        let navWH = customNavBar.frame.size.width / 2
        let navH = customNavBar.frame.size.height
        
        customNavBarLeftTapGestureView.frame = CGRect(x: 0, y: 0, width: navWH, height: navH)
        customNavBarRightTapGestureView.frame = CGRect(x: navWH, y: 0, width: navWH, height: navH)
        customNavBar.addSubview(customNavBarLeftTapGestureView)
        customNavBar.addSubview(customNavBarRightTapGestureView)
        
        let navGestureLeft = UITapGestureRecognizer(target: self, action: #selector(dismissTapped))
        customNavBarLeftTapGestureView.addGestureRecognizer(navGestureLeft)
        
        let navGestureRight = UITapGestureRecognizer(target: self, action: #selector(hideShowChatPrompt))
        customNavBarRightTapGestureView.addGestureRecognizer(navGestureRight)
    }
    
    fileprivate func radiusForView(radius: CGFloat, view: UIView, mask: Bool) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = mask
    }
    
    @objc fileprivate func searchBarConfig() {
        searchBar.frame = CGRect(x: 10, y: 10, width: searchHeaderView.frame.size.width - 20, height: searchHeaderView.frame.size.height - 20)
        searchHeaderView.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.barTintColor = Colors().searchBarBlue
        searchBar.tintColor = .white
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = .white
        } else {
            // Fallback on earlier versions
            
            // TODO imp.
        }
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.textColor = .black
        } else {
            // Fallback on earlier versions
            
            // TODO imp.
        }
        radiusForView(radius: 5, view: searchBar, mask: true)
    }
    
    fileprivate func collectionSetup() {
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        //Register cell
        mainCollectionView.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: "ccvc")
        
        view.addSubview(mainCollectionView)
        mainCollectionView.anchor(top: searchHeaderView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: view.frame.size.width - 40, height: 0) //TODO diff. height value
        
        //Put in refresh function
        mainCollectionView.reloadData()
        
        view.bringSubview(toFront: chatOptionsView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainChatsListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    //Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allChats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let theCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ccvc", for: indexPath) as! ChatCollectionViewCell
        //Config
        let chat = allChats[indexPath.row]
        theCell.configureWithChat(chat: chat)
        
        return theCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //TODO add grid mode for messages
        //TODO adjust height/size of iPad
        return CGSize(width: self.view.frame.size.width - 10, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chat = allChats[indexPath.row]
        self.detailShouldCheckForExistingChat = false
        self.chatToPass = chat
        
        //TODO present options
        self.presentFromSelection()
    }
    
    //Search Bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        //reload
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}
