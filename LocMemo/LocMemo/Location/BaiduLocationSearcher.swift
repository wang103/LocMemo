//
//  BaiduLocationSearcher.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/23/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

class BaiduLocationSearcher: LocationSearcher {
    static let shared = BaiduLocationSearcher()

    func getPlacemarks(_ addressString: String,
                       completionHandler: @escaping ([CLPlacemark]?, NSError?) -> Void) {

    }
}
