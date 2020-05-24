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
        geocoder.geocodeAddressString(addressString, in: nil, preferredLocale: locale) { (placemarks, error) in
            if error == nil {
                completionHandler(placemarks, nil)
                return
            }

            completionHandler(nil, error as NSError?)
        }
    }
}
