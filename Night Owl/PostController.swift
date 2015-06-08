//
//  PostController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/23/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class PostController: UIViewController, ApplePayDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate {
    
    // MARK: Instance Variables
    var capturedImage: UIImage!
    var cameraController: CameraController!
    var cardWasAdded = false
    private var textEditor: CHTTextView!
    private var previewImageView: UIImageView!
    private var subjects: [Subject] = []
    private var subjectChosen: Subject!
    private var user: User = User.current()
    private var settings: Settings!
    private var storyBoard = UIStoryboard(name: "Main", bundle: nil)
    private var alertMode: AlertMode!
    private var applePay: ApplePay!
    
    // MARK: Enums
    enum AlertMode {
        case AskForCard, ThankYou, PaymentError
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var subjectPicker: UIPickerView!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var postBigButton: UIButton!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Background
        self.view.backgroundColor = UIColor.blackColor()
        
        // Disable Post Buttons
        self.postButton.enabled = false
        self.postBigButton.enabled = false
        
        // Configure Subject Picker
        self.subjectPicker.delegate = self
        self.subjectPicker.dataSource = self
        
        // Get Subjects
        Subject.subjects(true, callback: { (subjects) -> Void in
            self.subjects = subjects
            var index: Int = subjects.count/2
            
            if self.user.subject != nil {
                for (i, subject) in enumerate(subjects) {
                    if self.user.subject.name == subject.name {
                        index = i
                        break
                    }
                }
            }
            
            self.subjectChosen = subjects[index]
            self.subjectPicker.reloadAllComponents()
            self.subjectPicker.selectRow(index, inComponent: 0, animated: false)
        })
        
        // Add Post Button Style
        var buttonBorder = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 3))
        buttonBorder.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.postBigButton.addSubview(buttonBorder)
        self.postBigButton.backgroundColor = UIColor(red:0.27, green:0.62, blue:0.7, alpha:0.8)
        
        // Set Preview Image
        let imageSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        self.previewImageView = UIImageView(frame: self.view.frame)
        self.previewImageView.contentMode = .Center
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
        self.textEditor.frame.origin.y += 90
        self.textEditor.scrollEnabled = false
        self.textEditor.placeholder = "Tell us which problem\n(optional)"
        self.textEditor.font = UIFont(name: "HelveticaNeue-Bold", size: 24)
        self.textEditor.textColor = UIColor.whiteColor()
        self.textEditor.textAlignment = NSTextAlignment.Center
        self.textEditor.backgroundColor = UIColor.clearColor()
        self.textEditor.layer.shadowColor = UIColor(white: 0, alpha: 0.2).CGColor
        self.textEditor.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.textEditor.layer.shadowOpacity = 1
        self.textEditor.layer.shadowRadius = 0
        self.textEditor.returnKeyType = .Done
        self.view.insertSubview(self.textEditor, belowSubview: self.subjectPicker)
        
        // Set Current Price
        Settings.sharedInstance { (settings) -> Void in
            self.settings = settings

            if self.user.freeQuestions > 0 {
                self.title = "\(self.user.freeQuestions) Free Left"
            } else if settings.questionPrice == 0 {
                self.title = "Free Right Now!"
            } else {
                self.title = "Price: \(settings.priceFormatted())"
            }
            
            self.postButton.tintColor = UIColor(white: 1, alpha: 1)
            self.postButton.enabled = true
            self.postBigButton.enabled = true
        }
        
        if let font = UIFont(name: "HelveticaNeue", size: 20) {
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([
                NSFontAttributeName: font
                ], forState: UIControlState.Normal)
        }
        
        // Create Apple Pay
        self.applePay = ApplePay(user: self.user)
        self.applePay.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Configure Navigation Bar
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // Create Text Shadow
        var shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
        shadow.shadowOffset = CGSizeMake(0, 2);
        
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 22) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor(red:0.16, green:0.71, blue:0.96, alpha:1),
                NSFontAttributeName: font,
                NSShadowAttributeName: shadow
            ]
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.cardWasAdded {
            self.cardAdded()
        }
    }
    
    // MARK: Instance Methods
    func createAssignment() {
        var editorText: NSString! = self.textEditor.text
        
        if editorText.length == 0 {
            editorText = nil
        }
        
        var description = editorText as? String
        
        self.user.chargeQuestion(description, callback: { (error) -> Void in
            if error == nil {
                Assignment.create(description, question: self.capturedImage, creator: self.user, subject: self.subjectChosen)
                
                self.user.updateSubject(self.subjectChosen)
                self.cameraController.slideToQuestions()
            } else {
                self.alertMode = .PaymentError
                UIAlertView(title: "Payment Error",
                    message: "An error occurred processing your payment. Please update your payment information!",
                    delegate: self, cancelButtonTitle: "Okay").show()
            }
        })
    }
    
    func cardAdded() {
        self.alertMode = .ThankYou
        UIAlertView(title: "Thank You For Adding Your Information!",
            message: "As promised, this answer is completely on us!",
            delegate: self, cancelButtonTitle: "Okay").show()
    }

    // MARK: IBActions
    @IBAction func canelPost(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func createPost(sender: AnyObject) {
        if self.user.freeQuestions < 1 && self.settings.questionPrice > 0 && self.user.card == nil {
            self.alertMode = .AskForCard
            
            UIAlertView(title: "Want This Answer Free?",
                message: "Add your payment information to get this one us! Don't worry, we WON'T charge you until you use up your free questions.",
                delegate: self, cancelButtonTitle: "No Thanks", otherButtonTitles: "Add Info").show()
        } else {
            self.createAssignment()
        }
    }
    
    // MARK: UIAlertView Methods
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if self.alertMode == .AskForCard {
            if buttonIndex == 0 {
                self.navigationController?.popViewControllerAnimated(false)
            } else {
                if self.applePay.enabled {
                    self.presentViewController(self.applePay.getModal(), animated: true, completion: nil)
                } else {
                    self.paymentsControllerShow()
                }
            }
        } else if self.alertMode == .ThankYou {
            self.user.creditQuestions(1)
            self.createAssignment()
        } else {
            self.navigationController?.popViewControllerAnimated(false)
        }
        
        self.alertMode = nil
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
        var pickerLabel = view as! UILabel!
        var shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha:0.1)
        shadow.shadowOffset = CGSizeMake(0, 2);
        
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel.backgroundColor = UIColor(red:1, green:0.88, blue:0.2, alpha:0.8)
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
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.textEditor.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    // MARK: Payment Methods
    func paymentsControllerShow() {
        var paymentController = self.storyBoard.instantiateViewControllerWithIdentifier("PaymentController") as? PaymentController
        paymentController?.postController = self
        self.navigationController?.pushViewController(paymentController!, animated: true)
    }
    
    func applePayAuthorized(authorized: Bool) {
        self.cardWasAdded = authorized
    }
    
    func applePayClose() {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            if self.cardWasAdded {
                self.cardAdded()
            } else {
                self.paymentsControllerShow()
            }
        })
    }
}
