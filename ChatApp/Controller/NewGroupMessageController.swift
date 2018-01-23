//
//  NewGroupMessageController.swift
//  ChatApp
//
//  Created by Danny on 23/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class NewGroupMessageController: UITableViewController {
    let chatWithUsers = [User]()
    let cellId = "cellId"
    var users = [User]()
    var timer: Timer?
    var messagesController = MessagesController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group", style: .plain,target: self, action: #selector(handleGroup))
        fetchUser()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    @objc func handleGroup() {
        print("Group")
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    //Defines the number of cells in the tableview.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    //Fetches each user from the database, and populates the tableview with each user.
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
    //Reloads the tableview.
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    //Each cell for the tableview.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        
        // Configure the cell...
        cell.textLabel!.text = "row: \(indexPath.row)"
        
        if cell.isSelected
        {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell!.isSelected == true
        {
            cell!.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else
        {
            cell!.accessoryType = UITableViewCellAccessoryType.none
        }
    }

    //Defines the height of each cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

}
