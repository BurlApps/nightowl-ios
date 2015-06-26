//
//  Message.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 4/26/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class Message: NSObject {
    
    // MARK: Instance Variables
    var text: String!
    var type: Int!
    var created: NSDate!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.text = object["text"] as? String
        self.type = object["type"] as? Int
        self.created = object.createdAt
        self.parse = object
    }
    
    class func create(text: String!, user: User) {
        var message = PFObject(className: "Message")
        
        message["text"] = text
        message["user"] = user.parse
        message["type"] = 2
        
        message.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success && error == nil {
                user.messages = user.messages + 1
                user.parse["messages"] = user.messages
                user.parse.saveInBackground()
                
                user.mixpanel.people.set("Messages", to: user.messages)
                
                if let id = message.objectId {
                    if let userId = user.parse.objectId {
                        user.mixpanel.track("MOBILE: Message Created", properties: [
                            "ID": id,
                            "User ID": userId
                        ])
                    }
                }
            }
        }
    }
}
