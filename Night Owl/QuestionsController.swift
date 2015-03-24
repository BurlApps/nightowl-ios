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
    
    // MARK: Instance Methods
    func reloadQuestions() {
        self.user.getAssignments { (assignments) -> Void in
            self.title = "Questions"
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
                if NSString(string: question.name).containsString(filter) {
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var company = self.questionsFiltered[indexPath.row]
        var cell: UITableViewCell! = self.tableView.cellForRowAtIndexPath(indexPath)
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        println(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var question = self.questionsFiltered[indexPath.row]
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: self.cellIdentifier)
            cell.textLabel?.textColor = UIColor.darkGrayColor()
            cell.textLabel?.font = UIFont.systemFontOfSize(18)
        }
        
        cell.textLabel?.text = question.name
        
        return cell
    }


}
