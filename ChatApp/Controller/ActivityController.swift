//
//  ActivityController.swift
//  ChatApp
//
//  Created by Danny on 11/03/2018.
//  Copyright © 2018 Danny. All rights reserved.
//

import UIKit

class ActivityController: UIViewController {
    //MARK: - Constants
    ///The activity indicator.
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    ///The background view.
    let loadingView: UIView = UIView()
    ///The container of all of the subviews.
    let container: UIView = UIView()

    //MARK: - View initialisation

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tag = 1
    }

    //MARK: - Activity Indicator

    
    /**
     Shows the activity indicator, and starts the animation.
     - Parameters:
         - uiView : The view to add the activity indicator to.
     */
    func showActivityIndicatory(uiView: UIView) {
        container.frame = uiView.frame
        container.center = uiView.center
        
        loadingView.frame = CGRect.init(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor.init(r: 196, g: 196, b: 196)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        actInd.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint.init(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        uiView.alpha = 0.5
        
        actInd.startAnimating()
    }
    
    /**
     Finishes the activity indicator's animation.
     - Parameters:
         - uiView : the view to add the activity indicator to.
     */
    func finishAnimating(uiView: UIView) {
        uiView.alpha = 1
        actInd.stopAnimating()
        container.removeFromSuperview()
    }
}
