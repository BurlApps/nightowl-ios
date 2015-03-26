//
//  RootController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/24/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class RootController: UIViewController {
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background Color
        self.view.backgroundColor = UIColor.blackColor()
        
        // Create Loading Spinner
        var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.alpha = 0
        spinner.frame = CGRectMake(0, 0, 40, 40)
        spinner.center = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        spinner.startAnimating()
        self.view.addSubview(spinner)
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            spinner.alpha = 1
        }, completion: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        // Login User
        if let user = User.current() {
            user.fetch({ (user) -> Void in
                self.performSegueWithIdentifier("loginSegue", sender: self)
            })
        } else {
            User.login({ (user) -> Void in
                self.performSegueWithIdentifier("loginSegue", sender: self)
            })
        }
    }
}
