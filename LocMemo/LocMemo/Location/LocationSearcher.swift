//
//  LocationSearcher.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/23/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

import Combine

protocol LocationSearcher {
    func getPlacemarks(_ addressString : String) -> Future<[LMPlacemark]?, NSError>
}
