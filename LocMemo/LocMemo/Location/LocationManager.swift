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
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        // TODO: Issue #1
        // Update the UI with error message.
    }
}
