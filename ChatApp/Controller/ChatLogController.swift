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
    //Variables.
    var messages = [Message]()
    var containerViewBA: NSLayoutConstraint?
    var sanitiseWords = [String]()
    var messageSend = String()
    
    var users: [User?] = []{
        didSet{
            let titleView = UITextView()

            if users.count == 1 {
                chatWithUser = users[0]!
                titleView.text = chatWithUser.name!.components(separatedBy: " ")[0]
                titleView.isEditable = false
                titleView.isUserInteractionEnabled = true
                titleView.backgroundColor? = UIColor.clear
                let tap = UITapGestureRecognizer(target: self, action: #selector(showUserProfile))
                
                titleView.addGestureRecognizer(tap)
                observeMessages()
                


            }
            else {
                titleView.text = "Group"
//                titleView.isEditable = false
//                titleView.isUserInteractionEnabled = true
//                titleView.backgroundColor? = UIColor.clear
//                let tap = UITapGestureRecognizer(target: self, action: #selector(showGroupProfile))
//                titleView.addGestureRecognizer(tap)
//                observeGroupMessages()
            }


            let calendarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCalendar))
            calendarButton.image = UIImage(named: "CalendarIcon")
            calendarButton.title = ""
            navigationItem.rightBarButtonItem = calendarButton
            navigationItem.titleView = titleView

            }
    }
   
    var chatWithUser = User()

    lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.placeholder = "Type Message..."
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        return inputTextField
    }()

    
    lazy var calenderButton: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad(){
        self.hidesBottomBarWhenPushed = true
        reloadCollectionView()
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor(patternImage: UIImage(named:"background")!)
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 60, right: 0)

        setupSanitiseWords()
        setupInputComponents()
        setupKeyboard()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {

            print(self.messages.count)
            if self.messages.count == 0 {
                self.noMessages()
            }
        }
    }
    
//    @objc func showGroupProfile(){
//        print("123")
//    }
    
    /**
     This function sets up the the words and adds them to a list of words.
     */
    func setupSanitiseWords() {
        let file = Bundle.main.path(forResource: "badWords", ofType: "txt")
        do {
            var readString = try String(contentsOfFile: file!, encoding: String.Encoding.utf8)
            sanitiseWords = readString.components(separatedBy: "\r\n")
        } catch let error as NSError {
            print("error   \(error)")
            return
        }
    }
    ///Shows the users profile by tapping the users name.
    @objc func showUserProfile(){
        let profileController = ProfileController()
        profileController.user = chatWithUser
        self.show(profileController, sender: self)
    }
    /**
     This function sanitises a message. This function is called when the send button is pressed. It finds words in the message which could be a bad word, and replaces the word with characyers in the middle of the string with * characters.
     - Parameters:
         - Message: The message to sanitise.
     - Returns: Returns a sanitised version of the message.
     */
    func sanitiseMessage(Message: String) -> String{
        var sanitisedMessage = Message
        var words = Message.components(separatedBy: " ")
        for i in 0...(sanitiseWords.count-1) {

            for j in 0...(words.count - 1) {
                if sanitiseWords[i].caseInsensitiveCompare(words[j]) == ComparisonResult.orderedSame {
                    if(words[j] != ""){
                        var badWord = words[j]
                        var goodWord = String(describing: badWord.characters.first!)
                        for k in 1...(words[j].characters.count - 1) {
                            goodWord = goodWord + "*"
                        }
                        words[j] = goodWord + String(describing: badWord.characters.last!)

                }
            }
        }
        }
        sanitisedMessage = words.joined(separator: " ")
        return sanitisedMessage
    }
    
    ///Adds listener to the keyboards to show when it should hide and show.
    func setupKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    /**
     Defines how to show the keyboard.
     - Parameters:
         - notification: Used to get the keyboard size so that the text field and send button will appear above the keyboard when it shows.
     */
    @objc func handleKeyboardWillShow(notification: Notification){
        let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? CGRect
        containerViewBA?.constant = -((keyboardFrame?.height)!)
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    /**
     Defines how to hide the keyboard.
     - Parameters:
         - notification: Used to get the keyboard size so that the text field and send button will appear at the bottom of the screen when the keyboard hides.
     */
    @objc func handleKeyboardWillHide(notification: Notification){
        containerViewBA?.constant = 0
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reloadCollectionView()
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     When the plus button in the corner of the chatlog controller is pressed, then the calendarcontroller view will show, which is where the user can create an event.
     */
    @objc func showCalendar(){
        let calendarView = CalendarController()
        calendarView.user = chatWithUser
        self.show(calendarView, sender: self)
    }
    
    /**
     Observes the messages for the chat with this particular user.
     */
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid).child((self.chatWithUser.id)!)
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
                message.decrypt(key: DataSnapshot.key)
                self.messages.append(message)
                self.messages.sort { (m1, m2) -> Bool in
//                    print((Int)(m1.timestamp!))
                    return m1.timestamp!.intValue < m2.timestamp!.intValue
                }
                    self.reloadCollectionView()
                
            }, withCancel: nil)
        })

    }
