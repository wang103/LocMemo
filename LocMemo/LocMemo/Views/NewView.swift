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

    @State private var showLoading: Bool = false

    @State private var locationText: String = ""
    @State private var showLocationsPopover: Bool = false
    @State private var locationCandidates: [CLPlacemark] = []

    @State private var selectedPlacemark: CLPlacemark? = nil

    var body: some View {
        LoadingView(isShowing: $showLoading) {
            NavigationView {
                self.getMainView()
                .navigationBarTitle("Create New Memo")
            }
            .alert(isPresented: self.$showError, content: self.getErrorAlert)
        }
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
            }

            Button(action: {}) {
                Text("Create")
            }
        }
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
            errMsg = "Invalid location. Please refine your search."
            showError = true
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
}
