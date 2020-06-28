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

    private let DEFAULT_RADIUS_METER = 70.0

    var searchToCallback: [BMKSuggestionSearch: Future<GetPlacemarksResult, NSError>.Promise]
    let lock: NSLock

    override init() {
        self.searchToCallback = [:]
        self.lock = NSLock()
    }

    func getPlacemarks(_ addressString : String) -> Future<GetPlacemarksResult, NSError> {
        let search = BMKSuggestionSearch()
        search.delegate = self

        let suggestionOption = BMKSuggestionSearchOption()
        suggestionOption.cityname = "全国"
        suggestionOption.keyword = addressString

        let future = Future<GetPlacemarksResult, NSError> { promise in
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
            handler!(.success(GetPlacemarksResult(
                sourceName: getName(),
                results: placemarks
            )))
        } else {
            handler!(.failure(NSError(
                domain: "BaiduLocationSearcher - onGetSuggestionResult",
                code: Int(error.rawValue),
                userInfo: nil
            )))
        }
    }

    func getName() -> String {
        return NSLocalizedString("Baidu", comment: "")
    }

    fileprivate func toPlacemark(_ suggestionInfo: BMKSuggestionInfo) -> LMPlacemark {
        let region = CLCircularRegion(center: suggestionInfo.location,
                                      radius: DEFAULT_RADIUS_METER,
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
            -> Future<GetPlacemarksResult, NSError>.Promise? {
        lock.lock()
        defer {
            lock.unlock()
        }
        return searchToCallback.removeValue(forKey: searcher)
    }
}
