//
//  EditVC.swift
//  FinalMarchingDrillSet
//
//  Created by Abhinay on 16/11/15.
//  Copyright © 2015 BandApps. All rights reserved.
//

import UIKit
import CoreLocation

class EditVC:UIViewController,CLLocationManagerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate
{
    //MARK: - Constants
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let locationManager:CLLocationManager = CLLocationManager()
    let imagePicker = UIImagePickerController()
    
    //MARK: - Properties
    var currentLocation:CLLocation?
    var location:Location?
    
    //MARK: - IBOutlets
    @IBOutlet weak var txtEntrySet: UITextField!
    @IBOutlet weak var txtEntryCount: UITextField!
    @IBOutlet weak var txtLattitude: UITextField!
    @IBOutlet weak var txtLongitude: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var lblDirection: UILabel!
    @IBOutlet weak var lblPreviousLat: UILabel!
    @IBOutlet weak var lblPreviousLong: UILabel!
    @IBOutlet weak var scrlView:UIScrollView!

    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageAppearance()
        self.initialSetUP()
    }
    //xx
    
    deinit{
        locationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - IBAction
    @IBAction func cancelTapped(sender: AnyObject) {
        dismissVC()
    }
    
    @IBAction func saveTapped(sender: AnyObject)
    {
        var image:NSData?
        if let img = self.imageView.image{
            image = UIImagePNGRepresentation(img)
        }
        
         //Update existing record
        LocationManager.updateRecord(location!, lat: self.txtLattitude.text!, long: self.txtLongitude.text!, set: self.txtEntrySet.text!, count: self.txtEntryCount.text!, image:image )
        
        self.dismissVC()
    }
    
    @IBAction func openPhotoLibrary (){
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func showCamera (){
        imagePicker.sourceType = .Camera
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    //MARK: - Private Methods
    func pageAppearance(){
        //Any appearance for this page
        self.txtLongitude.userInteractionEnabled = false
        self.txtLattitude.userInteractionEnabled = false
        self.totalDistance.hidden = true
        self.lblPreviousLat.hidden = true
        self.lblPreviousLong.hidden = true
        self.lblDirection.text = ""
        let deviceSize = UIScreen.mainScreen().bounds.size
        self.scrlView.scrollEnabled = true
        self.scrlView.contentSize = CGSizeMake(deviceSize.width, 718)
    }
    func initialSetUP()
    {
        if let loc = location
        {
            self.txtEntrySet.text = loc.set
            self.txtEntryCount.text = loc.count
            self.lblPreviousLat.text = "Saved Lat: " + loc.latitude!
            self.lblPreviousLong.text = "Saved Long: " + loc.longitude!
            self.lblPreviousLong.hidden = false
            self.lblPreviousLat.hidden = false
            
            if let img = location?.image{
                self.imageView.image = UIImage(data: img)
            }
        }
    
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        //LocationManager properties to get the location
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        self.locationManager.requestWhenInUseAuthorization()
        
    }
   
    func dismissVC() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK; - Text Field Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Location Manager Delegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError" + error.description)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation)
    {
        currentLocation = newLocation
        txtLattitude.text = "\(currentLocation!.coordinate.latitude)"
        txtLongitude.text = "\(currentLocation!.coordinate.longitude)"
        
        self.calculateDistance()
        self.setLocationDiretion()
    }
    
    //MARK:- Image Picker Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?)
    {
        self.imageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:- Distance and Directions
    func calculateDistance ()
    {
        if location != nil {
            self.totalDistance.hidden = false
            let locA:CLLocation = CLLocation(latitude: (location?.latitude?.floatValue)!, longitude: (location?.longitude?.floatValue)!)
            let locB:CLLocation = CLLocation(latitude: (self.txtLattitude.text!.floatValue), longitude: (self.txtLongitude.text!.floatValue))
            var distance:CLLocationDistance = locA.distanceFromLocation(locB)
            distance = distance*100 //1 meter =  100 cm
            let dis = Int(distance)
            self.totalDistance.text = "Total Distance: \(dis)"
        }
       
    }
    
    func setLocationDiretion ()
    {
        if location != nil {
            let locA:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (location?.latitude?.floatValue)!, longitude: (location?.longitude?.floatValue)!)
            let locB:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (self.txtLattitude.text!.floatValue), longitude: (self.txtLongitude.text!.floatValue))
            let degree = self.getHeadingForDirectionFromCoordinate(locA, toLoc: locB)
            let direction = windDirectionFromDegrees(degree)
            self.lblDirection.text = "Direction: \(direction)"
        }
        
    }
    func getHeadingForDirectionFromCoordinate(fromLoc:CLLocationCoordinate2D,toLoc:CLLocationCoordinate2D) -> Double
    {
        let fLat = degreesToRadians(fromLoc.latitude);
        let fLng = degreesToRadians(fromLoc.longitude);
        let tLat = degreesToRadians(toLoc.latitude);
        let tLng = degreesToRadians(toLoc.longitude);
        
        let degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
        
        if (degree >= 0) {
            return degree;
        } else {
            return 360+degree;
        }
    }
    
    func degreesToRadians (x:Double) -> Double{
        return (M_PI * x) / 180.0
    }
    func radiandsToDegrees (x:Double) -> Double{
        return (x * 180.0 / M_PI)
    }
    
    func windDirectionFromDegrees(degrees:Double) -> String
    {
        let directions = ["N","NNE","NE","ENE","E","ESE","SE","SSE",
            "S","SSW","SW","WSW","W","WNW","NW","NNW"]
        let i:Int = Int((degrees+11.25)/22.5)
        return directions[(i % 16)]
    }
    
    

}

