//
//  User.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class User: NSObject {
    
    // MARK: Instance Variables
    var freeQuestions: Int!
    var card: String!
    var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFUser) {
        self.init()
        
        self.freeQuestions = object["freeQuestions"] as? Int
        self.card = object["card"] as? String
        self.parse = object
    }
    
    // MARK: Class Methods
    class func login(callback: ((user: User) -> Void)!) {
        Settings.sharedInstance { (settings) -> Void in
            PFAnonymousUtils.logInWithBlock { (user: PFUser!, error: NSError!) -> Void in
                if error == nil {
                    user["charges"] = 0
                    user["freeQuestions"] = settings.freeQuestions
                    
                    var tempUser = User(user)
                    Installation.current().setUser(tempUser)
                    callback?(user: tempUser)
                }
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
    
    func updateCard(card: PTKCard, callback: ((error: NSError!) -> Void)!) {
        let number = NSString(string: card.number)
        self.card = number.substringFromIndex(number.length - 4)
        self.parse["card"] = self.card
        self.parse.saveInBackgroundWithBlock(nil)
        
        var stCard = STPCard()
        stCard.number = card.number
        stCard.expMonth = card.expMonth
        stCard.expYear = card.expYear
        stCard.cvc = card.cvc
        
        let infoDictionary = NSBundle.mainBundle().infoDictionary!
        let stripeKey = infoDictionary["StripeClientKey"] as String
        
        STPAPIClient(publishableKey: stripeKey).createTokenWithCard(stCard, completion: { (token: STPToken!, error: NSError!) -> Void in
            callback!(error: error)
            
            if token != nil && error == nil {
                PFCloud.callFunctionInBackground("addCard", withParameters: ["card":token.tokenId], block: nil)
            }
        })
    }
    
    func chargeQuestion() {
        Settings.sharedInstance { (settings) -> Void in
            self.fetch { (user) -> Void in
                if user.freeQuestions > 0 {
                    user.freeQuestions = user.freeQuestions - 1
                    user.parse["freeQuestions"] = user.freeQuestions
                } else {
                    let charges = user.parse["charges"] as Float
                    user.parse["charges"] = charges + settings.questionPrice
                }
                
                user.parse.saveInBackgroundWithBlock(nil)
            }
            
            return ()
        }
    }
    
    func refundQuestion() {
        self.fetch { (user) -> Void in
            user.freeQuestions = user.freeQuestions + 1
            user.parse["freeQuestions"] = user.freeQuestions
            user.parse.saveInBackgroundWithBlock(nil)
        }
    }
    
    func fetch(callback: ((user: User) -> Void)!) -> User {
        self.parse.fetchInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            if object != nil && error == nil {
                self.freeQuestions = object["freeQuestions"] as? Int
                self.card = object["card"] as? String
                callback!(user: self)
            } else {
                User.logout()
                User.login(callback)
            }
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