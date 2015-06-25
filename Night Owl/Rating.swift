//
//  Rating.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 6/24/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class Rating: NSObject {
    
    // MARK: Instance Variables
    var note: String!
    var rating: Int!
    var parse: PFObject!
    
    // MARK: Convenience Methods
    convenience init(_ object: PFObject) {
        self.init()
        
        self.note = object["note"] as? String
        self.rating = object["rating"] as? Int
        self.parse = object
    }

}
