//
//  Extensions.swift
//  ChatApp
//
//  Created by Danny on 31/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    
    //loads the user's image from cache, and if it cannot find it there, it will download it from the database.
    func loadImageUsingCache(urlString: String?){
        self.image = nil
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            self.image = cachedImage
            return
        }
        if let profileImageUrl = urlString {
            print("pass")
            let url = URL(string: profileImageUrl)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
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
