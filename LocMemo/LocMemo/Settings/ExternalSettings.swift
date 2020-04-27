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

    @Published var contentViewSelectedView: Int = 0
}
