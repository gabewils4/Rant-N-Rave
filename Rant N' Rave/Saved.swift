//
//  SavedVC.swift
//  Rant N' Rave
//
//  Created by Gabe Wilson on 12/31/15.
//  Copyright © 2015 Gabe Wilson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse


class Saved: UITableViewController, UITextFieldDelegate {
    
    var longDeltaArray = [Double]()
    var latDeltaArray = [Double]()
    var longArray = [Double]()
    var latArray = [Double]()
    var titlesArray = [String]()
    var idArray = [String]()
    var currentUserId = ""
    var notLoggedIn = false
    var fromLogin = false
    var loadingIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var textField: UITextField!
    var longDelta = Double()
    var latDelta = Double()
    var long = Double()
    var lat = Double()
    var newName = ""
    var indexName = ""
    var indexValue = 0
    var user = ""
    
    override func viewDidLoad() {
        loadingView.startAnimating()
        loadingView.hidesWhenStopped = true
        print("currentUserId", currentUserId)
        self.textField.hidden = true
        textField.delegate = self
        setupColors()
        pullSavedLocations()
    }
    
    override func viewDidAppear(animated: Bool) {
        textField.enabled = false
        if PFUser.currentUser() == nil {
            textField.text = "Log in or Sign up in settings."
            loadingView.stopAnimating()
            textField.hidden = false
            titlesArray.removeAll()
            longDeltaArray.removeAll()
            latDeltaArray.removeAll()
            longArray.removeAll()
            latArray.removeAll()
            idArray.removeAll()
            tableView.reloadData()
        } else {
            textField.hidden = true
            loadingView.stopAnimating()
        }
        if self.fromLogin {
            pullSavedLocations()
        }
        fromLogin = false
    }
    
