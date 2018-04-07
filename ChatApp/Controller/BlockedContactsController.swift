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
    
    ///Blocked Users
    var blockedUsers = [User?]()
    
    //MARK: - View initalisation
    override func viewDidLoad() {
        
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
        cell.textLabel!.text = blockedUsers[indexPath.row]?.name!
        cell.profileImageView.loadImageUsingCache(urlString: blockedUsers[indexPath.row]?.profileImageUrl!)
        return cell
    }
    ///Defines the height of each table cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func loadBlockedForUser() {
        
    }

    
}
