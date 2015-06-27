//
//  User.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

private var currentInstance: User!
private var lastSubject: Subject!

class User: NSObject {
    
    // MARK: Instance Variables
    var freeQuestions: Int = 0
    var charges: Float = 0
    var payed: Float = 0
    var questions: Int = 0
    var messages: Int = 0
    var card: String!
    var name: String!
    var email: String!
    var subject: Subject!
    var mixpanel: Mixpanel!
    var hasReferred: Bool = false
    var parse: PFUser!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFUser) {
        self.init()
        
        self.mixpanel = Mixpanel.sharedInstance()
        self.loadProperties(object, callback: nil)
    }
    
    // MARK: Class Methods
    class func register(callback: (user: User!) -> Void, referral: (credits: Int) -> Void, promo: () -> Void) {
        var mixpanel = Mixpanel.sharedInstance()
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(nil, block: { (user: PFUser?, error: NSError?) -> Void in
            if user != nil && error == nil {
                var userTemp = User(user!)
                
                user!["source"] = "ios"
                user!.saveInBackground()
                
                userTemp.registerMave()
                userTemp.setInstallation()
                userTemp.facebookInformation()
                userTemp.aliasMixpanel()
                callback(user: userTemp)
                
                if user!.isNew {
                    userTemp.isReferral({ (referred, credits, referree) -> Void in
                        if referred {
                            referral(credits: credits)
                            
                            mixpanel.track("Mobile.User.Registered", properties: [
                                "Referral": referred,
                                "Credits": credits,
                                "Referree": referree
                            ])
                        } else {
                            promo()
                            mixpanel.track("Mobile.User.Registered")
                        }
                    })
                } else {
                    mixpanel.track("Mobile.User.Logged In")
                }
            } else {
                callback(user: nil)
                mixpanel.track("Mobile.User.Failed Authentication")
                println(error)
            }
        })
    }
    
    class func current() -> User! {
        if currentInstance != nil {
            return currentInstance
        } else if let object = PFUser.currentUser() {
            var user = User(object)
            currentInstance = user
            return user
        } else {
            Global.showHomeController()
            return nil
        }
    }
    
    class func logout() {
        currentInstance = nil
        PFUser.logOut()
    }
    
    // MARK: Instance Methods
    func logout() {
        self.mixpanel.track("Mobile.User.Logout")
        self.mixpanel.reset()
        User.logout()
    }
    
    func becomeUser() {
        PFUser.becomeInBackground(self.parse.sessionToken!)
        
        self.setInstallation()
        self.identifyMave()
    }
    
    func aliasMixpanel() {
        self.mixpanel.createAlias(self.parse.objectId, forDistinctID: self.mixpanel.distinctId)
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
                    var properties: [NSObject: AnyObject] = [
                        "Free Questions": self.freeQuestions,
                        "Charges": self.charges,
                        "Questions": self.questions,
                        "Messages": self.messages,
                        "Has Referred": self.hasReferred
                    ]
                    
                    if var id = self.parse.objectId {
                        properties["ID"] = id
                    }
                    
                    if let name = data["name"] as? String {
                        self.parse["name"] = name
                        properties["$name"] = name
                    }
                    
                    if let email = data["email"] as? String {
                        self.parse["email"] = email
                        properties["$email"] = email
                    }
                    
                    self.mixpanel.people.set(properties)
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
    
    func loadProperties(object: PFUser, callback: ((user: User!) -> Void)!) {
        if let questions = object["questions"] as? Int {
            self.questions = questions
        }
        
        if let messages = object["messages"] as? Int {
            self.messages = messages
        }
        
        if let freeQuestions = object["freeQuestions"] as? Int {
            self.freeQuestions = freeQuestions
        }
        
        if let charges = object["charges"] as? Float {
            self.charges = charges
        }
        
        if let payed = object["payed"] as? Float {
            self.payed = payed
        }
        
        if let hasReferred = object["hasReferred"] as? Bool {
            self.hasReferred = hasReferred
        }
        
        self.card = object["card"] as? String
        self.name = object["name"] as? String
        self.email = object["email"] as? String
        self.subject = lastSubject
        self.parse = object
        callback?(user: self)
        
        var properties: [NSObject: AnyObject] = [
            "Free Questions": self.freeQuestions,
            "Charges": self.charges + self.payed,
            "Questions": self.questions,
            "Messages": self.messages,
            "Has Referred": self.hasReferred
        ]
        
        if var id = self.parse.objectId {
            properties["ID"] = id
        }
        
        if var card = self.card {
            properties["Card"] = card
        }
        
        if var name = self.name {
            properties["$name"] = name
        }
        
        
        if var email = self.email {
            properties["$email"] = email
        }
        
        self.mixpanel.people.set(properties)
    }
    
    func fetch(callback: ((user: User!) -> Void)!) -> User {
        self.parse.fetchInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            if var tempObject = object as? PFUser {
                self.loadProperties(tempObject, callback: callback)
            } else {
                User.logout()
                Global.showHomeController()
            }
        }
        
        return self
    }
    
    func referredUser() {
        self.hasReferred = true
        self.parse["hasReferred"] = true
        self.parse.saveInBackground()
        
        self.mixpanel.people.set("Has Referred", to: true)
    }
    
    func isReferral(callback: (referred: Bool, credits: Int, referree: String) -> Void) {
        MaveSDK.sharedInstance().getReferringData { (data: MAVEReferringData!) -> Void in
            var referred = false
            var credits = 0
            var referree = ""
            
            if data != nil && data.customData != nil && data.referringUser != nil {
                if let tempCredits = data.customData["credits"] as? Int {
                    if self.parse.objectId != data.referringUser.userID {
                        referred = true
                        credits = tempCredits
                        referree = data.referringUser.userID
                        
                        self.creditQuestions(credits)
                        
                        PFCloud.callFunctionInBackground("referredUser", withParameters: [
                            "user": referree,
                            "credits": credits
                        ], block: nil)
                    }
                }
            }
            
            callback(referred: referred, credits: credits, referree: referree)
        }
    }
    
    func updateSubject(subject: Subject!) {
        lastSubject = subject
    }
    
    func updateName(name: String) {
        self.name = name
        self.parse["name"] = self.name
        self.parse.saveInBackground()
        self.mixpanel.track("Mobile.User.Name.Changed")
    }
    
    func getCardName() -> String! {
        if self.card == nil {
            return nil
        }
        
        return (split(self.card) {$0 == ","})[0]
    }
    
    func changeCard(card: String) {
        self.card = card
        self.parse["card"] = self.card
        self.parse.saveInBackground()
    }
    
    func isApplePayActive() -> Bool {
        if self.card != nil {
            var splitCard = split(self.card) {$0 == ","}
            
            if splitCard.count > 1 {
                return splitCard[1] == "1"
            }
        }
        
        return false
    }
    
    func updateCard(card: CardIOCreditCardInfo, callback: (error: NSError!) -> Void) {
        var stCard = STPCard()
        stCard.number = card.cardNumber
        stCard.expMonth = card.expiryMonth
        stCard.expYear = card.expiryYear
        stCard.cvc = card.cvv
        
        STPAPIClient.sharedClient().createTokenWithCard(stCard, completion: { (token: STPToken?, error: NSError?) -> Void in
            if token != nil && error == nil {
                self.changeCard(stCard.last4!)

                PFCloud.callFunctionInBackground("addCard", withParameters: [
                    "card": token!.tokenId
                ], block: nil)
                
                self.mixpanel.track("Mobile.User.Card.Added")
                self.mixpanel.people.set("Card", to: stCard.last4!)
            }
            
            callback(error: error)
        })
    }
    
    func addApplePay(payment: PKPayment, callback: (error: NSError!) -> Void) {
        STPAPIClient.sharedClient().createTokenWithPayment(payment, completion: { (token: STPToken?, error: NSError?) -> Void in
            if token != nil && error == nil {
                self.changeCard("Apple Pay,1")
                
                PFCloud.callFunctionInBackground("addCard", withParameters: [
                    "card": token!.tokenId
                ], block: nil)
                
                self.mixpanel.track("Mobile.User.Apple Pay.Added")
                self.mixpanel.people.set("Card", to: "Apple Pay")
            }
            
            callback(error: error)
        })
    }
    
    func chargeQuestion(price: Float!, callback: (paid: Bool, error: NSError!) -> Void) {
        Settings.sharedInstance { (settings) -> Void in
            self.fetch { (user) -> Void in
                if price == 0 {
                    callback(paid: false, error: nil)
                } else if self.freeQuestions > 0 {
                    self.creditQuestions(-1)
                    
                    Global.reloadSettingsController()
                    callback(paid: false, error: nil)
                } else {
                    self.charges = self.charges + price
                    self.parse["charges"] = self.charges
                    self.parse.saveInBackground()
                    
                    var newCharges = NSNumber(float: price)
                    self.mixpanel.people.trackCharge(newCharges)
                    
                    callback(paid: true, error: nil)
                }
            }
        }
    }
    
    func creditQuestions(freeAmount: Int) {
        self.fetch { (user) -> Void in
            user.freeQuestions = user.freeQuestions + freeAmount
            user.parse["freeQuestions"] = user.freeQuestions
            user.parse.saveInBackground()
            
            self.mixpanel.people.set("Free Questions", to: user.freeQuestions)
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
                
                if let id = promo.parse.objectId {
                    self.mixpanel.track("Mobile.User.Promo.Successful", properties: [
                        "ID": id,
                        "Credits": promo.credits,
                        "Name": promo.name,
                        "Code": promo.code
                    ])
                }
            } else {
                println(error)
                callback(promo: nil)
                
                self.mixpanel.track("Mobile.User.Promo.Failure", properties: [
                    "Code": code
                ])
            }
        }
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