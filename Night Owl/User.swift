//
//  User.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class User: NSObject {
    
    // MARK: Instance Variables
    var name: String!
    var email: String!
    var stripe: String!
    var charges: Int!
    var freeQuestions: Int!
    var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFUser) {
        self.init()
        
        self.name = object["name"] as? String
        self.email = object["email"] as? String
        self.stripe = object["stripe"] as? String
        self.charges = object["charges"] as? Int
        self.freeQuestions = object["freeQuestions"] as? Int
        self.parse = object
    }
    
    // MARK: Class Methods
    class func login(callback: ((user: User) -> Void)!) {
        PFAnonymousUtils.logInWithBlock { (user: PFUser!, error: NSError!) -> Void in
            if error == nil {
                var tempUser = User(user)
                Installation.current().setUser(tempUser)
                callback!(user: tempUser)
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
    
    func fetch() -> User {
        self.parse.fetchInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            self.name = object["name"] as? String
            self.email = object["email"] as? String
            self.stripe = object["stripe"] as? String
            self.charges = object["charges"] as? Int
            self.freeQuestions = object["freeQuestions"] as? Int
        }
        
        return self
    }
    
    func getAssignments(callback: ((assignments: [Assignment]) -> Void)) {
        var assignments: [Assignment] = []
        var query = PFQuery(className: "Assignment")
        
        query.whereKey("creator", equalTo: self.parse)
        query.orderByDescending("updatedAt")
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects as [PFObject] {
                    var assignment = Assignment(object)
                    assignment.subject.fetch()
                    assignments.append(assignment)
                }
                
                callback(assignments: assignments)
            } else if error != nil {
                println(error)
            }
        })
    }
}
