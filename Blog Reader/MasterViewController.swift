//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by Johnny Chen on 1/10/16.
//  Copyright (c) 2016 JohnnyChen. All rights reserved.
//

import UIKit
import CoreData

//the fetchresult controller delegate allows us to do the fetch in a neat way
class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate{

    //allows us to work with and extract from coredata easily
    var managedObjectContext:NSManagedObjectContext? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //create variable to access our appdelegate
        var appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        
        let url = NSURL(string: "https://www.googleapis.com/blogger/v3/blogs/10861780/posts?key=AIzaSyCWHQIxPFhF5hG-UIppwBB1zl2BBeRO4zg")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                println(error)
            }
            else {
//                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                
                let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                if jsonResult.count > 0 {
                    if let items = jsonResult["items"] as? NSArray {
                        
                        //REMOVE ALL THE POSTS THAT WERE STORED PREVIOUSLY
                        var request = NSFetchRequest(entityName: "Posts")
                        request.returnsObjectsAsFaults = false
                        
                        var results = context.executeFetchRequest(request, error: nil)!
                        if results.count > 0 {
                            for result in results {
                                context.deleteObject(result as NSManagedObject)
                                context.save(nil)
                            }
                        }
                        
                        for item in items {
                            //println(item)
                            
                            //both title and content should exist
                            if let title = item["title"] as? String {
                                if let content = item["content"] as? String {
                                    println(title)
                                    println("\n")
//                                    println(content)
                                    var newPost :NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Posts", inManagedObjectContext: context) as NSManagedObject
                                    newPost.setValue(title, forKey: "title")
                                    newPost.setValue(content, forKey: "content")
                                    
                                    context.save(nil)
                                }
                            }
                            
                            
                        }
                        println("1-savePoststoCoredata")
                    }
                }

                /*
                //make sure everything is saved properly
                var request = NSFetchRequest(entityName: "Posts")
                request.returnsObjectsAsFaults = false
                
                var results = context.executeFetchRequest(request, error: nil)!
                println(results)
                */

                //reload the table after saving everything
                self.tableView.reloadData()
                println("2-reloadData")
            }
        })
        task.resume()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
//            println("Show detail")
            
            //FINDING WHERE YOU PRESSED
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
                (segue.destinationViewController as DetailViewController).detailItem = object
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
//        println("hi")
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        println("hi")
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
//        cell.textLabel?.text = "Test"
        self.configureCell(cell, atIndexPath: indexPath)

        return cell
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
//        println(indexPath)
//        println(object)
        cell.textLabel!.text = object.valueForKey("title")!.description
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Posts", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

}

