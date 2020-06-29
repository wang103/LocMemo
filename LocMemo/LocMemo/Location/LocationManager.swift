//
//  LocationManager.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import Combine
import CoreData
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()

    private let clLocationManager: CLLocationManager

    private var getPlacemarksCancellable: AnyCancellable? = nil

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
                       completionHandler: @escaping([GetPlacemarksResult], NSError?) -> Void) {
        if getPlacemarksCancellable != nil {
            getPlacemarksCancellable!.cancel()
        }

        let setting = getSettingData()
        let future1 = setting.appleLocationSearcher ?
            AppleLocationSearcher.shared.getPlacemarks(addressString) :
            getNotEnabledResult(AppleLocationSearcher.shared.getName())
        let future2 = setting.baiduLocationSearcher ?
            BaiduLocationSearcher.shared.getPlacemarks(addressString) :
            getNotEnabledResult(BaiduLocationSearcher.shared.getName())
        getPlacemarksCancellable = Publishers.Zip(future1, future2).sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    completionHandler([], error)
                }
            },
            receiveValue: { (value1, value2) in
                completionHandler([value1, value2], nil)
            }
        )
    }

    private func getNotEnabledResult(_ sourceName: String) -> Future<GetPlacemarksResult, NSError> {
        let result = GetPlacemarksResult(
            sourceName: sourceName, results: [], comment: NSLocalizedString("Not enabled", comment: ""))
        return Future<GetPlacemarksResult, NSError> { promise in
            promise(.success(result))
        }
    }

    private func getSettingData() -> SettingData {
        do {
            return try DataManager.shared.getSetting()
        } catch let error as NSError {
            print("LocationManager - getSettingData \(error)")
            return SettingData(obj: NSManagedObject(), appleLocationSearcher: true, baiduLocationSearcher: true)
        }
    }

    func startMonitoring(region: CLCircularRegion) -> Bool {
        // Make sure the device supports region monitoring.
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            return false
        }

        print("Start monitoring region centered at \(region.center) with radius \(region.radius)")

        // Register the region.
        clLocationManager.startMonitoring(for: region)
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

    func getMonitoredRegion(_ identifier: String) -> CLCircularRegion? {
        let region = clLocationManager.monitoredRegions.first(
            where: { $0.identifier == identifier }
        )
        if region != nil {
            return (region! as! CLCircularRegion)
        }
        return nil
    }

    func createRegion(cr: CLCircularRegion,
                      identifier: String,
                      radius: CLLocationDistance) -> CLCircularRegion {

        let region = CLCircularRegion(center: cr.center, radius: radius, identifier: identifier)
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
            if memo != nil {
                NotificationManager.shared.scheduleNotification(memo: memo!)
            } else {
                print("Cannot schedule notification due to memo not found")
            }
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
