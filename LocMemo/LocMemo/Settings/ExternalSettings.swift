//
//  ExternalSettings.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/9/20.
//  Copyright © 2020 x. All rights reserved.
//

import Combine

class ExternalSettings: ObservableObject {
    static let shared = ExternalSettings()

    @Published var locationAuthStatus = ""

    @Published var notificationAuthStatus = ""

    /* Views related */

    @Published var contentViewSelectedView: Int = 0

    @Published var memosViewShowMemoPopover: Bool = false
    @Published var memosViewSelectedId = ""

    func displayMemo(id: String) {
        memosViewSelectedId = id
        memosViewShowMemoPopover = true
        contentViewSelectedView = 0
    }
}
