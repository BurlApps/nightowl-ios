//
//  User.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class User: NSObject {
    
    // MARK: Instance Variables
    var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFUser) {
        self.init()
        
        self.parse = object
    }
    
    // MARK: Class Methods
    class func login(callback: ((user: User) -> Void)!) {
        PFAnonymousUtils.logInWithBlock { (user: PFUser!, error: NSError!) -> Void in
            if error == nil {
                callback!(user: User(user))
            }
        }
    }
    
    class func current() -> User! {
        if let user = PFUser.currentUser() {
            return User(user)
        } else {
            return nil
        }
    }
    
    class func logout() {
        PFUser.logOut()
    }
    
    // MARK: Instance Methods
    func logout() {
        User.logout()
    }
}
