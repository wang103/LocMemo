//
//  DataManager.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/6/20.
//  Copyright © 2020 x. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class DataManager {
    static let shared = DataManager()

    func saveLocMemo(identifier: String,
                     locationText: String,
                     memoText: String) throws {
        let now = Date()
        try saveLocMemo(identifier: identifier,
                        locationText: locationText,
                        memoText: memoText,
                        status: .active,
                        createdAt: now,
                        updatedAt: now)
    }

    func saveLocMemo(identifier: String,
                     locationText: String,
                     memoText: String,
                     status: LocMemoStatus,
                     createdAt: Date,
                     updatedAt: Date) throws {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "LocMemo", in: managedContext)!
        let locMemo = NSManagedObject(entity: entity, insertInto: managedContext)

        locMemo.setValue(identifier, forKey: "identifier")
        locMemo.setValue(locationText, forKey: "locationText")
        locMemo.setValue(memoText, forKey: "memoText")
        locMemo.setValue(status.rawValue, forKey: "status")
        locMemo.setValue(createdAt, forKey: "createdAt")
        locMemo.setValue(updatedAt, forKey: "updatedAt")

        try managedContext.save()
    }

    func updateLocMemo(identifier: String,
                       locationText: String,
                       memoText: String) throws {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let obj = getLocMemo(id: identifier).obj
        obj.setValue(locationText, forKey: "locationText")
        obj.setValue(memoText, forKey: "memoText")
        obj.setValue(Date(), forKey: "updatedAt")

        try managedContext.save()
    }

    func delete(_ object: NSManagedObject) throws {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        managedContext.delete(object)
        try managedContext.save()
    }

    func deleteAll() throws {
        let memos = try getAllLocMemos()
        try memos.forEach({
            try delete($0.obj)
        })
    }

    func getLocMemo(id: String) -> LocMemoData {
        let predicate = NSPredicate(format: "identifier == %@", id)
        do {
            return try getAllLocMemos(predicate: predicate)[0]
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    func getAllLocMemos(predicate: NSPredicate? = nil) throws -> [LocMemoData] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocMemo")
        if predicate != nil {
            fetchRequest.predicate = predicate!
        }

        return try managedContext.fetch(fetchRequest).map({
            LocMemoData(obj: $0,
                        id: $0.value(forKeyPath: "identifier") as! String,
                        locationText: $0.value(forKeyPath: "locationText") as! String,
                        memoText: $0.value(forKeyPath: "memoText") as! String,
                        status: LocMemoStatus(rawValue: $0.value(forKeyPath: "status") as! Int16)!,
                        createdAt: $0.value(forKeyPath: "createdAt") as! Date,
                        updatedAt: $0.value(forKeyPath: "updatedAt") as! Date
            )
        }).sorted(by: {
            return $0.updatedAt.compare($1.updatedAt) == .orderedDescending
        })
    }
}
