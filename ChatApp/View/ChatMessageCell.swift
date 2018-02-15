//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Danny on 06/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
///CollectionViewCell's implementation so can edit the layout of each cell. This is used in the ChatLogController to layout the messages.
class ChatMessageCell: UICollectionViewCell {
    ///Where the message text appears.
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    ///The message container that resembles a bubble.
    let bubbleView: UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImage: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultPic")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    /*
      These NSLayoutConstraints are made global so I can change them when I want to. It is used once I determine who sent a certain message. If the currently logged in user sent the message, I can change the right anchor, and if it is another user, I can change left anchor. As well as this, when I estimate the width of the container which will be needed to hold the message, I can change the width anchor of the bubbleView to say how wide it should be.
     */
    var bubbleWidth: NSLayoutConstraint?
    var bubbleViewRA : NSLayoutConstraint?
    var bubbleViewLA : NSLayoutConstraint?
    var bubbleViewCA : NSLayoutConstraint?
    
    /**
     Defines where everything should be layed out in the cell, including the profileImageView and the timeLabel.
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImage)
        //x,y,height,width
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //x,y,height,width
        
        bubbleViewRA = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10)
        bubbleViewRA?.isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidth?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        bubbleViewLA = bubbleView.leftAnchor.constraint(equalTo:profileImage.rightAnchor, constant: 10)
        bubbleViewCA = bubbleView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        //x,y,width,height
        profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        //profile image in bottom of the cell
        //profileImage.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        //profile image in the center of the cell
        //profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        //profile image in the top of the cell
        profileImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant:32).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant:32).isActive = true
    }
    func setTouchable(bool: Bool) {
        self.isUserInteractionEnabled = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
