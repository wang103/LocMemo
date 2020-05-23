//
//  LocationManager.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import CoreLocation

class LocationManager: NSObject, LocationSearcher {
    static let shared = LocationManager()

    private let clLocationManager: CLLocationManager

    override init() {
        self.clLocationManager = CLLocationManager()
        self.clLocationManager.allowsBackgroundLocationUpdates = true

        super.init()

        // The system calls this delegate object’s methods from the thread in
        // which we started the corresponding location services. That thread
        // must itself have an active run loop, like the app's main thread.
        self.clLocationManager.delegate = self
    }

    func requestUserPermission() {
        clLocationManager.requestAlwaysAuthorization()
    }

    func getPlacemarks(_ addressString : String,
                       completionHandler: @escaping([CLPlacemark]?, NSError?) -> Void) {
        AppleLocationSearcher.shared.getPlacemarks(addressString, completionHandler: completionHandler)
    }

    func startMonitoring(region: CLRegion) -> Bool {
        // Make sure the device supports region monitoring.
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            return false
        }

        let circularRegion = region as! CLCircularRegion
        print("Start monitoring region centered at \(circularRegion.center) with radius \(circularRegion.radius)")

        // Register the region.
        clLocationManager.startMonitoring(for: circularRegion)
        return true
    }

    func stopMonitoring(identifier: String) {
        let region = clLocationManager.monitoredRegions.first(
            where: { $0.identifier == identifier }
        )
        if region != nil {
            stopMonitoring(region: region!)
        }
    }

    func stopMonitoring(region: CLRegion) {
        clLocationManager.stopMonitoring(for: region)
    }

    func stopMonitoringAll() {
        clLocationManager.monitoredRegions.forEach({ stopMonitoring(region: $0) })
    }

    func getMonitoredRegions() -> Set<CLRegion> {
        return clLocationManager.monitoredRegions
    }

    func createRegion(cr: CLCircularRegion, identifier: String) -> CLRegion {
        let region = CLCircularRegion(center: cr.center, radius: cr.radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        return region
    }

    func getAuthorizationStatusStr(_ authStatus: CLAuthorizationStatus) -> String {
        if authStatus == .authorizedAlways {
            return NSLocalizedString("Always", comment: "")
        } else if authStatus == .authorizedWhenInUse {
            return NSLocalizedString("When in use", comment: "")
        } else if authStatus == .denied {
            return NSLocalizedString("Never", comment: "")
        } else if authStatus == .notDetermined {
            return NSLocalizedString("Ask next time", comment: "")
        } else if authStatus == .restricted {
            return NSLocalizedString("Not authorized", comment: "")
        } else {
            return NSLocalizedString("Unknown", comment: "")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            let memo = DataManager.shared.getLocMemo(id: identifier)
            NotificationManager.shared.scheduleNotification(memo: memo)
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        // Do nothing.
        print("monitoringDidFailFor withError \(error)")
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        ExternalSettings.shared.locationAuthStatus = getAuthorizationStatusStr(status)
    }
}
