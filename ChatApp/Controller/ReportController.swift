//
//  ReportController.swift
//  ChatApp
//
//  Created by Danny on 22/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit
import Firebase
class ReportController: UIViewController {
    // MARK: - Constants
   
    ///Page title.
    let pageTitle : UITextView = {
        let name = UITextView()
        name.allowsEditingTextAttributes = false
        name.isEditable = false
        name.isUserInteractionEnabled = false
        name.translatesAutoresizingMaskIntoConstraints = false
        name.textAlignment = .center
        name.font = UIFont(name: "arial", size: 20)
        name.backgroundColor = UIColor.clear
        name.textColor = UIColor.black
        return name
    }()
    
    ///Reason for reporting the user text field.
    let reasonForReportingTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("reasonForReporting", comment: "Reason for placeholer")
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont(name: "arial", size: 10)
        tf.textColor = UIColor.black
        tf.backgroundColor = UIColor.white
        return tf
    }()
    
    ///Report button.
    let reportButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("reportTitle", comment: "Title for button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(handleReport), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Variables
    ///The user who is being reported.
    var user : User? {
        didSet {
            pageTitle.text = NSLocalizedString("reportTitle", comment: "report title") + " " + (user?.name!)!
        }
    }
    
    //MARK: - View initialisation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 233, g: 175,b: 50)
        // Do any additional setup after loading the view.
        view.addSubview(pageTitle)
        view.addSubview(reasonForReportingTextField)
        view.addSubview(reportButton)
        setupFields()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: NSLocalizedString("backText", comment: "back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    //MARK: - Setup
    
    ///Sets up view constraints.
    func setupFields() {
        pageTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 75).isActive = true
        pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageTitle.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        pageTitle.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        reasonForReportingTextField.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 20).isActive = true
        reasonForReportingTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reasonForReportingTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        reasonForReportingTextField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        reportButton.topAnchor.constraint(equalTo: reasonForReportingTextField.bottomAnchor, constant: 20).isActive = true
        reportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        reportButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        reportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
    }
    
    
    
    //MARK: - Interaction
    ///Called when the submit report button is pressed.
    @objc func handleReport() {
        guard let id = Auth.auth().currentUser?.uid else {
            return
        }
        let values = ["UserReported": user?.id!, "Reporter": id, "Comment": reasonForReportingTextField.text!] as [String : Any]
        
        let ref = Database.database().reference().child("Reports").child((user?.id)!).child(id)
        ref.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if  err != nil {
                return
            }
            self.sucessfulReport()
        })
        
    }
    
    ///Back button for NavigationBarItem
    @objc func back(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Alert
    
    /// Called when a report has been submitted successfully.
    func sucessfulReport(){
        let alert = UIAlertController(title: NSLocalizedString("reportTitle", comment: "Title"), message: NSLocalizedString("reportBody", comment: "Report body"), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (x) in
            alert.dismiss(animated: true, completion: nil)
            self.back(sender: self.navigationItem.leftBarButtonItem!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
   
    //MARK: - Keyboard
    
    ///Hides Keyboard when called.
    @objc func hideKeyboard() {
        view.self.endEditing(true)
    }
    
    ///Hides the keyboard when the return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
  
    
}

