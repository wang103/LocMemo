//
//  LMPlacemark.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/24/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

import Contacts

class LMPlacemark {
    public var region: CLCircularRegion
    public var name: String?
    public var isoCountryCode: String?
    public var postalAddress: CNPostalAddress?

    init(region: CLCircularRegion, name: String?, isoCountryCode: String?, postalAddress: CNPostalAddress?) {
        self.region = region
        self.name = name
        self.isoCountryCode = isoCountryCode
        self.postalAddress = postalAddress
    }
}
