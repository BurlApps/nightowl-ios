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
    private var user = User.current()
    private var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor(red:0.13, green:0.59, blue:0.95, alpha:1))
    private var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor(red:0.93, green:0.94, blue:0.95, alpha:1))
    
    // MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure Chat Room
        self.sender = self.user.parse.objectId
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.textView.placeHolder = "Tell us how we can help..."
        
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
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0, green:0.44, blue:0.59, alpha:1)
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: UIBarMetrics.Default)
        
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 22) {
            self.navigationController?.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: font,
                NSShadowAttributeName: shadow
            ]
        }
        
        // Load Messages
        self.reloadMessages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        Message.create(text, user: self.user)
        
        self.messages.append(message)
        self.finishSendingMessage()
    }
    
    
    // MARK: Instance Methods
    func reloadMessages() {
        self.user = User.current()
        
        Message.messages(self.user, callback: { (messages) -> Void in
            self.messages = []
            
            for message in messages {
                var sender = "support"
                
                if message.byUser == true {
                    sender = self.sender
                }
                
                var tempMessage = JSQMessage(text: message.text, sender: sender, date: message.created)
                self.messages.append(tempMessage)
            }
            
            self.finishReceivingMessage()
        })
    }
    
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
        var image: UIImageView!
        
        let message = messages[indexPath.item]
        
        if message.sender() == self.sender {
            image = self.outgoingBubbleImageView
        } else {
            image = self.incomingBubbleImageView
        }
        
        return UIImageView(image: image.image, highlightedImage: image.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        var showTime = false
        
        if indexPath.item == 0 {
            showTime = true
        } else {
            let prevMessage = self.messages[indexPath.item - 1]
            let interval = message.date().timeIntervalSinceDate(prevMessage.date())
            
            showTime = floor(interval/3600) > 0
        }
        
        if(showTime) {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date())
        } else {
            return nil
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = self.messages[indexPath.item]
        
        if message.sender() == self.sender {
            cell.textView.textColor = UIColor.whiteColor()
        } else {
            cell.textView.textColor = UIColor.blackColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = self.messages[indexPath.item]
        var showTime = false
        
        if indexPath.item == 0 {
            showTime = true
        } else {
            let prevMessage = self.messages[indexPath.item - 1]
            let interval = message.date().timeIntervalSinceDate(prevMessage.date())
            
            showTime = floor(interval/3600) > 0
        }
        
        if(showTime) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault + 10
        } else {
            return CGFloat(0.0)
        }
    }
}
