//
//  User.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

private var lastSubject: Subject!

class User: NSObject {
    
    // MARK: Instance Variables
    var freeQuestions: Int!
    var card: String!
    var parse: PFUser!
    var subject: Subject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFUser) {
        self.init()
        
        self.freeQuestions = object["freeQuestions"] as? Int
        self.card = object["card"] as? String
        self.parse = object
        self.subject = lastSubject
    }
    
    // MARK: Class Methods
    class func login(callback: ((user: User) -> Void)!) {
        Settings.sharedInstance { (settings) -> Void in
            PFAnonymousUtils.logInWithBlock { (user: PFUser?, error: NSError?) -> Void in
                if var tempUser = user {
                    tempUser["charges"] = 0
                    tempUser["freeQuestions"] = settings.freeQuestions
                    
                    var userTemp = User(user!)
                    Installation.current().setUser(userTemp)
                    callback?(user: userTemp)
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
    
    func updateSubject(subject: Subject!) {
        lastSubject = subject
    }
    
    func updateCard(card: CardIOCreditCardInfo, callback: ((error: NSError!) -> Void)!) {
        let number = NSString(string: card.redactedCardNumber)
        self.card = number.substringFromIndex(number.length - 4)
        self.parse["card"] = self.card
        self.parse.saveInBackgroundWithBlock(nil)
        
        var stCard = STPCard()
        stCard.number = card.cardNumber
        stCard.expMonth = card.expiryMonth
        stCard.expYear = card.expiryYear
        stCard.cvc = card.cvv
        
        STPAPIClient.sharedClient().createTokenWithCard(stCard, completion: { (token: STPToken!, error: NSError!) -> Void in
            callback!(error: error)
            
            if token != nil && error == nil {
                PFCloud.callFunctionInBackground("addCard", withParameters: [
                    "card":token.tokenId
                ], block: nil)
            }
        })
    }
    
    func chargeQuestion() {
        Settings.sharedInstance { (settings) -> Void in
            self.fetch { (user) -> Void in
                if user.freeQuestions > 0 {
                    user.freeQuestions = user.freeQuestions - 1
                    user.parse["freeQuestions"] = user.freeQuestions
                    Global.reloadSettingsController()
                } else {
                    let charges = user.parse["charges"] as! Float
                    user.parse["charges"] = charges + settings.questionPrice
                }
                
                user.parse.saveInBackgroundWithBlock(nil)
            }
            
            return ()
        }
    }
    
    func cardAdded(freeAmount: Int) {
        self.fetch { (user) -> Void in
            user.freeQuestions = user.freeQuestions + freeAmount
            user.parse["freeQuestions"] = user.freeQuestions
            user.parse.saveInBackgroundWithBlock(nil)
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
        self.parse.fetchInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            if var tempObject = object {
                self.freeQuestions = tempObject["freeQuestions"] as? Int
                self.card = tempObject["card"] as? String
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
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects as! [PFObject] {
                    var assignment = Assignment(object)
                    assignments.append(assignment)
                }
                
                callback(assignments: assignments)
            } else if error != nil {
                println(error)
            }
        })
    }
}