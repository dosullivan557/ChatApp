//
//  BlockedContactsController.swift
//  ChatApp
//
//  Created by Danny on 07/04/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class BlockedContactsController: UITableViewController {
    // MARK: - Constants
    ///Array for the settings.
    
    let cellId = "cellId"
    // MARK: - Variables
    
    ///The current user of the system.
    var currentUser = User()
    ///MessagesController
    var messagesController = MessagesController()
    ///Blocked Users
    var blockedUsers = [User?]()
    ///Timer
    var timer: Timer?
    
    //MARK: - View initalisation
    override func viewDidLoad() {
        loadBlockedForUser()
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        let titleView = UITextView()
        titleView.text = NSLocalizedString("blockedTitle", comment: "Blocked title")
        titleView.isEditable = false
        titleView.isUserInteractionEnabled = false
        titleView.backgroundColor? = UIColor.clear
        navigationItem.titleView = titleView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handleReload()
    }
    
    
    //MARK: - Tableview
    
    ///Reloads the table view using the main thread.
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    ///Gives the number of rows in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUsers.count
    }
    ///Specifies each element in the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        cell.profileImageView.image = UIImage(named: "defaultPic")
        cell.textLabel!.text = blockedUsers[indexPath.row]?.name!
        cell.profileImageView.loadImageUsingCache(urlString: blockedUsers[indexPath.row]?.profileImageUrl!)
        return cell
    }
    ///Defines the height of each table cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func loadBlockedForUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-blocked").child(uid)
        ref.observe(.childAdded) { (DataSnapshot) in
//            self.blockedUsers.append(DataSnapshot.key)
//            print("blocked id's: \(self.blockedId)")
            let userRef = Database.database().reference().child("users").child(DataSnapshot.key)
            userRef.observe(.value, with: { (DataSnapshot2) in
                if let dictionary = DataSnapshot2.value as? [String: AnyObject] {
                    let user = User()
                    user.id = DataSnapshot2.key
                    user.name = dictionary["name"] as? String
                    user.profileImageUrl = dictionary["profileImageUrl"] as? String
                    user.email = dictionary["email"] as? String
                    user.status = dictionary["status"] as? String
                    self.blockedUsers.append(user)
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let unblock = UITableViewRowAction(style: .normal, title: NSLocalizedString("unblockTitle", comment: "Unblock")) { action, index in
            self.unblock(indexPath: index)
        }
        unblock.backgroundColor = UIColor.red
        
        return [unblock]
    }
    
    func unblock(indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref1 = Database.database().reference().child("user-blocked").child(uid)
        let ref2 = Database.database().reference().child("blocked-user").child((blockedUsers[indexPath.row]?.id)!)
        ref1.child((blockedUsers[indexPath.row]?.id)!).removeValue()
        ref2.child(uid).removeValue()
        blockedUsers.remove(at: indexPath.row)
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleMessagesReload), userInfo: nil, repeats: false)
    }
    
    @objc func handleMessagesReload() {
        messagesController.handleReloadForBlock()
      self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.handleReload), userInfo: nil, repeats: false)
    }

    
}
