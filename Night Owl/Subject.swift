//
//  Subject.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/23/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class Subject: NSObject {
    
    // MARK: Instance Variables
    var name: String!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.name = object["name"] as? String
        self.parse = object
    }
    
    // MARK: Class Methods
    class func subjects(localStore: Bool, callback: ((subjects: [Subject]) -> Void)!) {
        var subjects: [Subject] = []
        var query = PFQuery(className: "Subject")
        
        if localStore {
            query.fromLocalDatastore()
        }
        
        query.orderByAscending("rank")
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if localStore && objects.count == 0 {
                    self.subjects(false, callback: callback)
                } else {
                    for object in objects as [PFObject] {
                        object.pinInBackgroundWithBlock(nil)
                        subjects.append(Subject(object))
                    }
                    
                    callback?(subjects: subjects)
                }
            } else if error != nil {
                println(error)
            }
        })
    }
    
    // MARK: Instance Methods
    func fetch() -> Subject {
        self.parse.fetchFromLocalDatastoreInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            self.name = object["name"] as? String
        }
        
        return self
    }
}
