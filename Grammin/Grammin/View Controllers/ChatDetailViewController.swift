//
//  ChatDetailViewController.swift
//  Grammin
//
//  Created by Ethan Hess on 1/3/20.
//  Copyright © 2020 EthanHess. All rights reserved.
//

import UIKit
import Firebase

//For messages

class ChatDetailViewController: UIViewController {
    //Header will contain chat name as well as participants (can reuse old user partipants view?)
    
    //TODO have option to search through messages, use a trie?
    
    //We will for now and change if we need
    var chatOptionsView : ChatUserRequestChoiceView = {
        let chatView = ChatUserRequestChoiceView()
        return chatView
    }()
    
    //Will pop up with keyboard
    var messageInputView : UIView = {
        let miv = UIView()
        miv.backgroundColor = Colors().customGray
        miv.layer.cornerRadius = 5
        miv.layer.masksToBounds = true
        return miv
    }()
    
    //Font Awesome (TODO)
    var sendButton : UIButton = {
        let sb = UIButton()
        sb.setTitle("Send", for: .normal)
        sb.setTitleColor(Colors().aquarium, for: .normal)
        sb.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return sb
    }()
    
    var mediaButton : UIButton = {
        let mb = UIButton()
        mb.setTitle("Media", for: .normal)
        mb.setTitleColor(Colors().aquarium, for: .normal)
        return mb
    }()
    
    var inputField : UITextField = {
        let itf = UITextField()
        itf.placeholder = "Compose Message"
        itf.backgroundColor = Colors().awesomeBlack
        itf.textColor = Colors().aquarium
        return itf
    }()
    
    var messageTable : UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    //Subclass
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
    
    //UIDs
    var participants : [User] = []
    var messages : [Message] = []
    var chat : Chat?
    var keyboardIsShowing = false
    var keyboardFrame = CGRect.zero //For animtions

    var shouldCheckForExistingChat : Bool? {
        didSet {
            self.seeIfChatExistsWithCurrentParticipants()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotification()
        viewConfigure()
    }
    
    fileprivate func viewConfigure() {
        view.backgroundColor = .black
        addInputViewToKeyboard()
        registerAndConfigureTableView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    
    fileprivate func addInputViewToKeyboard() {
        messageInputView.frame = messageInputFrame()
        view.addSubview(messageInputView)
        addSubviewsToMIF()
        
        //inputField.inputAccessoryView = messageInputView //This won't work because it needs to show when Keyboard is down, unlike IAV
    }
    
    fileprivate func registerAndConfigureTableView() {
        messageTable.register(MessageTableViewCell.self, forCellReuseIdentifier: "message_cell")
        messageTable.dataSource = self
        messageTable.delegate = self
        
        view.addSubview(messageTable)
        messageTable.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 100, paddingLeft: 20, paddingBottom: 100, paddingRight: 20, width: view.frame.size.width - 40, height: view.frame.size.height - 200)
        
        messageTable.layer.cornerRadius = 5
        messageTable.layer.borderColor = UIColor.white.cgColor
        messageTable.layer.borderWidth = 0.5
        messageTable.layer.masksToBounds = true
        
        messageTable.backgroundColor = .clear
    }
    
    fileprivate func addSubviewsToMIF() {
        mediaButton.frame = CGRect(x: messageInputFrame().size.width - 70, y: 10, width: 60, height: 60)
        sendButton.frame = CGRect(x: messageInputFrame().size.width - 140, y: 10, width: 60, height: 60)
        inputField.frame = CGRect(x: 10, y: 10, width: messageInputFrame().size.width - 160, height: 60)
        inputField.delegate = self
        messageInputView.addSubview(mediaButton)
        messageInputView.addSubview(sendButton)
        messageInputView.addSubview(inputField)
        cornerRadius(radius: 5, view: inputField, borderColor: Colors().aquarium)
        cornerRadius(radius: 30, view: sendButton, borderColor: Colors().aquarium)
        cornerRadius(radius: 30, view: mediaButton, borderColor: Colors().aquarium)
    }
    
    fileprivate func cornerRadius(radius: CGFloat, view: UIView, borderColor: UIColor) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = radius
        view.layer.borderColor = borderColor.cgColor
        view.layer.borderWidth = 1
    }
    
    fileprivate func messageInputFrame() -> CGRect {
        let viewSize = view.frame.size
        return CGRect(x: 0, y: viewSize.height - 80, width: viewSize.width, height: 80)
    }
    
    //https://stackoverflow.com/questions/36714522/how-do-i-check-in-swift-if-two-arrays-contain-the-same-elements-regardless-of-th
    
    //https://nshipster.com/equatable-and-comparable/
    
    //Shall we have "currentUser" object (shared app data) to not have to read from Auth singleton?
    fileprivate func seeIfChatExistsWithCurrentParticipants() {
        if self.shouldCheckForExistingChat == true {
            guard let currentUID = Auth.auth().currentUser?.uid else {
                Logger.log("No UID")
                GlobalFunctions.presentAlert(title: "Oops, something went wrong", text: "Please check your internet connection", fromVC: self)
                return
            }
            //return chat obj if exists
            ChatsController.seeIfChatAlreadyExistsWithParticipants(users: self.participants, currentUserID: currentUID) { [self] (exists, chat) in
                if exists == true {
                    self.chat = chat!
                    self.dataFetch()
                } else {
                    ChatsController.createNewChatWithCreator(creatorUID: currentUID, chatDict: self.chatDict(uid: currentUID), users: self.participants) { (success, chatRef) in
                        if success == true {
                            guard let refKey = chatRef?.key else {
                                Logger.log("No ref key")
                                return
                            }
                            fDatabase.child(mainChatsNode).child(currentUID).child(refKey).observeSingleEvent(of: .value) { (snap) in
                                if snap.exists() {
                                    guard let theChatDict = snap.value as? [String: Any] else { return }
                                    self.chat = Chat(chatDict: theChatDict)
                                    self.chat!.chatID = snap.key
                                    //Data fetch
                                }
                            }
                        } else {
                            Logger.log("Error creating new chat")
                        }
                    }
                }
            }
        } else {
            //Use self.chat to fetch existing messages (selected from table)
            dataFetch()
        }
    }
    
