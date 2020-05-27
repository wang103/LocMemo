//
//  BaiduLocationSearcher.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/23/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

import Combine
import Intents

class BaiduLocationSearcher: NSObject, LocationSearcher, BMKSuggestionSearchDelegate {
    static let shared = BaiduLocationSearcher()

    var searchToCallback: [BMKSuggestionSearch: Future<[LMPlacemark]?, NSError>.Promise]
    let lock: NSLock

    override init() {
        self.searchToCallback = [:]
        self.lock = NSLock()
    }

    func getPlacemarks(_ addressString : String) -> Future<[LMPlacemark]?, NSError> {
        let search = BMKSuggestionSearch()
        search.delegate = self

        let suggestionOption = BMKSuggestionSearchOption()
        suggestionOption.cityname = "全国"
        suggestionOption.keyword = addressString

        let future = Future<[LMPlacemark]?, NSError> { promise in
            self.lock.lock()
            defer {
                self.lock.unlock()
            }

            let success = search.suggestionSearch(suggestionOption)

            if success {
                self.searchToCallback[search] = promise
            } else {
                promise(.failure(NSError(
                    domain: "BaiduLocationSearcher - getPlacemarks",
                    code: -1,
                    userInfo: nil
                )))
            }
        }
        return future
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
            let placemarks = result.suggestionList.map({toPlacemark($0)})
            handler!(.success(placemarks))
        } else {
            handler!(.failure(NSError(
                domain: "BaiduLocationSearcher - onGetSuggestionResult",
                code: Int(error.rawValue),
                userInfo: nil
            )))
        }
    }

    fileprivate func toPlacemark(_ suggestionInfo: BMKSuggestionInfo) -> LMPlacemark {
        let region = CLCircularRegion(center: suggestionInfo.location,
                                      radius: 70,
                                      identifier: suggestionInfo.uid)
        return LMPlacemark(region: region,
                           name: getDisplayStr(suggestionInfo),
                           isoCountryCode: "CN",
                           postalAddress: nil)
    }

    func getDisplayStr(_ suggestionInfo: BMKSuggestionInfo) -> String {
        return "\(suggestionInfo.city ?? "") \(suggestionInfo.district ?? "") \(suggestionInfo.key ?? "")"
    }

    fileprivate func removeCallback(_ searcher: BMKSuggestionSearch!)
            -> Future<[LMPlacemark]?, NSError>.Promise? {
        lock.lock()
        defer {
            lock.unlock()
        }
        return searchToCallback.removeValue(forKey: searcher)
    }
}