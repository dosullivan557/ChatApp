//
//  EventCell.swift
//  ChatApp
//
//  Created by Danny on 05/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
//Table cell implementation so can edit the layout of each cell. Used to define the way a cell looks - for events.
class EventCell: UITableViewCell {
    
    /*
      When the event is set for the cell, set this information using the variable's data.
     */
    var event: Event? {
        didSet {
            let startTimestampDate = Date(timeIntervalSince1970: event?.startTime as! TimeInterval)
            let finishTimestampDate = Date(timeIntervalSince1970: event?.finishTime as! TimeInterval)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy hh:mm a"
            detailTextLabel?.text = dateFormatter.string(from: startTimestampDate) + " - " + dateFormatter.string(from: finishTimestampDate)
            setupNameAndProfileImage()
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
    

    /**
     Sets up the image and name of the user for the event.
    */
    func setupNameAndProfileImage() {
        if let eventWithId = event?.eventWithId() {
            let ref = Database.database().reference().child("users").child(eventWithId)
            profileImageView.image = nil
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    var name = dictionary["name"] as? String
                    name = name?.components(separatedBy: " ")[0]
                    self.textLabel?.text = ((self.event?.title)!)
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    /**
     Defines where everything should be layed out in the cell, including the profileImageView and the timeLabel.
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    /**
     Defines where everything should be layed out in the cell, including the profileImageView and the timeLabel.
     */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


