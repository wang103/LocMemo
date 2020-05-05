//
//  AppReviewManager.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/5/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

import Foundation
import StoreKit

class AppReviewManager {
    static let shared = AppReviewManager()

    func promptForReview() {
        do {
            let appVersion = try DataManager.shared.getCurAppVersion()
            if appVersion.promptedReview || appVersion.memoNotiCount <= 0 {
                return
            }

            SKStoreReviewController.requestReview()
            DataManager.shared.markPromptedReview()
        } catch let error as NSError {
            print("promptForReview error: \(error.localizedDescription)")
        }
    }
}
