//
//  LoginController.swift
//  ChatApp
//
//  Created by Danny on 28/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Variables
    var messagesController: MessagesController?
    
    //constants
    //container for text fields
    let inputsContainerView : UIView={
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    //picture container
    let pictureContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.niceOrange
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    
    //register Button
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.niceBlue
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(r: 239, g: 239, b: 239), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)

        return button
    }()
    
    
    //name TextField
    lazy var nameTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = UITextAutocapitalizationType.words
        tf.delegate = self
        return tf
    }()
    //seperator
    let nameSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 239, g: 239, b: 239)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    //email TextField
    lazy var emailTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = UITextAutocapitalizationType.none
        tf.delegate = self
        return tf
    }()
    //seperator
    let emailSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 239, g: 239, b: 239)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    //password TextField
    lazy var passwordTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        return tf
    }()
    
    //Register page logo image
    let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Icon-App-29x29")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    //upload profileImage
    lazy var profileImageUpload: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "defaultPic")
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 50
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    //segmented display
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: UIControlState.selected)
        sc.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black], for: UIControlState.normal)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.niceBlue
        
//        sc.backgroundColor = UIColor.niceBlue
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    //clear image button
    let clearProfilePictureImage: UIButton = {
        let button = UIButton()
        button.setTitle("Clear Image", for: .normal)
        button.addTarget(self, action: #selector(handleClearImage), for: .touchUpInside)
        button.setTitleColor(UIColor.niceBlue, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    //height anchor for picture container
    var pictureContainerHeightAnchor: NSLayoutConstraint?
    //height anchor for input container
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    //height anchor for name textfield
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    //height anchor for email textfield
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    //height anchor for password textfield
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgotten Password?", for: .normal)
        button.addTarget(self, action: #selector(handlePasswordReset), for: .touchUpInside)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.niceOrange
        //add the inputs, button, and image into the view
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(logo)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(profileImageUpload)
        view.addSubview(clearProfilePictureImage)
        view.addSubview(resetButton)
        pictureContainer.addSubview(clearProfilePictureImage)
        pictureContainer.addSubview(profileImageUpload)
        view.addSubview(pictureContainer)
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupLogo()
        setupLoginRegisterSegmentedControl()
        setupProfilePic()
        setupClearImage()
        setupPictureContainer()
        setupResetPasswordButton()
    }
    func setupResetPasswordButton(){
        resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resetButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 35).isActive = true
    }
    
    ///Shows the view for restting a users password.
    @objc func handlePasswordReset(){
        let vc = PasswordResetController()
        show(vc, sender: self)
    }
    ///Setup the picture container, which contains the image uploader and the clear image button.
    func setupPictureContainer(){
        pictureContainer.topAnchor.constraint(equalTo: loginRegisterSegmentedControl.bottomAnchor, constant: 10).isActive = true
        pictureContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pictureContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        pictureContainer.heightAnchor.constraint(equalToConstant: 140).isActive = true
        pictureContainerHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        pictureContainerHeightAnchor?.isActive = true
    }
    
    ///Setup the login register segmented display constraints.
    func setupLoginRegisterSegmentedControl(){
        //x,y, width, height constraints
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.topAnchor.constraint(equalTo:view.topAnchor, constant: 30).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    ///Setup profile picture constraints.
    func setupProfilePic(){
        //x, y, width, height
        profileImageUpload.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageUpload.topAnchor.constraint(equalTo: pictureContainer.topAnchor).isActive = true
        profileImageUpload.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageUpload.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    
    ///Setup the container for the name, email and password constraints.
    func setupInputsContainerView() {
        //x,y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: pictureContainer.bottomAnchor, constant: 10).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeperatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        //x,y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo:inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo:inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo:inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        //x,y, width, height constraints
        nameSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //x,y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo:inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo:nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo:inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        //x,y, width, height constraints
        emailSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //x,y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo:inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo:emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo:inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    ///Setup the login and register button constraints.
    func setupLoginRegisterButton() {
        //x,y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 10).isActive = true
        //        loginRegisterButton.bottomAnchor.constraint(equalTo: logo.topAnchor).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    ///Setup the logo constraints.
    func setupLogo(){
        //x,y, width, height constraints
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //        logo.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor).isActive = true
        logo.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 150).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    ///Hide keyboard when screen is touched.
    @objc func hideKeyboard() {
        view.self.endEditing(true)
    }
    //Hides the keyboard when the return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
   
    ///Checks whether the segmented display is equal to login or register, and calls either the [handleLogin()]() or [handleRegister]().
    @objc func handleLoginRegister(){
        if(loginRegisterSegmentedControl.selectedSegmentIndex == 0 ){
            handleLogin()
        }
        else{
            self.handleRegister()
        }
    }
    
    ///Handles a login of a user.
    @objc func handleLogin(){
        print("handle login func")
        
        guard let email = emailTextField.text,  let password = passwordTextField.text else {
            showAlert(title: "Invalid data", message: "Invalid email or Password")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.firebaseAuth(error: error!)
                return
            }
            
            self.messagesController?.fetchUser()
            self.dismiss(animated: true, completion: nil)
        }
    }

    /**
     All possible errors for logging in or registering that could be thrown by firebase are passed into here and shows an alert box which notifies the user of the error. An example of how to use it correctly is shown below.
     
                if error != nil{
                     self.firebaseAuth(error: error!)
                     return
                 }
     - Parameters:
         - error: The error code which has been returned.
     */
    func firebaseAuth(error: Error){
        if let errCode = AuthErrorCode(rawValue: error._code) {
            if loginRegisterSegmentedControl.selectedSegmentIndex == 1 {
                if nameTextField.text?.count == 0 {
                    self.showAlert(title: "Invalid Name", message: "Please enter your name and try again!")
                    return
                }
            }
            if emailTextField.text?.count == 0{
                self.showAlert(title: "Invalid Email", message: "Please enter a valid email address and try again!")
                return
            }
            
            if passwordTextField.text?.count == 0 {
                self.showAlert(title: "Empty Password Field", message: "Please enter a valid password and try again.")
                return
            }
            
        switch errCode {
        case AuthErrorCode.invalidEmail:
            self.showAlert(title: "Invalid Email", message: "Please insert a valid email address, and try again!")
            return
        case AuthErrorCode.emailAlreadyInUse:
            self.showAlert(title: "Email Already In Use", message: "Email address is already in use, please insert a different one, or login!.")
            return
            
        case AuthErrorCode.weakPassword:
            self.showAlert(title: "Weak Password", message: "Please insert a more secure password and try again.")
            return
            
        case AuthErrorCode.userNotFound:
            self.showAlert(title: "User Does Not Exist", message: "The user with the email \"\(emailTextField.text!)\" does not exist, Please register for an account!")
            return
            
        case AuthErrorCode.wrongPassword:
            self.showAlert(title: "Wrong Password", message: "Please check the password and try again.")
            return
        default:
            self.showAlert(title: "Oops", message: "There was an error, please try again later!")
            return
            }
        }
    }
    /// Clears the a profile image that has been added, and replaces it with the defaultPic.
    @objc func handleClearImage(){
        profileImageUpload.image = UIImage(named: "defaultPic")
        clearProfilePictureImage.isHidden = true
        
    }
    ///Setup the clear image constraints.
    func setupClearImage(){
        clearProfilePictureImage.topAnchor.constraint(equalTo: profileImageUpload.bottomAnchor, constant: 10).isActive = true
        clearProfilePictureImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        clearProfilePictureImage.isHidden = true
    }
    ///Called when the segmented display is changed. This changes certain details in the page, such as hiding the name field for the register tab.
    @objc func handleLoginRegisterChange(){
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //change height of InputContainerView
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex==0 ? 100: 150
        //change heightof nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo:inputsContainerView.heightAnchor, multiplier:loginRegisterSegmentedControl.selectedSegmentIndex==0 ? 0: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //change height of emailTextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo:inputsContainerView.heightAnchor, multiplier:loginRegisterSegmentedControl.selectedSegmentIndex==0 ? 1/2: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //change height of passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo:inputsContainerView.heightAnchor, multiplier:loginRegisterSegmentedControl.selectedSegmentIndex==0 ? 1/2: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        //hide upload image and clear image data
        pictureContainerHeightAnchor?.isActive = false
        pictureContainerHeightAnchor = pictureContainer.heightAnchor.constraint(equalTo:inputsContainerView.heightAnchor, multiplier:loginRegisterSegmentedControl.selectedSegmentIndex==0 ? 0: 1)
        
    
        pictureContainerHeightAnchor?.isActive = true
        
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        profileImageUpload.image = UIImage(named: "defaultPic")

        resetButton.alpha = (loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1 : 0)
        
        handleClearImage()
        
    }
    
    
    ///Image picker. Shown when the profile image view is tapped.
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = (self as? UIImagePickerControllerDelegate as! UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        
    }

    //By creating the method in this way, I was able to reduce a lot of extra code by just calling this function when its just a simple alert.
    /**
     Shows alerts for the given message and title. Calls [createAlertButton]() to add in the relevant buttons onto the alert.
     - Parameters:
         - title: The title to set for the alert box.
         - message: The message to set for the alert box.

     */
    
    func showAlert(title: String, message: String) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert = createAlertButton(title: title, alert: alert)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //Adds the relevant buttons to the alert box.
    /**
     Adds the relevant buttons to the alert box.
     - Parameters:
         - title: The title of the alert, so I can use it to determine what the meaning of the alert is, and therefore add in the relevant buttons.
         - alert: The alert box to add the buttons to.
      - Returns: The alert box with the relevant buttons added.
     */

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
    /**
     Shows alert if you haven't got an upload image. If the user doesn't wish to upload one, then they can say no, otherwise they get a change to change their mind and add one.
     - Returns: A boolean to use as a flag to get the users response. This determines whether to continue the registering or to stop and allow the user to upload one.
     */
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
    
    /**
     Is called to verify the whether the password is valid before sending it to Firebase.
     - Parameters:
         - testStr: The string to test.
     - Returns: A boolean value to say whether the password is valid.
     */
    func isValidPassword(testStr: String) -> Bool{
        let length = testStr.count
        
        return length >= 7
        
    }
    
    /**
     Is called to verify the whether the email is valid locally before sending it to Firebase. Uses a regular expression to check the email typed in abides by the conventions.
     - Parameters:
         - testStr: The string to test.
         - Returns: A boolean value to say whether the email is valid.
     */
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    //handleRegister
    /**
     Handles the registration of the user. Checks the information is valid locally, and then checks it against Firebase Authentication to authenticate it there as well.
     */
    func handleRegister(){
        guard let email = emailTextField.text else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address")
            return
        }
        guard let password = passwordTextField.text else{
            showAlert(title: "Invalid Password", message: "Please enter a valid password")
            return
        }
        guard let name = nameTextField.text else {
            showAlert(title: "Invalid Name", message: "Please enter a valid name")
            return
        }
        
        if (!isValidEmail(testStr: email)){
            showAlert(title: "Invalid Email", message: "Please enter a valid email address")
            return
        }
        if(!isValidPassword(testStr: password)){
            showAlert(title: "Invalid Password", message: "Please enter a valid password")
            return
        }
        
        if self.profileImageUpload.image == UIImage(named: "defaultPic") {
             let bool = self.showImageUploadAlert()
            print(bool)
            if bool==true {
                return
            }
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
    
    /**
     Registers the user into the database upon registering.
     - Parameters:
     - uid: The unique identifier for the user.
     - values: A dictionary of `[String: AnyObject]` to upload to the database. This contains all of the information to upload.
     */
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]){
        //save info
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if  err != nil {
                return
            }
            let settingsRef = Database.database().reference().child("user-settings").child(uid)
            let settingsValues = ["Greeting" : "Hey :O", "YourColor" : "Green", "TheirColor" : "Pink"]
            settingsRef.updateChildValues(settingsValues, withCompletionBlock: { (err, ref) in
                if err != nil {
                    return
                }
            })
            self.messagesController?.fetchUser()
            self.dismiss(animated: true, completion: nil)
        })
    }
    
}
