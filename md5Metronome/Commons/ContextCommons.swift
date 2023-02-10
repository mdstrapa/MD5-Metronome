//
//  ContextCommons.swift
//  md5Metronome
//
//  Created by Marcos Strapazon on 29/07/18.
//  Copyright © 2018 Marcos Strapazon. All rights reserved.
//

import UIKit
import CoreData

class ContextCommons{
    
    //MARK: Context Initialization
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    public var moc:NSManagedObjectContext?
    
    init() {
        moc = appDelegate.persistentContainer.viewContext
    }
    
    public func saveMoc() -> Bool{
        do{
            try moc?.save()
            return true
        }catch{
            print(error)
            return false
        }
    }
    
    
    //MARK: SetLists Common Methods
    var fetchedSetListsResultControler:NSFetchedResultsController<SetLists>!
    
    func initSetListsFetchedResultController(request:NSFetchRequest<SetLists>) -> NSFetchedResultsController<SetLists>{
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc!, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func performSetListsRequest(fetchedResultControler: NSFetchedResultsController<SetLists>){
        do{
            try fetchedResultControler.performFetch()
        }catch{
            print(error.localizedDescription)
        }
    }

    
    //SetList Requests
    public func getSetListList() -> [SetLists]?{
        let request = ContextCommons().createSetListListRequest()
        fetchedSetListsResultControler = ContextCommons().initSetListsFetchedResultController(request:request)
        ContextCommons().performSetListsRequest(fetchedResultControler: fetchedSetListsResultControler)
        return fetchedSetListsResultControler.fetchedObjects
    }
    
    
    func createSetListListRequest() -> NSFetchRequest<SetLists>{
        let request:NSFetchRequest<SetLists> = SetLists.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return request
    }

    
    

}
