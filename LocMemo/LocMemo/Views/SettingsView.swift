//
//  SettingsView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @State private var showResetActionSheet = false

    var body: some View {
        NavigationView {
            getMainView()
            .navigationBarTitle("Settings")
        }
    }

    func getMainView() -> some View {
        return VStack {
            HStack {
                Button(action: resetButtonCallback) {
                    Text("Reset")
                        .foregroundColor(.red)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                .padding(.leading, 22)
                .actionSheet(isPresented: $showResetActionSheet) {
                    self.getResetActionSheet()
                }

                Spacer()
            }

            Spacer()
        }
    }

    func resetButtonCallback() {
        showResetActionSheet = true
    }

    func getResetActionSheet() -> ActionSheet {
        return ActionSheet(title: Text("Are you sure?"),
                           message: Text("This will delete all the memos."),
                           buttons: [.destructive(Text("Yes"), action: reset),
                                     .cancel()]
        )
    }

    func reset() {

    }
}
