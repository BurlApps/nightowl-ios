//
//  AccountsController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 4/1/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class AccountsController: UITableViewController, UIAlertViewDelegate {
    
    // MARK: Instance Variables
    private var accounts: [DebugAccount] = []
    private var cellIdentifier = "cell"
    private var account: DebugAccount!
    private var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Spinner
        self.spinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
        self.spinner.center = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        self.spinner.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.spinner)
        
        // Add Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("reloadAccounts"), forControlEvents: UIControlEvents.ValueChanged)
        
        // Reload Questions
        self.reloadAccounts()
    }
    
    // MARK: Instance Methods
    func reloadAccounts() {
        DebugAccount.accounts { (accounts) -> Void in
            self.accounts = accounts
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }
    
    // MARK: UIAlertView Methods
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.title = "loading..."
            
            User.logout()
            Parse.setApplicationId(self.account.appID, clientKey: self.account.appSecret)
            Subject.subjects(false, callback: nil)
            Settings.update { (settings) -> Void in
                DebugAccount.setAlternateDebug(self.account.name)
                Global.showHomeController()
            }
        }
    }
    
    // MARK: UITableViewController Methods
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.account = self.accounts[indexPath.row]
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        UIAlertView(title: "Confirm Change",
            message: "This will logout the current user and create a new user account on the selected debug account.",
            delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Confirm ").show()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var account = self.accounts[indexPath.row]
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: self.cellIdentifier)
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.systemFontOfSize(18)
        }
        
        if account.name == DebugAccount.accountActive() {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        cell.textLabel?.text = account.name
        return cell
    }
}
