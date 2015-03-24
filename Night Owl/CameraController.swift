//
//  CameraController.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class CameraController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var captureButton: UIButton!
    
    // MARK: Instance Variables
    private var cameraView: LLSimpleCamera!
    private var capturedImage: UIImage!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Background
        self.view.backgroundColor = UIColor.blackColor()
        
        // Style Capture Button
        self.captureButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.captureButton.layer.borderWidth = 6
        self.captureButton.layer.shadowColor = UIColor(white: 0, alpha: 0.1).CGColor
        self.captureButton.layer.shadowOpacity = 0.8
        self.captureButton.layer.shadowRadius = 0
        self.captureButton.layer.shadowOffset = CGSizeMake(0, 3)
        self.captureButton.layer.cornerRadius = self.captureButton.frame.width/2
        self.captureButton.backgroundColor = UIColor(white: 1, alpha: 0.2)
        
        // Configure Navigation Bar
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // Setup Camera
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cameraView = LLSimpleCamera(quality: CameraQualityHigh, andPosition: CameraPositionBack)
            self.cameraView.view.frame = self.view.frame
            self.cameraView.view.alpha = 0
            self.cameraView.start()
            self.view.insertSubview(self.cameraView.view, belowSubview: self.captureButton)
            
            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.cameraView.view.alpha = 1
            }, completion: nil)
            
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start Camera View
        if self.cameraView != nil {
            self.cameraView.start()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let pageController = self.navigationController as PageController
        pageController.rootController.unlockPageView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let viewController = segue.destinationViewController as PostController
        let pageController = self.navigationController as PageController
        viewController.capturedImage = self.capturedImage
        viewController.cameraController = self
        pageController.rootController.lockPageView()
    }
    
    // MARK: IBActions
    @IBAction func goToQuestions(sender: UIBarButtonItem) {
        self.slideToQuestions()
    }
    
    @IBAction func goToSettings(sender: UIBarButtonItem) {
        self.slideToSettings()
    }
    
    @IBAction func captureImage(sender: UIButton) {
        self.cameraView.capture { (camera: LLSimpleCamera!, image: UIImage!, metaInfo:[NSObject : AnyObject]!, error: NSError!) -> Void in
            if image != nil && error == nil {
                self.capturedImage = image
                self.performSegueWithIdentifier("postSegue", sender: self)
            } else {
                UIAlertView(title: "Capture Image", message: "Sorry! We failed to take the image.", delegate: nil, cancelButtonTitle: "Ok").show()
                self.cameraView.start()
            }
            
            self.captureButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.captureButton.backgroundColor = UIColor(white: 1, alpha: 0.2)
        }
    }
    
    @IBAction func captureDown(sender: UIButton) {
        self.captureButton.layer.borderColor = UIColor(red:0, green:0.74, blue:0.83, alpha:1).CGColor
        self.captureButton.backgroundColor = UIColor(red:0, green:0.74, blue:0.83, alpha:0.2)
    }
    
    @IBAction func captureExit(sender: UIButton) {
        self.captureButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.captureButton.backgroundColor = UIColor(white: 1, alpha: 0.2)
    }
    
    // MARK: Instance Methods
    func slideToQuestions() {
        let pageController = self.navigationController as PageController
        pageController.rootController.setActiveChildController(0, animated: true, direction: .Reverse)
    }
    
    func slideToSettings() {
        let pageController = self.navigationController as PageController
        pageController.rootController.setActiveChildController(2, animated: true, direction: .Forward)
    }
}
