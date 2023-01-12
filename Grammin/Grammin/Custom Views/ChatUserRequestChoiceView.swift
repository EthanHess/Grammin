//
//  ChatUserRequestChoiceView.swift
//  Grammin
//
//  Created by Ethan Hess on 1/14/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit
import Firebase

protocol ChatChoiceDelegate : class {
    func usersChosenForChat(users: [User])
    func cancelTapped()
}

//TODO have option to select multiple recipients, make sure it checks to see if they're already in a chat together, and display which ones have been picked before heading to detail view

//Can choose to chat with following or send request
class ChatUserRequestChoiceView: UIView {
    
    weak var delegate : ChatChoiceDelegate?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    //with lazy can reference self inside computed property since self will exist, may not actually want this to be lazy, if not, will need to reference self after brought to life
    lazy var searchBar: UISearchBar = {
        let theSearchBar = UISearchBar()
        theSearchBar.delegate = self
        theSearchBar.barTintColor = Colors().coolBlue
        if #available(iOS 13.0, *) {
            theSearchBar.searchTextField.backgroundColor = Colors().aquarium
        } else {
            // Fallback on earlier versions
            
            // TODO imp.
        }
        return theSearchBar
    }()
    
    lazy var optionsContainer: OptionsContainer = {
        let theContainer = OptionsContainer()
        //Delegate
        return theContainer
    }()
    
    lazy var chosenParticipants: ChosenChatParticipantsContainer = {
        let cpView = ChosenChatParticipantsContainer()
        //Delegate?
        cpView.backgroundColor = .mainBlue() //TODO update
        return cpView
    }()
    
    lazy var userTable: UITableView = {
        let theTable = UITableView(frame: .zero, style: .grouped)
        theTable.delegate = self
        theTable.dataSource = self
        theTable.backgroundColor = .clear
        return theTable
    }()
    
    //TODO fetch
    var allUserArray : [User] = [] //TODO don't display this, just search DB when they want to add
    var filteredUsers : [User] = []
    var following : [User] = []
    var followingUIDS : [String] = [] //necessary here?
    var selectedUsersForChat : [User] = [] //UIDs as well?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        viewConfig()
        dataFetch()
        backgroundColor = .black //TODO image
    }
    
    fileprivate func viewConfig() {
        //Register TV
        userTable.register(ChatSearchUserCell.self, forCellReuseIdentifier: "csuc")
        
        addSubview(searchBar)
        searchBar.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: self.frame.size.width - 20, height: 50)
        
        addSubview(optionsContainer)
        optionsContainer.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: self.frame.size.width - 20, height: 50)
        
        addSubview(chosenParticipants)
        chosenParticipants.anchor(top: optionsContainer.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 0, paddingRight: 10, width: self.frame.size.width - 20, height: 50)
        
        addSubview(userTable)
        userTable.anchor(top: chosenParticipants.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10, width: self.frame.size.width - 20, height: self.frame.size.height - 175)
    }
    
    fileprivate func dataFetch() {
        guard let theUID = Auth.auth().currentUser?.uid else {
            Logger.log("No UID")
            return
        }
        //TODO fetch all users for chat request or following, should ideally store this in the app?
        FirebaseController.fetchWhoCurrentUserFollows(idString: theUID) { (userIdsDictionary) in
            guard let theDict = userIdsDictionary else {
                //Do nothing? display something?
                return
            }
            let semaphore = DispatchSemaphore(value: 0)
            let s_queue = DispatchQueue(label: "semaphore_queue")
            s_queue.async {
                theDict.forEach({ (key, value) in
                    FirebaseController.fetchUserWithUID(userID: key, completion: { (user) in
                        if let theUser = user {
                            self.following.append(theUser)
                            semaphore.signal()
                        } else {
                            Logger.log("")
                            semaphore.signal()
                        }
                    })
                    semaphore.wait() //Don't call on main queue, will freeze app
                })
                DispatchQueue.main.async {
                    self.refreshTable()
                }
            }
        }
    }
    
    @objc fileprivate func refreshTable() {
        self.userTable.reloadData()
    }
    
    //Should this be inside cell? UIView is okay, just an idea
    @objc fileprivate func refreshChatParticipantsView() {
        self.chosenParticipants.configureWithParticipants(participants: self.selectedUsersForChat)
    }
    
    @objc fileprivate func proceedHandler() {
        self.delegate?.usersChosenForChat(users: self.selectedUsersForChat)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatUserRequestChoiceView: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //TODO fetch then add filter etc.
        return following.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "csuc") as! ChatSearchUserCell
        //TODO config for diff modes, following, all etc.
        
        let theUser = following[indexPath.row]
        cell.user = theUser
        
        cell.checkMarkImageView.image = nil
        
        //Better to do a hash table of their UIDs
        for user in selectedUsersForChat {
            if user.uid == theUser.uid {
                cell.checkMarkImageView.image = UIImage(named: "checkmarkHotPink")
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO config for diff modes, following, all etc.
        //Start chat with user if available
        let user = following[indexPath.row]
        var hasSelected = false
        for selectedUser in selectedUsersForChat {
            if selectedUser.uid == user.uid {
                hasSelected = true
                selectedUsersForChat.removeAll { (user) -> Bool in
                    user.uid == selectedUser.uid
                }
                refreshTable()
                //self.perform(#selector(refreshTable), with: nil, afterDelay: 0.25)
                refreshChatParticipantsView()
            }
        }
        if hasSelected == false {
            selectedUsersForChat.append(user)
            refreshTable()
            refreshChatParticipantsView()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let theView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 50))
        let label = UILabel(frame: CGRect(x: 5, y: 5, width: tableView.frame.size.width - 10, height: 40))
        let noUsers = selectedUsersForChat.count == 0
        label.text = noUsers ? "Select Participants" : "Proceed"
        label.textAlignment = .center
        label.textColor = noUsers ? .white : .mainBlue()
        label.layer.borderColor = noUsers ? UIColor.white.cgColor : UIColor.mainBlue().cgColor
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.layer.borderWidth = 1
        let gesture = UITapGestureRecognizer(target: self, action: #selector(proceedHandler))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        theView.addSubview(label)
        return theView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //TODO Search
}
