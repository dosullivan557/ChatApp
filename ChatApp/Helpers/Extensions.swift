//
//  Extensions.swift
//  ChatApp
//
//  Created by Danny on 31/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
//Stores cache of the profile images.
let imageCache = NSCache<AnyObject, AnyObject>()

//Extended UIImageView to add this functionality
extension UIImageView {
    
    /**
      Loads the user's image from cache, and if it cannot find it there, it will download it from the database. Once it is downloaded, it will set the image.
      - Parameters:
           - urlString: The url of the users profile picture to load, whih is stored inside of the user object.
     */
    func loadImageUsingCache(urlString: String?){
        self.image = nil
        //Check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        //Download the image from Firebase Storage
        if let profileImageUrl = urlString {
            print("pass")
            let url = URL(string: profileImageUrl)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                //If there was an error downloading it, such as cannot find image, set the image to the empty profile image silhouette.
                if error != nil{
                    self.image = UIImage(named:"defaultPic")
                    return
                }
                DispatchQueue.main.async(){
                    if let downloadedImage = UIImage(data: data!){
                        self.image = downloadedImage
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    }
        
                }
            }).resume()
        }
    }
}
