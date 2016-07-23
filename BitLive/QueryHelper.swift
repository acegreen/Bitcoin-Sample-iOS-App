//
//  QueryHelper.swift
//  BitLive
//
//  Created by Ace Green on 7/14/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import UIKit

public class QueryHelper {
    
    static let sharedInstance = QueryHelper()
    
    public func queryWith(queryString: String, completionHandler: (result: () throws -> NSData) -> Void) -> Void {
        
        if let queryUrl: NSURL = NSURL(string: queryString) {
            
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithURL(queryUrl, completionHandler: { (queryData, response, error) -> Void in
                
                guard error == nil else { return completionHandler(result: {throw Constants.Errors.ErrorQueryingForData}) }
                
                guard queryData != nil, let queryData = queryData else {
                    return completionHandler(result: {throw Constants.Errors.QueryDataEmpty})
                }
                
                return completionHandler(result: { queryData })
            })
            task.resume()
        }
    }
}