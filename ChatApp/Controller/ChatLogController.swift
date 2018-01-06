//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Danny on 04/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate{
    override func viewDidLoad(){
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        setupInputComponents()
    }
    
    var user: User?{
        didSet{
            navigationItem.title = user?.name
        }
    }
    lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.placeholder = "Type Message..."
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        return inputTextField
    }()
    func setupInputComponents(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        //x, y, width, height
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor.purple, for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(sendButton)
        //x,y,height, width for sendButton
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo:containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        //text field
        
        containerView.addSubview(inputTextField)
        //x, y, width, height for text field
        inputTextField.leftAnchor.constraint(equalTo:containerView.leftAnchor, constant: 10).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true

        //seperator
        let seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(seperatorLine)
        
        //x,y,height, width
        seperatorLine.leftAnchor.constraint(equalTo:containerView.leftAnchor).isActive = true
        seperatorLine.topAnchor.constraint(equalTo:containerView.topAnchor).isActive = true
        seperatorLine.heightAnchor.constraint(equalToConstant:0.5).isActive = true
        seperatorLine.widthAnchor.constraint(equalTo:containerView.widthAnchor).isActive = true
    }

    @objc func handleSend() {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        //is it there best thing to include the name inside of the message node
        let recieveId = user!.id!
        let sendId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)


        let values = ["text": inputTextField.text!, "RecieveId": recieveId, "SendId": sendId, "TimeStamp": timestamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(sendId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(recieveId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    

    //Hide keyboard when screen is touched
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        self.view.endEditing(true)
        return true
    }
    
    
}
