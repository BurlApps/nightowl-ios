//
//  AssignmentsController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/23/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class QuestionsController: UITableViewController, UISearchBarDelegate {
    
    // MARK: Instance Variables
    private var user: User = User.current()
    private var questions: [Assignment] = []
    private var questionsFiltered: [Assignment] = []
    private var question: Assignment!
    private var cellIdentifier = "cell"
    
    // MARK: IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Text Shadow
        var shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
        shadow.shadowOffset = CGSizeMake(0, 2);
        
        // Configure Navigation Bar
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.08, green:0.58, blue:0.53, alpha:1)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 22) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font,
                NSShadowAttributeName: shadow
            ]
        }
        
        // Configure Search Bar
        self.searchBar.delegate = self
        
        // Add Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: Selector("reloadQuestions"), forControlEvents: UIControlEvents.ValueChanged)
        
        // Load Questions
        self.reloadQuestions()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let pageController = self.navigationController as PageController
        pageController.rootController.unlockPageView()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let viewController = segue.destinationViewController as QuestionController
        let pageController = self.navigationController as PageController
        viewController.question = self.question
        pageController.rootController.lockPageView()
    }
    
    // MARK: Instance Methods
    func reloadQuestions() {
        self.user.getAssignments { (assignments) -> Void in
            self.questions = assignments
            self.filterQuestions(self.searchBar.text)
            self.refreshControl?.endRefreshing()
        }
    }
    
    func filterQuestions(filter: String) {
        self.questionsFiltered = []
        
        if filter.isEmpty {
            self.questionsFiltered = self.questions
        } else {
            for question in self.questions {
                let containsName = NSString(string: question.name).containsString(filter)
                let containsSubject = NSString(string: question.subject.name).containsString(filter)
                
                if containsName || containsSubject {
                    self.questionsFiltered.append(question)
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: IBActions
    @IBAction func goToCamera(sender: UIBarButtonItem) {
        let pageController = self.navigationController as PageController
        pageController.rootController.setActiveChildController(1, animated: true, direction: .Forward)
    }
    
    // UISearchBar Methods
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterQuestions(self.searchBar.text)
    }
    
    // UITableViewController Methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questionsFiltered.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var question = self.questionsFiltered[indexPath.row]
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if question.state >= 3 {
            self.question = question
            self.performSegueWithIdentifier("questionSegue", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var question = self.questionsFiltered[indexPath.row]
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: self.cellIdentifier)
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.systemFontOfSize(18)
            cell.detailTextLabel?.textColor = UIColor.grayColor()
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(15)
        }
        
        cell.imageView?.image = UIImage(named: "Cirlce")
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if question.state >= 3 {
            cell.selectionStyle = UITableViewCellSelectionStyle.Gray
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        
        switch(question.state) {
        case 0:
            if let size = cell.imageView?.image?.size {
                var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                spinner.frame = CGRectMake(0, 0, size.width, size.height)
                spinner.hidesWhenStopped = true
                spinner.startAnimating()
                cell.imageView?.tintColor = UIColor.whiteColor()
                cell.imageView?.addSubview(spinner)
            }
        case 1: cell.imageView?.tintColor = UIColor(red:0.62, green:0.62, blue:0.62, alpha:0.25)
        case 2: cell.imageView?.tintColor = UIColor(red:0.01, green:0.66, blue:0.96, alpha:0.5)
        case 3: cell.imageView?.tintColor = UIColor(red:0.3, green:0.69, blue:0.31, alpha:0.75)
        default: cell.imageView?.tintColor = UIColor(red:0.96, green:0.26, blue:0.21, alpha:0.75)
        }

        cell.textLabel?.text = question.name
        cell.detailTextLabel?.text = question.subject.name
        
        return cell
    }


}
