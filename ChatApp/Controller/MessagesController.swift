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
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        let image = UIImage(named: "newMessage")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
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
    
    func setupNavBar(user: User){
//        self.navigationItem.title = user.name
        print("setup navbar")
        let titleView = UIView()
        
        titleView.backgroundColor = UIColor.blue
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        if let profileImageUrl = user.profileImageUrl{
            profileImageView.loadImageUsingCache(urlString: profileImageUrl)
            
        }
        titleView.addSubview(profileImageView)
        

        //x, y, width. height
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true

        let nameLabel = UILabel()
        titleView.addSubview(nameLabel)

        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: titleView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        
        self.navigationItem.titleView = titleView
        print("finished")
        

    }
    @objc func handleLogout(){
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

