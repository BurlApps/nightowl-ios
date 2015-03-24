//
//  Assignment.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class Assignment: NSObject {
    
    // MARK: Instance Variables
    var name: String!
    var question: PFFile!
    var answer: PFFile!
    var comment: String!
    var completed: Bool!
    var rating: Int!
    var creator: User!
    var subject: Subject!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.name = object["name"] as String
        self.question = object["question"] as PFFile
        self.answer = object["answer"] as PFFile
        self.comment = object["comment"] as? String
        self.completed = object["completed"] as Bool
        self.rating = object["rating"] as Int
        self.creator = User(object["creator"] as PFUser)
        self.subject = Subject(object["subject"] as PFObject)
        self.parse = object
    }
    
    // MARK: Class Methods
    class func create(name: String, question: UIImage, creator: User, subject: Subject) {
        var assignment = PFObject(className: "Assignment")
        var imageData = UIImagePNGRepresentation(question)
        var imageFile = PFFile(name: "image.png", data: imageData)
        
        assignment["name"] = name
        assignment["question"] = imageFile
        assignment["creator"] = creator.parse
        assignment["subject"] = subject.parse
        
        assignment.saveInBackgroundWithBlock(nil)
    }
}
