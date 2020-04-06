//
//  ContentView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selection = 0
 
    var body: some View {
        TabView(selection: $selection){
            MemosView()
                .tabItem {
                    VStack {
                        Image("TabMemos")
                        Text("Memos")
                    }
                }
                .tag(0)

            NewView()
                .tabItem {
                    VStack {
                        Image("TabNew")
                        Text("New")
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
