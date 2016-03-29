//
//  LoginViewController.swift
//  FriendManager
//
//  Created by A Wilson on 6/16/15.
//  Copyright (c) 2015 A Wilson. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var signupActive = true
    var loggedIn = false
    
    let success = true
    let fail = false
    var shouldSegue = false
    var unwinded = false
    var barbuttonOutlet = UIButton()
    
    @IBOutlet weak var textFieldBackground: UITextField!
    
    @IBOutlet weak var username: UITextField!
    
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var email: UITextField!
    
    
    
    
    @IBOutlet weak var submitButton: UIButton!
    
    
    
    @IBOutlet weak var toggleScreenButton: UIButton!
    
    @IBOutlet weak var endEditingButtonOutlet: UIButton!
    
    @IBOutlet weak var loggedUser: UILabel!
    
    @IBAction func endEditingButton(sender: AnyObject) {
        print("inside end editing")
        self.view.endEditing(true)
    }
    
    @IBAction func submitButtonAction(sender: AnyObject) {
        
        var error: String = ""
        
        
        if checkUserInput(username.text!, password: password.text!) == fail {
            return
        }
        
        
        var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 10, 37, 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        
        
        
        // Attempt to Sign Up User
        if signupActive  {
            
            
            
            
            // Attempt to signup user
            var user = PFUser()
            user.username = username.text
            user.password = password.text
            user.email = email.text
            
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, signupError: NSError?) -> Void in
                
                
                // Signup user in Parse if no errors
                if signupError == nil {
                    
                    var currentUser = PFUser.currentUser()
                    if currentUser != nil {
                        
                        // Do stuff with the user
                        
                        self.loggedUser.text = currentUser?.username
                        self.loggedIn = true
                        
                        
                        
                        
                    } else {
                        
                        // Show the signup or login screen
                        self.loggedUser.text = "Welcome!"
                        self.loggedIn = false
                        
                        
                        
                    }
                    
                    
                    loadingIndicator.stopAnimating()
                    //self.performSegueWithIdentifier("toSaved", sender: nil)
                    return
                    
                }
                
                
                // Check for Parse Signup errors
                if let errorString = signupError!.userInfo["error"] as? NSString {
                    
                    error = errorString as String
                    self.displayAlert("Signup Error!", error: error)
                    
                    loadingIndicator.stopAnimating()
                    return
                    
                } else {
                    
                    error = "Please try again later!"
                    self.displayAlert("Signup Error!", error: error)
                    
                    loadingIndicator.stopAnimating()
                    return
                    
                }
                
                
            }
            
            
            
        } else {
            
            
            
            
            // Attempt to Login User
            PFUser.logInWithUsernameInBackground (username.text!, password: password.text!) {
                (user: PFUser?, loginError: NSError?) -> Void in
                
                
                if user != nil {
                    
                    var currentUser = PFUser.currentUser()
                    if currentUser != nil {
                        
                        // Do stuff with the user
                        self.loggedUser.text = currentUser?.username
                        self.loggedIn = true
                        
                        
                        
                        loadingIndicator.stopAnimating()
                        self.performSegueWithIdentifier("savedUnwindAction", sender: nil)
                        //self.performSegueWithIdentifier("toSaved", sender: nil)
                        
                        
                        
                    } else {
                        
                        // Show the signup or login screen
                        self.loggedUser.text = "Welcome!"
                        self.loggedIn = false
                        
                        
                        
                        
                        loadingIndicator.stopAnimating()
                    }
                    
                    
                    
                } else {
                    
                    
                    // Check for Parse Login errors
                    if let errorString = loginError!.userInfo["error"] as? NSString {
                        
                        error = errorString as String
                        
                        loadingIndicator.stopAnimating()
                        self.displayAlert("Login Error!", error: error)
                        
                        return
                        
                    } else {
                        
                        error = "Please try again later!"
                        
                        loadingIndicator.stopAnimating()
                        self.displayAlert("Login Error!", error: error)
                        
                        
                        return
                        
                    }
                    
                    
                    
                }
                
                
            }
            
            
            
            
        }
        
        
        
        
    
    }
    
    
    
    
    @IBAction func toggleScreenButtonAction(sender: AnyObject) {
        
        username.text = ""
        password.text = ""
        email.text = ""
        
        
        if signupActive == true {
            
            submitButton.setTitle("Login", forState: UIControlState.Normal)
            
            
            toggleScreenButton.setTitle("Signup", forState: UIControlState.Normal)
            
            signupActive = false
            
            self.email.hidden = true
            
            
        } else {
            
            submitButton.setTitle("Signup", forState: UIControlState.Normal)
            
            toggleScreenButton.setTitle("Login", forState: UIControlState.Normal)
            
            signupActive = true
            
            self.email.hidden = false
            
        }
        
        
        
        
    }
    
    
    
    
    
    
    func displayAlert(title: String, error: String) {
        
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {action in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            print("dismissed without unwind")
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    
    func checkUserInput(username: String, password: String) -> Bool {
        
        
        var error = ""
        
        // Attempt to get username/password; check for errors
        if username == "" || password == "" || email == "" {
            
            error = "Please enter a username and password"
            
        }
        
        
        // Check for errors while attempting to get username and password
        if error != "" {
            
            displayAlert("Signup Error", error: error)
            
            return fail
            
        }
        resignFirstResponder()
        print("here at success")
        return success
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if username != "" && password != ""
        {
            print(self.username.text!)
            print(self.password.text!)
            checkUserInput(self.username.text!, password: self.password.text!)
        }
        textField.resignFirstResponder()
        return true
    }
    
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil
        {
            self.barbuttonOutlet.setTitle("Logout", forState: UIControlState.Normal)
            self.textFieldBackground.hidden = true
            self.submitButton.hidden = true
            self.username.hidden = true
            self.password.hidden = true
            self.email.hidden = true
        } else {
            self.barbuttonOutlet.setTitle("Login", forState: UIControlState.Normal)
        }
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            loggedUser.text = currentUser?.username
            loggedIn = true
        } else {
            // Show the signup or login screen
            loggedUser.text = "Welcome!"
            loggedIn = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        
        if (segue.identifier == "toSaved") {
            // pass data to next view
            
            self.unwinded = true
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! Saved
            targetController.user = self.loggedUser.text!
        } else if segue.identifier == "savedUnwindAction" {
            let nav = segue.destinationViewController as! Saved
            nav.currentUserId = (PFUser.currentUser()?.objectId)!
            nav.fromLogin = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("reached view did load")
        setUpVC()
        viewDidAppear(true)
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func setUpVC() {
        textFieldBackground.enabled = false
        toggleScreenButton.hidden = true
        self.password.delegate = self
        self.email.delegate = self
        self.username.delegate = self
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.greenColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.greenColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.navigationController!.navigationBar.tintColor = UIColor.greenColor()
        /*
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "barButtonItemClicked:"), animated: true)
        self.navigationItem.rightBarButtonItem?.title = "Login"
        print(self.navigationItem.rightBarButtonItem?.title)*/
        let rightButton: UIButton = UIButton(type: UIButtonType.Custom)
        rightButton.frame = CGRectMake(0, 0, 80, 40) ;
        rightButton.addTarget(self, action: "rightNavButtonClick", forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
        rightButton.setTitle("Login", forState: UIControlState.Normal)
        self.barbuttonOutlet = rightButton
        let itemTitle: NSDictionary = [NSForegroundColorAttributeName: UIColor.greenColor()]
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: rightButton)
        rightBarButtonItem.tintColor = UIColor.greenColor()
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false);
    }
    
    
    
    func rightNavButtonClick() {
        if self.barbuttonOutlet.titleLabel?.text == "Logout" {
            
            var currentUser = PFUser.currentUser() // this will now be nil
            loggedUser.text = "Welcome!"
            username.text = ""
            password.text = ""
            email.text = ""
            self.barbuttonOutlet.setTitle("Sign up", forState: UIControlState.Normal)
            submitButton.setTitle("Login", forState: UIControlState.Normal)
            submitButton.hidden = false
            self.password.hidden = false
            self.textFieldBackground.hidden = false
            self.username.hidden = false
            self.loggedIn = false
            self.signupActive = false
            PFUser.logOutInBackground()
            return
        }
        self.barbuttonOutlet.alpha = 0.5
        UIView.animateWithDuration(0.5, animations: {
            self.barbuttonOutlet.alpha = 1.0
        })
        username.text = ""
        password.text = ""
        email.text = ""
        print(loggedUser.text)
        
        if loggedUser.text == "Welcome!" {
        
            if signupActive == true {
                
                self.barbuttonOutlet.setTitle("Sign Up", forState: UIControlState.Normal)
                submitButton.setTitle("Login", forState: UIControlState.Normal)
                toggleScreenButton.setTitle("Signup", forState: UIControlState.Normal)
                signupActive = false
                self.email.hidden = true
                self.password.hidden = false
                self.username.hidden = false
            } else {
                self.barbuttonOutlet.setTitle("Login", forState: UIControlState.Normal)
                submitButton.setTitle("Signup", forState: UIControlState.Normal)
                toggleScreenButton.setTitle("Login", forState: UIControlState.Normal)
                signupActive = true
                self.email.hidden = false
                self.username.hidden = false
                self.password.hidden = false
                self.submitButton.hidden = false
                self.textFieldBackground.hidden = false
            }
        } else {
            self.barbuttonOutlet.setTitle("Logout", forState: UIControlState.Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
