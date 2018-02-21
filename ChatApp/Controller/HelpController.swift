//
//  HelpController.swift
//  ChatApp
//
//  Created by Danny on 23/01/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit

class HelpController: UIViewController, UIWebViewDelegate {
    


    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false

        super.viewDidLoad()
        setupFields()
        view.backgroundColor = UIColor.white
//        let webV:UIWebView = UIWebView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//        let url = URL(fileURLWithPath: "https://www.youtube.com/embed/9bZkp7q19f0")
//        webV.loadRequest(url)
//        webV.delegate = self as UIWebViewDelegate
//        self.view.addSubview(webV)
    }
    
    ///Setup fields.
    func setupFields(){

    }

}

