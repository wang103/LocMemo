//
//  NewView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import Contacts
import CoreLocation
import SwiftUI

struct NewView: View {
    private static let ADDRESS_FORMATTER = CNPostalAddressFormatter()

    @State private var showError: Bool = false
    @State private var errMsg: String = ""

    @State private var showSuccess: Bool = false
    @State private var successMsg: String? = nil

    @State private var showLoading: Bool = false

    @State private var locationText: String = ""
    @State private var showLocationsPopover: Bool = false
    @State private var locationCandidates: [CLPlacemark] = []

    @State private var selectedPlacemark: CLPlacemark? = nil

    @State private var memoText: String = ""

    var body: some View {
        LoadingView(isShowing: $showLoading) {
            NavigationView {
                self.getMainView()
                .navigationBarTitle("Create New Memo")
                .navigationBarItems(trailing:
                    Button("Save", action: self.createNewMemo)
                )
            }
            .alert(isPresented: self.$showError, content: self.getErrorAlert)
            .alert(isPresented: self.$showSuccess, content: self.getSuccessAlert)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }

    func createNewMemo() {
        if selectedPlacemark == nil {
            showErrorMsg("Please select a location first.")
            return
        }

        if memoText.isEmpty {
            showErrorMsg("Please write a memo first.")
            return
        }

        let success = LocationManager.shared.monitorRegionAtLocation(
            center: selectedPlacemark!.location!.coordinate,
            identifier: locationText
        )
        if !success {
            showErrorMsg("Device does not support region monitoring.")
        } else {
            showSuccessMsg()
            clearInputs()
        }
    }

    func clearInputs() {
        locationText = ""
        memoText = ""
    }

    func getMainView() -> some View {
        return Form {
            Section {
                Text("When I arrive at location")
                TextField("", text: self.$locationText, onCommit: { self.locationOnCommit() })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .popover(isPresented: self.$showLocationsPopover) { self.getLocationsPopoverView() }
            }

            Section {
                Text("Show me this memo")
                MultilineTextField($memoText, placeholder: "", onCommit: memoOnCommit)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray4)))
            }
        }
    }

    func memoOnCommit() {
        // intentionally empty
    }

    func getLocationsPopoverView() -> some View {
        return NavigationView {
            List {
                ForEach(0..<locationCandidates.count) { index in
                    SelectableCell(
                        text: self.getDisplayStr(self.locationCandidates[index]),
                        id: index,
                        selectedCallback: self.locationSelected
                    )
                }
            }
            .navigationBarTitle("Select Location")
            .navigationBarItems(trailing:
                Button("Close") { self.showLocationsPopover = false }
            )
        }
    }

    func locationSelected(id: Int) {
        let placemarkDisplayStr = getDisplayStr(locationCandidates[id])
        if !placemarkDisplayStr.isEmpty {
            locationText = placemarkDisplayStr
        } else {
            // Could not format the CLPlacemark retrieved, just leave as is.
        }

        selectedPlacemark = locationCandidates[id]

        showLocationsPopover = false
    }

    func locationOnCommit() {
        if locationText.isEmpty {
            return
        }

        selectedPlacemark = nil
        showLoading = true

        LocationManager.shared.getPlacemarks(
            locationText,
            completionHandler: getPlacemarksCompletionHandler
        )
    }

    func getPlacemarksCompletionHandler(placemarks: [CLPlacemark]?,
                                        error: NSError?) {
        selectedPlacemark = nil
        showLoading = false

        if error != nil || placemarks == nil || placemarks!.count == 0 {
            showErrorMsg("Invalid location. Please refine your search.")
            return
        }

        if placemarks!.count == 1 {
            locationCandidates = placemarks!
            locationSelected(id: 0)
        } else {
            locationCandidates = placemarks!
            showLocationsPopover = true
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

    /**
     * Returns empty string if couldn't format.
     */
    func getDisplayStr(_ placemark: CLPlacemark) -> String {
        if placemark.postalAddress != nil {
            return NewView.ADDRESS_FORMATTER
                .string(from: placemark.postalAddress!)
                .replacingOccurrences(of: "\n", with: ", ")
        }
        return ""
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
