//
//  CameraController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class CameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    // MARK: IBOutlets
    @IBOutlet weak var captureButton: UIButton!
    
    // MARK: Instance Variables
    var cameraView: LLSimpleCamera!
    private var capturedImage: UIImage!
    
    // MARK: IBOutlets Variables
    @IBOutlet weak var toolbar: UIToolbar!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Background
        self.view.backgroundColor = UIColor.blackColor()
        
        // Set Back Button Color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
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
        
        self.toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.Any)
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        self.toolbar.backgroundColor = UIColor.clearColor()
        
        // Setup Camera
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cameraView = LLSimpleCamera(quality: CameraQualityHigh, andPosition: CameraPositionBack)
            self.cameraView.view.frame = self.view.frame
            self.cameraView.view.alpha = 0
            self.cameraView.start()
            self.view.insertSubview(self.cameraView.view, belowSubview: self.captureButton)
            
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.cameraView.view.alpha = 1
            }, completion: nil)
            
        })
    }
    
    override func viewDidLayoutSubviews() {        
        if self.cameraView != nil {
            self.cameraView.view.frame = self.view.frame
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Unlock Page Controller
        Global.unlockPageView()
        
        // Start Camera View
        if self.cameraView != nil {
            self.cameraView.view.frame = self.view.frame
            self.cameraView.start()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let viewController = segue.destinationViewController as! PostController
        
        viewController.capturedImage = self.capturedImage
        viewController.cameraController = self
        
        Global.lockPageView()
    }
    
    // MARK: IBActions
    @IBAction func goToQuestions(sender: UIBarButtonItem) {
        self.slideToQuestions()
    }
    
    @IBAction func goToSettings(sender: UIBarButtonItem) {
        self.slideToSettings()
    }
    
    @IBAction func libraryImage(sender: UIBarButtonItem) {
        // Create Image Picker
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.mediaTypes = ["public.image"]
        self.presentViewController(imagePicker, animated: true, completion: { () -> Void in
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        })
    }

    @IBAction func shareFriends(sender: UIBarButtonItem) {
        Global.showInvite("cameraController", dismissed: nil)
    }
    
    @IBAction func captureImage(sender: UIButton) {
        self.cameraView.capture ({ (camera: LLSimpleCamera!, var image: UIImage!, metaInfo:[NSObject : AnyObject]!, error: NSError!) -> Void in
            if image != nil && error == nil {
                self.capturedImage = image.fixOrientation()
                self.performSegueWithIdentifier("postSegue", sender: self)
            } else {
                UIAlertView(title: "Aww Snap!", message: "Sorry! We failed to take the picture.", delegate: nil, cancelButtonTitle: "Try Again").show()
                self.cameraView.stop()
                self.cameraView.start()
            }
            
            self.captureButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.captureButton.backgroundColor = UIColor(white: 1, alpha: 0.2)
        }, exactSeenImage: true)
    }
    
    @IBAction func captureDown(sender: UIButton) {
        self.captureButton.layer.borderColor = UIColor(red:1, green:0.88, blue:0.2, alpha:1).CGColor
        self.captureButton.backgroundColor = UIColor(red:1, green:0.88, blue:0.2, alpha:0.2)
    }
    
    @IBAction func captureExit(sender: UIButton) {
        self.captureButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.captureButton.backgroundColor = UIColor(white: 1, alpha: 0.2)
    }
    
    // MARK: UIImagePickerController Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // Close Image Picker
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            // Configure Status Bar
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
            
            // Post Segue
            self.capturedImage = image.fixOrientation()
            self.performSegueWithIdentifier("postSegue", sender: self)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Close Image Picker
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            // Configure Status Bar
            UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        })
    }
    
    // MARK: Instance Methods    
    func slideToQuestions() {
        Global.slideToController(1, animated: true, direction: .Reverse)
    }
    
    func slideToSettings() {
        Global.slideToController(3, animated: true, direction: .Forward)
    }
}
