//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Danny on 06/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    let textView: UITextView = {
        let tv = UITextView()
//        tv.backgroundColor = UIColor.green
        tv.backgroundColor = UIColor.clear
        tv.textColor = UIColor.white
        tv.text = "Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text "
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    let bubbleView: UIView={
        let view = UIView()
        view.backgroundColor = UIColor.purple
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    var bubbleWidth: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        //x,y,height,width
        textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 10).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        //x,y,height,width
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidth = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidth?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
