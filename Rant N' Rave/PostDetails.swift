//
//  PostDetails.swift
//  Rant N' Rave
//
//  Created by Gabe Wilson on 1/17/16.
//  Copyright © 2016 Gabe Wilson. All rights reserved.
//


import UIKit
import CoreLocation
import Parse


class PostDetails: UIViewController{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    var objectIdArray = [String]()
    var imagesArray = [UIImage]()
    var commentsArray = [String]()
    var passedId = ""
    var selectedAnnotationTitle = ""
    var yPlacement: CGFloat = 0.0
    var xPlacement: CGFloat = 0.0
    
    override func viewDidLoad() {
        print("This is run on the background queue")
        self.createScrollView()
        /*
        backgroundThread(background: {
            //self.pullImage2()
            // Your function here to run in the background
            },
            completion: {
                self.createScrollView()
                // A function to run in the foreground when the background thread is complete
        })*/

    }
    
    func backgroundThread(delay: Double = 1.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }
    
    
    func pullImage2() {

        imagesArray.removeAll()
        commentsArray.removeAll()
        print(objectIdArray)
        if objectIdArray.count > 0
        {
            for var ii = 0; ii < objectIdArray.count; ii++
            {
                let query = PFQuery(className: "Post")
                print(objectIdArray[ii])
                query.orderByDescending("createdAt")
                query.getObjectInBackgroundWithId(objectIdArray[ii]) {
                (object: PFObject?, error: NSError?) -> Void in
                    if error == nil && object != nil {
                        if let image = object!["image"] as? PFFile {
                            image.getDataInBackgroundWithBlock {
                                (imageData:NSData?, error:NSError?) -> Void in
                                if error == nil  {
                                    if let finalimage = UIImage(data: imageData!) {
                                        self.imagesArray.append(finalimage)
                                        let comment = object!["Comment"] as! String
                                        self.commentsArray.append(comment)
                                        print("append", ii, comment)
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }

    func createScrollView() {
        print("Creating scroll view")
        let imageHeight:CGFloat = 300
        let imageWidth:CGFloat = 320
        let textWidth:CGFloat = 300
        let textHeight:CGFloat = 35
        var yPosition: CGFloat = 0
        let buttonWidth:CGFloat = 30
        let buttonHeight:CGFloat = 30
        var scrollViewContentSize:CGFloat = 0
        self.scrollView.contentSize.height = CGFloat(imagesArray.count * Int(imageHeight + 50))
        print(self.imagesArray.count)
        self.view.backgroundColor = UIColor.lightGrayColor()
        for var index = 0; index<self.imagesArray.count; index++ {
            let image = self.imagesArray[index]
            print(objectIdArray.indexOf(objectIdArray[index]))
            let newImageView = UIImageView()
            newImageView.image = image
            newImageView.frame.size.width = imageWidth - 20
            newImageView.frame.size.height = imageHeight + 20
            newImageView.center = self.view.center
            newImageView.frame.origin.y = yPosition
            
            self.scrollView.addSubview(newImageView)
            yPosition += imageHeight + 50
            
            
            let newTextView: UITextView = UITextView()
            newTextView.editable = false
            newTextView.tintColor = UIColor.magentaColor()
            newTextView.backgroundColor = UIColor(white: 6, alpha: 12.0)
            newTextView.text = self.commentsArray[index]
            
            newTextView.frame.size.width = textWidth
            newTextView.frame.size.height = textHeight
            if self.commentsArray[index] == self.selectedAnnotationTitle {
                print("caught by the name of", self.commentsArray[index])
                self.yPlacement = yPosition - 350
                self.xPlacement = newImageView.frame.size.width
                print(self.xPlacement, self.yPlacement)
                
            }
            newTextView.center = self.view.center
            newTextView.frame.origin.y = yPosition - 45
            self.scrollView.addSubview(newTextView)
            
            
            let button   = UIButton(type: UIButtonType.System) as UIButton
            button.center = newTextView.center
            button.center.x = newTextView.center.x + 70
            button.center.y = newTextView.center.y - 15
            button.frame.size.height = buttonHeight
            button.frame.size.width = buttonWidth
            button.backgroundColor = UIColor.lightGrayColor()
            button.tintColor = UIColor.greenColor()
            button.setTitle("√", forState: UIControlState.Normal)
            button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = index
            self.scrollView.addSubview(button)
            
            let button2   = UIButton(type: UIButtonType.System) as UIButton
            button2.center = newTextView.center
            button2.center.x = newTextView.center.x + 110
            button2.center.y = newTextView.center.y - 15
            button2.frame.size.height = buttonHeight
            button2.frame.size.width = buttonWidth
            button2.backgroundColor = UIColor.lightGrayColor()
            button2.tintColor = UIColor.redColor()
            button2.setTitle("X", forState: UIControlState.Normal)
            button2.addTarget(self, action: "buttonAction2:", forControlEvents: UIControlEvents.TouchUpInside)
            button2.tag = index
            self.scrollView.addSubview(button2)
            scrollViewContentSize += imageHeight + 100
            
            //self.scrollView.contentSize = CGSize(width: imageWidth, height: imageHeight)
        }
        print("all dunzo")
        print(self.xPlacement, self.yPlacement)
        scrollView.setContentOffset(CGPointMake(self.xPlacement, self.yPlacement), animated: true)
    }
    
    func buttonAction(sender:UIButton!)
    {
        let query = PFQuery(className:"Post")
        query.getObjectInBackgroundWithId(objectIdArray[sender.tag]) {
            (upVotes: PFObject?, error: NSError?) -> Void in
            upVotes!.incrementKey("upVotes")
            upVotes!.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The score key has been incremented
                } else {
                    // There was a problem, check error.description
                }
            }
        }
        
        print(objectIdArray[sender.tag])
        sender.enabled = false
        print("Check tapped")
    }
    
    func buttonAction2(sender:UIButton!)
    {
        let query = PFQuery(className:"Post")
        query.getObjectInBackgroundWithId(objectIdArray[sender.tag]) {
            (upVotes: PFObject?, error: NSError?) -> Void in
            upVotes!.incrementKey("downVotes")
            upVotes!.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The score key has been incremented
                } else {
                    // There was a problem, check error.description
                }
            }
        }
        print(objectIdArray[sender.tag])
        sender.enabled = false
        print("X tapped")
    }
    
    func pullComment() {
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (post:[PFObject]?, error:NSError?) -> Void in
            for object : PFObject in (post)! {
                if let comment = object["Comment"] as? String {
                //self.textView.text = comment
                print(comment)
                self.commentsArray.append(comment)
            }
        }
    }
    }
    
    
    
}