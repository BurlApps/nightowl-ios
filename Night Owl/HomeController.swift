
//
//  HomeController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 5/14/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class HomeController: UIViewController, UIAlertViewDelegate {
    
    // MARK: Instance Variables
    var cameraView: LLSimpleCamera!
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    // MARK: IBOutlets
    @IBOutlet weak var logoView: FLAnimatedImageView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var onboardingLabel: UILabel!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide Navigation Bar
        self.navigationController?.navigationBarHidden = true
        
        // Set Background
        self.view.backgroundColor = UIColor.blackColor()
        self.container.backgroundColor = UIColor(red:1, green:0.88, blue:0.2, alpha:1)
        
        // Setup Logo Animation
        var imageUrl = NSBundle.mainBundle().URLForResource("Logo", withExtension: "gif")
        var imageData = NSData(contentsOfURL: imageUrl!)
        self.logoView.animatedImage = FLAnimatedImage(animatedGIFData: imageData)
        
        // Style Onboarding Label
        self.onboardingLabel.textAlignment = NSTextAlignment.Center
        self.onboardingLabel.textColor = UIColor.blackColor()
        self.onboardingLabel.shadowColor = UIColor(white: 0, alpha: 0.1)
        self.onboardingLabel.shadowOffset = CGSize(width: 0, height: 2)
        self.onboardingLabel.numberOfLines = 0
        self.onboardingLabel.adjustsFontSizeToFitWidth = true
        
        // Sytle Login Button
        self.loginButton.backgroundColor = UIColor(red:0.23, green:0.35, blue:0.59, alpha:1)
        self.loginButton.layer.cornerRadius = 7
        self.loginButton.layer.shadowColor = UIColor(red:0.18, green:0.27, blue:0.45, alpha:1).CGColor
        self.loginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.loginButton.layer.shadowRadius = 0
        self.loginButton.layer.shadowOpacity = 1
        self.loginButton.layer.masksToBounds = false
        
        // Add Spinner to Login Button
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self.spinner.frame = CGRectMake(0, 0, 40, 40)
        self.loginButton.addSubview(spinner)
        
        // Setup Camera
        self.cameraView = LLSimpleCamera(quality: CameraQualityHigh, andPosition: CameraPositionBack)
        self.cameraView.view.frame = self.view.frame
        self.view.insertSubview(self.cameraView.view, belowSubview: self.container)
        
        // Move to Feed View if Logged In
        if let user = User.current() {
            user.becomeUser()
            self.performSegueWithIdentifier("finishedSegue", sender: self)
        } else {
            self.cameraView.start()
            
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.container.backgroundColor = UIColor(red:1, green:0.88, blue:0.2, alpha:0.9)
            }, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.cameraView.view.frame = self.view.frame
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Status Bar
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start Camera View
        if self.cameraView != nil {
            self.cameraView.view.frame = self.view.frame
            self.cameraView.start()
        
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.container.backgroundColor = UIColor(red:1, green:0.88, blue:0.2, alpha:0.9)
            }, completion: nil)
        }
        
        // Center Spinner
        self.spinner.center = CGPointMake(self.loginButton.frame.width/2, self.loginButton.frame.height/2)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.cameraView.stop()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Setup Login Button
        self.loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.loginButton.setTitle("SIGN IN WITH FACEBOOK", forState: UIControlState.Normal)
        self.spinner.stopAnimating()
    }
    
    // IBActions
    @IBAction func loginUpInside(sender: UIButton) {
        self.loginButton.setTitleColor(UIColor.clearColor(), forState: UIControlState.Normal)
        self.spinner.startAnimating()
        
        User.register({ (user) -> Void in
            if user != nil {
                self.performSegueWithIdentifier("finishedSegue", sender: self)
            } else {
                self.loginButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                self.loginButton.setTitle("Failed To Log In", forState: UIControlState.Normal)
                self.spinner.stopAnimating()
            }
        }, referral: { (credits) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                UIAlertView(title: "You Are Awesome",
                    message: "You and your friend both get \(credits) free questions for the referral!",
                    delegate: self, cancelButtonTitle: "Thanks!").show()
            })
        })
    }
    
    // MARK: UIAlertViewDelegate Methods
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.performSegueWithIdentifier("finishedSegue", sender: self)
    }
}
