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
        return image
    }()
    let nameLabel : UITextView = {
       let name = UITextView()
        name.allowsEditingTextAttributes = false
        name.isEditable = false
        name.isUserInteractionEnabled = false
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textAlignment = .center
        name.font = UIFont(name: "arial", size: 20)
        return name
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        setupFields()
    func setupFields(){
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 20).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo:profileImage.centerXAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: profileImage.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    }
