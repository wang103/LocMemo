//
//  LocationSearcher.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/23/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

import Combine

struct GetPlacemarksResult {
    var sourceName: String
    var results: [LMPlacemark]
    var comment: String
}

protocol LocationSearcher {
    func getPlacemarks(_ addressString : String) -> Future<GetPlacemarksResult, NSError>

    func getName() -> String
}
