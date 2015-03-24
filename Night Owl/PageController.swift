//
//  PageController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class PageController: UINavigationController {
    
    // MARK: Instance Variables
    var pageIndex: Int!
    var rootController: RootController!
    
    // MARK: Instance Methods
    func lockPageView() {
        self.rootController.lockPageView()
    }
    
    func unlockPageView() {
        self.rootController.unlockPageView()
    }
}
