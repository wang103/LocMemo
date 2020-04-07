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

    func getAllLocMemos() throws -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocMemo")

        return try managedContext.fetch(fetchRequest)
    }
}
