//
//  Extensions.swift
//  ChatApp
//
//  Created by Danny on 31/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit
///Stores cache of the profile images.
let imageCache = NSCache<AnyObject, AnyObject>()


//Ease of use for setting a colour
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat){
        self.init(red:r/255, green: g/255, blue: b/255, alpha:1)
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat){
        self.init(red:r/255, green: g/255, blue: b/255, alpha:a)
    }
    static let niceOrange: UIColor = UIColor(r: 255, g: 184, b: 77, a: 1)
    static let niceBlue: UIColor = UIColor(r: 0, g: 136, b: 204, a: 0.5)
}



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

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[Range(start ..< end)])
    }
    
    func stringToChars(String: String) -> [Character] {
        var chars = [Character]()
      
        for char in String {
            chars.append(char)
        }
        return chars
    }
    var nsrange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

}

extension Character {
    ///Gets the ascii value of the character.
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
    /**
     Takes a character and coverts it into a string containing just that character.
     - Returns: Returns the string.
     */
    func charToString() -> String{
        var string = ""
        string.append(self)
        return string
    }
}

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }

}
