//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Danny on 28/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//
import UIKit
import Firebase
class NewGroupMessageController: UITableViewController {
    //Constants.
    let cellId = "cellId"
    //Variables
    var AllUsers = [User]() {
        didSet{
            handleReload()
        }
    }
    var selectedUsers = [User]()
    var timer: Timer?
    var messagesController = MessagesController()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        navigationItem.rightBarButtonItem = nil
//        fetchUser()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
    }
//    func addGroupToDataBase() {
//        let ref = Database.database().reference().child("Groups").childByAutoId()
//        ref.updateChildValues("Group Name": "GroupName", "People" : )
//    }


    @objc func handleCreateGroup() {
        
        
            dismiss(animated: true)

            
            self.messagesController.showChatControllerForUser(selectedUsers)
        
    }
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    //Defines the number of cells in the tableview.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return AllUsers.count
    }

    //Reloads the tableview.
    @objc func handleReload() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    //Each cell for the tableview.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? UserCell
        let user = AllUsers[indexPath.row]
        cell?.profileImageView.image = UIImage(named: "defaultPic")
        cell?.textLabel?.text = user.name
        cell?.detailTextLabel?.text = user.email
        if let profileImageUrl = user.profileImageUrl {
            cell?.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
            
        }
        
        return cell!
        
    }

    //Defines the height of each cell.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if !(selectedUsers.contains(AllUsers[indexPath.row]))
        {
            cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedUsers.append(AllUsers[indexPath.row])
            navigationItem.rightBarButtonItem = UIBarButtonItem(title:"Create Group", style: .plain, target: self, action: #selector(handleCreateGroup))

        }
        else
        {
            cell!.accessoryType = UITableViewCellAccessoryType.none
            print(indexPath.row)
            if(selectedUsers.contains(AllUsers[indexPath.row])){
            for i in 0...selectedUsers.count{
                    if selectedUsers[i] == AllUsers[indexPath.row] {
                        selectedUsers.remove(at: i)
                        if selectedUsers.count == 0 {
                            navigationItem.rightBarButtonItem = nil
                        }
                        break
                    }
                }
            }

            print(selectedUsers.count)
        }
    }
}

