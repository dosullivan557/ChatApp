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
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)

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
            profileImageUpload.image = selectedImage
        }
        clearProfilePictureImage.isHidden = false

        dismiss(animated: true, completion: nil)
    }

    
   
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    //handleRegister
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: ({
            (user: Firebase.User?, error) in
            if  error != nil {
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
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]){
        //save info
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if  err != nil {
                return
            }
            self.messagesController?.fetchUser()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
}
