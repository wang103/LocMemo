//
//  AppleLocationSearcher.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/23/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

import Combine

class AppleLocationSearcher: LocationSearcher {
    static let shared = AppleLocationSearcher()

    func getPlacemarks(_ addressString : String) -> Future<[LMPlacemark]?, NSError> {
        let locale = Locale.current
        let geocoder = CLGeocoder()
        let future = Future<[LMPlacemark]?, NSError> { promise in
            geocoder.geocodeAddressString(addressString, in: nil, preferredLocale: locale) { (placemarks, error) in
                if error == nil {

                    var lmPlacemarks: [LMPlacemark]? = nil
                    if placemarks != nil {
                        lmPlacemarks = placemarks!.map({self.toLMPlacemark($0)})
                    }

                    promise(.success(lmPlacemarks))
                    return
                }

                promise(.failure(error! as NSError))
            }
        }
        return future
    }

    fileprivate func toLMPlacemark(_ placemark: CLPlacemark) -> LMPlacemark {
        return LMPlacemark(region: placemark.region as! CLCircularRegion, name: placemark.name,
                           isoCountryCode: placemark.isoCountryCode, postalAddress: placemark.postalAddress)
    }
}
