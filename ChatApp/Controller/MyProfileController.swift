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
    
    let profileImage : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "defaultPic")
        image.layer.cornerRadius = 75
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let overlay : UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor.clear
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let label : UITextView = {
        let label = UITextView()
        label.text = "Change Picture"
        label.allowsEditingTextAttributes = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "arial", size: 15)
        return label
    }()
    var user : User? {
        didSet {
            print("Profile page set")
            nameLabel.text = user?.name
            emailLabel.text = user?.email
            profileImage.loadImageUsingCache(urlString: user?.profileImageUrl)
        }
    }

    @objc func handleTap() {
        handleSelectProfileImageView()
    }
    
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
    let helpButton : UIButton = {
        let button = UIButton()
        button.setTitle("Help me", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(handleHelp), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    @objc func handleHelp() {
        print("Help me")
    }
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        label.addGestureRecognizer(tap)
        view.backgroundColor = UIColor.white
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(overlay)
        view.addSubview(emailLabel)
        view.addSubview(helpButton)
        self.navigationController?.isNavigationBarHidden = true
        setupFields()
        setupOverlay()
        getUser()
    }
    
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
    func setupFields(){
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 20).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        emailLabel.centerXAnchor.constraint(equalTo:view.centerXAnchor).isActive = true
        emailLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        helpButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        helpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helpButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        helpButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    func getUser(){
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject]{
                let user = User()
                user.name = dictionary["name"] as? String
                user.email = dictionary["email"] as? String
                user.profileImageUrl = dictionary["profileImageUrl"] as? String
                user.id = DataSnapshot.key
                self.setupWithUser(user: user)
                print(user)
            }
        }, withCancel: nil)
    }
    
    //Image picker.
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        print("picker")
        picker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        
    }
    func deleteImageFromDatabase() {
        let optionalVal = user?.profileImageUrl?.components(separatedBy: "%2F")[1].prefix(40)
        if let imageName = optionalVal {
        let storageRef = Storage.storage().reference().child("profileImages").child(String(describing: imageName))
        print(String(describing: imageName))
        storageRef.delete { (Error) in
                if let error = Error {
                    // Uh-oh, an error occurred!
                    print("ERROR")
                    print(error)
                    return
                } else {
                    // File deleted successfully
                    print("Success")
                }
            }
        }
    }
    func uploadImageToDatabase(){
        let storageRef = Storage.storage().reference().child("profileImages").child("\(NSUUID().uuidString).png")
        if let uploadData = UIImagePNGRepresentation(self.profileImage.image!){
            storageRef.putData(uploadData, metadata: nil, completion: {
                (metadata, error) in
                if error != nil{
                    print(error)
//                    return
                }
                if let profileUrl = metadata?.downloadURL()?.absoluteString{
                    let values = ["name": self.user?.name, "email": self.user?.email, "profileImageUrl": profileUrl] as [String: AnyObject]
                    self.updateValuesInDatabase(values: values)
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    delegate?.updateUser()

                }
            })
            
        }
    }
    func updateValuesInDatabase(values: [String: AnyObject]) {
        if let id = Auth.auth().currentUser?.uid{
            print("Yes")
            print(values)
            let ref = Database.database().reference().child("users").child(id)
            ref.updateChildValues(values)
        }
        else {
            print("Error")

        }
        dismiss(animated: true, completion: nil)

    }

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
        deleteImageFromDatabase()
        uploadImageToDatabase()
    }
    
    
    //Cancel button for the image picker.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
        dismiss(animated: true, completion: nil)
    }
    //shows alert if you haven't got an upload image
    func showImageUploadAlert() -> Bool{
        var bool = true
        let alert = UIAlertController(title: "No profile image", message: "Would you like to upload a profile image, or not?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
            bool = false
        }))
        alert.addAction(UIAlertAction(title: "Yes, Let me!", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
            self.handleSelectProfileImageView()
            bool = true
        }
        ))
        self.present(alert, animated: true, completion: nil)
        return bool
    }
    
    
    func setupWithUser(user: User){
        if let profileImageUrl = user.profileImageUrl {
            profileImage.loadImageUsingCache(urlString: profileImageUrl)
            nameLabel.text = user.name
            emailLabel.text = user.email
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if user?.id == nil {
//            viewDidLoad()
//        }
//        else {
//            self.setupWithUser(user: user!)
//        }
//    }
}
