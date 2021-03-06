//
//  Extensions.swift
//  ChatApp
//
//  Created by Danny on 31/12/2017.
//  Copyright © 2017 Danny. All rights reserved.
//

import UIKit

import Firebase
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
    
    static let niceOrange: UIColor = UIColor(r: 255, g: 127, b: 80, a: 1)
    static let niceOtherOrange: UIColor = UIColor(r: 255, g: 99, b: 71, a: 1)
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
    
    var hourBefore: Date {
        print("Hour before: \(self.addingTimeInterval(-3600))")
//        return Calendar.date(from: self.addingTimeInterval(-3600))!
        return self.addingTimeInterval(-3600)
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
}


extension UIViewController: UITextFieldDelegate{
    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.purple
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
     
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    @objc func donePressed(){
        view.endEditing(true)
    }
    
   

}

///Posting error protocol. Protocols are used to make a class abide by certain things, and make the class implement the methods that are defined there.
protocol postError {
    func postError(error: Error)
}

extension EventsController: postError {
    /**
     Uploads any errors to the database for examination.
     - Parameters:
         - error: The error code which is called.
     */
    func postError(error: Error){
        let ref = Database.database().reference().child("Error").child("EventsController").child(NSUUID().uuidString)
        let values = ["Error Description": error.localizedDescription]
        ref.updateChildValues(values as [String: AnyObject])
    }
}

extension MyEventsController: postError {
    /**
     Uploads any errors to the database for examination.
     - Parameters:
         - error: The error code which is called.
     */
    func postError(error: Error){
        let ref = Database.database().reference().child("Error").child("MyEventsController").child(NSUUID().uuidString)
        let values = ["Error Description": error.localizedDescription]
        ref.updateChildValues(values as [String: AnyObject])
    }
}


extension CalendarController: postError {
    /**
     Uploads any errors to the database for examination.
     - Parameters:
         - error: The error code which is called.
     */
    func postError(error: Error){
        let ref = Database.database().reference().child("Error").child("CalendarController").child(NSUUID().uuidString)
        let values = ["Error Description": error.localizedDescription]
        ref.updateChildValues(values as [String: AnyObject])
    }
}

extension Bool {
    mutating func negate() {
        self = !self
    }
}

