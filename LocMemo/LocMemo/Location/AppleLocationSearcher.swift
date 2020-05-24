//
//  AppleLocationSearcher.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/23/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

class AppleLocationSearcher: LocationSearcher {
    static let shared = AppleLocationSearcher()

    func getPlacemarks(_ addressString: String,
                       completionHandler: @escaping ([CLPlacemark]?, NSError?) -> Void) {
        let locale = Locale.current
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString, in: nil, preferredLocale: locale) { (_placemarks, error) in
            if error == nil {

                var placemarks = _placemarks
                if placemarks != nil {
                    // All placemark coordinates fetched from Apple is in WGS84. However, in China,
                    // Apple Map would use GCJ02. So convert if needed now.
                    placemarks = placemarks!.map({self.toChinaPlacemark($0)})
                }

                completionHandler(placemarks, nil)
                return
            }

            completionHandler(nil, error as NSError?)
        }
    }

    fileprivate func toChinaPlacemark(_ placemark: CLPlacemark) -> CLPlacemark {
        if placemark.isoCountryCode == nil || placemark.isoCountryCode! != "CN" {
            return placemark
        }

        var oldCenter = (placemark.region as! CLCircularRegion).center
        oldCenter = CLLocationCoordinate2DMake(oldCenter.latitude, oldCenter.longitude)
        let newCenter = toGcj02(oldCenter)
        let newLocation = CLLocation(latitude: newCenter.latitude, longitude: newCenter.longitude)
        return CLPlacemark(location: newLocation, name: placemark.name, postalAddress: placemark.postalAddress)
    }

    fileprivate func toGcj02(_ wgs84: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return BMKCoordTrans(wgs84, .COORDTYPE_GPS, .COORDTYPE_COMMON)
    }
}
