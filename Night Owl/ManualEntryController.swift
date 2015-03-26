//
//  ManualEntryController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 3/26/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class ManualEntryController: UIViewController {
    
    // MARK: Instance Variables
    private var user = User.current()
    
    // MARK: IBoutlets
    @IBOutlet weak var cardInput: UITextField!
    @IBOutlet weak var expirationInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Inputs
        self.cardInput.borderStyle = .None
        self.expirationInput.borderStyle = .None
        self.cvcInput.borderStyle = .None
        
        self.cardInput.leftView = UIView(frame: CGRectMake(0, 0, 20, 20))
        self.expirationInput.leftView = UIView(frame: CGRectMake(0, 0, 20, 20))
        self.cvcInput.leftView = UIView(frame: CGRectMake(0, 0, 20, 20))
        
        self.cardInput.leftViewMode = .Always
        self.expirationInput.leftViewMode = .Always
        self.cvcInput.leftViewMode = .Always
        
        self.cardInput.layer.borderWidth = 1
        self.expirationInput.layer.borderWidth = 1
        self.cvcInput.layer.borderWidth = 1
        
        self.cardInput.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.expirationInput.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.cvcInput.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        // Card Input First Responder
        self.cardInput.becomeFirstResponder()
    }
}
