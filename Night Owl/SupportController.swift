//
//  SupportController.swift
//  Night Owl
//
//  Created by Brian Vallelunga on 4/25/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

class SupportController: JSQMessagesViewController {

    // MARK: Instance Variables
    var messages: [JSQMessageData] = []
    private var user: User = User.current()
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Chat Room
        self.sender = self.user.parse.objectId
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.textView.placeHolder = "Message support..."
        
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
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.96, green:0.26, blue:0.21, alpha:1)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 22) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font,
                NSShadowAttributeName: shadow
            ]
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView.collectionViewLayout.springinessEnabled = true
        
        // Focus Text Box
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.inputToolbar.contentView.textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.inputToolbar.contentView.textView.resignFirstResponder()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        var message = JSQMessage(text: text, sender: sender, date: date)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.messages.append(message)
        self.finishSendingMessage()
    }
    
    
    // MARK: Instance Methods
    func recievedMessage(text: String) {
        var message = JSQMessage(text: text, sender: "support", date: NSDate())
        
        JSQSystemSoundPlayer.jsq_playMessageReceivedAlert()
        self.messages.append(message)
        self.finishReceivingMessage()
    }
    
    // MARK: IBActions
    @IBAction func goToQuestions(sender: UIBarButtonItem) {
        Global.slideToController(1, animated: true, direction: .Forward)
    }
    
    // MARK: MessageViewController Methods
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = self.messages[indexPath.item]
        
        if message.sender() == self.sender {
            cell.textView.textColor = UIColor.whiteColor()
            cell.textView.backgroundColor = UIColor(red:0.13, green:0.59, blue:0.95, alpha:1)
        } else {
            cell.textView.textColor = UIColor.blackColor()
            cell.textView.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1)
        }
        
        cell.textView.layer.cornerRadius = 15
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0;
    }
}
