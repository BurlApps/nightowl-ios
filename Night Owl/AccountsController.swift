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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        }
    }
    
    // MARK: UIAlertView Methods
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.title = "loading..."
            
            Parse.setApplicationId(self.account.appID, clientKey: self.account.appSecret)

            Settings.update { (settings) -> Void in
                User.logout()
                User.login { (user) -> Void in
                    Global.reloadQuestionsController()
                    Global.reloadSettingsController()
                    self.navigationController?.popViewControllerAnimated(true)
                    return ()
                }
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
            message: "This will logout the current user and create a new user account on the selected debug account.\n\nWARNING: Push Notifications will not work from now on. To renable push notifications, force the close app and reopen.",
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
        
        cell.textLabel?.text = account.name
        
        return cell
    }
}
