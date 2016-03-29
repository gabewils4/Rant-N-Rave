//
//  RantVC.swift
//  Rant N' Rave
//
//  Created by Gabe Wilson on 12/31/15.
//  Copyright © 2015 Gabe Wilson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse


class RantNRave: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var sendButtonOutlet: UIBarButtonItem!
    @IBAction func endEditingButton(sender: AnyObject) {
        self.view.endEditing(true)
    }
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var cameraOutlet: UIBarButtonItem!
    @IBOutlet weak var sendOutlet: UIBarButtonItem!
    var chosenImage = UIImage()
    var imageExists = false
    var userCanceled = false
    var identifier = ""
    let picker = UIImagePickerController()
    var image = UIImagePickerController()
    var savedKeyBoardHeight = CGFloat()
    var amountOfLinesToBeShown:CGFloat = 6
    var long = 0.0
    var lat = 0.0
    var mapView = MKMapView()
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var placeHolder = ""
    var passedImage = UIImage()
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func takePhoto(sender: AnyObject) {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.cameraCaptureMode = .Photo
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func sendPost(sender: AnyObject) {
        let point = PFGeoPoint(location: currentLocation)
        let Post = PFObject(className: "Post")
        Post["currentLocation"] = point
        Post["centerLat"] = self.lat
        Post["centerLong"] = self.long
        Post["Comment"] = textView.text
        Post["image"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(self.passedImage, 0.5)!)
        Post["RantOrRave"] = self.identifier
        Post["upVotes"] = 0
        Post["downVotes"] = 0
        Post.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                print("saved")
            } else {
                // There was a problem, check error.description
            }
        }
        self.performSegueWithIdentifier("placesUnwindAction", sender: self)
    }
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.cameraCaptureMode = .Photo
        picker.cameraDevice = .Front
        presentViewController(picker, animated: true, completion: nil)
    }
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.placeHolder
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if !textView.text.isEmpty {
            self.sendButtonOutlet.enabled = true
        } else {
            self.sendButtonOutlet.enabled = false
        }
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        print("here at text view ends")
        return true
    }
    
    override func viewDidLoad() {
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        imageView.image = passedImage
        hideButtons()
        //print(textViewBottomConstraint.constant)
        picker.delegate = self
        textView.delegate = self
        mapView.delegate = self
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        navigationItem.title = identifier
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            print("here is my location.")
            self.currentLocation = locations.last!
            self.locationManager.stopUpdatingLocation()
    }
    
    func hideButtons() {
        textView.textColor = UIColor.lightGrayColor()
        if self.identifier == "Rave"
        {
            self.placeHolder = "Rave about something in your location!"
            
        } else {
            self.placeHolder = "Rant about something in your location!"
        }
        sendButtonOutlet.enabled = false
        toolBar.hidden = true
        self.navigationController?.navigationBar.hidden = true
    }
    
    func checkIdentifier() {
        print("This is the identifier", identifier)
        if identifier == "Rant" {
            let nav = self.navigationController?.navigationBar
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            navigationItem.leftBarButtonItem?.tintColor = UIColor.redColor()
            navigationItem.rightBarButtonItem?.tintColor = UIColor.redColor()
            nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.redColor()]
            cameraOutlet.tintColor = UIColor.redColor()
            sendOutlet.tintColor = UIColor.redColor()
        } else {
            let nav = self.navigationController?.navigationBar
            UIApplication.sharedApplication().statusBarStyle = .LightContent
            navigationItem.leftBarButtonItem?.tintColor = UIColor.greenColor()
            navigationItem.rightBarButtonItem?.tintColor = UIColor.greenColor()
            nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.greenColor()]
            cameraOutlet.tintColor = UIColor.greenColor()
            sendOutlet.tintColor = UIColor.greenColor()
        }
        showView()
    }
    
    func showView() {
        navigationController?.navigationBar.hidden = false
        toolBar.hidden = false
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        chosenImage = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            self.chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            imageView.contentMode = .ScaleAspectFit
            print("aqui")
            imageView.image = chosenImage
            self.imageExists = true
            dismissViewControllerAnimated(true, completion: nil)
            textViewDidChange(textView)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        self.userCanceled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        if imageView.image == nil {
            self.userCanceled = false
        } else {
            self.imageExists = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        print("aqui")
        imageView.frame.size.width = view.frame.size.width
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        print(self.imageExists)
        print(self.userCanceled)
        if self.imageExists == true || self.userCanceled == true {
            print("no need to image picker")
        } else {
            //TODO
        }
        checkIdentifier()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        //textViewBottomConstraint.constant = 0.0
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                //textViewBottomConstraint.constant -= keyboardHeight
                self.savedKeyBoardHeight = keyboardHeight
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }


}