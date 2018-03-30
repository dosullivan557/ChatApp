//
//  MyProfileController.swift
//  ChatApp
//
//  Created by Danny on 22/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//


import UIKit
import Firebase
class MyProfileController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // MARK: - Constants

    ///The users profile picture.
    let profileImage : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "defaultPic")
        image.layer.cornerRadius = 75
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        return image
    }()
    ///The overlay.
    let overlay : UIView = {
        let view = UIView()
        //        view.backgroundColor = UIColor.clear
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    ///Change picture overlay.
    let label : UITextView = {
        let label = UITextView()
        label.text = NSLocalizedString("changePictureText", comment: "Change Picture text")
        label.allowsEditingTextAttributes = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "arial", size: 15)
        return label
    }()

    ///Label to show the users name.
    let nameLabel : UITextView = {
        let name = UITextView()
        name.allowsEditingTextAttributes = false
        name.isEditable = false
        name.isUserInteractionEnabled = false
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textAlignment = .center
        name.textColor = UIColor.black
        name.font = UIFont(name: "arial", size: 20)
        return name
    }()
    
    ///Label to show the users status.
    let statusLabel : UITextView = {
        let status = UITextView()
        status.allowsEditingTextAttributes = false
        status.isEditable = false
        status.isUserInteractionEnabled = false
        status.translatesAutoresizingMaskIntoConstraints = false
        status.textAlignment = .center
        status.textColor = UIColor.black
        status.font = UIFont(name: "arial", size: 15)
        return status
    }()
    
    
    
    ///Text view to show the user which email address they are signed up with.
    let emailLabel : UITextView = {
        let email = UITextView()
        email.allowsEditingTextAttributes = false
        email.isEditable = false
        email.isUserInteractionEnabled = false
        email.translatesAutoresizingMaskIntoConstraints = false
        email.textAlignment = .center
        email.textColor = UIColor.black
        return email
    }()
    ///Button to get help.
    let helpButton : UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("helpButton", comment: "Help Button title"), for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(handleHelp), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    ///Button to view that users events.
    let myEventsButton : UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("myEvents", comment: "My Events title"), for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(handleMyEvents), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    ///Button which allows the user to delete their profile.
    let deleteProfileButton : UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("deleteProfileButton", comment: "Delete Profile title"), for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    ///Activity Indicator
    let activityInd = ActivityController()

    
    // MARK: - Variables

    ///The current user of the system.
    var user : User? {
        didSet {
//            print(user?.status)
            nameLabel.text = user?.name
            emailLabel.text = user?.email
            profileImage.loadImageUsingCache(urlString: user?.profileImageUrl)
            statusLabel.text = user?.status
        }
    }
    
    
    //MARK: - View initialisation
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("logoutButton", comment: "Logout text for logout button"), style: .plain, target: self, action: #selector(checkLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear"), style: .plain, target: self, action: #selector(handleShowSettings))
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        label.addGestureRecognizer(tap)
        view.backgroundColor = UIColor.white
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(overlay)
        view.addSubview(emailLabel)
        view.addSubview(helpButton)
        view.addSubview(myEventsButton)
        view.addSubview(statusLabel)
        view.addSubview(deleteProfileButton)
        //        self.navigationController?.isNavigationBarHidden = true
        setupFields()
        setupOverlay()
        getUser()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //        if user?.id == nil {
        //            viewDidLoad()
        //        }
        //        else {
        //            self.setupWithUser(user: user!)
        //        }
        
        //        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    //MARK: - Setup
    
    ///Sets up the overlay constraints for resetting the profile picture.
    func setupOverlay() {
        overlay.addSubview(label)
        
        overlay.heightAnchor.constraint(equalToConstant: 150).isActive = true
        overlay.widthAnchor.constraint(equalToConstant: 150).isActive = true
        overlay.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        overlay.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor).isActive = true
        
        label.bottomAnchor.constraint(equalTo: overlay.bottomAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        label.heightAnchor.constraint(equalToConstant: 42).isActive = true
        label.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        
    }
    
    ///Sets up the views constraints.
    func setupFields(){
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 90).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 20).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        statusLabel.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        statusLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        statusLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        emailLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor).isActive = true
        emailLabel.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        myEventsButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        myEventsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        myEventsButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        myEventsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        helpButton.topAnchor.constraint(equalTo: myEventsButton.bottomAnchor).isActive = true
        helpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helpButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        helpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        deleteProfileButton.topAnchor.constraint(equalTo: helpButton.bottomAnchor).isActive = true
        deleteProfileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteProfileButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        deleteProfileButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    /**
     Sets up the page with the user's information.
     - Parameters:
         - user: The current users information.
     */
    func setupWithUser(user: User){
        if let profileImageUrl = user.profileImageUrl {
            profileImage.loadImageUsingCache(urlString: profileImageUrl)
            nameLabel.text = user.name
            emailLabel.text = user.email
            statusLabel.text = user.status
        }
    }
    
    
    
    //MARK: - Interaction
    
    ///Called when the overlay for the profile image is pressed.
    @objc func handleTap() {
        handleSelectProfileImageView()
    }
   
    ///Called when the delete profile button is pressed.
    @objc func deletePressed(){
        showDeleteAlert(title: NSLocalizedString("deleteProfileTitle", comment: "Title"), message: NSLocalizedString("deleteProfileBody", comment: "Body"))
        
    }
    ///Called when the delete profile is confirmed.
    func handleDelete(){
        deleteImageFromDatabase()
        Auth.auth().currentUser?.delete(completion: nil)
        let ref = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!)
        ref.removeValue()
        handleLogout()
    }
    
    
     ///This function is called if there is no user logged into the system or if the user wants to logout.
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError{
            print(logoutError)
        }
        
        tabBarController?.selectedIndex = 0
        
    }
    ///Opens the myevents controller.
    @objc func handleMyEvents(){
        let myEventController = MyEventsController()
        myEventController.currentUser = user!
        show(myEventController, sender: self)
    }
    ///Opens the help controller.
    @objc func handleHelp() {
        let helpController = HelpTableController()
        helpController.hidesBottomBarWhenPushed = true
        show(helpController, sender: self)
    }
    
    ///Called when the settings button is pressed.
    @objc func handleShowSettings(){
        let settingsController = SettingsController()
        settingsController.profileView = self
        settingsController.currentUser = self.user!
        settingsController.hidesBottomBarWhenPushed = true
        show(settingsController, sender: self)
    }
    
    /// Opens up an image picker and allows the user to select the picture.
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    //MARK: - Alert
    
    //By creating the method in this way, I was able to reduce a lot of extra code by just calling this function when its just a simple alert.
    /**
     Shows alerts for the given message and title. Calls [createAlertButton]() to add in the relevant buttons onto the alert.
     - Parameters:
         - title: The title to set for the alert box.
         - message: The message to set for the alert box.
     
     */
    
    func showDeleteAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "yes"), style: UIAlertActionStyle.default, handler: { (x) in
            self.handleDelete()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: "No"), style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    ///Shows alert to check whether the user definitely wants to log out. If so, It will handle the logout, otherwise, it will do nothing.
    @objc func checkLogout() {
        let alert = UIAlertController(title: NSLocalizedString("logoutButton", comment: "Logout"), message: NSLocalizedString("logoutCheck", comment: "Logout check"), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: "yes"), style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
            self.handleLogout()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("no", comment: "no"), style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
        }
        ))
        self.present(alert, animated: true, completion: nil)
    }
    
   
    //MARK: - Firebase
    ///Gets your users information and sets the data.
    func getUser(){
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = DataSnapshot.key
                user.status = dictionary["status"] as? String
                self.setupWithUser(user: user)
            }
        }, withCancel: nil)
    }
    
    
   
    ///Deletes the users current profile picture.
    func deleteImageFromDatabase() {
        let profileURLParts = user?.profileImageUrl?.components(separatedBy: "%2F")[1].prefix(40)
        if let imageName = profileURLParts {
            let storageRef = Storage.storage().reference().child("profileImages").child(String(describing: imageName))
            print(String(describing: imageName))
            storageRef.delete { (Error) in
                if let error = Error {
                    // An error occurred!
                    print(error)
                    return
                } else {
                    // File deleted successfully
                    print("Success")
                }
            }
        }
    }
    ///Uploads the new profile image for the user.
    func uploadImageToDatabase(){
        let storageRef = Storage.storage().reference().child("profileImages").child("\(NSUUID().uuidString).png")
        if let uploadData = UIImagePNGRepresentation(self.profileImage.image!){
            storageRef.putData(uploadData, metadata: nil, completion: {
                (metadata, error) in
                if error != nil{
                    return
                }
                if let profileUrl = metadata?.downloadURL()?.absoluteString{
                    let values = ["name": self.user?.name, "email": self.user?.email, "profileImageUrl": profileUrl] as [String: AnyObject]
                    self.updateValuesInDatabase(values: values)
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    delegate?.updateUser()
                    self.activityInd.finishAnimating(uiView: self.view)

                }
            })
            
        }
    }
    
    /**
     Updates the users information in the database.
     - Parameters:
         - values: The values to update.
     */
    func updateValuesInDatabase(values: [String: AnyObject]) {
        if let id = Auth.auth().currentUser?.uid{
            print(values)
            let ref = Database.database().reference().child("users").child(id)
            ref.updateChildValues(values)
        }
        else {
            print("Error")
            
        }
//        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - ImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFP: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"]{
            selectedImageFP = editedImage as? UIImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"]{
            selectedImageFP = originalImage as? UIImage
        }
        if let selectedImage = selectedImageFP {
            profileImage.image = selectedImage
        }
                dismiss(animated: true, completion: nil)

        activityInd.showActivityIndicatory(uiView: view)
        
        deleteImageFromDatabase()
        uploadImageToDatabase()
    }
    
    
    //Cancel button for the image picker.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
        dismiss(animated: true, completion: nil)
    }
}
