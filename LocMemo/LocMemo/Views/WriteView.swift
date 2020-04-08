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

struct WriteView: View {
    private static let ADDRESS_FORMATTER = CNPostalAddressFormatter()

    // For this view
    @Binding var isToCreate: Bool
    @Binding var locationText: String
    @Binding var memoText: String
    @Binding var regionIdentifier: String

    @State private var showError: Bool = false
    @State private var errMsg: String = ""

    @State private var showSuccess: Bool = false
    @State private var successMsg: String? = nil

    @State private var showLoading: Bool = false

    @State private var showLocationsPopover: Bool = false
    @State private var locationCandidates: [CLPlacemark] = []

    @State private var locationTextChanged: Bool = false
    @State private var selectedPlacemark: CLPlacemark? = nil

    var body: some View {
        LoadingView(isShowing: $showLoading) {
            NavigationView {
                self.getMainView()
                .navigationBarTitle(self.isToCreate ? "Create New Memo" : "Edit Memo")
                .navigationBarItems(trailing:
                    Button("Save", action: self.saveCallback)
                )
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .onDisappear(perform: {
                if !self.isToCreate {
                    self.clearInputs()
                }
            })
        }
    }

    func updateMemo() {
        if locationTextChanged && selectedPlacemark == nil {
            showErrorMsg("Please select a location first.")
            return
        }

        if memoText.isEmpty {
            showErrorMsg("Please write a memo first.")
            return
        }

        // Only if locationTextChanged, we need to call startMonitoring on the
        // new region, using the existing region identifier.
        var success: Bool = true
        if locationTextChanged {
            let region = LocationManager.shared.createRegion(
                center: selectedPlacemark!.location!.coordinate,
                identifier: regionIdentifier
            )
            success = LocationManager.shared.startMonitoring(region: region)
        }

        if !success {
            showErrorMsg("Device does not support region monitoring.")
        } else {
            do {
                try DataManager.shared.updateLocMemo(identifier: regionIdentifier,
                                                     locationText: locationText,
                                                     memoText: memoText)

                showSuccessMsg()
            } catch let error as NSError {
                showErrorMsg("Saving memo encounterd error. Please try again. \(error.localizedDescription)")
            }
        }
    }

    func createMemo() {
        if selectedPlacemark == nil {
            showErrorMsg("Please select a location first.")
            return
        }

        if memoText.isEmpty {
            showErrorMsg("Please write a memo first.")
            return
        }

        let identifier = UUID().uuidString
        let region = LocationManager.shared.createRegion(
            center: selectedPlacemark!.location!.coordinate,
            identifier: identifier
        )
        let success = LocationManager.shared.startMonitoring(region: region)
        if !success {
            showErrorMsg("Device does not support region monitoring.")
        } else {
            do {
                try DataManager.shared.saveLocMemo(identifier: identifier,
                                                   locationText: locationText,
                                                   memoText: memoText)

                showSuccessMsg()
                clearInputs()
            } catch let error as NSError {
                LocationManager.shared.stopMonitoring(region: region)
                showErrorMsg("Saving memo encounterd error. Please try again. \(error.localizedDescription)")
            }
        }
    }

    func saveCallback() {
        if isToCreate {
            createMemo()
        } else {
            updateMemo()
        }
    }

    func clearInputs() {
        isToCreate = true
        locationText = ""
        memoText = ""
        regionIdentifier = ""
        locationTextChanged = false
    }

    func getMainView() -> some View {
        let locationTextBinding = Binding(
            get: { self.locationText },
            set: {
                self.locationText = $0
                self.locationTextChanged = true
            }
        )

        return Form {
            Section {
                Text("When I arrive at location")
                TextField("", text: locationTextBinding, onCommit: locationOnCommit)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .popover(isPresented: self.$showLocationsPopover) { self.getLocationsPopoverView() }
            }
            .alert(isPresented: self.$showSuccess, content: self.getSuccessAlert)

            Section {
                Text("Show me this memo")
                MultilineTextField($memoText, placeholder: "", onCommit: memoOnCommit)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray4)))
            }
            .alert(isPresented: self.$showError, content: self.getErrorAlert)
        }
    }

    func memoOnCommit() {
        // intentionally empty
    }

    func getLocationsPopoverView() -> some View {
        return NavigationView {
            List {
                ForEach(0..<locationCandidates.count) { index in
                    SelectableCell(id: index, selectedCallback: self.locationSelected) {
                        Text(self.getDisplayStr(self.locationCandidates[index]))
                    }
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
            return WriteView.ADDRESS_FORMATTER
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
