//
//  UserCell.swift
//  ChatApp
//
//  Created by Danny on 05/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
class UserCell: UITableViewCell {
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        //defaultImage
        imageView.image = UIImage(named: "defaultPic")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        
        
        return imageView
    }()
    

    var message: Message? {
        didSet {
            if let receieveId = message?.receiveId {
                let ref = Database.database().reference().child("users").child(receieveId)
                ref.observeSingleEvent(of: .value, with: { (DataSnapshot) in 
                    if let dictionary = DataSnapshot.value as? [String : AnyObject] {
                        self.textLabel!.text = dictionary["name"] as? String
                        if let profileImageUrl = dictionary["profileImageUrl"]{
                            self.profileImageView.loadImageUsingCache(urlString: profileImageUrl as! String)
                        }
                    }
                })
            }
            detailTextLabel!.text = message?.message
        }
    }
    let timeLabel : UILabel = {
        let label =  UILabel()
        label.text = "HH:MM:SS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview((profileImageView))
        //x, y, width, height
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant:8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(timeLabel)
        //x, y, width, height
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: (textLabel?.centerYAnchor)!).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 66, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 66, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
}
