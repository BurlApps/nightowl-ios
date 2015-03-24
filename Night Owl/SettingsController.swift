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
    private var themeColor = UIColor(red:0.25, green:0.32, blue:0.71, alpha:1)
    private var settings: Settings!
    private var user = User.current()
    
    // MARK: IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var freeQuestionsLabel: UILabel!

    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.navigationController?.navigationBar.barTintColor = self.themeColor
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
        
        // Set Fetch User Info
        self.reloadUser()
        
        // Get Settings
        Settings.sharedInstance { (settings) -> Void in
            self.settings = settings
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let pageController = self.navigationController as PageController
        pageController.rootController.unlockPageView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let pageController = self.navigationController as PageController
        pageController.rootController.lockPageView()
        
        if self.selectedRow != nil && self.selectedRow.section == 2 {
            let viewController = segue.destinationViewController as WebController
            
            switch(self.selectedRow.row) {
            case 0:
                viewController.name = "Support"
                viewController.website = self.settings.supportUrl
            case 1:
                viewController.name = "Privacy Policy"
                viewController.website = self.settings.privacyUrl
            default:
                viewController.name = "Terms of Use"
                viewController.website = self.settings.termsUrl
            }
        }
    }
    
    // MARK: InstanceMethods
    func reloadUser() {
        self.user.fetch { (user) -> Void in
            self.nameLabel.text = self.user.name
            self.phoneLabel.text = self.user.phone
            self.emailLabel.text = self.user.email
            self.freeQuestionsLabel.text = "\(self.user.freeQuestions)"
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: IBActions
    @IBAction func goToCamera(sender: UIBarButtonItem) {
        let pageController = self.navigationController as PageController
        pageController.rootController.setActiveChildController(1, animated: true, direction: .Reverse)
    }
    
    // MARK: UITableViewController Methods
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedRow = indexPath
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
