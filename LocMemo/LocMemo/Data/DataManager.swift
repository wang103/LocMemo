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
                     memoText: String,
                     latitude: Double,
                     longitude: Double,
                     radius: Double) throws {
        let now = Date()
        try saveLocMemo(identifier: identifier,
                        locationText: locationText,
                        memoText: memoText,
                        status: .active,
                        createdAt: now,
                        updatedAt: now,
                        latitude: latitude,
                        longitude: longitude,
                        radius: radius)
    }

    // latitude, longitude & radius are added >= version 2.0.
    func saveLocMemo(identifier: String,
                     locationText: String,
                     memoText: String,
                     status: LocMemoStatus,
                     createdAt: Date,
                     updatedAt: Date,
                     latitude: Double? = nil,
                     longitude: Double? = nil,
                     radius: Double? = nil) throws {

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
        locMemo.setValue(latitude, forKey: "latitude")
        locMemo.setValue(longitude, forKey: "longitude")
        locMemo.setValue(radius, forKey: "radius")

        try managedContext.save()
    }

    func updateLocMemo(identifier: String,
                       locationText: String,
                       memoText: String,
                       latitude: Double,
                       longitude: Double,
                       radius: Double) throws {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let obj = getLocMemo(id: identifier)!.obj
        obj.setValue(locationText, forKey: "locationText")
        obj.setValue(memoText, forKey: "memoText")
        obj.setValue(Date(), forKey: "updatedAt")
        obj.setValue(latitude, forKey: "latitude")
        obj.setValue(longitude, forKey: "longitude")
        obj.setValue(radius, forKey: "radius")

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

    func getLocMemo(id: String) -> LocMemoData? {
        let predicate = NSPredicate(format: "identifier == %@", id)
        do {
            let memos = try getAllLocMemos(predicate: predicate)
            if memos.count < 1 {
                print("getLocMemo - unable to find memo with ID \(id)")
                print("Existing IDs from LocationManager:")
                for region in LocationManager.shared.getMonitoredRegions() {
                    print("ID: \(region.identifier)")
                }
                print("Existing IDs from CoreData:")
                for memo in try getAllLocMemos() {
                    print("ID: \(memo.id)")
                }
                return nil
            }
            return memos[0]
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
                        updatedAt: $0.value(forKeyPath: "updatedAt") as! Date,
                        latitude: $0.value(forKeyPath: "latitude") as? Double,
                        longitude: $0.value(forKeyPath: "longitude") as? Double,
                        radius: $0.value(forKeyPath: "radius") as? Double
            )
        }).sorted(by: {
            return $0.updatedAt.compare($1.updatedAt) == .orderedDescending
        })
    }

    func incMemoNotiCount() -> Int64 {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        do {
            let appVersion = try ensureCurAppVersion()
            var count = appVersion.value(forKeyPath: "memoNotiCount") as! Int64
            count += 1
            appVersion.setValue(count, forKey: "memoNotiCount")
            try managedContext.save()
            return count
        } catch let error as NSError {
            print("incMemoNotiCount error: \(error.localizedDescription)")
            return -1
        }
    }

    func markPromptedReview() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        do {
            let appVersion = try ensureCurAppVersion()
            appVersion.setValue(true, forKey: "promptedReview")
            try managedContext.save()
        } catch let error as NSError {
            print("markPromptedReview error: \(error.localizedDescription)")
        }
    }

    func getSetting() throws -> SettingData {
        let obj = try ensureSetting()
        return SettingData(
            obj: obj,
            appleLocationSearcher: obj.value(forKeyPath: "appleLocationSearcher") as! Bool,
            baiduLocationSearcher: obj.value(forKeyPath: "baiduLocationSearcher") as! Bool
        )
    }

    func ensureSetting() throws -> NSManagedObject {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Setting")

        let results = try managedContext.fetch(fetchRequest)
        if results.count == 0 {
            return try saveSetting(useAppleMap: true, useBaiduMap: true)
        } else {
            return results[0]
        }
    }

    func saveSetting(useAppleMap: Bool, useBaiduMap: Bool) throws -> NSManagedObject {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Setting", in: managedContext)!
        let settingDataObj = NSManagedObject(entity: entity, insertInto: managedContext)

        settingDataObj.setValue(useAppleMap, forKey: "appleLocationSearcher")
        settingDataObj.setValue(useBaiduMap, forKey: "baiduLocationSearcher")

        try managedContext.save()
        return settingDataObj
    }

    func updateUseAppleMap(_ useAppleMap: Bool) throws {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let obj = try getSetting().obj
        obj.setValue(useAppleMap, forKey: "appleLocationSearcher")
        try managedContext.save()
    }

    func updateUseBaiduMap(_ useBaiduMap: Bool) throws {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext

        let obj = try getSetting().obj
        obj.setValue(useBaiduMap, forKey: "baiduLocationSearcher")
        try managedContext.save()
    }

    func getCurAppVersion() throws -> AppVersionData {
        let obj = try ensureCurAppVersion()
        return AppVersionData(
            appVersion: obj.value(forKeyPath: "appVersion") as! String,
            memoNotiCount: obj.value(forKeyPath: "memoNotiCount") as! Int64,
            promptedReview: obj.value(forKeyPath: "promptedReview") as! Bool
        )
    }

    fileprivate func ensureCurAppVersion() throws -> NSManagedObject {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        let appVersion = UIApplication.appVersion
        let predicate = NSPredicate(format: "appVersion == %@", appVersion)

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AppVersion")
        fetchRequest.predicate = predicate

        let appVersions = try managedContext.fetch(fetchRequest)
        if appVersions.count == 0 {
            return try saveAppVersion(appVersion: appVersion)
        } else {
            return appVersions[0]
        }
    }

    fileprivate func saveAppVersion(appVersion: String) throws -> NSManagedObject {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "AppVersion", in: managedContext)!
        let appVersionObj = NSManagedObject(entity: entity, insertInto: managedContext)

        appVersionObj.setValue(appVersion, forKey: "appVersion")
        appVersionObj.setValue(0, forKey: "memoNotiCount")
        appVersionObj.setValue(false, forKey: "promptedReview")

        try managedContext.save()
        return appVersionObj
    }
}
