//
//  LocationManager.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import CoreLocation

class LocationManager {
    static let shared = LocationManager()

    private let clLocationManager: CLLocationManager

    init() {
        self.clLocationManager = CLLocationManager()
        self.clLocationManager.delegate = LocationManagerDelegate()
    }
}