//    func observeGroupMessages() {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//
//        let ref = Database.database().reference().child("Groups").child(uid).childByAutoId()
//        ref.observe(.childAdded, with: { (DataSnapshot) in
//            let messageId = DataSnapshot.key
//            let messagesRef = Database.database().reference().child("messages").child(messageId)
//            messagesRef.observeSingleEvent(of: .value, with: { (DataSnapshot) in
//                guard let dictionary = DataSnapshot.value as? [String: AnyObject] else{
//                    return
//                }
//                let message = Message()
//                message.message = dictionary["text"] as? String
//                message.sendId = dictionary["SendId"] as? String
//                message.receiveId = dictionary["RecieveId"] as? String
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
    
    
    /**
     Reloads the collectionView
     */
    func reloadCollectionView(){

        DispatchQueue.main.async(execute: {
            self.hidesBottomBarWhenPushed = true
            self.collectionView?.reloadData()
        })
    }
    
    @objc func handleCorrectSend() {
        if users.count == 1 {
            handleSend()
        }
        else {
            handleGroupSend()
        }
    }

    ///Defines the textfield and submit button constraints.
    func setupInputComponents(){
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white
        view.addSubview(containerView)
        
        //x, y, width, height
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerViewBA = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBA?.isActive = true
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
        sendButton.addTarget(self, action: #selector(handleCorrectSend), for: .touchUpInside)
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
    //Defines the ssize of each section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let text = messages[indexPath.item].message{
            height = estimatedBubble(message: text).height + 10
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    /**
    Estimates the size of the bubble which will be needed for the message.
     - Parameters:
         - text: The message to use to estimate the size of the bubble container for that message.
     */
    func estimatedBubble(message: String) -> CGRect {
        return NSString(string: message).boundingRect(with: CGSize(width: 150, height: 100), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    
//    //This method is called when the send button is pressed.
    @objc func handleGroupSend() {
//
//        if inputTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
//            inputTextField.text = ""
//            print("Cannot send empty messages")
//            return
//        }
//
//        let ref = Database.database().reference().child("messages")
//        let childRef = ref.childByAutoId()
//        let recieveId = "1"
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
//            for i in 1...self.users.count {
//                let userMessagesRef = Database.database().reference().child("user-messages").child(sendId).child((self.users[i-1]?.id)!)
//            let messageId = childRef.key
//            userMessagesRef.updateChildValues([messageId: 1])
//
//                let recipientUserMessagesRef = Database.database().reference().child("user-messages").child((self.users[i-1]?.id)!).child(sendId)
//            recipientUserMessagesRef.updateChildValues([messageId: 1])
//            }
//        }
//        self.inputTextField.text = ""
    }
    
    
    //This method is called when the send button is pressed.
    
    /**
     This method is called when the send button is pressed. It verifies that the message isn't empty, and then updates the database with the new message.
    */
    @objc func handleSend() {
        
        if inputTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            inputTextField.text = ""
            return
        }
        let id = NSUUID().uuidString
        let ref = Database.database().reference().child("messages")
        let childRef = ref.child(id)
        let recieveId = chatWithUser.id!
        let sendId = Auth.auth().currentUser!.uid
//        let timestamp = Int(Date().timeIntervalSince1970)
        let sanitisedMessage = sanitiseMessage(Message: inputTextField.text!)
        
        let message = Message()
        message.message = sanitisedMessage
        message.receiveId = chatWithUser.id!
        message.sendId = Auth.auth().currentUser!.uid
        message.timestamp = Int(Date().timeIntervalSince1970) as NSNumber
        
        
       message.encrypt(key: id)
        let values = ["text": message.message, "RecieveId": message.receiveId, "SendId": message.sendId, "TimeStamp": message.timestamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error ?? "")
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(sendId).child(recieveId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(recieveId).child(sendId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
        self.inputTextField.text = ""
    }
    //Defines how many sections that should be in the collection view.
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return messages.count
    }

    func noMessages(){
        let message = Message()
        message.message = "Say Heyy"
        message.sendId = "Me"
        message.receiveId = "Me"
        messageSend = "Heyy :)"
        messages.append(message)
        reloadCollectionView()
    }
    
    //Setup each section in the collection view.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAutoSend))

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.message
        cell.bubbleWidth?.constant = estimatedBubble(message: message.message!).width + 25
        
        if message.sendId == Auth.auth().currentUser?.uid {
            //outgoing
            cell.bubbleView.backgroundColor = UIColor.purple
            cell.textView.textColor = UIColor.white
            cell.bubbleViewLA?.isActive = false
            cell.bubbleViewRA?.isActive = true
            cell.profileImage.isHidden = true
            cell.bubbleViewCA?.isActive = false
            cell.setTouchable(bool: false)
            cell.removeGestureRecognizer(tap)
            cell.isUserInteractionEnabled = false

        }
        else if message.receiveId != message.sendId {
            //Incoming
            cell.bubbleViewRA?.isActive = false
            cell.bubbleViewLA?.isActive = true
            cell.bubbleViewCA?.isActive = false

            cell.bubbleView.backgroundColor = UIColor.lightGray
            cell.textView.textColor = UIColor.black
            cell.profileImage.isHidden = false
            cell.setTouchable(bool: false)
            cell.removeGestureRecognizer(tap)
            cell.isUserInteractionEnabled = false

            //load other person's image
            if let profileImageUrl = self.chatWithUser.profileImageUrl {
                cell.profileImage.loadImageUsingCache(urlString: profileImageUrl)
            }
        }
        else {
            cell.bubbleViewLA?.isActive = false
            cell.bubbleViewRA?.isActive = false
            cell.bubbleViewCA?.isActive = true
            cell.textView.textColor = UIColor.black
            cell.bubbleView.backgroundColor = UIColor.niceOrange
            cell.profileImage.isHidden = true
//            cell.setTouchable(bool: true)
            cell.isUserInteractionEnabled = true
            cell.addGestureRecognizer(tap)
        }
        return cell
    }
    
    
    @objc func handleAutoSend() {
//        self.collectionView?.deleteItems(at: [NSIndexPath(item:1, section:1) as IndexPath])

        self.inputTextField.text = messageSend
        print(messages[0].message!)
        messages.removeAll()

        self.handleSend()
        reloadCollectionView()

    }
    
    ///Hide keyboard when screen is touched
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        self.view.endEditing(true)
        return true
    }
    
    
}
