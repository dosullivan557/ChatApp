//
//  UserCell.swift
//  ChatApp
//
//  Created by Danny on 05/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
//Table cell implementation so can edit the layout of each cell.
class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            if ((message?.message?.count)!) > 40 {
                
                detailTextLabel?.text = String(describing: (message?.message?.prefix(40))!)
                detailTextLabel?.text?.append("...")
            }
                
            else{
                detailTextLabel?.text = message?.message
            }
            //from yesterday
            if let seconds = message?.timestamp?.doubleValue {
                if (seconds < Double(Date().timeIntervalSince1970) - 604800) {
                    let timestampDate = Date(timeIntervalSince1970: seconds)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy"
                    timeLabel.text = dateFormatter.string(from: timestampDate)
                }
            else if (seconds < Double(Date().timeIntervalSince1970) - 86400) {
                    let timestampDate = Date(timeIntervalSince1970: seconds)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    timeLabel.text = ("Yesterday: " + dateFormatter.string(from: timestampDate))
                }
                //from today
                else {
                    let timestampDate = Date(timeIntervalSince1970: seconds)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    timeLabel.text = dateFormatter.string(from: timestampDate)
                }

            }
            
            
        }
    }

    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    fileprivate func setupNameAndProfileImage() {
        
        if let id = message?.chatWithId() {
            let ref = Database.database().reference().child("users").child(id)
            profileImageView.image = nil
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }


    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //need x,y,width,height anchors
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 50).isActive = true
        //time label centered
        //        timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        //time label top
        timeLabel.topAnchor.constraint(equalTo:self.topAnchor, constant: 18).isActive = true
        
        //time label bottom
//        timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
//        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

