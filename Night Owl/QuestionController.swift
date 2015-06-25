//
//  QuestionController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/24/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class QuestionController: UIViewController, UIActionSheetDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, CNPPopupControllerDelegate {
    
    // MARK: Instance Variable
    var question: Assignment!
    var user = User.current()
    private var pages = 1
    private let startPage = 1
    private var currentPage = 1
    private var buttonState: Int!
    private var controllers = Dictionary<Int, ImageController>()
    private var pageController: UIPageViewController!
    private var rateController: CNPPopupController!
    
    // MARK: IBOutlets
    @IBOutlet weak var flagButton: UIBarButtonItem!
    @IBOutlet weak var pagesContainer: UIView!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background Color
        self.view.backgroundColor = UIColor.blackColor()
        
        // Check To See If Answer Is Available
        if self.question.answer != nil && contains([3, 7, 8], self.question.state) {
            self.pages += 1
        }
        
        // Check To Enable Flag
        if self.question.state != 3 {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        // Create Page View Controller
        self.pageController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        self.pageController.dataSource = self
        self.pageController.delegate = self
        self.pageController.view.backgroundColor = UIColor.blackColor()
        self.pageController.view.frame = CGRectMake(0, 0, self.pagesContainer.frame.width, self.pagesContainer.frame.height)
        self.addChildViewController(self.pageController)
        self.pagesContainer.addSubview(self.pageController.view)
        self.pageController.didMoveToParentViewController(self)
        self.updateLabel(0)
        
        // Rate Popup Controller
        var title = UILabel(frame: CGRectMake(0, 0, self.view.frame.width, 60))
        title.text = "How'd The Tutor Do?"
        title.textAlignment = NSTextAlignment.Center
        title.textColor = UIColor(red:0.26, green:0.27, blue:0.27, alpha:1)
        title.font = UIFont.boldSystemFontOfSize(24)
        title.backgroundColor = UIColor(red:0.97, green:0.99, blue:0.99, alpha:1)
        
        var birdSize: CGFloat = 115
        var ratingView = UIView(frame: CGRectMake(0, 20, birdSize*3, birdSize + 25))
        
        // Angry Bird
        var angryButton = CNPPopupButton(frame: CGRectMake(0, 0, birdSize, birdSize + 25))
        var angryBird = UIImageView(frame: CGRectMake(0, 0, birdSize, birdSize))
        var angryLabel = UILabel(frame: CGRectMake(0, birdSize, birdSize, 25))
        
        angryLabel.text = "Horrible!"
        angryLabel.textAlignment = NSTextAlignment.Center
        angryLabel.textColor = UIColor(red:0.97, green:0.65, blue:0.16, alpha:1)
        angryLabel.font = UIFont.boldSystemFontOfSize(20)
        
        angryBird.image = UIImage(named: "AngryBird")
        angryBird.contentMode = UIViewContentMode.ScaleAspectFit
        
        angryButton.addSubview(angryLabel)
        angryButton.addSubview(angryBird)
        
//        angryButton.selectionHandler = { (button: CNPPopupButton) in
//            self.rateController.dismissPopupControllerAnimated(true)
//        }
        
        ratingView.addSubview(angryButton)
        
        // Neutral Bird
        var neutralButton = CNPPopupButton(frame: CGRectMake(birdSize, 0, birdSize, birdSize + 25))
        var neutralBird = UIImageView(frame: CGRectMake(0, 0, birdSize, birdSize))
        var neutralLabel = UILabel(frame: CGRectMake(0, birdSize, birdSize, 25))
        
        neutralLabel.text = "Alright"
        neutralLabel.textAlignment = NSTextAlignment.Center
        neutralLabel.textColor = UIColor(red:0.25, green:0.7, blue:0.31, alpha:1)
        neutralLabel.font = UIFont.boldSystemFontOfSize(20)
        
        neutralBird.image = UIImage(named: "NeutralBird")
        neutralBird.contentMode = UIViewContentMode.ScaleAspectFit
        
        neutralButton.addSubview(neutralLabel)
        neutralButton.addSubview(neutralBird)
        
        //        neutralButton.selectionHandler = { (button: CNPPopupButton) in
        //            self.rateController.dismissPopupControllerAnimated(true)
        //        }
        
        ratingView.addSubview(neutralButton)
        
        
        // Happy Bird
        var happyButton = CNPPopupButton(frame: CGRectMake(birdSize*2, 0, birdSize, birdSize + 25))
        var happyBird = UIImageView(frame: CGRectMake(0, 0, birdSize, birdSize))
        var happyLabel = UILabel(frame: CGRectMake(0, birdSize, birdSize, 25))
        
        happyLabel.text = "Amazing!"
        happyLabel.textAlignment = NSTextAlignment.Center
        happyLabel.textColor = UIColor(red:0.22, green:0.68, blue:0.64, alpha:1)
        happyLabel.font = UIFont.boldSystemFontOfSize(20)
        
        happyBird.image = UIImage(named: "HappyBird")
        happyBird.contentMode = UIViewContentMode.ScaleAspectFit
        
        happyButton.addSubview(happyLabel)
        happyButton.addSubview(happyBird)
        
        //        happyButton.selectionHandler = { (button: CNPPopupButton) in
        //            self.rateController.dismissPopupControllerAnimated(true)
        //        }
        
        ratingView.addSubview(happyButton)
        
        self.rateController = CNPPopupController(contents: [title, ratingView])
        self.rateController.theme = CNPPopupTheme.defaultTheme()
        self.rateController.theme.popupContentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        self.rateController.theme.popupStyle = CNPPopupStyle.ActionSheet
        self.rateController.delegate = self
        self.rateController.presentPopupControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Customize Page Control
        var pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.backgroundColor = UIColor.clearColor()
        
        // Set First View
        self.pageController.setViewControllers([self.viewControllerAtIndex(0)],
            direction: .Forward, animated: false, completion: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: Instance Methods
    func updateLabel(index: Int) {
        if self.pages == 1 || index == 1  {
            self.title = "Question"
        } else {
            self.title = "Solution"
        }
    }
    
    func viewControllerAtIndex(index: Int) -> ImageController! {
        if index >= self.pages {
            return nil
        }
        
        // Create PageViewController
        var page = self.controllers[index]
        
        if page == nil {
            page = ImageController()
            page?.pageIndex = index
            page?.question = self.question
            page?.user = self.user
            
            if self.pages == 1 || index == 1 {
                page?.imageType = .Question
            } else {
                page?.imageType = .Answer
            }
            
            self.controllers[index] = page
        }
        
        return page
    }
    
    // MARK: Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        if finished && completed {
            var index = (previousViewControllers[0] as! ImageController).pageIndex
            index = 1 - index
        
            self.updateLabel(index)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ImageController).pageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        return self.viewControllerAtIndex(index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! ImageController).pageIndex
        
        if index == NSNotFound || (index + 1) == self.pages {
            return nil
        }
        
        return self.viewControllerAtIndex(index + 1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pages
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.startPage - 1
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
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != 3 {
            UIAlertView(title: "Answer Has Been Flagged!",
                message: "We are sorry for the inconvenience. This question have been assigned to a new tutor who will answer it shortly!",
                delegate: nil, cancelButtonTitle: "Okay").show()
            self.navigationController?.popViewControllerAnimated(true)
            self.question.changeState(buttonIndex + 4)
        }
    }
}
