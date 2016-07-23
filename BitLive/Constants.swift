//
//  Constants.swift
//  BitLive
//
//  Created by Ace Green on 7/14/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import UIKit
import Foundation

public class Constants {
    
    public static var window: UIWindow? {
        get {
            return UIApplication.sharedApplication().keyWindow
        }
    }
    
    public static let current = UIDevice.currentDevice()
    public static let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier
    public static let infoDict = NSBundle.mainBundle().infoDictionary
    public static let AppVersion = infoDict!["CFBundleShortVersionString"]!
    public static let BundleVersion = infoDict!["CFBundleVersion"]!
    
    public static let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    public static let payloadShort = "Version: \(AppVersion) (\(BundleVersion)) \n Copyright © 2016"
    public static let payload = [ "BundleID" : infoDict!["CFBundleIdentifier"]!,
        "AppVersion" : AppVersion,
        "BundleVersion" : BundleVersion,
        "DeviceModel" : current.model,
        "SystemName" : current.systemName,
        "SystemVersion" : current.systemVersion ]
    
    public static let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
    
    public static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    public static let app = UIApplication.sharedApplication()
    static let appDel:AppDelegate = app.delegate as! AppDelegate
    
    public static let goldColor: UIColor = UIColor(red: 245, green: 192, blue: 24)
    
    public enum Errors: ErrorType {
        case NoInternetConnection
        case ErrorQueryingForData
        case QueryDataEmpty
        case ErrorParsingData
        case URLEmpty
        
        public func message() -> String {
            switch self {
            case .NoInternetConnection:
                return "No internet connection!\nMake sure your device is connected"
            case .ErrorQueryingForData:
                return  "Oops! We ran into an issue querying for data"
            case .QueryDataEmpty:
                return "There seems to be no data at the moment"
            case .ErrorParsingData:
                return "Oops! there was an error while grabbing data"
            case .URLEmpty:
                return "We ran into an issue querying for data"
            }
        }
        static let allErrors = [NoInternetConnection, ErrorQueryingForData, QueryDataEmpty, ErrorParsingData, URLEmpty]
    }
}