    //Have toggle which shows current participants subview
    fileprivate func updateParticipantsUI() {
        
    }
    
    //Will want alert for chat name? we currently don't have this
    fileprivate func chatDict(uid: String) -> Dictionary<String, Any> {
        var participantsUIDArray = self.participants.map({ $0.uid })
        participantsUIDArray.append(uid) //add current user
        return [chatParticipantsKey: participantsUIDArray, chatLastMessageKey: "", chatAuthorUIDKey: uid, chatNameKey: "Test Chat"]
    }

    //TODO Paginate
    fileprivate func dataFetch() {
        guard let theChat = self.chat else {
            Logger.log("--- NO CHAT ---") //check internet?
            return
        }
        ChatsController.fetchAllMessagesForChat(chatID: theChat.chatID!) { (messages) in
            guard let theMessages = messages else {
                Logger.log("--- NO MESSAGES ---")
                return
            }
            self.messages = theMessages
            self.reloadTable()
        }
    }
    
    //Have option to collapse and view small messages?
    fileprivate func reloadTable() {
        DispatchQueue.main.async {
            self.messageTable.reloadData()
        }
    }
    
    //Should be "did show" ?
    fileprivate func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowing), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHiding), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc fileprivate func keyboardShowing(notif: Notification) {
        guard let notifInfo = notif.userInfo else {
            return
        }
        let dict = notifInfo as NSDictionary
        let kbFrame = dict.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let kbRect = kbFrame.cgRectValue
        self.keyboardFrame = kbRect
        keyboardIsShowing = true
        animateInputField()
    }
    
    @objc fileprivate func keyboardHiding(notif: Notification) {
        keyboardIsShowing = false
        animateInputField()
    }
    
    fileprivate func animateInputField() {
        if messageInputView.frame == messageInputFrame() { //Is down
            UIView.animate(withDuration: 0.1) { //Only need one block
                if self.keyboardIsShowing == true {
                    let x = self.messageInputFrame().origin.x
                    let y = self.messageInputFrame().origin.y - self.keyboardFrame.size.height
                    let width = self.messageInputFrame().size.width
                    let height = self.messageInputFrame().size.height
                    self.messageInputView.frame = CGRect(x: x, y: y, width: width, height: height)
                }
            }
        } else { //Up
            UIView.animate(withDuration: 0.1) {
                if self.keyboardIsShowing == false {
                    self.messageInputView.frame = self.messageInputFrame()
                }
            }
        }
    }
    
    //MARK: End Lifecycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Send functions
    
    //NOTE: write "lastMessage" property to chat as well as who wrote it here upon success (Have seperate node to not write to all users every time?)
    @objc fileprivate func sendTapped() {
        
        guard let currentUID = Auth.auth().currentUser?.uid else {
            GlobalFunctions.presentAlert(title: "Oops, something went wrong", text: "Please check your internet connection", fromVC: self)
            return
        }
        if !canWrite() {
            GlobalFunctions.presentAlert(title: "Please enter some text or choose an image or video", text: "", fromVC: self)
            return
        }
        
        //TODO some values are static (for test) but need to be updated when other functionality is added
        let dict = [messageAuthorUIDKey: currentUID, messageImageURLKey: "", messageVideoURLKey: "", messageMediaTypeKey: "None", messageBodyTextKey: self.inputField.text!, messageMultipleKey: false, messageTimestampKey: 0.0] as [String : Any]
        
        if self.chat == nil {
            GlobalFunctions.presentAlert(title: "Oops, there was an error", text: "Please check your internet connection", fromVC: self)
            return
        }
        
        //NOTE: Unowned self?
        ChatsController.addMessageToChat(chatID: self.chat!.chatID!, messageDict: dict) { (success) in
            if success == true {
                //TODO observe last one and don't reload all
                self.dataFetch()
                self.notifyAllUsers()
                self.writeLastMessageToChat(lastMessage: self.inputField.text!)
            } else {
                //Alert
            }
        }
    }
    
    //Push notifs (Firebase)
    fileprivate func notifyAllUsers() {
        
    }
    
    //TODO add to constants
    fileprivate func writeLastMessageToChat(lastMessage: String) {
        fDatabase.child("LastChatMessage").child(self.chat!.chatID!).setValue(lastMessage) { (error, ref) in
            
        }
    }
    
    //TODO check URL strings when added
    fileprivate func canWrite() -> Bool {
        return self.inputField.text != nil
    }
    
    //TODO imp.
    fileprivate func deleteMessageIfYourOwn(message: Message) {
        
    }
    
    //MARK: Media functions
    
    //TODO imp.

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ChatDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theCell = tableView.dequeueReusableCell(withIdentifier: "message_cell") as! MessageTableViewCell
        
        let theMessage = self.messages[indexPath.row]
        theCell.configureWithMessage(message: theMessage)
        
        return theCell
    }
    
    //This will need to update based on media / text size, we can store an array of IP heights eventually
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //Share etc?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //TODO delete message
    }
}
