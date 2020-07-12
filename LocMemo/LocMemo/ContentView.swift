//
//  ContentView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var externalSettings = ExternalSettings.shared

    // For write view
    @State private var writeViewIsToCreate: Bool = true
    @State private var writeViewLocationText: String = ""
    @State private var writeViewRadiusText: String = ""
    @State private var writeViewMemoText: String = ""
    @State private var writeViewRegionIdentifier: String = ""
    @State private var writeViewSelectedPlacemark: LMPlacemark? = nil

    var body: some View {
        TabView(selection: $externalSettings.contentViewSelectedView) {
            MemosView(writeViewIsToCreate: $writeViewIsToCreate,
                      writeViewLocationText: $writeViewLocationText,
                      writeViewRadiusText: $writeViewRadiusText,
                      writeViewMemoText: $writeViewMemoText,
                      writeViewRegionIdentifier: $writeViewRegionIdentifier,
                      writeViewSelectedPlacemark: $writeViewSelectedPlacemark)
                .tabItem {
                    VStack {
                        Image("TabMemos")
                        Text(NSLocalizedString("Memos", comment: ""))
                    }
                }
                .tag(0)

            WriteView(isToCreate: $writeViewIsToCreate,
                      locationText: $writeViewLocationText,
                      radiusText: $writeViewRadiusText,
                      memoText: $writeViewMemoText,
                      regionIdentifier: $writeViewRegionIdentifier,
                      selectedPlacemark: $writeViewSelectedPlacemark)
                .tabItem {
                    VStack {
                        Image("TabNew")
                        Text(NSLocalizedString("Write", comment: ""))
                    }
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    VStack {
                        Image("TabSettings")
                        Text(NSLocalizedString("Settings", comment: ""))
                    }
                }
                .tag(2)
        }
    }
}

// MARK: - UIApplication

extension UIApplication {
    static var locationUsageDescription: String {
        return Bundle.main.object(
            forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") as! String
    }

    static var appVersion: String {
        let key = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: key) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary") }
        return currentVersion
    }
}
