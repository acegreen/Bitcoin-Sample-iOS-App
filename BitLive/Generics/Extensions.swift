//
//  Extensions.swift
//  BitLive
//
//  Created by Ace Green on 7/14/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import UIKit
import Foundation

extension Collection {
    func find(_ predicate: (Self.Iterator.Element) throws -> Bool) rethrows -> Self.Iterator.Element? {
        return try index(where: predicate).map({self[$0]})
    }
}

extension Array {
    
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    func get(_ index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
    
    mutating func moveItem(fromIndex oldIndex: Index, toIndex newIndex: Index) {
        insert(remove(at: oldIndex), at: newIndex)
    }
    
    func reduceWithIndex<T>(_ initial: T, combine: (T, Int, Array.Iterator.Element) throws -> T) rethrows -> T {
        var result = initial
        for (index, element) in self.enumerated() {
            result = try combine(result, index, element)
        }
        return result
    }
}

extension Array where Element: Equatable {
    
    mutating func removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func removeObjectsInArray(_ array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}

extension Int {
    
    func suffixNumber() -> String {
        
        var num: Double = Double(self)
        let sign = ((num < 0) ? "-" : "" )
        
        num = fabs(num)
        
        if (num < 1000.0) {
            return "\(sign)\(Int(num))"
        }
        
        let exp:Int = Int(log10(num) / 3.0 )
        
        let units:[String] = ["K","M","G","T","P","E"]
        
        let roundedNum:Int = Int(round(10 * num / pow(1000.0,Double(exp))) / 10)
        
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
}

extension Double {
    
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    
    func URLEncodedString() -> String? {
        let escapedString = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return escapedString
    }
    
    func decodeEncodedString() -> String? {
        
        let encodedData = self.data(using: String.Encoding.utf8)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject
        ]
        
        do {
            
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            
            return attributedString.string
            
        } catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
            
            return nil
            
        }
    }
    
    func replace(_ target: String, withString: String) -> String {
        
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return self.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor?  {
        get {
            return self.borderColor
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func imageFromLayer() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension UISegmentedControl {
    
    func insertSegmentWithMultilineTitle(_ title: String, atIndex segment: Int, animated: Bool) {
        let label: UILabel = UILabel()
        label.text = title
        label.textColor = self.tintColor
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.sizeToFit()
        self.insertSegment(with: label.imageFromLayer(), at: segment, animated: animated)
    }
    
    func insertSegmentWithMultilineAttributedTitle(_ attributedTitle: NSAttributedString, atIndex segment: Int, animated: Bool) {
        let label: UILabel = UILabel()
        label.attributedText = attributedTitle
        label.numberOfLines = 0
        label.sizeToFit()
        self.insertSegment(with: label.imageFromLayer(), at: segment, animated: animated)
    }
    
    func segmentWithMultilineAttributedTitle(_ attributedTitle: NSAttributedString, atIndex segment: Int, animated: Bool) {
        let label: UILabel = UILabel()
        label.attributedText = attributedTitle
        label.numberOfLines = 0
        label.sizeToFit()
        
        self.setImage(label.imageFromLayer(), forSegmentAt: segment)
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    class func colorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension URL {
    
    var fragments: [String: String] {
        var results = [String: String]()
        if let pairs = self.fragment?.components(separatedBy: "&") , pairs.count > 0 {
            for pair: String in pairs {
                if let keyValue = pair.components(separatedBy: "=") as [String]? {
                    results.updateValue(keyValue[1], forKey: keyValue[0])
                }
            }
        }
        return results
    }
    
    func parseQueryString (_ urlQuery: String, firstSeperator: String, secondSeperator: String) -> NSDictionary? {
        
        let dict: NSMutableDictionary = NSMutableDictionary()
        
        let pairs = urlQuery.components(separatedBy: firstSeperator)
        
        for pair in pairs {
            
            let elements: [String] = pair.components(separatedBy: secondSeperator)
            
            guard let key = (elements[0]).removingPercentEncoding,
                let value = (elements[1]).removingPercentEncoding
                else { return dict }
            
            dict.setObject(value, forKey: key as NSCopying)
        }
        
        return dict
    }
}

extension UIImage {
    
    enum AssetIdentifier: String  {
        
        case bitcoin = "bitcoin"
        case bitcoin_large = "bitcoin_large"
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
    
    var rounded: UIImage {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = size.height < size.width ? size.height/2 : size.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    
    var circle: UIImage {
        let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

extension UIViewController {
    func isBeingPresentedInFormSheet() -> Bool {
        if let presentingViewController = presentingViewController {
            return traitCollection.horizontalSizeClass == .compact && presentingViewController.traitCollection.horizontalSizeClass == .regular
        }
        return false
    }
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}
