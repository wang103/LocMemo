//
//  LocationManager.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()

    private let clLocationManager: CLLocationManager

    override init() {
        self.clLocationManager = CLLocationManager()

        super.init()

        // The system calls this delegate object’s methods from the thread in
        // which we started the corresponding location services. That thread
        // must itself have an active run loop, like the app's main thread.
        self.clLocationManager.delegate = self
    }

    func getPlacemarks(_ addressString : String,
                       completionHandler: @escaping([CLPlacemark]?, NSError?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                completionHandler(placemarks, nil)
                return
            }

            completionHandler(nil, error as NSError?)
        }
    }

    func monitorRegionAtLocation(center: CLLocationCoordinate2D, identifier: String) -> Bool {
        // Make sure the device supports region monitoring.
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            return false
        }

        // Register the region.
        let maxDistance = clLocationManager.maximumRegionMonitoringDistance
        let region = CLCircularRegion(center: center, radius: maxDistance, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false

        clLocationManager.startMonitoring(for: region)

        return true
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
        // TODO: implementation
    }

    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        // TODO: implementation
    }
}
