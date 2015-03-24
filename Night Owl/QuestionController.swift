//
//  QuestionController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/24/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class QuestionController: UIViewController, UIScrollViewDelegate, UIActionSheetDelegate {
    
    // MARK: Instance Variable
    var question: Assignment!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var user = User.current()
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update Title
        let title = NSString(string: self.question.name)
        let length = min(15, title.length)
        self.title = title.substringToIndex(length)
        
        if title.length > 15 {
            self.title = self.title! + "..."
        }
        
        // Set Back Button Color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Set Background Color
        self.view.backgroundColor = UIColor.blackColor()
        
        // Create Loading Spinner
        var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.frame = CGRectMake(0, 0, 40, 40)
        spinner.center = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        spinner.startAnimating()
        self.view.addSubview(spinner)
        
        // Create Scroll View
        self.scrollView = UIScrollView(frame: self.view.frame)
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 10
        self.view.addSubview(self.scrollView)
        
        // Create Image View
        self.imageView = UIImageView(frame: self.view.frame)
        self.scrollView.addSubview(self.imageView)
        
        // Download Answer
        question.getAnswer { (image) -> Void in
            self.imageView.image = image
            spinner.stopAnimating()
        }
    }
    
    // MARK: IBActions
    @IBAction func flagAnswer(sender: UIBarButtonItem) {
        var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil, otherButtonTitles: "Incorrect Answer", "Not Enough Steps", "Messy Handwriting", "Cancel")
        actionSheet.destructiveButtonIndex = 3
        actionSheet.cancelButtonIndex = 3
        actionSheet.actionSheetStyle = UIActionSheetStyle.Automatic
        actionSheet.showInView(self.view)
    }
    
    // MARK: UIActionSheet Methods
    func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != 3 {
            self.question.changeState(buttonIndex + 4)
            UIAlertView(title: "Answer Has Been Flagged", message: "We are sorry for the inconvenience. This question have been assigned to a new tutor who will answer it shortly!", delegate: nil, cancelButtonTitle: "Okay").show()
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: UIScrollView Methods
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
