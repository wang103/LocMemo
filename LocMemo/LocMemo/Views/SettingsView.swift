//
//  SettingsView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            getMainView()
            .navigationBarTitle("Settings")
        }
    }

    func getMainView() -> some View {
        return Form {
            Section {
                Button(action: reset) {
                    Text("Reset")
                        .foregroundColor(.red)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
            }
        }
    }

    func reset() {
        print("clicked")
    }
}
