//
//  Assignment.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class Assignment: NSObject {
    
    // MARK: Instance Variables
    var name: String!
    var question: PFFile!
    var answer: PFFile!
    var answerCached: UIImage!
    var comment: String!
    var state: Int!
    var rating: Int!
    var creator: User!
    var subject: Subject!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.name = object["name"] as String
        self.question = object["question"] as? PFFile
        self.answer = object["answer"] as? PFFile
        self.comment = object["comment"] as? String
        self.state = object["state"] as? Int
        self.rating = object["rating"] as? Int
        self.creator = User(object["creator"] as PFUser)
        self.subject = Subject(object["subject"] as PFObject)
        self.parse = object
    }
    
    // MARK: Class Methods
    class func create(name: String, question: UIImage, creator: User, subject: Subject, callback: ((assignment: Assignment) -> Void)!) {
        var assignment = PFObject(className: "Assignment")
        
        assignment["name"] = name
        assignment["state"] = 0
        assignment["creator"] = creator.parse
        assignment["subject"] = subject.parse
        
        callback!(assignment: Assignment(assignment))
        assignment.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
            if success && error == nil {
                var imageData = UIImagePNGRepresentation(question)
                var imageFile = PFFile(name: "image.png", data: imageData)
                assignment["question"] = imageFile
                
                assignment.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
                    assignment["state"] = 1
                    assignment.saveInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
    // MARK: Instance Methods
    func getAnswer(callback: (image: UIImage) -> Void) {
        if self.answerCached == nil {
            if self.answer != nil {
                let request = NSURLRequest(URL: NSURL(string: self.answer.url)!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                    (response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        self.answerCached = UIImage(data: data)
                        
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                            // Makes a 1x1 graphics context and draws the image into it
                            UIGraphicsBeginImageContext(CGSizeMake(1,1))
                            let context = UIGraphicsGetCurrentContext()
                            CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.answerCached.CGImage)
                            UIGraphicsEndImageContext()
                            
                            // Now the image will have been loaded and decoded
                            // and is ready to rock for the main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                callback(image: self.answerCached)
                            })
                        })
                    } else {
                        println(error)
                    }
                })
            }
        } else {
            callback(image: self.answerCached)
        }
    }

}
