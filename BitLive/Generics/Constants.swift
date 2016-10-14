//
//  Constants.swift
//  BitLive
//
//  Created by Ace Green on 7/14/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import UIKit
import Foundation

open class Constants {
    
    open static var window: UIWindow? {
        get {
            return UIApplication.shared.keyWindow
        }
    }
    
    open static let current = UIDevice.current
    open static let bundleIdentifier = Bundle.main.bundleIdentifier
    open static let infoDict = Bundle.main.infoDictionary
    open static let AppVersion = infoDict!["CFBundleShortVersionString"]!
    open static let BundleVersion = infoDict!["CFBundleVersion"]!
    
    open static let userDefaults: UserDefaults = UserDefaults.standard
    
    open static let payloadShort = "Version: \(AppVersion) (\(BundleVersion)) \n Copyright © 2016"
    open static let payload = [ "BundleID" : infoDict!["CFBundleIdentifier"]!,
        "AppVersion" : AppVersion,
        "BundleVersion" : BundleVersion,
        "DeviceModel" : current.model,
        "SystemName" : current.systemName,
        "SystemVersion" : current.systemVersion ]
    
    open static let settingsURL = URL(string: UIApplicationOpenSettingsURLString)
    
    open static let storyboard = UIStoryboard(name: "Main", bundle: nil)
    open static let app = UIApplication.shared
    static let appDel:AppDelegate = app.delegate as! AppDelegate
    
    open static let goldColor: UIColor = UIColor(red: 245, green: 192, blue: 24)
    
    public enum Errors: Error {
        case noInternetConnection
        case errorQueryingForData
        case queryDataEmpty
        case errorParsingData
        case urlEmpty
        
        public func message() -> String {
            switch self {
            case .noInternetConnection:
                return "No internet connection!\nMake sure your device is connected"
            case .errorQueryingForData:
                return  "Oops! We ran into an issue querying for data"
            case .queryDataEmpty:
                return "There seems to be no data at the moment"
            case .errorParsingData:
                return "Oops! there was an error while grabbing data"
            case .urlEmpty:
                return "We ran into an issue querying for data"
            }
        }
        static let allErrors = [noInternetConnection, errorQueryingForData, queryDataEmpty, errorParsingData, urlEmpty]
    }
}
