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

    @State private var location: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("When I arrive at location")
                    TextField("", text: $location, onCommit: { self.locationOnCommit() })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section {
                    Text("Show me this memo")
                }

                Button(action: {}) {
                    Text("Create")
                }
            }
            .navigationBarTitle("Create New Memo")
        }
        .alert(isPresented: $showError, content: getErrorAlert)
    }

    func locationOnCommit() {
        LocationManager.shared.getPlacemarks(
            location,
            completionHandler: getPlacemarksCompletionHandler
        )
    }

    func getPlacemarksCompletionHandler(placemarks: [CLPlacemark]?,
                                        error: NSError?) {
        if error != nil || placemarks == nil || placemarks!.count == 0 {
            errMsg = "Invalid location. Please refine your search."
            showError = true
            return
        }

        if placemarks!.count == 1 {
            let placemarkDisplayStr = getDisplayStr(placemarks![0])
            if !placemarkDisplayStr.isEmpty {
                location = placemarkDisplayStr
            } else {
                // Could not format the CLPlacemark retrieved, just leave as is.
            }
        } else {

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
