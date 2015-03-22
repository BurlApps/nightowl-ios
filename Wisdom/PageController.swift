//
//  PageController.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class PageController: UIViewController {
    
    // Instance Variables
    var pageIndex: Int!
    
    // Convience Constructor
    convenience init(frame: CGRect, index: Int) {
        self.init()
        
        self.view.frame = frame
        self.pageIndex = index
        
        println(index)
    }
}
