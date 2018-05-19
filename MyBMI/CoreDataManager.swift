//
//  CoreDataManager.swift
//  MyBMI
//
//  Created by Khiem Vo on 19/05/18.
//  Copyright © 2018 Khiem Vo. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    let appDelegate : AppDelegate
    let entityName: String
    
    init (appDelegate : AppDelegate, entityName: String) {
        self.appDelegate = appDelegate
        self.entityName = entityName
    }
    
    public func currentContext() -> NSManagedObjectContext {
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
    
    public func newRowToEntity() -> NSManagedObject {
        let context = currentContext()
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
    }
    
    public func addRowToEntity(row: NSManagedObject) {
        do {
            let context = currentContext()
            try context.save()
        } catch {
            print("Failed to add")
            print("Unexpected error: \(error).")
        }
    }
    
    public func deleteRowFromEntity(row: NSManagedObject) {
        do {
            let context = currentContext()
            context.delete(row)
            try context.save()
        } catch {
            print("Failed to delete")
            print("Unexpected error: \(error).")
        }
    }
    
    // Fetch all rows for Entity
    func fetchRows() -> [NSManagedObject] {
        let context = currentContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            return results as! [NSManagedObject]
        } catch {
            print("Failed to fetch")
            print("Unexpected error: \(error).")
        }
        
        return [NSManagedObject]()
    }
}
