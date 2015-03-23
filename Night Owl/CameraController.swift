//
//  CameraController.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class CameraController: UIViewController, VLBCameraViewDelegate {
    
    // MARK: Instance Variables
    var imagePicker: UIImagePickerController!
    
    // MARK: Private Instance Variables
    private var cameraView: VLBCameraView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Background
        self.view.backgroundColor = UIColor.blackColor()
        
        // VLBCameraView Set Delegate
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.cameraView = VLBCameraView(frame: self.view.frame)
            self.cameraView.delegate = self
            self.cameraView.awakeFromNib()
            self.cameraView.alpha = 0
            self.view.addSubview(self.cameraView)
            //self.view.insertSubview(self.cameraView, belowSubview: self.captureButton)
            
            UIView.animateWithDuration(0.5, delay: 0.3, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.cameraView.alpha = 1
            }, completion: nil)
            
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.cameraView != nil && !self.cameraView.session.running {
            self.cameraView.awakeFromNib()
        }
        
        // Configure Navigation Bar
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: IBActions
    @IBAction func goToQuestions(sender: UIBarButtonItem) {
        let pageController = self.navigationController as PageController
        pageController.rootController.setActiveChildController(0, animated: true, direction: .Reverse)
    }
    
    @IBAction func goToSettings(sender: UIBarButtonItem) {
        let pageController = self.navigationController as PageController
        pageController.rootController.setActiveChildController(2, animated: true, direction: .Forward)
    }
    
    // MARK: VLBCameraView Methods
    func cameraView(cameraView: VLBCameraView!, didFinishTakingPicture image: UIImage!, withInfo info: [NSObject : AnyObject]!, meta: [NSObject : AnyObject]!) {
        
    }
    
    func cameraView(cameraView: VLBCameraView!, didErrorOnTakePicture error: NSError!) {
        UIAlertView(title: "Capture Image", message: "Sorry! We failed to your image.", delegate: nil, cancelButtonTitle: "Ok").show()
        self.cameraView.retakePicture()
    }
}
