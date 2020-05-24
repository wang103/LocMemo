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
                       completionHandler: @escaping ([LMPlacemark]?, NSError?) -> Void) {
        let locale = Locale.current
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString, in: nil, preferredLocale: locale) { (placemarks, error) in
            if error == nil {

                var lmPlacemarks: [LMPlacemark]? = nil
                if placemarks != nil {
                    lmPlacemarks = placemarks!.map({self.toLMPlacemark($0)})
                }

                completionHandler(lmPlacemarks, nil)
                return
            }

            completionHandler(nil, error as NSError?)
        }
    }

    fileprivate func toLMPlacemark(_ placemark: CLPlacemark) -> LMPlacemark {
        return LMPlacemark(region: placemark.region as! CLCircularRegion, name: placemark.name,
                           isoCountryCode: placemark.isoCountryCode, postalAddress: placemark.postalAddress)
    }
}