    func pullSavedLocations() {
        titlesArray.removeAll()
        longDeltaArray.removeAll()
        latDeltaArray.removeAll()
        longArray.removeAll()
        latArray.removeAll()
        idArray.removeAll()
        tableView.reloadData()
        let query = PFQuery(className: "Region")
        query.orderByDescending("createdAt")
        query.whereKey("userObjectId", equalTo: currentUserId)
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            for object : PFObject in objects! {
                if (object as PFObject)["latitudeDelta"] as? Double != nil {
                    self.latDeltaArray.append(((object as PFObject)["latitudeDelta"] as? Double)!)
                }
                if (object as PFObject)["longitudeDelta"] as? Double != nil {
                    self.longDeltaArray.append(((object as PFObject)["longitudeDelta"] as? Double)!)
                }
                if (object as PFObject)["latitude"] as? Double != nil {
                    self.latArray.append(((object as PFObject)["latitude"] as? Double)!)
                }
                if (object as PFObject)["longitude"] as? Double != nil {
                    self.longArray.append(((object as PFObject)["longitude"] as? Double)!)
                }
                if (object as PFObject)["title"] as? String != nil {
                    self.titlesArray.append(((object as PFObject)["title"] as? String)!)
                }
                self.idArray.append(object.objectId!)
                self.tableView.reloadData()
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    @IBAction func savedUnwindAction(unwindSegue: UIStoryboardSegue) {
    }
    
    func setupColors() {
        self.upperView.frame.size.height = self.view.frame.size.height / 14.0
        if self.currentUserId.isEmpty {
            textField.hidden = false
            textField.text = "Log in or Sign up in settings."
        }
        textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        navigationItem.rightBarButtonItem = editButtonItem()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.greenColor()
        navigationItem.leftBarButtonItem?.tintColor = UIColor.greenColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.greenColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        /*
        let newItem = UIBarButtonItem()
        newItem.image = UIImage(named: "Settings")
        newItem.tintColor = UIColor.greenColor()
        
        navigationItem.rightBarButtonItems?.append(newItem)*/
        let newItem = UIButton()
        newItem.setImage(UIImage(named: "Settings"), forState: .Normal)
        newItem.frame = CGRectMake(0, 0, 24, 24)
        newItem.addTarget(self, action: Selector("settings"), forControlEvents: .TouchUpInside)
        
        //.... Set Right/Left Bar Button item
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = newItem
        self.navigationItem.rightBarButtonItems?.append(rightBarButton)
        
    }
    
    func settings() {
        print("pressed")
        self.performSegueWithIdentifier("toSettings", sender: nil)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if textField.text!.isEmpty == false  {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    /*
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print("here")
        if editingStyle == .Delete {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }*/
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let doneItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("updateName"))
        doneItem.tintColor = UIColor.greenColor()
        self.navigationItem.rightBarButtonItem = doneItem
        doneItem.enabled = false
        
        /*let undo = UIBarButtonItem(barButtonSystemItem: .Undo, target: self, action: Selector("undo"))
        undo.tintColor = UIColor.greenColor()
                self.navigationItem.leftBarButtonItems?.append(undo)*/
        
        return true
    }
    
    func undo() {
        self.navigationItem.leftBarButtonItems?.removeLast()
        self.navigationItem.rightBarButtonItems?.removeLast()
        navigationItem.rightBarButtonItem = editButtonItem()
        titlesArray[indexValue] = indexName
        self.view.endEditing(true)
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        updateName()
        return true
    }
    
    
    func updateName() {
        textField.resignFirstResponder()
        if textField.text?.isEmpty == false {
            let query = PFQuery(className:"Region")
            self.titlesArray[self.indexValue] = self.textField.text!
            query.getObjectInBackgroundWithId(idArray[indexValue]) {
                (name: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let name = name {
                    //we know that cell is not empty now so we use ! to force unwrapping
                    name["title"] = self.textField.text
                    name.saveInBackground()
                }
            }
        }
        tableView.reloadData()
    }
    
    
    override func tableView(tableView: UITableView,
        editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
            self.indexValue = indexPath.row
            self.indexName = titlesArray[indexPath.row]
            print("here and index name is ", self.indexName)
            let rename = UITableViewRowAction(style: .Normal, title: "Rename") { action, index in
                self.textField.text = ""
                self.self.textField.hidden = false
                self.textField.enabled = true
                self.textField.becomeFirstResponder()
                print("here in tableview method")
                self.titlesArray[indexPath.row] = self.newName
                tableView.reloadData()
            }
            rename.backgroundColor = UIColor.lightGrayColor()
            
            let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
                self.deleteRow()
                self.titlesArray.removeAtIndex(indexPath.row)
                tableView.reloadData()
            }
            delete.backgroundColor = UIColor.redColor()
            
            return [rename, delete]
    }
    
    func deleteRow() {
        let query = PFQuery(className:"Region")
        query.getObjectInBackgroundWithId(idArray[indexValue]) {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let object = object {
                object.deleteEventually()
            }
        }

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return titlesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = titlesArray[indexPath.row]
        loadingView.stopAnimating()
        //cell.textLabel?.textColor = UIColor.cyanColor() --> *USE LATER*
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            self.lat = latArray[(indexPath.row)]
            self.long = longArray[(indexPath.row)]
            self.longDelta = longDeltaArray[(indexPath.row)]
            self.latDelta = latDeltaArray[(indexPath.row)]
            self.performSegueWithIdentifier("toFollowedLocationSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(segue.identifier, "Identifier!!!")
        if segue.identifier == "toFollowedLocationSegue" {
            
            let nav = segue.destinationViewController as! Places
            nav.fromLocations = true
            nav.long = self.long
            nav.lat = self.lat
            nav.longDelta = self.longDelta
            nav.latDelta = self.latDelta
        } else if segue.identifier == "toSettings" {
            let nav = segue.destinationViewController as! LoginViewController
            print("Inside here")
        } else {
            let nav = segue.destinationViewController as! Places
            print("Inside here")
        }
    }


    

    
}