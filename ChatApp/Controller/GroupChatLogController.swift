////
////  GroupChatLogController.swift
////  ChatApp
////
////  Created by Danny on 04/01/2018.
////  Copyright © 2018 Danny. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//class GroupChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout{
//    //Variables.
//    var messages = [Message]()
//    var users = [User?](){
//        didSet{
//            if users.count == 1 {
//                let titleView = UITextView()
//                titleView.text = users?.name!.components(separatedBy: " ")[0]
//                titleView.isEditable = false
//                titleView.isUserInteractionEnabled = true
//                titleView.backgroundColor? = UIColor.clear
//                let tap = UITapGestureRecognizer(target: self, action: #selector(showUserProfile))
//                
//                titleView.addGestureRecognizer(tap)
//                
//                let calendarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCalendar))
//                calendarButton.image = UIImage(named: "CalendarIcon")
//                calendarButton.title = ""
//                navigationItem.rightBarButtonItem = calendarButton
//                navigationItem.titleView = titleView
//                
//                observeMessages()
//            }
//            else {
//                let titleView = UITextView()
//                titleView.text = "Group"
//                titleView.isEditable = false
//                titleView.isUserInteractionEnabled = true
//                titleView.backgroundColor? = UIColor.clear
////                let tap = UITapGestureRecognizer(target: self, action: #selector(showUserProfile))
//                
////                titleView.addGestureRecognizer(tap)
//                
//                let calendarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCalendar))
//                calendarButton.image = UIImage(named: "CalendarIcon")
////                calendarButton.title = ""
//                navigationItem.rightBarButtonItem = calendarButton
//                navigationItem.titleView = titleView
//                
////                observeGroupMessages()
//            }
//        }
//    }
//    @objc func showUserProfile(){
//        let profileController = ProfileController()
//        profileController.user = user
//        self.show(profileController, sender: self)
//        print("tapped")
//    }
//    lazy var inputTextField: UITextField = {
//        let inputTextField = UITextField()
//        inputTextField.placeholder = "Type Message..."
//        inputTextField.translatesAutoresizingMaskIntoConstraints = false
//        inputTextField.delegate = self
//        return inputTextField
//    }()
//    @objc func handleNameClick() {
//        print("Name Tap")
//    }
//    
//    lazy var calenderButton: UIImageView = {
//        let imageView = UIImageView()
//        
//        return imageView
//    }()
//    
//    let cellId = "cellId"
//    
//    override func viewDidLoad(){
//        self.hidesBottomBarWhenPushed = true
//        reload()
//        super.viewDidLoad()
//        collectionView?.backgroundColor = UIColor(patternImage: UIImage(named:"background")!)
//        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
//        collectionView?.alwaysBounceVertical = true
//        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
//        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)
//        
//        
//        setupInputComponents()
//        setupKeyboard()
//    }
//    
//    
//    func setupKeyboard(){
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
//    
//    @objc func handleKeyboardWillShow(notification: Notification){
//        let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? CGRect
//        containerViewBA?.constant = -((keyboardFrame?.height)!)
//        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
//        UIView.animate(withDuration: keyboardDuration!) {
//            self.view.layoutIfNeeded()
//        }
//    }
//    @objc func handleKeyboardWillHide(notification: Notification){
//        containerViewBA?.constant = 0
//        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
//        UIView.animate(withDuration: keyboardDuration!) {
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        reload()
//        NotificationCenter.default.removeObserver(self)
//    }
//    //show calendar
//    @objc func showCalendar(){
//        print("calendar")
//        let calendarView = CalendarController()
//        calendarView.user = user
//        self.show(calendarView, sender: self)
//        
//    }
//    
//    //Function which observes the database for new messages being sent.
//    func observeMessages(){
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//        
//        let ref = Database.database().reference().child("user-messages").child(uid).child((self.user?.id)!)
//        ref.observe(.childAdded, with: { (DataSnapshot) in
//            let messageId = DataSnapshot.key
//            let messagesRef = Database.database().reference().child("messages").child(messageId)
//            messagesRef.observeSingleEvent(of: .value, with: { (DataSnapshot) in
//                guard let dictionary = DataSnapshot.value as? [String: AnyObject] else{
//                    return
//                }
//                let message = Message()
//                message.message = dictionary["text"] as? String
//                message.sendId = dictionary["SendId"] as! [String?]
//                message.receiveId = dictionary["RecieveId"] as! [String?]
//                message.timestamp = dictionary["TimeStamp"] as? NSNumber
//                
//                self.messages.append(message)
//                
//                DispatchQueue.main.async(execute: {
//                    self.collectionView?.reloadData()
//                })
//                
//            }, withCancel: nil)
//        })
//    }
//    
//    var containerViewBA: NSLayoutConstraint?
//    
//    func reload(){
//        DispatchQueue.main.async(execute: {
//            self.hidesBottomBarWhenPushed = true
//            self.collectionView?.reloadData()
//        })
//    }
//    
//    //Defines the textfield and submit button.
//    func setupInputComponents(){
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        containerView.backgroundColor = UIColor.white
//        view.addSubview(containerView)
//        
//        //x, y, width, height
//        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        containerViewBA = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        containerViewBA?.isActive = true
//        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        
//        let sendButton = UIButton(type: .system)
//        sendButton.setTitle("Send", for: .normal)
//        sendButton.setTitleColor(UIColor.purple, for: .normal)
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        containerView.addSubview(sendButton)
//        //x,y,height, width for sendButton
//        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        sendButton.centerYAnchor.constraint(equalTo:containerView.centerYAnchor).isActive = true
//        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
//        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
//        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
//        //text field
//        
//        containerView.addSubview(inputTextField)
//        //x, y, width, height for text field
//        inputTextField.leftAnchor.constraint(equalTo:containerView.leftAnchor, constant: 10).isActive = true
//        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
//        
//        //seperator
//        let seperatorLine = UIView()
//        seperatorLine.backgroundColor = UIColor(r: 220, g: 220, b: 220)
//        seperatorLine.translatesAutoresizingMaskIntoConstraints = false
//        
//        containerView.addSubview(seperatorLine)
//        
//        //x,y,height, width
//        seperatorLine.leftAnchor.constraint(equalTo:containerView.leftAnchor).isActive = true
//        seperatorLine.topAnchor.constraint(equalTo:containerView.topAnchor).isActive = true
//        seperatorLine.heightAnchor.constraint(equalToConstant:0.5).isActive = true
//        seperatorLine.widthAnchor.constraint(equalTo:containerView.widthAnchor).isActive = true
//    }
//    //Defines the ssize of each section.
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var height: CGFloat = 80
//        if let text = messages[indexPath.item].message{
//            height = estimatedBubble(text: text).height + 10
//        }
//        
//        return CGSize(width: view.frame.width, height: height)
//    }
//    //Estimates the size of the bubble which will be needed for the message.
//    func estimatedBubble(text: String) -> CGRect {
//        
//        return NSString(string: text).boundingRect(with: CGSize(width: 150, height: 100), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
//    }
//    //This method is called when the send button is pressed.
//    @objc func handleSend() {
//        
//        if inputTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
//            inputTextField.text = ""
//            print("Cannot send empty messages")
//            return
//        }
//        
//        let ref = Database.database().reference().child("messages")
//        let childRef = ref.childByAutoId()
//        let recieveId = user!.id!
//        let sendId = Auth.auth().currentUser!.uid
//        let timestamp = Int(Date().timeIntervalSince1970)
//        
//        
//        let values = ["text": inputTextField.text!, "RecieveId": recieveId, "SendId": sendId, "TimeStamp": timestamp] as [String : Any]
//        
//        childRef.updateChildValues(values) { (error, ref) in
//            if error != nil {
//                print(error ?? "")
//                return
//            }
//            
//            let userMessagesRef = Database.database().reference().child("user-messages").child(sendId).child(recieveId)
//            
//            let messageId = childRef.key
//            userMessagesRef.updateChildValues([messageId: 1])
//            
//            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(recieveId).child(sendId)
//            recipientUserMessagesRef.updateChildValues([messageId: 1])
//        }
//        self.inputTextField.text = ""
//    }
//    //Defines how many sections that should be in the collection view.
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
//    }
//    //Setup each section in the collection view.
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
//        let message = messages[indexPath.item]
//        cell.textView.text = message.message
//        cell.bubbleWidth?.constant = estimatedBubble(text: message.message!).width + 25
//        
//        if message.sendId[0] == Auth.auth().currentUser?.uid {
//            //outgoing
//            cell.bubbleView.backgroundColor = UIColor.purple
//            cell.textView.textColor = UIColor.white
//            cell.bubbleViewLA?.isActive = false
//            cell.bubbleViewRA?.isActive = true
//            cell.profileImage.isHidden = true
//        }
//        else {
//            //Incoming
//            cell.bubbleViewRA?.isActive = false
//            cell.bubbleViewLA?.isActive = true
//            cell.bubbleView.backgroundColor = UIColor.lightGray
//            cell.textView.textColor = UIColor.black
//            cell.profileImage.isHidden = false
//            //load other person's image
//            if let profileImageUrl = self.user?.profileImageUrl {
//                cell.profileImage.loadImageUsingCache(urlString: profileImageUrl)
//            }
//        }
//        return cell
//    }
//    
//    
//    //Hide keyboard when screen is touched
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        handleSend()
//        self.view.endEditing(true)
//        return true
//    }
//    
//    
//}
//
