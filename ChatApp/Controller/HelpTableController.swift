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
    var list = [QuadStructure<String, String, String, String>]()

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
  
    func setupList() {
        let sendMessageQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: NSLocalizedString("howToSendMessage", comment: "How to send a message"), s2: "e4nsaeAqIHU"), s2: Tuple<String, String>(s1: NSLocalizedString("howToSendMessageDesc", comment: "How to send message description "), s2: NSLocalizedString("howToSendMessageList", comment: "How to send a message list.")))
        list.append(sendMessageQuad)
        
        let planEventQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: NSLocalizedString("howToPlanEvent", comment: "How to plan event"), s2: "UpqdPjGRBlI"), s2: Tuple<String, String>(s1: NSLocalizedString("howToPlanEventDesc", comment: "How to plan an event description."), s2: NSLocalizedString("howToPlanEventList", comment: "How to plan event list.")))
        list.append(planEventQuad)
        
        let acceptEventQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: NSLocalizedString("howToAcceptEvent", comment: "How to accept an event"), s2: "pw-xJ4RIYkY"), s2: Tuple<String, String>(s1: NSLocalizedString("howToAcceptEventDesc", comment: "How to plan an event description."), s2: NSLocalizedString("howToAcceptEventList", comment: "How to accept an event list.")))
        list.append(acceptEventQuad)
        
        
        let declineEventQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: NSLocalizedString("howToDeclineEvent", comment: "How to decline an event"), s2: "pw-xJ4RIYkY"), s2: Tuple<String, String>(s1: NSLocalizedString("howToDeclineEventDesc", comment: "How to decline an event description."), s2: NSLocalizedString("howToDeclineEventList", comment: "How to decline an event list.")))
        list.append(declineEventQuad)
        
        let changeUserSettingsQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: NSLocalizedString("howToChangeUserSettings", comment: "How to change user settings"), s2: "OPHwGhXadnE"), s2: Tuple<String, String>(s1: NSLocalizedString("howToChangeUserSettingsDesc", comment: "How to change user settings description."), s2: NSLocalizedString("howToChangeUserSettingsList", comment: "How to change user settings list.")))
           
        list.append(changeUserSettingsQuad)
        
        let changeProfilePictureQuad = QuadStructure<String, String, String, String>(s1: Tuple<String, String>(s1: NSLocalizedString("howToChangeProfilePicture", comment: "How to change profile picture."), s2: "ivYrhtMADM4"), s2: Tuple<String, String>(s1: NSLocalizedString("howToChangeProfilePictureDesc", comment: "How to change profile image description."), s2: NSLocalizedString("howToChangeProfilePictureList", comment: "How to change user settings list")))
        list.append(changeProfilePictureQuad)
        
        handleReload()
    }
    
    // MARK: - TableView
    
   
    ///Reloads the table view using the main thread.
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    //Gives the number of rows in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    //Specifies each element in the table view.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.detailTextLabel?.text = list[indexPath.row].getObjectOne().getObjectOne()
        
        return cell
    }
    
    //Defines the height of each table cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    //Called when a tablecell is selected.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let helpController = HelpController()
        helpController.quadTuple = list[indexPath.row]
        self.show(helpController, sender: self)
//        print(list[indexPath.row].getStringTwo())
    }
    
    
}

