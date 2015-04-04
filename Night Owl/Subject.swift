//
//  Subject.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/23/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

var subjectsCached: [String: Subject] = [:]

class Subject: NSObject {
    
    // MARK: Instance Variables
    var name: String!
    var rank: Int!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.name = object["name"] as? String
        self.rank = object["rank"] as? Int
        self.parse = object
    }
    
    // MARK: Class Methods
    class func subject(objectId: String) -> Subject! {
        return subjectsCached[objectId]
    }
    
    class func subjects(localStore: Bool, callback: ((subjects: [Subject]) -> Void)!) {
        var subjects: [Subject] = []
        var query = PFQuery(className: "Subject")
        
        if localStore && subjectsCached.count > 0 {
            for (id, subject) in subjectsCached {
                subjects.append(subject)
            }
            
            subjects.sort({ $0.rank < $1.rank })
            callback?(subjects: subjects)
            return
        }
        
        subjectsCached = [:]
        query.orderByAscending("rank")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil && objects.count > 0 {
                for object in objects as [PFObject] {
                    var subject = Subject(object)
                    subjectsCached[object.objectId] = subject
                    subjects.append(subject)
                }
                
                callback?(subjects: subjects)
            } else {
                println(error)
            }
        })
    }
    
    // MARK: Instance Methods
    func fetch() -> Subject {
        self.name = subjectsCached[self.parse.objectId]?.name
        return self
    }
}
