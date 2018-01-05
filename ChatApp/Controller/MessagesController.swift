//
//  ViewController.swift
//  ChatApp
//
//  Created by Danny on 28/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController, UITextFieldDelegate {
    let cellId = "cellId"
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let image = UIImage(named: "newMessage")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        observeMessages()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    var messages = [Message]()
    func observeMessages(){
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (Datasnapshot) in
            print(Datasnapshot)
            if let dictionary = Datasnapshot.value as? [String: AnyObject]{
                let message = Message()
                message.sendId = dictionary["SendId"] as? String
                message.receiveId = dictionary["RecieveId"] as? String
                message.message = dictionary["text"] as? String
                message.timestamp = dictionary["TimeStamp"] as? NSNumber
                print("TS")
                print(dictionary["TimeStamp"] as? NSNumber) 
                self.messages.append(message)
                DispatchQueue.main.async(){
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self 
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController,animated: true, completion: nil)
    }
    

    
    func checkIfUserIsLoggedIn(){
        if (Auth.auth().currentUser?.uid == nil) {
            performSelector(inBackground: #selector(handleLogout), with: nil)
        } else {
            fetchUser()
        }
    }
    
    func fetchUser(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return 
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {
            (DataSnapshot) in
            print(DataSnapshot)
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                self.setupNavBar(user: user)
            }
        }, withCancel: nil)
    }
    lazy var titleView: UIView = {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        titleView.backgroundColor = UIColor.red
        return titleView
    }()
    
    func setupNavBar(user: User){
        

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)

        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "defaultPic")
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCache(urlString: profileImageUrl)

        }
        containerView.addSubview(profileImageView)

        //x, y, width. height
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
        profileImageView.isUserInteractionEnabled = true
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.bringSubview(toFront: profileImageView)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true


        self.navigationItem.titleView = titleView
    }
    @objc func showChatController(user: User){
        
        print("123")
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    @objc func handleLogout(user: User){
        do{
           try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        self.navigationItem.title = ""
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }



}

