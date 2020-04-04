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
                        Image("first")
                        Text("Memos")
                    }
                }
                .tag(0)

            NewView()
                .tabItem {
                    VStack {
                        Image("second")
                        Text("New")
                    }
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    VStack {
                        Image("first")
                        Text("Settings")
                    }
                }
                .tag(2)
        }
    }
}

struct MemosView: View {
    var body: some View {
        Color.white
    }
}

struct NewView: View {
    var body: some View {
        Color.white
    }
}

struct SettingsView: View {
    var body: some View {
        Color.white
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
