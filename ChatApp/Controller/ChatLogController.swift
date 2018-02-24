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
    // MARK: - Constants
    
    ///The settings of the current user.
    let currentUserSettings = Settings()
    ///Cell reuse identifier for collection view.
    let cellId = "cellId"
    
    // MARK: - Variables
    
    ///The list of messages for this chat.
    var messages = [Message]()
    ///The container views bottom anchor, made global so I can change it. This contains the text field for the user to type in as well as the send button.
    var containerViewBA: NSLayoutConstraint?
    ///Words that are to be filtered out. Read in from the badWords.txt file.
    var sanitiseWords = [String]()
    ///Text is added here for smart message features, such as the "Say Hi" button.
    var messageSend = String()

    ///The colour that the user has chosen to use as the chat bubble colour for the currentUser.
    var myColor = UIColor()
    ///The text colour goes with the colour that the user has chosen for the currentUsers bubble colour.
    var myTextColor = UIColor()
    ///The colour that the user has chosen to use as the chat bubble colour for the chatWithUser.
    var theirColor = UIColor()
    ///The text colour goes with the colour that the user has chosen for the chatWithUser's bubble colour.
    var theirTextColor = UIColor()
    ///The users the user is chatting with.
    var users: [User?] = []{
        didSet{
            getUserSettings()
//            print(currentUserSettings.toString())
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
                //titleView.isEditable = false
                //titleView.isUserInteractionEnabled = true
                //titleView.backgroundColor? = UIColor.clear
                //let tap = UITapGestureRecognizer(target: self, action: #selector(showGroupProfile))
                //titleView.addGestureRecognizer(tap)
                //observeGroupMessages()
            }
            
            
            let calendarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCalendar))
            calendarButton.image = UIImage(named: "CalendarIcon")
            calendarButton.title = ""
            navigationItem.rightBarButtonItem = calendarButton
            navigationItem.titleView = titleView
            
        }
    }
    ///Time which is pulled from the message.
    var time: String?
    ///Location which is pulled from the message.
    var location: String?
    ///Description which is pulled from the message.
    var desc: String?
    
    ///The user that the current user is chatting to.
    var chatWithUser = User()
    
    ///Text field for the user to type a message.
    lazy var inputTextField: UITextField = {
        let inputTextField = UITextField()
        inputTextField.placeholder = "Type Message..."
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        return inputTextField
    }()
    
    
   
    var eventMessages = [Message]()
    
    // MARK: - View initialisation

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
    //Called when the view is dismissed
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        reloadCollectionView()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Setup

    /**
     Estimates the size of the bubble which will be needed for the message.
     - Parameters:
         - message: The message to use to estimate the size of the bubble container for that message.
     */
    func estimatedBubble(message: String) -> CGRect {
        return NSString(string: message).boundingRect(with: CGSize(width: 150, height: 100), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
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
    
    ///This function sets up the the words and adds them to a list of words
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
    
    //MARK: - Firebase
    
    ///Downloads the settings for that user from the database, and sets them here.
    func getUserSettings() {
        let ref = Database.database().reference().child("user-settings").child((Auth.auth().currentUser?.uid)!)
        ref.observe(.value) { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                self.currentUserSettings.greeting = dictionary["Greeting"] as? String
                self.currentUserSettings.theirColor = dictionary["TheirColor"] as? String
                self.currentUserSettings.myColor = dictionary["YourColor"] as? String
                
                print("My Colour: \(self.currentUserSettings.myColor)")
                print("Their Colour: \(self.currentUserSettings.theirColor)")
                print("Greeting: \(self.currentUserSettings.greeting)")
                self.setColors()
            }
        }
    }
    ///Checks which send should be called.
    @objc func handleCorrectSend() {
        if users.count == 1 {
            handleSend()
        }
        else {
            handleGroupSend()
        }
    }
    
    
    
    
    ///This method is called when the send button is pressed.
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
    
    
    
    /**
     This method is called when the send button is pressed. It verifies that the message isn't empty, and then updates the database with the new message.
     */
    @objc func handleSend() {
        
        if inputTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            inputTextField.text = ""
            return
        }
        if(messages.count == 1) {
            let message = messages[0]
            if message.sendId! == message.receiveId! {
                messages.removeAll()
                reloadCollectionView()
            }
        }
        let id = NSUUID().uuidString
        let ref = Database.database().reference().child("messages")
        let childRef = ref.child(id)
        let recieveId = chatWithUser.id!
        let sendId = Auth.auth().currentUser!.uid
        let timestamp = Int(Date().timeIntervalSince1970)
        let sanitisedMessage = sanitiseMessage(Message: inputTextField.text!)
        
        let message = Message()
        message.message = sanitisedMessage
        message.receiveId = chatWithUser.id!
        message.sendId = Auth.auth().currentUser!.uid
        message.timestamp = timestamp as NSNumber
        message.message?.append(" ")
        
        message.encrypt(key: id)
        
        //       message.message = message.message?.encodeEmoji
        
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
    
    //MARK: - Settings
    
    ///Decides which colours are downloaded, and using them, it sets the colours as UIColours to global variables, and using them, it can set colours to the bubble chat's colours.
    func setColors(){
        
        switch currentUserSettings.myColor! {
        case "Green":
            myColor = UIColor.green
            myTextColor = UIColor.black
        case "Pink" :
            myColor = UIColor.blue
            myTextColor = UIColor.white
        case "Purple" :
            myColor = UIColor.purple
            myTextColor = UIColor.white
        default:
            myColor = UIColor.orange
            myTextColor = UIColor.black
        }
        
        switch currentUserSettings.theirColor! {
        case "Green":
            theirColor = UIColor.green
            theirTextColor = UIColor.black
        case "Pink" :
            theirColor = UIColor.blue
            theirTextColor = UIColor.white
        case "Purple" :
            theirColor = UIColor.purple
            theirTextColor = UIColor.white
        default:
            theirColor = UIColor.orange
            theirTextColor = UIColor.black
        }
        
    }
   
    
    //    @objc func showGroupProfile(){
    //        print("123")
    //    }
    
    
    //MARK: - Interaction

    ///Shows the users profile by tapping the users name.
    @objc func showUserProfile(){
        let profileController = ProfileController()
        profileController.user = chatWithUser
        self.show(profileController, sender: self)
    }
    
    /**
     When the plus button in the corner of the chatlog controller is pressed, then the calendarcontroller view will show, which is where the user can create an event.
     */
    @objc func showCalendar(){
        let calendarView = CalendarController()
        calendarView.user = chatWithUser
        self.show(calendarView, sender: self)
    }
    
    
    //MARK: - Sanitise
    
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
    
    //MARK: - Keyboard

    ///Hide keyboard when screen is touched
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        self.view.endEditing(true)
        return true
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
    
   
    
    //MARK: - Firebase
    
    ///Observes the messages for the chat with this particular user.
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
    func observeUserSettings() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
            
        }
        let ref = Database.database().reference().child("user-settings").child(uid)
        ref.observe(.value) { (DataSnapshot) in
            guard let dictionary = DataSnapshot.value as? [String: AnyObject] else {
                return
            }
            let settings = Settings()
            settings.greeting = dictionary["Greeting"] as? String
            settings.myColor = dictionary["YourColor"] as? String
            settings.theirColor = dictionary["TheirColor"] as? String
//            self.currentUserSettings = settings
 
        }
        
        
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
    
    
    //MARK: - CollectionView
    
    
    //Setup each section in the collection view.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        cell.textView.text = message.message
        cell.bubbleWidth?.constant = estimatedBubble(message: message.message!).width + 25
        let autoSendMessageGesture = UITapGestureRecognizer(target: self, action: #selector(handleAutoSend))
        //        let autoEvent = UITapGestureRecognizer(target: self, action: #selector(handleAutoEvent(sender:)))
        //About event
        if messageIsAboutEvent(message: message) {
            eventMessages.append(message)
            cell.bubbleViewLA?.isActive = false
            cell.bubbleViewRA?.isActive = false
            cell.bubbleViewCA?.isActive = true
            cell.textView.textColor = UIColor.black
            cell.bubbleView.backgroundColor = UIColor.niceBlue
            cell.profileImage.isHidden = true
            cell.isUserInteractionEnabled = true
            //cell.addGestureRecognizer(autoEvent)
            
            cell.removeGestureRecognizer(autoSendMessageGesture)
            
        }
            //Send message
        else if (message.sendId! == message.receiveId!){
            cell.bubbleViewLA?.isActive = false
            cell.bubbleViewRA?.isActive = false
            cell.bubbleViewCA?.isActive = true
            cell.textView.textColor = UIColor.black
            cell.bubbleView.backgroundColor = UIColor.niceOrange
            cell.profileImage.isHidden = true
            cell.addGestureRecognizer(autoSendMessageGesture)
            //cell.removeGestureRecognizer(autoEvent)
            
        }
            //Outgoing message
        else if message.sendId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = myColor
            cell.textView.textColor = myTextColor
            
            cell.bubbleViewLA?.isActive = false
            cell.bubbleViewRA?.isActive = true
            cell.profileImage.isHidden = true
            cell.bubbleViewCA?.isActive = false
            cell.removeGestureRecognizer(autoSendMessageGesture)
            cell.isUserInteractionEnabled = false
            //cell.removeGestureRecognizer(autoEvent)
            
        }
            //Incoming message
        else if message.receiveId != message.sendId{
            cell.bubbleViewRA?.isActive = false
            cell.bubbleViewLA?.isActive = true
            cell.bubbleViewCA?.isActive = false
            //cell.removeGestureRecognizer(autoEvent)
            
            cell.bubbleView.backgroundColor = theirColor
            cell.textView.textColor = theirTextColor
            cell.profileImage.isHidden = false
            cell.setTouchable(bool: false)
            cell.removeGestureRecognizer(autoSendMessageGesture)
            cell.isUserInteractionEnabled = false
            
            //load other person's image
            if let profileImageUrl = self.chatWithUser.profileImageUrl {
                cell.profileImage.loadImageUsingCache(urlString: profileImageUrl)
            }
        }
        return cell
    }
    
    ///Reloads the collectionView
    func reloadCollectionView(){
        DispatchQueue.main.async(execute: {
            self.hidesBottomBarWhenPushed = true
            self.collectionView?.reloadData()
            if(self.messages.count>1){
                let lastItemIndex = NSIndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: lastItemIndex as IndexPath, at: .bottom, animated: true)
            }
        })

    }
    
   
    
   
    //Defines the ssize of each section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        if let text = messages[indexPath.item].message{
            height = estimatedBubble(message: text).height + 10
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    //Defines how many sections that should be in the collection view.
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
  

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        _ = messageIsAboutEvent(message: message)
        handleAutoEvent()
    }
    
    //MARK: - Smart Features
    ///Called when there is no messages in a certain chat.
    func noMessages(){
        let message = Message()
        message.message = "Say Heyy"
        message.sendId = "Me"
        message.receiveId = "Me"
        
        messages.append(message)
        reloadCollectionView()
    }
    ///Called when a event message is pressed. Fills in information about the event in the calendarcontroller.
    @objc func handleAutoEvent(){
        let calendarView = CalendarController()
        calendarView.user = chatWithUser
        
        if let rTime = time {
            var thing = rTime.components(separatedBy: ":")
            var adjust = 0
            var temp = ""
            for char in thing[0].stringToChars(String: thing[0]) {
                if char.asciiValue! >= "0".stringToChars(String: "0")[0].asciiValue! && char.asciiValue! <= "9".stringToChars(String: "9")[0].asciiValue! {
                    print(char.charToString())
                    temp.append(char.charToString())
                    print(temp)
                }
            }
            thing[0] = temp
            temp = ""
            
            for char in thing[1].stringToChars(String: thing[1]) {
                if char.asciiValue! >= "0".stringToChars(String: "0")[0].asciiValue! && char.asciiValue! <= "9".stringToChars(String: "9")[0].asciiValue! {
                    temp.append(char)
                }
            }
            thing[1] = temp
            if ((Int) (thing[0])! > 12) {
                adjust = 12
            }
            else {
                adjust = -12
            }
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = DateFormatter.Style.short
            timeFormatter.dateStyle = DateFormatter.Style.long
            let correctTime = Date().tomorrow.addingTimeInterval(TimeInterval(((Int) (((Int)(thing[0])! + adjust) * 60 * 60)) + ((Int) ((Int)(thing[1])! * 60))))
            let strDate = timeFormatter.string(from: correctTime)
            
            calendarView.sDate = correctTime
            calendarView.dateFieldS.text = strDate
        }
        if let rLocation = location {
            calendarView.locationField.text = rLocation
        }
        if let rDesc = desc {
            calendarView.descriptionField.text = rDesc
        }
        self.show(calendarView, sender: self)
    }
    

    
 
    
    /**
     Reads in a message, and decides whether it is about an event.
     - Parameters:
         - message: The message to test.
     - Returns: Returns a true or false value to decide whether the message is about an event or not.
     */
    func messageIsAboutEvent(message: Message) -> Bool {
        let words = message.message!.components(separatedBy: " ")
        var numberOfEventWords = Int()
        var counter = 0
        let max = words.count
        let locationWords = ["at", "the", "cinema", "park", "pub", "college", "uni", "bar", "town", "shop", "shops", "nandos", "restaurant", "office", "club",]
        var foundMeetAt : Bool? = false
        var timeTest : NSRegularExpression?
        do {
            timeTest = try NSRegularExpression(pattern: "(\\d\\d)+[.:]+(\\d\\d)", options: .caseInsensitive)
        } catch let error{
            print("error: \(error)")
        }
        if message.message!.lowercased().range(of: "meet at") != nil {
            foundMeetAt = true
        }
        for word in words {
            //            print("test: \(String(describing: timeTest?.firstMatch(in: word, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: word.nsrange))!)")
            counter += 1
            //            print(word)
            
            let test = timeTest?.firstMatch(in: word, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: word.nsrange)
            //            print("test: \(test)")
            if (test != nil){
                numberOfEventWords += 1
                self.time = word
            }
                //            print("test: \(test)")
            else if locationWords.contains(word.lowercased()) {
                
                if word == "at" {
                    if max > counter+1 {
                        
                        if (((words[counter+1].stringToChars(String: words[counter+1]))[0] >= "a") && ((words[counter+1].stringToChars(String: words[counter+1])[0]) <= "z")) {
                            print("location")
                            self.location = words[counter+1]
                        }
                            
                        else {
                            print("IDK")
                        }
                    }
                }
                numberOfEventWords += 1
            }
        }
        if(numberOfEventWords > 1) {
            desc = message.message
            return true
        }
        else{
            return false
        }
    }
    
    ///Called when the the no messages button is pressed.
    @objc func handleAutoSend() {
        print(currentUserSettings.greeting!)

        self.inputTextField.text = currentUserSettings.greeting!
        print(messages[0].message!)
        messages.removeAll()
        self.handleSend()
        reloadCollectionView()
        
    }
}
