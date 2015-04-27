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
    var byUser: Bool!
    var created: NSDate!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.text = object["text"] as? String
        self.byUser = object["byUser"] as? Bool
        self.created = object.createdAt
        self.parse = object
    }
    
    class func messages(user: User, callback: ((messages: [Message]) -> Void)!) {
        var messages: [Message] = []
        var query = PFQuery(className: "Message")
        
        query.whereKey("user", equalTo: user.parse)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil && objects!.count > 0 {
                for object in objects as! [PFObject] {
                    var message = Message(object)
                    messages.append(message)
                }
                
                callback?(messages: messages)
            } else {
                println(error)
            }
        })
    }
    
    class func create(text: String!, user: User) {
        var message = PFObject(className: "Message")
        
        message["text"] = text
        message["user"] = user.parse
        message["byUser"] = true
        
        message.saveInBackgroundWithBlock(nil)
    }
}
