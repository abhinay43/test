//
//  AddVC.swift
//  FinalMarchingDrillSet
//
//  Created by Abhinay on 24/11/15.
//  Copyright © 2015 BandApps. All rights reserved.
//

import UIKit
import CoreLocation

class AddVC: UIViewController,CLLocationManagerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate
{
    //MARK: - Constants
    let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let locationManager:CLLocationManager = CLLocationManager()
    let imagePicker = UIImagePickerController()
    
    //MARK: - Properties
    var currentLocation:CLLocation?
    
    //MARK: - IBOutlets
    @IBOutlet weak var txtEntrySet: UITextField!
    @IBOutlet weak var txtEntryCount: UITextField!
    @IBOutlet weak var txtLattitude: UITextField!
    @IBOutlet weak var txtLongitude: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrlView:UIScrollView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageAppearance()
        self.initialSetUP()
    }
    
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
        //Save/Add new record in core data
        LocationManager.saveRecord(self.txtLattitude.text!, long: self.txtLongitude.text!, set: self.txtEntrySet.text!, count: self.txtEntryCount.text!, image:image)
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
        
        let deviceSize = UIScreen.mainScreen().bounds.size
        self.scrlView.contentSize = CGSizeMake(deviceSize.width, 586)
    }
    func initialSetUP()
    {
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
    
}