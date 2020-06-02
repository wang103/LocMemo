//
//  LocMemoData.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/6/20.
//  Copyright © 2020 x. All rights reserved.
//

import CoreData
import Foundation

struct LocMemoData: Identifiable {
    let obj: NSManagedObject
    let id: String              // UUID
    let locationText: String
    let memoText: String
    let status: LocMemoStatus
    let createdAt: Date
    let updatedAt: Date

    // Added >= version 2.0
    let latitude: Double?
    let longitude: Double?
    let radius: Double?
}
