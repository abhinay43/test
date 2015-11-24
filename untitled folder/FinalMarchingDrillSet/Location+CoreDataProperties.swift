//
//  Location+CoreDataProperties.swift
//  FinalMarchingDrillSet
//
//  Created by Abhinay on 20/11/15.
//  Copyright © 2015 BandApps. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var count: String?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var set: String?
    @NSManaged var image: NSData?

}
