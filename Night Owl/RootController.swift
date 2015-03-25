//
//  RootController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/24/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class RootController: UIViewController {
    
    // MARK: Instance Variables
    var pagesController: PagesController!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background Color
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        // Login User
        if User.current() == nil {
            User.login({ (user) -> Void in
                self.performSegueWithIdentifier("loginSegue", sender: self)
            })
        } else {
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.pagesController = segue.destinationViewController as PagesController
    }
}
