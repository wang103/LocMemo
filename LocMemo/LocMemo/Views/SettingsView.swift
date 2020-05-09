//
//  SettingsView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import GoogleMobileAds
import SwiftUI

struct SettingsView: View {

    @ObservedObject var externalSettings = ExternalSettings.shared

    @State private var showError: Bool = false
    @State private var errMsg: String = ""

    @State private var showSuccess: Bool = false
    @State private var successMsg: String? = nil

    @State private var showResetActionSheet = false

    var body: some View {
        VStack {

        NavigationView {
            getMainView()
            .navigationBarTitle(NSLocalizedString("Settings", comment: ""))
        }
        .alert(isPresented: self.$showError, content: self.getErrorAlert)

        HStack {
            Spacer()
            GADBannerViewController()
                .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
            Spacer()
        }

        } // end of VStack
    }

    func getMainView() -> some View {
        return VStack {

            HStack {
                Text(String.localizedStringWithFormat(
                        NSLocalizedString("Location Auth: %@", comment: ""),
                        externalSettings.locationAuthStatus))
                    .padding(.leading, 22)
                    .padding(.top, 5)

                Button(action: changeLocationAuthorization) {
                    Text(NSLocalizedString("Change", comment: ""))
                        .foregroundColor(.blue)
                        .padding(3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .padding(.top, 4)

                Spacer()
            }

            HStack {
                Text(String.localizedStringWithFormat(
                        NSLocalizedString("Notification Auth: %@", comment: ""),
                        externalSettings.notificationAuthStatus))
                    .padding(.leading, 22)
                    .padding(.top, 10)

                Button(action: changeNotificationAuthorization) {
                    Text(NSLocalizedString("Change", comment: ""))
                        .foregroundColor(.blue)
                        .padding(3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .padding(.top, 10)

                Spacer()
            }

            HStack {
                Text(String.localizedStringWithFormat(NSLocalizedString("auths_text", comment: ""),
                        LocationManager.shared.getAuthorizationStatusStr(.authorizedAlways),
                        NotificationManager.shared.getAuthorizationStatusStr(.authorized),
                        UIApplication.locationUsageDescription))
                .padding(.leading, 22)
                .padding(.top, 10)
                .font(.footnote)

                Spacer()
            }

            HStack {
                Button(action: reviewAppButtonCallback) {
                    Text(NSLocalizedString("Write Review", comment: ""))
                        .foregroundColor(.blue)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .padding(.leading, 22)
                .padding(.top, 40)

                Spacer()
            }

            HStack {
                Button(action: resetButtonCallback) {
                    Text(NSLocalizedString("Reset", comment: ""))
                        .foregroundColor(.red)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                .padding(.leading, 22)
                .padding(.top, 40)
                .actionSheet(isPresented: $showResetActionSheet) {
                    self.getResetActionSheet()
                }

                Spacer()
            }
            .alert(isPresented: self.$showSuccess, content: self.getSuccessAlert)

            Spacer()
        }
    }

    func changeNotificationAuthorization() {
        if let bundleId = Bundle.main.bundleIdentifier,
           let url = URL(string: "\(UIApplication.openSettingsURLString)&path=NOTIFICATION/\(bundleId)") {
            UIApplication.shared.open(url)
        }
    }

    func changeLocationAuthorization() {
        if let bundleId = Bundle.main.bundleIdentifier,
           let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
            UIApplication.shared.open(url)
        }
    }

    func reviewAppButtonCallback() {
        guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/id1510668870?action=write-review")
            else { fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }

    func resetButtonCallback() {
        showResetActionSheet = true
    }

    func getResetActionSheet() -> ActionSheet {
        return ActionSheet(title: Text(NSLocalizedString("Are you sure?", comment: "")),
                           message: Text(NSLocalizedString("This will delete all the memos.", comment: "")),
                           buttons: [.destructive(Text(NSLocalizedString("Yes", comment: "")), action: reset),
                                     .cancel()]
        )
    }

    func reset() {
        LocationManager.shared.stopMonitoringAll()

        do {
            try DataManager.shared.deleteAll()
            showSuccessMsg()
        } catch let error as NSError {
            showErrorMsg(String.localizedStringWithFormat(
                NSLocalizedString("Deleting memo encountered error. Please try again. %@", comment: ""),
                error.localizedDescription))
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
        return Alert(title: Text(NSLocalizedString("Error!", comment: "")),
                     message: Text(errMsg),
                     dismissButton: .default(Text(NSLocalizedString("OK", comment: ""))))
    }

    func getSuccessAlert() -> Alert {
        return Alert(title: Text(NSLocalizedString("Success!", comment: "")),
                     message: successMsg == nil ? nil : Text(successMsg!),
                     dismissButton: .default(Text(NSLocalizedString("OK", comment: ""))))
    }
}
