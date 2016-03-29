//
//  ViewController.swift
//  CraveRave3
//
//  Created by Gabe Wilson on 11/22/15.
//
//

import UIKit
import MapKit
import CoreLocation
import Parse


class Places: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraOutlet: UIBarButtonItem!
    @IBOutlet weak var searchBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var searchButtonOutlet: UIButton!
    @IBOutlet weak var endEditingButtonOutlet: UIButton!
    @IBOutlet weak var locationSavedLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hideListLabel: UIButton!
    @IBOutlet weak var showListLabel: UIButton!
    var identifier = ""
    var fromLocations = false
    var lat = 0.0
    var long = 0.0
    var latDelta = 0.0
    var longDelta = 0.0
    var selectedAnnotationTitle = ""
    var objectIdArray = [String]()
    var annotationArray = [MKAnnotation]()
    var idPass = ""
    var mapWidth = Double()
    var mapHeight = Double()
    var alreadyUpdatedLocation = Bool()
    var centerLat = 0
    var centerLong = 0
    var comment = ""
    var selected = true
    var imagesArray = [UIImage]()
    var commentArray = [String]()
    var didUpdateUserLocation = false
    var resultsList = [String]()
    let picker = UIImagePickerController()
    var chosenImage = UIImage()
    
    @IBAction func showListButton(sender: AnyObject) {
        hideListLabel.hidden = false
        tableView.hidden = false
        showListLabel.hidden = true
    }
    
    
    @IBAction func searchButtonExtension(sender: AnyObject) {
        searchButton(self)
    }
    
    @IBAction func refreshButtonExtension(sender: AnyObject) {
        if self.refreshButton.enabled {
            callFunc(self)
        }
    }
    
    @IBAction func callFunc(sender: AnyObject) {
        self.selected = true
        let duration = 2.0
        let delay = 0.0
        let options = UIViewKeyframeAnimationOptions.CalculationModePaced
        let fullRotation = CGFloat(M_PI * 2)
        self.refreshButton.enabled = false
        self.refreshButton.userInteractionEnabled = false
        hideListLabel.hidden = true
        tableView.hidden = true
        UIView.animateKeyframesWithDuration(duration, delay: delay, options: options, animations: {
            self.refreshButton.userInteractionEnabled = false
            NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "enableButton", userInfo: nil, repeats: false)
            // note that we've set relativeStartTime and relativeDuration to zero.
            // Because we're using `CalculationModePaced` these values are ignored
            // and iOS figures out values that are needed to create a smooth constant transition
            UIView.addKeyframeWithRelativeStartTime(3, relativeDuration: 3, animations: {
                self.refreshButton.transform = CGAffineTransformMakeRotation(1/3 * fullRotation)
                print("here in rotation")
                
            })
            
            UIView.addKeyframeWithRelativeStartTime(3, relativeDuration: 3, animations: {
                self.refreshButton.transform = CGAffineTransformMakeRotation(2/3 * fullRotation)
                print("here in rotation")
            })
            
            UIView.addKeyframeWithRelativeStartTime(3, relativeDuration: 3, animations: {
                self.refreshButton.transform = CGAffineTransformMakeRotation(3/3 * fullRotation)
                print("here in rotation")
            })
             self.refreshButton.userInteractionEnabled = true
            },  completion: nil)
        
        self.refreshButton.userInteractionEnabled = true
        mapView.removeAnnotations(mapView.annotations)
        searchWithinMapRegion()
    }
    
    func enableButton() {
        self.refreshButton.enabled = true
    }
    
    
    
    @IBAction func endEditingButton(sender: AnyObject) {
        self.view.endEditing(true)
        endEditingButtonOutlet.hidden = true
    }
    
    @IBAction func placesUnwindAction(unwindSegue: UIStoryboardSegue) {
    }
    
    @IBAction func searchButton(sender: AnyObject) {
        if searchButtonOutlet.titleLabel!.text != nil {
            print(searchButtonOutlet.titleLabel!.text!) // "Red"
            if searchButtonOutlet.titleLabel!.text! == "Undo"
            {
                searchButtonOutlet.setImage(UIImage(named: "Search"), forState: UIControlState.Normal)
                searchButtonOutlet.setTitle("Search", forState: UIControlState.Normal)
                self.selected = false
                searchBar.hidden = true
            } else {
                self.selected = false
                searchBar.hidden = false
                searchButtonOutlet.setImage(UIImage(named: "UndoSearch"), forState: UIControlState.Normal)
                searchButtonOutlet.setTitle("Undo", forState: UIControlState.Normal)
            }
        }
    }
    
    @IBAction func raveButton(sender: AnyObject) {
        self.identifier = "Rave"
                UIApplication.sharedApplication().sendAction(cameraOutlet.action, to: cameraOutlet.target, from: self, forEvent: nil)
        print("happens after image picked")
    }

    @IBAction func rantButton(sender: AnyObject) {
        self.identifier = "Rant"
        
        UIApplication.sharedApplication().sendAction(cameraOutlet.action, to: cameraOutlet.target, from: self, forEvent: nil)
    }
    
    @IBAction func hideListButton(sender: AnyObject) {
        hideListLabel.hidden = true
        tableView.hidden = true
        showListLabel.hidden = false
    }
    
    
    @IBAction func longTap(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began {
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: self.mapView.region.center.latitude, longitude: self.mapView.region.center.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                
                // Address dictionary
                print(placeMark.addressDictionary)
                let street = placeMark.addressDictionary?["Street"] as? String ?? ""
                let city = placeMark.addressDictionary?["City"] as? String ?? ""
                let address = street + ", " + city
                self.findRegionBoundaries(address)
            })
        }
    }
    
    var matchingItems: [MKMapItem] = [MKMapItem]()
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var coordinatesArray = [MKAnnotation]()
    var selectedCell = UITableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.objectIdArray.removeAll()
        self.locationSavedLabel.alpha = 0
        // Do any additional setup after loading the view, typically from a nib.
        setUpDelegates()
        //pullPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setUpDelegates() {
        picker.delegate = self
        self.tableView.rowHeight = 65.0
        searchBar.tintColor = UIColor.greenColor()
        endEditingButtonOutlet.hidden = true
        tableView.delegate = self
        tableView.dataSource = self
        self.showListLabel.hidden = true
        self.hideListLabel.hidden = true
        searchBar.hidden = true
        self.tableView.hidden = true
        mapView.delegate = self
        searchBar.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
    }
    
    func pullPosts() {
        let query = PFQuery(className: "Post")
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            for object : PFObject in objects! {
                if (object as PFObject)["centerLat"] as? Double != nil {
                    let centerLat = ((object as PFObject)["centerLat"] as? Double)!
                    let centerLong = ((object as PFObject)["centerLong"] as? Double)!
                    let comment = ((object as PFObject)["Comment"] as? String)!
                    self.objectIdArray.append(object.objectId!)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate.latitude = centerLat
                    annotation.coordinate.longitude = centerLong
                    annotation.title = comment
                    annotation.subtitle = "test" + object.objectId!
                    self.mapView.addAnnotation(annotation)
                    self.mapView(self.mapView, viewForAnnotation: annotation)
                    }
            }
        }
        fitAnnotations()
        
    }
    
    
    
    func stopUpdatingLocation() {
        
        // since I received my data within a block, I don't want to just return whenever it wants to :)
        dispatch_async(dispatch_get_main_queue()) {
            
            // the building stop updating location function call
            self.locationManager.stopUpdatingLocation()
            
            // my own trick to avoid keep getting updates
            self.alreadyUpdatedLocation = true
        }
    }
    
    func searchWithinMapRegion() {
        mapView.removeAnnotations(mapView.annotations)
        matchingItems.removeAll()
        annotationArray.removeAll()
        commentArray.removeAll()
        self.imagesArray.removeAll()
        self.objectIdArray.removeAll()
        let query = PFQuery(className: "Post")
        
        let mapWidth = Double(mapView.frame.width)
        let mapHeight = Double(mapView.frame.height)
        print(mapHeight)
        print(mapWidth)
        
        let neX = mapWidth
        let neY = 0.0
        
        let swX = 0.0
        let swY = mapHeight

        
        let swPoint = CGPointMake(CGFloat(swX), CGFloat(swY))
        let nePoint = CGPointMake(CGFloat(neX), CGFloat(neY))
        
        let swCoord = mapView.convertPoint(swPoint, toCoordinateFromView: mapView)
        let neCoord = mapView.convertPoint(nePoint, toCoordinateFromView: mapView)
        
        
        //___ Then transform those point into lat,lng values
        let swGP = PFGeoPoint(latitude: swCoord.latitude, longitude: swCoord.longitude)
        let neGP = PFGeoPoint(latitude: neCoord.latitude, longitude: neCoord.longitude)
        query.limit = 10
        query.whereKey("currentLocation", withinGeoBoxFromSouthwest: swGP, toNortheast: neGP)
        query.orderByDescending("createdAt")
        // NSTimer for refresh add spin.
        if self.objectIdArray.isEmpty {
        query.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error:NSError?) -> Void in
            print(self.objectIdArray.count, "object count")
            if self.objectIdArray.count != 0 {
                print("returning - error occured")
                return
            }
            for object : PFObject in objects! {
                if let image = object["image"] as? PFFile {
                    image.getDataInBackgroundWithBlock {
                        (imageData:NSData?, error:NSError?) -> Void in
                        if error == nil  {
                            if let finalimage = UIImage(data: imageData!) {
                                self.imagesArray.append(finalimage)
                                if (object as PFObject)["centerLat"] as? Double != nil {
                                    let centerLat = ((object as PFObject)["centerLat"] as? Double)!
                                    let centerLong = ((object as PFObject)["centerLong"] as? Double)!
                                    let comment = ((object as PFObject)["Comment"] as? String)!
                                    self.commentArray.append(comment)
                                    self.objectIdArray.append(object.objectId!)
                                    let rantOrRave = ((object as PFObject)["RantOrRave"] as? String)!
                                    if rantOrRave == "Rave" {
                                        let annotation = ColorPointAnnotation(pinColor: UIColor.greenColor(), title: comment, subtitle: object.objectId!, id: object.objectId!)
                                        annotation.coordinate.latitude = centerLat
                                        annotation.coordinate.longitude = centerLong
                                        annotation.title = comment
                                        annotation.subtitle = String(object.createdAt)
                                        self.mapView.addAnnotation(annotation)
                                        self.annotationArray.append(annotation)
                                        self.mapView(self.mapView, viewForAnnotation: annotation)
                                    } else {
                                        let annotation = ColorPointAnnotation(pinColor: UIColor.redColor(), title: comment, subtitle: String(object.createdAt), id: object.objectId!)
                                        
                                        annotation.coordinate.latitude = centerLat
                                        annotation.coordinate.longitude = centerLong
                                        annotation.title = comment
                                        annotation.subtitle = String(object.createdAt)
                                        self.mapView.addAnnotation(annotation)
                                        self.annotationArray.append(annotation)
                                        self.mapView(self.mapView, viewForAnnotation: annotation)
                                    }
                            }
                        }
                    }
                }
                }
            }
        }
            
            fitAnnotations()
        }
    }
    
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if self.fromLocations {
            
            self.mapView.userLocation.title = "Current Location"
        } else {
            if let ulav = mapView.viewForAnnotation(mapView.userLocation) {
                self.mapView.userLocation.title = " "
                ulav.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
                let rantButton = UIButton(type: UIButtonType.Custom) as UIButton
                rantButton.frame.size.width = 50
                rantButton.frame.size.height = 50
                rantButton.backgroundColor = UIColor.redColor()
                rantButton.setTitle("Rant", forState: UIControlState.Normal)
                
                let raveButton = UIButton(type: UIButtonType.Custom) as UIButton
                raveButton.frame.size.width = 50
                raveButton.frame.size.height = 50
                raveButton.backgroundColor = UIColor.greenColor()
                raveButton.setTitle("Rave", forState: UIControlState.Normal)
                
                ulav.leftCalloutAccessoryView = rantButton
                ulav.rightCalloutAccessoryView = raveButton
                }
        }
        
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        if self.selected
        {
        let detailButton = UIButton()
        detailButton.frame.size.width = 25
        detailButton.frame.size.height = 25
        detailButton.setImage(UIImage(named: "toDetails"), forState: UIControlState.Normal)
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            let colorPointAnnotation = annotation as! ColorPointAnnotation
            pinView?.pinTintColor = colorPointAnnotation.pinColor
            pinView?.animatesDrop = true
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIButton
            //pinView?.rightCalloutAccessoryView = detailButton
            
        }
        else {
            pinView!.canShowCallout = true
            pinView?.annotation = annotation
        }
            return pinView
        } else {
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
                    view.canShowCallout = true
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
            }
            return view
        }
    }

    func mapView(mapView: MKMapView,
        didSelectAnnotationView view: MKAnnotationView) {
            self.selectedAnnotationTitle = ((view.annotation?.title)!)!
            print(self.selectedAnnotationTitle)
            showListLabel.hidden = true
            //TODO get table view selected
            
            tableView.hidden = false
            hideListLabel.hidden = false
            tableView.reloadData()
            if self.selected {
                for var i = 0; i < self.annotationArray.count; ++i {
                    if annotationArray[i].title! == selectedAnnotationTitle {
                        let rowToSelect:NSIndexPath = NSIndexPath(forRow: i, inSection: 0);
                        self.tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.Middle);
                    }
                }
            }
            for var i = 0; i < self.matchingItems.count; ++i {
                if matchingItems[i].name == selectedAnnotationTitle {
                    let rowToSelect:NSIndexPath = NSIndexPath(forRow: i, inSection: 0);
                    self.tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.Middle);
                }
            }
            self.selected = true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("text has changed", searchBar.text?.utf16.count)
        if searchBar.text?.utf16.count == 1 {
            print("inside")
            let query = PFQuery(className: "Post")
            query.orderByAscending("createdAt")
            query.whereKey("Search", hasPrefix: searchBar.text?.lowercaseString)
            query.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error:NSError?) -> Void in
                for object : PFObject in objects! {
                    if (object as PFObject)["Search"] as? String != nil {
                        let searched = ((object as PFObject)["Search"] as? String)!
                        self.resultsList.append(searched)
                        print("here")
                    }
                }
            }
        } else {
        //do the cool filter thing
        }
        
    }
    
    func mapView(mapView: MKMapView,
    annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            print(control.backgroundColor)
            if control.backgroundColor == UIColor.greenColor() || control.backgroundColor == UIColor.redColor()
            {
                if control == view.rightCalloutAccessoryView {
                    print("Right!")
                    raveButton(self)
                } else if control == view.leftCalloutAccessoryView {
                    print("Left!")
                    rantButton(self)
                }
            } else {
                self.idPass = ((view.annotation?.subtitle)!)!
                self.performSegueWithIdentifier("annotationSegue", sender: nil)
            }
            print("you have selected the callout")
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        if !didUpdateUserLocation && self.objectIdArray.count > 0 {
            print("inside !didupdate")
            mapView.selectAnnotation(mapView.userLocation, animated: true)
            didUpdateUserLocation = true
            hideListButton(self)
        } else {
            //TODO
        }
    }
    
    //Centers the mapRegion around the current location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if fromLocations == true {
            self.showUserLocation()
            navigationController?.navigationBar.tintColor = UIColor.greenColor()
            print("here from locations")
            self.searchBarBottomConstraint.constant -= 100
            self.mapView.showsUserLocation = false
            let center = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: self.latDelta, longitudeDelta: self.longDelta))
            self.mapWidth = Double(mapView.frame.width)
            self.mapHeight = Double(mapView.frame.height)
            print(self.mapWidth)
            print(self.mapHeight)
            self.mapView.setRegion(region, animated: false)
            toolbarItems?.removeAll()
            if(self.alreadyUpdatedLocation) {
                
                return
            }
            searchWithinMapRegion()
            stopUpdatingLocation()
            
            mapView.scrollEnabled = false
            mapView.zoomEnabled = false
            mapView.rotateEnabled = false
            mapView.pitchEnabled = false
        } else {
            
            let location = locations.last
            let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            self.mapWidth = Double(mapView.frame.width)
            self.mapHeight = Double(mapView.frame.height)
            print(self.mapWidth)
            print(self.mapHeight)
            self.mapView.setRegion(region, animated: false)
            //TODO
            if(self.alreadyUpdatedLocation) {
                //TODO
                //print("here selecting user ")
                //mapView.selectAnnotation(mapView.userLocation, animated: true)
                return
            }
            searchWithinMapRegion()
            stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func findRegionBoundaries(title: String) {
        if self.fromLocations {
            locationSavedLabel.backgroundColor = UIColor.redColor()
            locationSavedLabel.text = "Already saved"
        }
        print(self.mapView.region.span.latitudeDelta)
        print(self.mapView.region.span.longitudeDelta)
        print(self.mapView.region.center.latitude)
        print(self.mapView.region.center.longitude)
        UIView.animateWithDuration(1.5, animations: {
            if PFUser.currentUser()?.objectId == nil {
                self.locationSavedLabel.text = "Sign in to save!"
                self.locationSavedLabel.backgroundColor = UIColor.redColor()
                self.locationSavedLabel.alpha = 1.0
                UIView.animateWithDuration(1.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.locationSavedLabel.alpha = 0.0
                    }, completion: nil)
            } else {
                self.locationSavedLabel.alpha = 1.0
                UIView.animateWithDuration(1.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.locationSavedLabel.alpha = 0.0
                    }, completion: nil)
                if self.fromLocations {
                    return
                }
                let Region = PFObject(className: "Region")
                Region["latitudeDelta"] = self.mapView.region.span.latitudeDelta
                Region["longitudeDelta"] = self.mapView.region.span.longitudeDelta
                Region["latitude"] = self.mapView.region.center.latitude
                Region["longitude"] = self.mapView.region.center.longitude
                Region["title"] = title
                Region["userObjectId"] = PFUser.currentUser()?.objectId
                Region.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // The object has been saved.
                        print("saved")
                    } else {
                        // There was a problem, check error.description
                    }
                }
            }
        })
        
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        endEditingButtonOutlet.hidden = false
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !tableView.hidden {
            self.showListLabel.hidden = true
        } else {
            self.showListLabel.hidden = false
        }
        self.selected = false
        self.coordinatesArray.removeAll()
        self.matchingItems.removeAll()
        mapView.removeAnnotations(mapView.annotations)
        performSearch()
        searchBar.resignFirstResponder()
    }
    
    
    //Performs the local establishment search.
    func performSearch() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler({(response: MKLocalSearchResponse?,
            error: NSError?) in
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                print(response!.mapItems.count)
                for item in response!.mapItems {
                    //Item is created with phone number and title.
                    self.matchingItems.append(item as MKMapItem)
                }
                print("selected value--> ",self.selected)
                self.createAnnotations()
            }
            print("matching items count",self.matchingItems.count)
            self.tableView.reloadData()
        })
    }
    
    //Places annotations in the long and lat of every returned establishment.
    func createAnnotations() {
        for item in self.matchingItems as [MKMapItem] {
            print("in create annotations")
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            let street = item.placemark.addressDictionary?["Street"] as? String ?? ""
            let city = item.placemark.addressDictionary?["City"] as? String ?? ""
            annotation.subtitle = street + ", " + city
            self.mapView.addAnnotation(annotation)
            self.coordinatesArray.append(annotation)
        }
        fitAnnotations()
    }
    
    //Fits all the annotations within the map view.
    func fitAnnotations() {
        //TODO fix this
        self.mapView.showsUserLocation = false
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        showUserLocation()
    }
    
    func showUserLocation() {
        self.mapView.showsUserLocation = true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selected {
            return self.annotationArray.count
        }
        return self.matchingItems.count;
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if self.selected || self.matchingItems.isEmpty {
            let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"cell")
            cell.textLabel?.text = self.annotationArray[indexPath.row].title!
            cell.detailTextLabel?.text = self.annotationArray[indexPath.row].subtitle!
            let cellImg : UIImageView = UIImageView(frame: CGRectMake(260, 5, 55, 55))
            //cell.imageView?.image = self.imagesArray[indexPath.row]
            cellImg.image = self.imagesArray[indexPath.row]
            cell.addSubview(cellImg)
            return cell
        } else {
            let cell:UITableViewCell = UITableViewCell(style:UITableViewCellStyle.Subtitle, reuseIdentifier:"cell")
            cell.textLabel?.text = self.matchingItems[indexPath.row].name
            cell.detailTextLabel!.text = self.coordinatesArray[indexPath.row].subtitle!
            return cell

        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell != selectedCell {
            self.selectedCell.accessoryType = UITableViewCellAccessoryType.None
        }
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            clickedOnce(indexPath.row, selectedCell: cell)
        } else if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
            self.performSegueWithIdentifier("annotationSegue", sender: nil)
        }
    }
    
    func clickedOnce(cellNumber: Int, selectedCell: UITableViewCell) {
        if self.selected || self.matchingItems.isEmpty  {
            self.mapView.region.center = self.annotationArray[cellNumber].coordinate
            self.mapView.selectAnnotation(self.annotationArray[cellNumber], animated: true)
            
        } else {
            mapView.showsUserLocation = false
            print("selected an local search request")
            self.mapView.region.center = self.coordinatesArray[cellNumber].coordinate
            print(self.coordinatesArray[cellNumber].subtitle)
            mapView.selectAnnotation(self.coordinatesArray[cellNumber], animated: true)
            self.selectedCell = selectedCell
        }
    }
    
    func searchBarBookmarkButtonClicked(searchBar: UISearchBar) {
        self.performSegueWithIdentifier("toSaved", sender: nil)
    }
    
    func disableButton() {
        self.refreshButton.enabled = false
        UIView.animateWithDuration(3, animations:{
            self.refreshButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        })
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        picker.allowsEditing = false
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.cameraCaptureMode = .Photo
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.chosenImage = image
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier("toPost", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toPost" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! RantNRave
            targetController.identifier = self.identifier
            targetController.lat = self.mapView.region.center.latitude
            targetController.long = self.mapView.region.center.longitude
            targetController.passedImage = self.chosenImage
        } else if segue.identifier == "annotationSegue" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! PostDetails
                targetController.objectIdArray = self.objectIdArray
                targetController.imagesArray = self.imagesArray
                targetController.commentsArray = self.commentArray
                targetController.selectedAnnotationTitle = self.selectedAnnotationTitle
        } else if segue.identifier == "toSaved" {
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! Saved
            if PFUser.currentUser()?.objectId != nil {
                targetController.currentUserId = (PFUser.currentUser()?.objectId)!
            } else {
                targetController.notLoggedIn = true
            }
            
        }
    }
}



