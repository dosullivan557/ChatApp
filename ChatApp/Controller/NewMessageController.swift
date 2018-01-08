//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Danny on 28/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
import Firebase
class NewMessageController: UITableViewController {
    let cellId = "cellId"
    var users = [User]()


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = DataSnapshot.key
                self.users.append(user)
                
                self.users.sort(by: { (u1, u2) -> Bool in
                    return u1.name! < u2.name!
                })
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
            }
        }, withCancel: nil)
        
    }
    
    var timer: Timer?
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? UserCell
        let user = users[indexPath.row]
        cell?.profileImageView.image = UIImage(named: "defaultPic")
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
        if let profileImageUrl = user.profileImageUrl {
            cell?.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
            
        }
        return cell!
        
    }
    var messagesController = MessagesController()

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true)
        let user = self.users[indexPath.row]
        
        self.messagesController.showChatControllerForUser(user)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

}




