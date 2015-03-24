//
//  PostController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/23/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class PostController: UIViewController, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Instance Variables
    var capturedImage: UIImage!
    var cameraController: CameraController!
    private var cityLocation: String!
    private var textEditor: CHTTextView!
    private var previewImageView: UIImageView!
    private var subjects: [Subject] = []
    private var subjectChosen: Subject!
    private var settings: Settings!
    private var user: User = User.current()
    
    // MARK: IBOutlets
    @IBOutlet weak var subjectPicker: UIPickerView!
    @IBOutlet weak var pickerOffset: NSLayoutConstraint!
    @IBOutlet weak var pickerHeight: NSLayoutConstraint!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Subject Picker
        self.subjectPicker.delegate = self
        self.subjectPicker.dataSource = self
        self.subjectPicker.alpha = 0
        
        // Get Subjects
        Subject.subjects( true, callback: { (subjects) -> Void in
            self.subjects = subjects
            self.subjectChosen = subjects[subjects.count/2]
            self.subjectPicker.reloadAllComponents()
            self.subjectPicker.selectRow(subjects.count/2, inComponent: 0, animated: false)
            self.subjectPicker.alpha = 1
        })
        
        // Set Preview Image
        let imageSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        self.previewImageView = UIImageView(frame: self.view.frame)
        self.previewImageView.image = RBResizeImage(self.capturedImage, imageSize)
        self.view.insertSubview(self.previewImageView, belowSubview: self.subjectPicker)
        
        // Add Darkener
        var darkener = UIView(frame: self.view.frame)
        darkener.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.insertSubview(darkener, belowSubview: self.subjectPicker)
        
        // Add Text Editor
        self.textEditor = CHTTextView(frame: self.view.frame)
        self.textEditor.delegate = self
        self.textEditor.frame.size.width -= 40
        self.textEditor.frame.origin.x += 20
        self.textEditor.frame.origin.y += 110
        self.textEditor.scrollEnabled = false
        self.textEditor.placeholder = "Give us a description"
        self.textEditor.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        self.textEditor.textColor = UIColor.whiteColor()
        self.textEditor.textAlignment = NSTextAlignment.Center
        self.textEditor.backgroundColor = UIColor.clearColor()
        self.textEditor.layer.shadowColor = UIColor(white: 0, alpha: 0.2).CGColor
        self.textEditor.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.textEditor.layer.shadowOpacity = 1
        self.textEditor.layer.shadowRadius = 0
        self.view.insertSubview(self.textEditor, belowSubview: self.subjectPicker)
        
        // Register for keyboard notifications
        var notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyboardDidShow:"), name:UIKeyboardDidShowNotification, object: nil)
        
        // Get Settings
        Settings.sharedInstance { (settings) -> Void in
            self.settings = settings
            self.navigationItem.title = "0/\(settings.questionNameLimit)"
        }
        
        // Configure Navigation Bar
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 22) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font
            ]
        }
        
        if let font = UIFont(name: "HelveticaNeue", size: 20) {
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([
                NSFontAttributeName: font
                ], forState: UIControlState.Normal)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Make Text Editor Active
        self.textEditor.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Make Text Editor Active
        self.textEditor.resignFirstResponder()
    }
    
    // MARK: IBActions
    @IBAction func canelPost(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func createPost(sender: UIBarButtonItem) {
        let editorText: NSString = self.textEditor.text
        let imageSize = CGSize(width: self.capturedImage.size.width/2, height: self.capturedImage.size.height/2)
        let imageResized = RBResizeImage(self.capturedImage, imageSize)
        
        if editorText.length == 0 {
            self.textEditor.placeholder = "Please enter a description"
            return
        }
        
        Assignment.create(editorText, question: imageResized, creator: self.user, subject: self.subjectChosen) { (assignment) -> Void in
            self.navigationController?.popViewControllerAnimated(false)
            self.cameraController.slideToQuestions()
        }
    }
    
    // MARK: NSNotificationCenter
    func keyboardDidShow(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        let keyboardRect = (userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey) as NSValue).CGRectValue()
                
        self.pickerHeight.constant = self.view.frame.height - keyboardRect.size.height - 190
        self.pickerOffset.constant = keyboardRect.size.height
        self.view.layoutIfNeeded()
    }
    
    // MARK: UIPickerView Methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.subjects.count
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.width - 50
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.subjects[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.subjectChosen = self.subjects[row]
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = view as UILabel!
        var shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha:0.2)
        shadow.shadowOffset = CGSizeMake(0, 2);
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel.backgroundColor = UIColor(red:1, green:0.88, blue:0.2, alpha:0.35)
            pickerLabel.textAlignment = .Center
        }
        
        pickerLabel.attributedText = NSAttributedString(string: self.subjects[row].name, attributes: [
            NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 26.0)!,
            NSForegroundColorAttributeName:UIColor.whiteColor(),
            NSShadowAttributeName: shadow
        ])

        return pickerLabel
    }
    
    // MARK: UITextView Methods
    func textView(textView: UITextView!, shouldChangeTextInRange range: NSRange, replacementText text: String!) -> Bool {
        return textView.text.utf16Count + (text.utf16Count - range.length) <= self.settings.questionNameLimit;
    }
    
    func textViewDidChange(textView: UITextView!) {
        var textColor = UIColor.whiteColor()
        var mutalableText = NSMutableAttributedString(attributedString: textView.attributedText)
        
        if mutalableText.length >= self.settings.questionNameLimit {
            textColor = UIColor(red:0.95, green:0.24, blue:0.31, alpha:1)
        } else if mutalableText.length >= self.settings.questionNameLimit/2 {
            textColor = UIColor(red:1, green:0.6, blue:0, alpha:1)
        }
        
        self.navigationItem.title = "\(textView.attributedText.length)/\(self.settings.questionNameLimit)"
        
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 22) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: textColor,
                NSFontAttributeName: font
            ]
        }
    }
}
