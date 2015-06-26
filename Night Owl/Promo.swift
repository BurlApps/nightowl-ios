//
//  Promo.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 5/18/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class Promo: NSObject {
    
    // MARK: Instance Variables
    var name: String!
    var code: String!
    var credits: Int!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.name = object["name"] as? String
        self.code = object["code"] as? String
        self.credits = object["credits"] as? Int
        self.parse = object
    }
    
    // MARK: Instance Methods
    func addUser(user: User) {
        var promoUsers = self.parse.relationForKey("users")
        promoUsers.addObject(user.parse)
        self.parse.saveInBackground()
    }
}