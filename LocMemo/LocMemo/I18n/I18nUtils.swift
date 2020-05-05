//
//  I18nUtils.swift
//  LocMemo
//
//  Created by Tianyi Wang on 5/4/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

import NaturalLanguage

class I18nUtils {
    static let shared = I18nUtils()

    func detectLocale(_ str: String) -> Locale? {
        guard let lang = NLLanguageRecognizer.dominantLanguage(for: str)?.rawValue else { return nil }
        return Locale(identifier: lang)
    }
}
