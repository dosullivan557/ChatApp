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
    
    // MARK: - Constants

    ///Reusable cell identidier.
    let cellId = "cellId"
    
    // MARK: - Variables

    ///An array of all the users to show.
    var users = [User]()
    ///An instance of timer so that we can make sure the tableview only gets refreshed once to prevent flickering when sorting.
    var timer: Timer?
    ///An instance of messageController which called this instance of NewMessageController so that I can push back to that view, and open the chat from there.
    var messagesController = MessagesController()
    
    
    // MARK: - View initialisation

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group", style: .plain,target: self, action: #selector(handleGroup))
        fetchUser()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
    }
    
    
    //    @objc func handleGroup () {
    //        let group = NewGroupMessageController()
    //        group.AllUsers = users
    //        group.messagesController = messagesController
    //        show(group, sender: self)
    //    }

    //MARK: - TableView
    //Defines the number of cells in the tableview.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    ///Reloads the tableview.
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    //Each cell for the tableview.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? UserCell
        let user = users[indexPath.row]
        cell?.profileImageView.image = UIImage(named: "defaultPic")
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.status
        if let profileImageUrl = user.profileImageUrl {
            cell?.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
        }
        
        return cell!
        
    }
    //Defines what happens when a cell is pressed.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true)
        var usersToChatWith = [User]()
        usersToChatWith.append(self.users[indexPath.row])
        
        self.messagesController.showChatControllerForUser(usersToChatWith)
    }
    //Defines the height of each cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    //MARK: - Interaction
    ///Cancel Button being pressed.
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Firebase
    ///Fetches each user from the database, and populates the tableview cells with each user.
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = DataSnapshot.key
                user.status = dictionary["status"] as? String
                if user.id != Auth.auth().currentUser?.uid {
                
                    self.users.append(user)
                    
                    self.users.sort(by: { (u1, u2) -> Bool in
                        return u1.name! < u2.name!
                    })
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                }
            }
            
        }, withCancel: nil)
        
        
    }

}



