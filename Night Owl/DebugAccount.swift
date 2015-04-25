//
//  DebugAccounts.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 4/1/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

var alternateDebugEnabled = false
var alternateAccountActive = "Debug"

class DebugAccount: NSObject {
    
    // MARK: Instance Variables
    var name: String!
    var appID: String!
    var appSecret: String!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.name = object["name"] as? String
        self.appID = object["appID"] as? String
        self.appSecret = object["appSecret"] as? String
        self.parse = object
    }
    
    // MARK: Class Methods
    class func accounts(callback: ((accounts: [DebugAccount]) -> Void)!) {
        var accounts: [DebugAccount] = []
        var query = PFQuery(className: "DebugAccount")
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects as! [PFObject] {
                    accounts.append(DebugAccount(object))
                }
                
                callback?(accounts: accounts)
            } else if error != nil {
                println(error)
            }
        })
    }
    
    class func alternateDebug() -> Bool {
        return alternateDebugEnabled
    }
    
    class func accountActive() -> String {
        return alternateAccountActive
    }
    
    class func setAlternateDebug(account: String) {
        alternateDebugEnabled = true
        alternateAccountActive = account
    }
}
