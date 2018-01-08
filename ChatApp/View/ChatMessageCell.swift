//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Danny on 06/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
//CollectionViewCell's implementation so can edit the layout of each cell.
class ChatMessageCell: UICollectionViewCell {
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.clear
        tv.isEditable = false
        tv.isUserInteractionEnabled = false
        tv.textColor = UIColor.white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
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
    
    var bubbleWidth: NSLayoutConstraint?
    var bubbleViewRA : NSLayoutConstraint?
    var bubbleViewLA : NSLayoutConstraint?
    
    
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
