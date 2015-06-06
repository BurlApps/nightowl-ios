//
//  HomePageControllerViewController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 6/5/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

import UIKit

class HomePageController: UIViewController {

    // MARK: Instance Variables
    var pageIndex: Int!
    var homeController: HomeController!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background
        self.view.backgroundColor = UIColor.clearColor()
    }
}
