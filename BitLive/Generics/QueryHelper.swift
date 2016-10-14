//
//  QueryHelper.swift
//  BitLive
//
//  Created by Ace Green on 7/14/16.
//  Copyright © 2016 Ace Green. All rights reserved.
//

import UIKit

open class QueryHelper {
    
    static let sharedInstance = QueryHelper()
    
    open func queryWith(_ queryString: String, completionHandler: @escaping (_ result: () throws -> Data) -> Void) -> Void {
        
        if let queryUrl: URL = URL(string: queryString) {
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: queryUrl, completionHandler: { (queryData, response, error) -> Void in
                
                guard error == nil else { return completionHandler({throw Constants.Errors.errorQueryingForData}) }
                
                guard queryData != nil, let queryData = queryData else {
                    return completionHandler({throw Constants.Errors.queryDataEmpty})
                }
                
                return completionHandler({ queryData })
            })
            task.resume()
        }
    }
}
