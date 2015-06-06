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
    var name: String!
    var email: String!
    var subject: Subject!
    var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFUser) {
        self.init()
        
        self.freeQuestions = object["freeQuestions"] as? Int
        self.card = object["card"] as? String
        self.name = object["name"] as? String
        self.email = object["email"] as? String
        self.subject = lastSubject
        self.parse = object
    }
    
    // MARK: Class Methods
    class func register(callback: (user: User!) -> Void, referral: (credits: Int) -> Void, promo: () -> Void) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions([
            "public_profile", "email"
        ], block: { (user: PFUser?, error: NSError?) -> Void in
            if user != nil && error == nil {
                var userTemp = User(user!)
                
                user!["source"] = "ios"
                user!.saveInBackground()
                
                userTemp.registerMave()
                userTemp.setInstallation()
                userTemp.facebookInformation()
                callback(user: userTemp)
                
                if user!.isNew {
                    userTemp.isReferral({ (referred, credits) -> Void in                            
                        if referred {
                            referral(credits: credits)
                        } else {
                            promo()
                        }
                    })
                }
            } else {
                callback(user: nil)
                println(error)
            }
        })
    }
    
    class func current() -> User! {
        if let user = PFUser.currentUser() {
            return User(user)
        } else {
            Global.showHomeController()
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
    
    func setInstallation() {
        Installation.current().setUser(self)
    }
    
    func registerMave() {
        MaveSDK.sharedInstance().trackSignup()
    }
    
    func identifyMave() {
        Settings.sharedInstance { (settings) -> Void in
            var maveData = MAVEUserData(automaticallyFromDeviceName: ())
            maveData.userID = self.parse.objectId
            maveData.customData = ["credits": settings.referralQuestions]
            MaveSDK.sharedInstance().identifyUser(maveData)
        }
    }
    
    func facebookInformation() {
        if let token = FBSDKAccessToken.currentAccessToken() {
            var request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            
            request.startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, data: AnyObject!, error: NSError!) -> Void in
                if data != nil && error == nil {
                    self.parse["name"] = data["name"]
                    self.parse["email"] = data["email"]
                    self.parse.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if !success || error != nil {
                            self.parse.removeObjectForKey("name")
                            self.parse.removeObjectForKey("email")
                        }
                    })
                }
            })
        }
    }
    
    func isReferral(callback: (referred: Bool, credits: Int!) -> Void) {
        MaveSDK.sharedInstance().getReferringData { (data: MAVEReferringData!) -> Void in
            var referred = false
            var credits = 0
            
            if data != nil && data.customData != nil && data.referringUser != nil {
                if let tempCredits = data.customData["credits"] as? Int {
                    if self.parse.objectId != data.referringUser.userID {
                        referred = true
                        credits = tempCredits
                        
                        self.creditQuestions(credits)
                        
                        PFCloud.callFunctionInBackground("referredUser", withParameters: [
                            "user": data.referringUser.userID,
                            "credits": credits
                        ], block: nil)
                    }
                }
            }
            
            callback(referred: referred, credits: credits)
        }
    }
    
    func becomeUser() {
        PFUser.becomeInBackground(self.parse.sessionToken!)
    }
    
    func updateSubject(subject: Subject!) {
        lastSubject = subject
    }
    
    func changeCard(card: String) {
        self.card = card
        self.parse["card"] = self.card
        self.parse.saveInBackgroundWithBlock(nil)
    }
    
    func updateCard(card: CardIOCreditCardInfo, callback: (error: NSError!) -> Void) {
        var stCard = STPCard()
        stCard.number = card.cardNumber
        stCard.expMonth = card.expiryMonth
        stCard.expYear = card.expiryYear
        stCard.cvc = card.cvv
        
        STPAPIClient.sharedClient().createTokenWithCard(stCard, completion: { (token: STPToken!, error: NSError!) -> Void in
            if token != nil && error == nil {
                self.changeCard(token.card.last4)

                PFCloud.callFunctionInBackground("addCard", withParameters: [
                    "card":token.tokenId
                ], block: nil)
            }
            
            callback(error: error)
        })
    }
    
    func addApplePay(payment: PKPayment, callback: (error: NSError!) -> Void) {
        STPAPIClient.sharedClient().createTokenWithPayment(payment, completion: { (token: STPToken!, error: NSError!) -> Void in
            if token != nil && error == nil {
                self.changeCard("Apple Pay")
                
                PFCloud.callFunctionInBackground("addCard", withParameters: [
                    "card":token.tokenId
                ], block: nil)
            }
            
            callback(error: error)
        })
    }
    
    func addVenmo(callback: (error: NSError!) -> Void) {
        if Venmo.sharedInstance().session.user != nil {
            self.changeCard("Venmo")
            
            callback(error: nil)
        } else {
            Venmo.sharedInstance().requestPermissions([
                "make_payments"
            ], withCompletionHandler: { (success: Bool, error: NSError!) -> Void in
                if success && error == nil {
                    self.changeCard("Venmo")
                }
                
                callback(error: error)
            })
        }
    }
    
    func chargeQuestion(description: String!, callback: (error: NSError!) -> Void) {
        Settings.sharedInstance { (settings) -> Void in
            self.fetch { (user) -> Void in
                if user.freeQuestions > 0 {
                    user.freeQuestions = user.freeQuestions - 1
                    user.parse["freeQuestions"] = user.freeQuestions
                    user.parse.saveInBackgroundWithBlock(nil)
                    
                    Global.reloadSettingsController()
                    callback(error: nil)
                } else if self.card == "Venmo" {
                    var amount = Int(settings.questionPrice * 100)
                    var note = "Thanks for the math help!"
                    
                    if description != nil {
                        note = "Help with \(description)"
                    }
                    
                    note = "\(note) \(settings.host)/d"
                    
                    self.addVenmo({ (error) -> Void in
                        if error == nil {
                            Venmo.sharedInstance().sendPaymentTo(settings.venmo, amount: UInt(amount),
                                note: note, audience: VENTransactionAudience.Public,
                                completionHandler: { (transaction: VENTransaction!, success: Bool, error: NSError!) -> Void in
                                    if success && error == nil {
                                        let payed = user.parse["payed"] as! Float
                                        
                                        user.parse["payed"] = payed + settings.questionPrice
                                        user.parse.saveInBackgroundWithBlock(nil)
                                    } else {
                                        println(error)
                                    }
                                    
                                    callback(error: error)
                            })
                        } else {
                            callback(error: error)
                        }
                    })
                } else {
                    let charges = user.parse["charges"] as! Float
                    
                    user.parse["charges"] = charges + settings.questionPrice
                    user.parse.saveInBackgroundWithBlock(nil)
                    callback(error: nil)
                }
            }
            
            return ()
        }
    }
    
    func creditQuestions(freeAmount: Int) {
        self.fetch { (user) -> Void in
            user.freeQuestions = user.freeQuestions + freeAmount
            user.parse["freeQuestions"] = user.freeQuestions
            user.parse.saveInBackgroundWithBlock(nil)
        }
    }
    
    func promoCode(code: String, callback: ((promo: Promo!) -> Void)) {
        var query = PFQuery(className: "Promo")
        
        query.whereKey("code", equalTo: code)
        query.whereKey("enabled", equalTo: true)
        
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            if object != nil && error == nil {
                var promo = Promo(object!)
                
                promo.addUser(self)
                self.creditQuestions(promo.credits)
                
                callback(promo: promo)
            } else {
                println(error)
                callback(promo: nil)
            }
        }
    }
    
    func fetch(callback: ((user: User!) -> Void)!) -> User {
        self.parse.fetchInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            if var tempObject = object {
                self.freeQuestions = tempObject["freeQuestions"] as? Int
                self.card = tempObject["card"] as? String
                callback!(user: self)
            } else {
                User.logout()
                Global.showHomeController()
            }
        }
        
        return self
    }
    
    func assignments(callback: ((assignments: [Assignment]) -> Void)) {
        var assignments: [Assignment] = []
        var query = PFQuery(className: "Assignment")
        
        query.whereKey("state", notEqualTo: 9)
        query.whereKey("creator", equalTo: self.parse)
        query.orderByDescending("updatedAt")
        query.cachePolicy = .NetworkElseCache
        
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
    
    func messages(skip: Int, callback: ((messages: [Message]) -> Void)!) {
        var messages: [Message] = []
        var query = PFQuery(className: "Message")
        
        query.whereKey("user", equalTo: self.parse)
        query.skip = skip
        query.orderByAscending("createdAt")
        query.cachePolicy = .NetworkElseCache
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
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
}