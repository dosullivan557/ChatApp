//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Danny on 04/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout{
    override func viewDidLoad(){
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)
        setupInputComponents()
    }
    var messages = [Message]()
    var user: User?{
        didSet{
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (DataSnapshot) in
            let messageId = DataSnapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (DataSnapshot) in
                guard let dictionary = DataSnapshot.value as? [String: AnyObject] else{
                    return
                }
                let message = Message()
                message.message = dictionary["text"] as? String
                message.sendId = dictionary["SendId"] as? String
                message.receiveId = dictionary["RecieveId"] as? String
                message.timestamp = dictionary["TimeStamp"] as? NSNumber
                
                if message.chatWithId() == self.user?.id{
                self.messages.append(message)
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
                }
            }, withCancel: nil)
        })
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
        containerView.backgroundColor = UIColor.white
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let text = messages[indexPath.item].message{
            height = estimatedBubble(text: text).height + 10
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    func estimatedBubble(text: String) -> CGRect {

        return NSString(string: text).boundingRect(with: CGSize(width: 200, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
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
        self.inputTextField.text = ""
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    let cellId = "cellId"
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.message
        cell.bubbleWidth?.constant = estimatedBubble(text: message.message!).width + 25
        return cell
    }
    

    //Hide keyboard when screen is touched
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        self.view.endEditing(true)
        return true
    }
    
    
}
