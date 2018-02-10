//
//  ProfileController.swift
//  ChatApp
//
//  Created by Danny on 09/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//
import UIKit
import Firebase
class ProfileController : UIViewController {
    
    let profileImage : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "defaultPic")
        image.layer.cornerRadius = 75
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "defaultPic")
        return image
    }()
    var user : User?{
        didSet{
            if let cu = user {
                print("huhuhuh")
                print(cu.name!)
                nameLabel.text = cu.name!
//                setupWithUser(user: cu)
            }
        }
    }
    let nameLabel : UITextView = {
        let name = UITextView()
        name.allowsEditingTextAttributes = false
        name.isEditable = false
        name.isUserInteractionEnabled = false
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textAlignment = .center
        name.font = UIFont(name: "arial", size: 20)
        name.textColor = UIColor.black
        return name
    }()
    let reportButton : UIButton = {
        let button = UIButton()
        button.setTitle("Report User", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        return button
    }()
    
    ///Opens the report controller.
    @objc func handleReport(){
        let reportController = ReportController()
        reportController.user = user
        show(reportController, sender: self)
    }
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(reportButton)
        setupWithUser(user: user!)
        setupFields()
    }
    ///Sets up the field constraints.
    func setupFields(){
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 20).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo:profileImage.centerXAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: profileImage.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        reportButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20).isActive = true
        reportButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        reportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        reportButton.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
    }

    
    ///Sets up the profile controller with the user.
    func setupWithUser(user: User){
        if let profileImageUrl = user.profileImageUrl {
            profileImage.loadImageUsingCache(urlString: profileImageUrl)
            print(user.name!)
            nameLabel.text = user.name!
        }
    }

}
