//
//  SettingsView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @State private var showError: Bool = false
    @State private var errMsg: String = ""

    @State private var showSuccess: Bool = false
    @State private var successMsg: String? = nil

    @State private var showResetActionSheet = false

    var body: some View {
        NavigationView {
            getMainView()
            .navigationBarTitle("Settings")
        }
        .alert(isPresented: self.$showError, content: self.getErrorAlert)
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
            .alert(isPresented: self.$showSuccess, content: self.getSuccessAlert)

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
        LocationManager.shared.stopMonitoringAll()

        do {
            try DataManager.shared.deleteAll()
            showSuccessMsg()
        } catch let error as NSError {
            showErrorMsg("Deleting memo encountered error. Please try again. \(error.localizedDescription)")
        }
    }

    func showErrorMsg(_ msg: String) {
        errMsg = msg
        showError = true
    }

    func showSuccessMsg(_ msg: String? = nil) {
        successMsg = msg
        showSuccess = true
    }

    func getErrorAlert() -> Alert {
        return Alert(title: Text("Error!"),
                     message: Text(errMsg),
                     dismissButton: .default(Text("OK")))
    }

    func getSuccessAlert() -> Alert {
        return Alert(title: Text("Success!"),
                     message: successMsg == nil ? nil : Text(successMsg!),
                     dismissButton: .default(Text("OK")))
    }
}
