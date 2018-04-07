//
//  ViewController.swift
//  ChatApp
//
//  Created by Danny on 28/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
import Firebase

//MARK: - Comparables
//issue where the comparators weren't working.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

//MARK: - Class declaration
///The tableview of all messages.
class MessagesController: UITableViewController {
    // MARK: - Constants

    ///The reuse identifier for the table cell.
    let cellId = "cellId"
    
    
    // MARK: - Variables

    ///Global timer - used to stop the table view refreshing unnecessarily.
    var timer: Timer?
    ///List of messages downloaded from the database.
    var messages = [Message]()
    ///A dictionary containing the user's id as the key and the message as the value. Used to sort the messages by user.
    var messagesDictionary = [String: Message]()
    ///A user value for the current user.
    var user = User()
    ///Blocked user id's
    var blockedId = [String?]()
    // MARK: - View initialisation
    
    override func viewDidAppear(_ animated: Bool) {
//        print("appeared")
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        let ad = UIApplication.shared.delegate as! AppDelegate
        if (ad.currentUser.profileImageUrl != user.profileImageUrl){
            user = ad.currentUser
            setupNavBarWithUser(user)
        }
    }
    
    override func viewDidLoad() {
        observeBlockedUsers()
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("logoutButton", comment: "Logout text for logout button"), style: .plain, target: self, action: #selector(checkLogout))
        
        let image = UIImage(named: "newMessage")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        _ = checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    // MARK: -  Setup
    
    ///Defines the current user of the system, and passes it to [setupNavBarWithUser(_ user: User)]( )) to setup the navigation bar for the particular user.
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.id = snapshot.key
                user.email = dictionary["email"] as? String
                user.name = dictionary["name"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                
                let settingsRef = Database.database().reference().child("user-settings").child((user.id)!)
                settingsRef.observe(.value, with: { (DataSnapshot) in
                    if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                        
                        user.settings?.id = user.id
                        user.settings?.greeting = dictionary["Greeting"] as? String
                        user.settings?.theirColor = dictionary["TheirColor"] as? String
                        user.settings?.myColor = dictionary["YourColor"] as? String
                    }
                })
                
                
                
                self.setupNavBarWithUser(user)
                
            }
            
        }, withCancel: nil)
    }
    
    /**
     Reads in the current user of the system which has been passed through from the [fetchUser()]() method. From here, it resets information such as the messages array and the messages dictionary, reloads the table to show the empty table, and then calls [observeUserMessages()]() to observe all the users messages. As well as this, everything is added into the navigation bar and positioned correctly.
     - Parameters:
         - user: Reads in the current user of the system, and will use this user object to set all the information in the navigation bar.
     */
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCache(urlString: profileImageUrl)
        }
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.currentUser = user
        containerView.addSubview(profileImageView)
        
        //x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name?.components(separatedBy: " ").first!
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
    }
    
    
    
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        if editingStyle == .delete {
            self.messages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            guard let chatId = message.chatWithId() else {
                return
            }
            
            if let currentUid = Auth.auth().currentUser?.uid {
                let ref = Database.database().reference().child("user-messages").child(currentUid).child(chatId)
                ref.removeValue()
                messagesDictionary.removeValue(forKey: chatId)
            }
        }
    }
    
    ///Reloads the table view using the main thread.
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    //Gives the number of rows in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    //Specifies each element in the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    //Defines the height of each table cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    //Called when a tablecell is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatId = message.chatWithId() else {
            return
        }
        let ref = Database.database().reference().child("users").child(chatId)
        ref.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            guard let dictionary = DataSnapshot.value as? [String: AnyObject] else {
                return
            }
            
            self.user.email = dictionary["email"] as? String
            self.user.name = dictionary["name"] as? String
            self.user.id = chatId
            self.user.profileImageUrl = dictionary["profileImageUrl"] as? String
            self.user.status = dictionary["status"] as? String
            var chatWithUser = [User]()
            chatWithUser.append(self.user)
            self.showChatControllerForUser(chatWithUser)
        }
            ,withCancel: nil)
    }
    
 
    
    // MARK: - Interaction
    
    
    
    /**
     Opens a chat log with an array of users, which is passed in.
     - Parameters:
         - user: The list of users that are being read in, and will be used to setup a chatlog controller.
     */
    func showChatControllerForUser(_ user: [User]) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.users = user
        chatLogController.messagesController = self
        chatLogController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatLogController, animated: true)
    }

    
    ///Shows alert to check whether the user definitely wants to log out. If so, It will handle the logout, otherwise, it will do nothing.
    @objc func checkLogout() {
        let alert = UIAlertController(title: NSLocalizedString("logoutButton", comment: "Title"), message: NSLocalizedString("logoutCheck", comment: "Body"), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "yes"), style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
            self.handleLogout()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: "no"), style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }
        ))
        self.present(alert, animated: true, completion: nil)
    }
    
    ///Defines how to open a new message controller when given an input.
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        newMessageController.blockedIds = self.blockedId
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    
    //MARK: - Firebase
    
    func observeBlockedUsers() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-blocked").child(uid)
        ref.observe(.childAdded) { (DataSnapshot) in
            self.blockedId.append(DataSnapshot.key)
            print("blocked id's: \(self.blockedId)")
        }
        
    }
    
    
    ///Checks the database for the messages for the current user. All this gets added into a dictionary of the user's Id, and then sorts the values into time order.
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (DataSnapshot) in
            let newRef = ref.child(DataSnapshot.key)
            newRef.observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                let messagesReference = Database.database().reference().child("messages").child(messageId)
                
                messagesReference.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                        let message = Message()
                        message.message = dictionary["text"] as? String
                        message.timestamp = dictionary["TimeStamp"] as? NSNumber
                        message.receiveId = dictionary["RecieveId"] as? String
                        message.sendId = dictionary["SendId"] as? String
                        message.decrypt(key: DataSnapshot.key)
                        if self.blockedId.contains(message.receiveId!) || self.blockedId.contains(message.sendId!){
                            print("user blocked")
                            return
                        }
                        if let chatId = message.chatWithId() {
                            self.messagesDictionary[chatId] = message
                            
                            self.messages = Array(self.messagesDictionary.values)
                            self.messages.sort(by: { (message1, message2) -> Bool in
                                
                                return message1.timestamp?.int32Value > message2.timestamp?.int32Value
                            })
                        }
                        //cancelled timer, so only 1 timer gets called, and therefore the only reloads the table once
                        self.timer?.invalidate()
                        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                    }
                    
                }, withCancel: nil)
            })
            
        }, withCancel: nil)
    }
    
    func handleReloadForBlock() {
        messages.removeAll()
        messagesDictionary.removeAll()
        observeBlockedUsers()
        observeUserMessages()
        handleReload()
    }
    
  
    /**
    Checks whether the user is logged in; if so, then fill in the information of the view, otherwise logout. This function is called when the app is first loaded.
     - Returns: Returns a boolean value representing whether the user is currently logged in.
     */
    func checkIfUserIsLoggedIn() -> Bool{
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            return false
        } else {
            fetchUser()
            return true
        }
    }
    
    
    ///This function is called if there is no user logged into the system or if the user wants to logout.
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
    
}
