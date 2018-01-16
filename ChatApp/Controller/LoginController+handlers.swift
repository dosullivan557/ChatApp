//
//  LoginController+handlers.swift
//  ChatApp
//
//  Created by Danny on 30/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Image picker.
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        print("picker")
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)

    }
    func pickImage(){
        print("Picker 2")
        let picker = UIImagePickerController()
        print("picker")
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    func showAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert = createAlertButton(title: title, alert: alert)
        
        self.present(alert, animated: true, completion: nil)
    }
    func createAlertButton(title: String, alert: UIAlertController) -> UIAlertController {
        if title.contains("Invalid") {
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (x) in
                alert.dismiss(animated: true, completion: nil)
            }))
        }
        else if title.contains("Profile"){
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (x) in
                alert.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "No, Let me!", style: UIAlertActionStyle.default, handler: { (x) in
                alert.dismiss(animated: true, completion: {
                    self.handleSelectProfileImageView()
                })

            }))
        }
            else {
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (x) in
                    alert.dismiss(animated: true, completion: nil)
                }
                ))
            }

        return alert
    }
    
    //Choose image from image picker.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFP: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"]{
            selectedImageFP = editedImage as? UIImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"]{
            selectedImageFP = originalImage as? UIImage
        }
        if let selectedImage = selectedImageFP {
            profileImageUpload.image = selectedImage
        }
        clearProfilePictureImage.isHidden = false

        dismiss(animated: true, completion: nil)
    }

    
   //Cancel button for the image picker.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    func showImageUploadAlert() {
        
        let alert = UIAlertController(title: "No profile image", message: "Would you like to upload a profile image, or not?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
            }))
        alert.addAction(UIAlertAction(title: "Yes, Let me!", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
                self.pickImage()
                return
            }
        ))
        self.present(alert, animated: true, completion: nil)

    }

    
    //handleRegister
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        if self.profileImageUpload.image == UIImage(named: "defaultPic") {
            self.showImageUploadAlert()
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: ({
            (user: Firebase.User?, error) in
            if  error != nil {
                self.firebaseAuth(error: error!)
                return

            }
            guard let uid = user?.uid else {
                return
            }
            
            //successfully authenticated
            //save image

            let storageRef = Storage.storage().reference().child("profileImages").child("\(NSUUID().uuidString).png")
            if let uploadData = UIImagePNGRepresentation(self.profileImageUpload.image!){
                storageRef.putData(uploadData, metadata: nil, completion: {
                    (metadata, error) in
                    if error != nil{
                        self.firebaseAuth(error: error!)
                        return
                    }
                    if let profileUrl = metadata?.downloadURL()?.absoluteString{
                    let values = ["name": name, "email": email, "profileImageUrl": profileUrl]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                })
            
            }
            

        })
        )
        
    }
    
    //Registers the user into the database upon registering.
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]){
        //save info
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if  err != nil {
                return
            }
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
}
