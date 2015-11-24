//
//  LocationManager.swift
//  FinalMarchingDrillSet
//
//  Created by Abhinay on 20/11/15.
//  Copyright © 2015 BandApps. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let managedObjectContext = (UIApplication.sharedApplication().delegate as!
    AppDelegate).managedObjectContext

class LocationManager:NSObject,NSFetchedResultsControllerDelegate
{
    
    class func saveRecord(lat:String,long:String,set:String,count:String,image:NSData?) ->Bool
    {
        let location:Location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
        location.set = set
        location.count = count
        location.latitude = lat
        location.longitude = long
        location.image = image
     
        do {
            try managedObjectContext.save()
        } catch let error {
            print(error)
            return false
        }
        return true
    }
    
    class func deleteRecord(location:Location) -> Bool
    {
        managedObjectContext.deleteObject(location)
        do {
            try managedObjectContext.save()
        } catch let error {
            print(error)
            return false
        }
        return true
    }
    
    class func updateRecord(location:Location,lat:String,long:String,set:String,count:String,image:NSData?) -> Bool {
        location.set = set
        location.count = count
        location.latitude = lat
        location.longitude = long
        location.image = image
        
        do {
            try managedObjectContext.save()
        } catch let error {
            print(error)
            return false
        }
        return true
    }
}


