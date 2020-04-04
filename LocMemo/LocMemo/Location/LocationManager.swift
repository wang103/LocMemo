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
    }

    /**
     * The system calls this delegate object’s methods from the thread in which we started the
     * corresponding location services. That thread must itself have an active run loop, like the app's main
     * thread.
     */
    func setDelegate(_ delegate: CLLocationManagerDelegate) {
        self.clLocationManager.delegate = delegate
    }
}
