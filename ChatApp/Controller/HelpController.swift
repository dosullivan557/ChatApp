//
//  HelpController.swift
//  ChatApp
//
//  Created by Danny on 23/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit

class HelpController: UIViewController, UIWebViewDelegate {
    // MARK: - Constants
    let uiview : UIWebView = {
        let view = UIWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let activityInd = ActivityController()

    
    // MARK: - Variables
    var tuple : Tuple? {
        didSet {
            activityInd.showActivityIndicatory(uiView: view)
            self.navigationItem.title = tuple?.getStringOne()
            getVideo(videoCode: (tuple?.getStringTwo())!)
        }
    }
    //MARK: - View initialisation
    override func viewDidLoad() {
        view.addSubview(uiview)
        super.viewDidLoad()
        setupFields()
//        UIWebViewDelegate. = self
        uiview.delegate = self
        view.backgroundColor = UIColor.white
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("finished")
        activityInd.finishAnimating(uiView: view)
    }
    
    //MARK: - Setup
    ///Setup fields.
    func setupFields(){

        uiview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        uiview.heightAnchor.constraint(equalToConstant: 150).isActive = true
        uiview.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        uiview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func getVideo(videoCode: String) {
        let url = URL(string: "https://www.youtube.com/embed/\(videoCode)")
        uiview.loadRequest(URLRequest(url: url!))
        
    }
    
}

