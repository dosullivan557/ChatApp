//
//  HelpController.swift
//  ChatApp
//
//  Created by Danny on 23/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit

//QuadTuple<Name, link, description, Steps>


class HelpController: UIViewController, UIWebViewDelegate {
    // MARK: - Constants
    let uiview : UIWebView = {
        let view = UIWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black
        return view
    }()
    
    
    let activityInd = ActivityController()

    let descriptionField: UITextView = {
        let tf = UITextView()
        tf.isEditable = false
        tf.allowsEditingTextAttributes = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    let listField: UITextView = {
        let tf = UITextView()
        tf.layer.borderColor = UIColor.black.cgColor
        tf.layer.borderWidth = 1
        tf.isEditable = false
        tf.allowsEditingTextAttributes = false
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // MARK: - Variables
    var quadTuple : QuadStructure<String, String, String, String>? {
        didSet {
            self.navigationItem.title = quadTuple?.getObjectOne().getObjectOne()
            getVideo(videoCode: (quadTuple?.getObjectOne().getObjectTwo())!)
        }
    }
    //MARK: - View initialisation
    override func viewDidLoad() {
        view.addSubview(uiview)
        view.addSubview(descriptionField)
        view.addSubview(listField)

        //        print("finished")
        super.viewDidLoad()
        setupFields()
        uiview.delegate = self
        view.backgroundColor = UIColor.white
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        //        activityInd.showActivityIndicatory(uiView: view)
        descriptionField.text = quadTuple?.getObjectTwo().getObjectOne()
        listField.text = quadTuple?.getObjectTwo().getObjectTwo()

        activityInd.showActivityIndicatory(uiView: view)
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityInd.finishAnimating(uiView: view)


    }
    
    //MARK: - Setup
    ///Setup fields.
    func setupFields(){
//        uiview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        uiview.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        uiview.heightAnchor.constraint(equalToConstant: 150).isActive = true
        uiview.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        uiview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        descriptionField.topAnchor.constraint(equalTo: uiview.bottomAnchor).isActive = true
        descriptionField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        descriptionField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        descriptionField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        listField.topAnchor.constraint(equalTo: descriptionField.bottomAnchor).isActive = true
        listField.heightAnchor.constraint(equalToConstant: 175).isActive = true
        listField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        listField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func getVideo(videoCode: String) {
        let url = URL(string: "https://www.youtube.com/embed/\(videoCode)")
        uiview.loadRequest(URLRequest(url: url!))
    }

}
