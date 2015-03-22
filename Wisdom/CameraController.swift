//
//  CameraController.swift
//  Wisdom
//
//  Created by Brian Vallelunga on 3/22/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class CameraController: PageController {
    
    // MARK: Instance Variables
    var imagePicker: UIImagePickerController!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Background
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Status Bar
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Configure Status Bar
        UIApplication.sharedApplication().statusBarHidden = false
    }
}
