//
//  DrillListTVC.swift
//  FinalMarchingDrillSet
//
//  Created by Abhinay on 16/11/15.
//  Copyright © 2015 BandApps. All rights reserved.
//

import UIKit
import CoreData

class DrillListTVC: UITableViewController,NSFetchedResultsControllerDelegate
{
    //MARK:- Constants
    let managedObjectContext = (UIApplication.sharedApplication().delegate as!
        AppDelegate).managedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Location")
        let primarySortDescriptor = NSSortDescriptor(key: "count", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "set", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "count",
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.pageAppearance()
        self.initialSetUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Private Methods
    func pageAppearance(){
        self.title = Config.getApplicationTitle()
    }
    func initialSetUp()
    {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
        NSFetchedResultsController.deleteCacheWithName("Root")
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.fetchedResultsController.sections?.count)!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 60.0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        self.configCell(cell, indexPath: indexPath)
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("EditRecordSegue", sender: indexPath)
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            let location:Location = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Location
            LocationManager.deleteRecord(location)
        }
    }
    
    
    func configCell(cell:UITableViewCell,indexPath:NSIndexPath)
    {
        let location:Location = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Location
        cell.textLabel?.text = location.set
        cell.detailTextLabel?.text = location.count
        
        if let img = location.image{
            cell.imageView?.image = UIImage(data: img)
        }
    }
    
    //MARK:- Fetch Request Controller Delegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        switch (type)
        {
        case NSFetchedResultsChangeType.Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            break;
            
        case NSFetchedResultsChangeType.Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            break;
            
        case NSFetchedResultsChangeType.Update:
           
            self.configCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
            break;
            
        case NSFetchedResultsChangeType.Move:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            break;
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch (type)
        {
        case NSFetchedResultsChangeType.Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            break;
            
        case NSFetchedResultsChangeType.Delete:
           self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
            break;
            
        case NSFetchedResultsChangeType.Update:
            break;
            
        case NSFetchedResultsChangeType.Move:
            break;
        }
    }
    
    //MARK:- Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "EditRecordSegue"
        {
            let indexPath = sender as! NSIndexPath
            let location:Location = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Location
            let editVC:EditVC = segue.destinationViewController as! EditVC
            editVC.location = location
        }
    }
}
