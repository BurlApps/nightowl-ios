//
//  Installation.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

var tokenData: NSData!

class Installation: NSObject {
    
    // MARK: Instance Variables
    var parse: PFInstallation!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFInstallation) {
        self.init()
        
        self.parse = object
    }
    
    // MARK: Class Methods
    class func current() -> Installation {
        return Installation(PFInstallation.currentInstallation())
    }
    
    // MARK: Instance Methods
    func setDeviceToken(token: NSData) {
        tokenData = token
        self.parse.setDeviceTokenFromData(token)
        self.parse.saveInBackgroundWithBlock(nil)
    }
    
    func setUser(user: User) {
        self.parse["user"] = user.parse
        self.parse.saveInBackgroundWithBlock(nil)
    }
}
