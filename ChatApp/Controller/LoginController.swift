//
//  LoginController.swift
//  ChatApp
//
//  Created by Danny on 28/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
import Firebase


class LoginController: UIViewController, UITextFieldDelegate {
    
    var messagesController: MessagesController?
    var counter = [false, false, false]
    
    
    let inputsContainerView : UIView={
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let pictureContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: 100, height: 680)
        return scrollView
    }()
    
    //register Button
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r:106, g: 96, b: 120)
        button.setTitle("Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(r: 239, g: 239, b: 239), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    let hideKeyboardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hide Keyboard", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        return button
        
    }()
    
    //name TextField
    lazy var nameTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = UITextAutocapitalizationType.words
        tf.addTarget(self, action: #selector(nameValidation), for: .editingDidEnd)
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
        tf.addTarget(self, action: #selector(emailValidation), for: .editingDidEnd)
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
        tf.addTarget(self, action: #selector(passwordValidation), for: .editingDidEnd)
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
        imageView.layer.masksToBounds = true
        return imageView
    }()
    //segmented display
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    let clearProfilePictureImage: UIButton = {
        let button = UIButton()
        button.setTitle("Clear Image", for: .normal)
        button.addTarget(self, action: #selector(handleClearImage), for: .touchUpInside)
        button.setTitleColor(UIColor.purple, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var pictureContainerHeightAnchor: NSLayoutConstraint?
    var hideKeyboardHeightAnchor: NSLayoutConstraint?
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    @objc func passwordValidation(){
        if (passwordTextField.text) != nil{
            let password = passwordTextField.text?.count
            if(password! >= 7){
                if !counter[2] {
                    counter[2] = true
                }
            }
            else{
                counter[2] = false
            }
        }
        else {
            counter[2] = false
        }
        check()
    }
    
    @objc func handleLoginRegister(){
        if(loginRegisterSegmentedControl.selectedSegmentIndex == 0 ){
            handleLogin()
        }
        else{
            self.handleRegister()
        }
    }
    
    
    @objc func emailValidation(){
        if (emailTextField.text) != nil{
            let email = emailTextField.text?.count
            if(email! >= 7){
                if !counter[1] {
                    counter[1] = true
                }
            }
            else{
                counter[1] = false
            }
        }
        else {
            counter[1] = false
        }
        check()
    }
    
    @objc func nameValidation(){
        if (nameTextField.text) != nil{
            let name = nameTextField.text?.count
            if(name! >= 7){
                if !counter[0] {
                    counter[0] = true
                }
            }
            else{
                counter[0] = false
            }
        }
        else {
            counter[0] = false
        }
        check()
    }
    
    func check(){
        
        if loginRegisterSegmentedControl.selectedSegmentIndex==0 {
            if(counter[1] && counter[2]){
                loginRegisterButton.alpha = 1
                loginRegisterButton.isEnabled = true
            }
            else{
                loginRegisterButton.alpha = 0.5
                loginRegisterButton.isEnabled = false
            }
        }
        else {
            if(counter[1] && counter[2] && counter[0]){
                loginRegisterButton.alpha = 1
                loginRegisterButton.isEnabled = true
            }
            else{
                loginRegisterButton.alpha = 0.5
                loginRegisterButton.isEnabled = false
            }
        }
    }
    
    
    @objc func handleLogin(){
        print("handle login func")
        
        guard let email = emailTextField.text,  let password = passwordTextField.text else {
            print("Invalid data")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func handleClearImage(){
        profileImageUpload.image = UIImage(named: "defaultPic")
        clearProfilePictureImage.isHidden = true
        
    }
    func setupClearImage(){
        clearProfilePictureImage.topAnchor.constraint(equalTo: profileImageUpload.bottomAnchor, constant: 10).isActive = true
        clearProfilePictureImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        clearProfilePictureImage.isHidden = true
    }
    
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
        
        hideKeyboardHeightAnchor?.isActive = false
        hideKeyboardHeightAnchor = hideKeyboardButton.topAnchor.constraint(equalTo: loginRegisterSegmentedControl.bottomAnchor, constant: loginRegisterSegmentedControl.selectedSegmentIndex==0 ? 0: 195)
        
        hideKeyboardHeightAnchor?.isActive = true
        pictureContainerHeightAnchor?.isActive = true
        
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        profileImageUpload.image = UIImage(named: "defaultPic")
        loginRegisterButton.alpha = 0.5
        loginRegisterButton.isEnabled = false
        counter[0] = false
        counter[1] = false
        counter[2] = false
        handleClearImage()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add the inputs, button, and image into the view
        scrollView.addSubview(inputsContainerView)
        scrollView.addSubview(loginRegisterButton)
        scrollView.addSubview(logo)
        scrollView.addSubview(loginRegisterSegmentedControl)
        scrollView.addSubview(profileImageUpload)
        scrollView.addSubview(hideKeyboardButton)
        scrollView.addSubview(clearProfilePictureImage)
        pictureContainer.addSubview(clearProfilePictureImage)
        pictureContainer.addSubview(profileImageUpload)
        scrollView.addSubview(pictureContainer)
        view.addSubview(scrollView)
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
        setupProfilePic()
        setupScrollView()
        setupKeyboardButton()
        setupClearImage()
        setupPictureContainer()
    }
    
    func setupPictureContainer(){
        pictureContainer.topAnchor.constraint(equalTo: loginRegisterSegmentedControl.bottomAnchor, constant: 20).isActive = true
        pictureContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pictureContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        pictureContainer.heightAnchor.constraint(equalToConstant: 140).isActive = true
        pictureContainerHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        pictureContainerHeightAnchor?.isActive = true
    }
    
    func setupLoginRegisterSegmentedControl(){
        //x,y, width, height constraints
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.topAnchor.constraint(equalTo:scrollView.topAnchor, constant:25).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    func setupProfilePic(){
        //x, y, width, height
        profileImageUpload.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        profileImageUpload.topAnchor.constraint(equalTo: pictureContainer.topAnchor).isActive = true
        profileImageUpload.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageUpload.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    func setupKeyboardButton() {
        hideKeyboardButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        hideKeyboardButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        hideKeyboardButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        hideKeyboardHeightAnchor = hideKeyboardButton.topAnchor.constraint(equalTo:clearProfilePictureImage.bottomAnchor, constant: 5)
        hideKeyboardHeightAnchor?.isActive = true
    }
    
    
    func setupInputsContainerView() {
        //x,y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -24).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: hideKeyboardButton.bottomAnchor, constant: 10).isActive = true
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
    func setupLoginRegisterButton() {
        //x,y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    func setupProfileImageView(){
        //x,y, width, height constraints
        logo.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        logo.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 10).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 150).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    
    func setupScrollView(){
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        // Do any additional setup after loading the view
    }
    
    
    
    
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    //Hide keyboard when screen is touched
    @objc func hideKeyboard() {
        view.self.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red:r/255, green: g/255, blue: b/255, alpha:1)
    }
}
