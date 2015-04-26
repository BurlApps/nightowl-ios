//
//  SettingsController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/23/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class SettingsController: UITableViewController {
    
    // MARK: Instance Variables
    private var selectedRow: NSIndexPath!
    private var settings: Settings!
    private var user = User.current()
    private var numberOfSections = 3
    
    // MARK: IBOutlets
    @IBOutlet weak var freeQuestionsLabel: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var questionPrice: UILabel!
    @IBOutlet weak var debugAccount: UILabel!

    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Back Button Color
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Create Text Shadow
        var shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
        shadow.shadowOffset = CGSizeMake(0, 2);
        
        // Add Bottom Border To Nav Bar
        if let frame = self.navigationController?.navigationBar.frame {
            var navBorder = UIView(frame: CGRectMake(0, frame.height-1, frame.width, 1))
            navBorder.backgroundColor = UIColor(white: 0, alpha: 0.2)
            self.navigationController?.navigationBar.addSubview(navBorder)
        }
        
        // Configure Navigation Bar
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.25, green:0.32, blue:0.71, alpha:1)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 22) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font,
                NSShadowAttributeName: shadow
            ]
        }
        
        // Add Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("reloadUser"), forControlEvents: UIControlEvents.ValueChanged)
        
        // Get Settings
        Settings.sharedInstance { (settings) -> Void in
            self.settings = settings
            self.questionPrice.text = settings.priceFormatted()
        }
        
        // Hide Labels
        self.hideLabels()
        
        // Set Fetch User Info
        self.reloadUser()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if Settings.getRelease() && self.numberOfSections == 3  {
            self.numberOfSections -= 1
            self.tableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: UITableViewRowAnimation.None)
        } else {
            self.debugAccount.text = DebugAccount.accountActive()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Global.unlockPageView()
        Global.cameraController(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        Global.lockPageView()
        
        if self.selectedRow != nil {
            if self.selectedRow.section == 0 {
                Global.cameraController(false)
            } else if self.selectedRow.section == 1 {
                let viewController = segue.destinationViewController as! WebController
                
                if self.selectedRow.row == 0 {
                    viewController.name = "Privacy Policy"
                    viewController.website = self.settings.privacyUrl
                } else {
                    viewController.name = "Terms of Use"
                    viewController.website = self.settings.termsUrl
                }
            }
        }
    }
    
    // MARK: InstanceMethods
    func hideLabels() {
        self.cardLabel.textColor = UIColor.clearColor()
        self.freeQuestionsLabel.textColor = UIColor.clearColor()
    }
    
    func reloadUser() {
        if self.cardLabel != nil {
            self.user = User.current()
            
            self.user.fetch { (user) -> Void in
                self.hideLabels()
                
                if self.user.card != nil {
                    self.cardLabel.text = self.user.card
                    self.cardLabel.textColor = UIColor.grayColor()
                }
                
                if self.user.freeQuestions != nil {
                    self.freeQuestionsLabel.text = "\(self.user.freeQuestions)"
                    self.freeQuestionsLabel.textColor = UIColor.grayColor()
                }
                
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func goToCamera(sender: UIBarButtonItem) {
        Global.slideToController(2, animated: true, direction: .Reverse)
    }
    
    // MARK: UITableViewController Methods
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedRow = indexPath
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: UITableViewController Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.numberOfSections
    }
}
