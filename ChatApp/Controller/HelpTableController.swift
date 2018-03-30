//
//  HelpTableController.swift
//  ChatApp
//
//  Created by Danny on 18/02/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class HelpTableController: UITableViewController {
    // MARK: - Constants
    let cellId = "cellId"

    // MARK: - Variables
    var list = [Tuple]()

    ///The current user of the system.
    
    
    //MARK: - View initalisation
    override func viewDidLoad() {
        setupList()
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        let titleView = UITextView()
        titleView.text = "Help"
        titleView.isEditable = false
        titleView.isUserInteractionEnabled = false
        titleView.backgroundColor? = UIColor.clear
        navigationItem.titleView = titleView
    }
  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    //Specifies each element in the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.detailTextLabel?.text = list[indexPath.row].getStringOne()
        
        return cell
    }
    
    //Defines the height of each table cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    //Called when a tablecell is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    
}

