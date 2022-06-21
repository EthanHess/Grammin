//
//  CoreDataStack.swift
//  Grammin
//
//  Created by Ethan Hess on 10/24/21.
//  Copyright © 2021 EthanHess. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStack: NSObject {
    
    static let shared = CoreDataStack()
    
    var managedObjectContext : NSManagedObjectContext? = {
        //MARK: Model URL
        guard let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd") else {
            return nil
        }
        guard let theManagedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            return nil
        }
        
        //MARK: MOC config
        let moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: theManagedObjectModel)
        return moc
    }()
    
    //MARK: Init
    override init() {
        super.init()
        self.setUpManagedObjectContext()
    }
    
    fileprivate func setUpManagedObjectContext() {
        let error: NSErrorPointer = nil
        do {
            try managedObjectContext!.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL(), options: nil)
        } catch let error1 as NSError {
            error?.pointee = error1
        }
    }
    
    func storeURL () -> URL? {
        let documentsDirectory = try? FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectory?.appendingPathComponent("db.sqlite")
    }
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "DataModel")
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                fatalError("Unable to load persistent stores: \(error)")
//            }
//        }
//        return container
//    }()
}
