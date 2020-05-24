//
//  BaiduLocationSearcher.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/23/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

import Intents

class BaiduLocationSearcher: NSObject, LocationSearcher, BMKSuggestionSearchDelegate {
    static let shared = BaiduLocationSearcher()

    var searchToCallback: [BMKSuggestionSearch: ([CLPlacemark]?, NSError?) -> Void]
    let lock: NSLock

    override init() {
        self.searchToCallback = [:]
        self.lock = NSLock()
    }

    func getPlacemarks(_ addressString: String,
                       completionHandler: @escaping ([CLPlacemark]?, NSError?) -> Void) {
        let search = BMKSuggestionSearch()
        search.delegate = self

        let suggestionOption = BMKSuggestionSearchOption()
        suggestionOption.cityname = "全国"
        suggestionOption.keyword = addressString

        lock.lock()
        defer {
            lock.unlock()
        }

        let success = search.suggestionSearch(suggestionOption)
        if success {
            searchToCallback[search] = completionHandler
            print("BaiduLocationSearcher - getPlacemarks succeeded.")
        } else {
            print("BaiduLocationSearcher - getPlacemarks failed.")
            completionHandler(nil, NSError(domain: "BaiduLocationSearcher - getPlacemarks",
                                           code: -1,
                                           userInfo: nil))
        }
    }

    func onGetSuggestionResult(_ searcher: BMKSuggestionSearch!,
                               result: BMKSuggestionSearchResult!,
                               errorCode error: BMKSearchErrorCode) {
        let handler = removeCallback(searcher)
        if handler == nil {
            print("onGetSuggestionResult - handler is unexpected nil")
            return
        }

        if (error == BMK_SEARCH_NO_ERROR) {
            print("onGetSuggestionResult - retrieved \(result.suggestionList.count)")
            let placemarks = result.suggestionList.map({toPlacemark($0)})
            handler!(placemarks, nil)
        } else {
            print("onGetSuggestionResult error \(error)")
            handler!(nil, NSError(domain: "BaiduLocationSearcher - onGetSuggestionResult",
                                 code: Int(error.rawValue),
                                 userInfo: nil)
            )
        }
    }

    fileprivate func toPlacemark(_ suggestionInfo: BMKSuggestionInfo) -> CLPlacemark {
        let location = CLLocation(latitude: suggestionInfo.location.latitude,
                                  longitude: suggestionInfo.location.longitude)
        return CLPlacemark(location: location, name: getDisplayStr(suggestionInfo), postalAddress: nil)
    }

    func getDisplayStr(_ suggestionInfo: BMKSuggestionInfo) -> String {
        return "\(suggestionInfo.city ?? "") \(suggestionInfo.district ?? "") \(suggestionInfo.key ?? "")"
    }

    fileprivate func removeCallback(_ searcher: BMKSuggestionSearch!)
            -> (([CLPlacemark]?, NSError?) -> Void)? {
        lock.lock()
        defer {
            lock.unlock()
        }
        return searchToCallback.removeValue(forKey: searcher)
    }
}
