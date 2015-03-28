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
    var questionCached: UIImage!
    var answer: PFFile!
    var answerCached: UIImage!
    var state: Int!
    var creator: User!
    var subject: Subject!
    var created: NSDate!
    var parse: PFObject!
    
    // MARK: Enum
    enum ImageType {
        case Question, Answer
    }
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.name = object["name"] as? String
        self.question = object["question"] as? PFFile
        self.answer = object["answer"] as? PFFile
        self.state = object["state"] as? Int
        self.creator = User(object["creator"] as PFUser)
        self.subject = Subject(object["subject"] as PFObject)
        self.created = object.createdAt
        self.parse = object
    }
    
    // MARK: Class Methods
    class func create(name: String!, question: UIImage, creator: User, subject: Subject) {
        var assignment = PFObject(className: "Assignment")
        
        if name != nil {
            assignment["name"] = name
        }
        
        assignment["state"] = 0
        assignment["creator"] = creator.parse
        assignment["subject"] = subject.parse
        
        assignment.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
            if success && error == nil {
                var imageData = UIImagePNGRepresentation(question)
                var imageFile = PFFile(name: "image.png", data: imageData)
                assignment["question"] = imageFile
                creator.pushReloadQuestions()
                
                assignment.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
                    assignment["state"] = 1
                    assignment.saveInBackgroundWithBlock(nil)
                    creator.pushReloadQuestions()
                }
            } else {
                println(error)
            }
        }
    }
    
    // MARK: Instance Methods
    func changeState(state: Int) {
        self.state = state
        self.parse["state"] = state
        
        if state >= 4 {
            if var tutor = self.parse["tutor"] as? PFObject {
                var flaggedAssignments = tutor.relationForKey("flaggedAssignments")
                flaggedAssignments.addObject(self.parse)
                tutor.saveInBackgroundWithBlock(nil)
            }
        }
        
        self.parse.saveInBackgroundWithBlock(nil)
    }
    
    
    
    func getImage(type: ImageType, callback: (image: UIImage) -> Void) {
        var tmpImage: PFFile!
        var tmpCache: UIImage!
        
        if type == .Question {
            tmpImage = self.question
            tmpCache = self.questionCached
        } else {
            tmpImage = self.answer
            tmpCache = self.answerCached
        }
        
        if tmpCache != nil {
            callback(image: tmpCache)
            return
        }
        
        if tmpImage != nil {
            let request = NSURLRequest(URL: NSURL(string: tmpImage.url)!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    tmpCache = UIImage(data: data)
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        // Makes a 1x1 graphics context and draws the image into it
                        UIGraphicsBeginImageContext(CGSizeMake(1,1))
                        let context = UIGraphicsGetCurrentContext()
                        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), tmpCache.CGImage)
                        UIGraphicsEndImageContext()
                        
                        // Now the image will have been loaded and decoded
                        // and is ready to rock for the main thread
                        dispatch_async(dispatch_get_main_queue(), {
                            callback(image: tmpCache)
                        })
                        
                        if type == .Question {
                            self.questionCached = tmpCache
                        } else {
                            self.answerCached = tmpCache
                        }
                    })
                } else {
                    println(error)
                }
            })
        }
    }

}
