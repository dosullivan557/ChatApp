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
    func loadImageUsingCache(urlString: String?){
        self.image = nil
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            print("image found in cache")
            self.image = cachedImage
            return
        }
        print("Image redownloaded")
        if let profileImageUrl = urlString {
            print("pass")
            let url = URL(string: profileImageUrl)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil{
                    print("failed downloading")
                    return
                }
                DispatchQueue.main.async(){
                    if let downloadedImage = UIImage(data: data!){
                        imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    }
        
                }
            }).resume()
        }
    }
}
