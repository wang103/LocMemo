//
//  ContentView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    // For this view
    @State private var selection = 0

    // For write view
    @State private var writeViewIsToCreate: Bool = true
    @State private var writeViewLocationText: String = ""
    @State private var writeViewMemoText: String = ""
    @State private var writeViewRegionIdentifier: String = ""
 
    var body: some View {
        TabView(selection: $selection) {
            MemosView(contentViewSelectedView: $selection,
                      writeViewIsToCreate: $writeViewIsToCreate,
                      writeViewLocationText: $writeViewLocationText,
                      writeViewMemoText: $writeViewMemoText,
                      writeViewRegionIdentifier: $writeViewRegionIdentifier)
                .tabItem {
                    VStack {
                        Image("TabMemos")
                        Text("Memos")
                    }
                }
                .tag(0)

            WriteView(isToCreate: $writeViewIsToCreate,
                      locationText: $writeViewLocationText,
                      memoText: $writeViewMemoText,
                      regionIdentifier: $writeViewRegionIdentifier)
                .tabItem {
                    VStack {
                        Image("TabNew")
                        Text("Write")
                    }
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    VStack {
                        Image("TabSettings")
                        Text("Settings")
                    }
                }
                .tag(2)
        }
    }
}

// MARK: - UIApplication

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
