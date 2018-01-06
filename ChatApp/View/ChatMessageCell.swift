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
        tv.backgroundColor = UIColor.green
        tv.text = "Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text Sample Text "
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textView)
        
        //x,y,height,width
        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
