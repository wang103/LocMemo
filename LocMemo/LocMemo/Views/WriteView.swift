//
//  NewView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import Contacts
import CoreLocation
import GoogleMobileAds
import SwiftUI

struct WriteView: View {
    private static let ADDRESS_FORMATTER = CNPostalAddressFormatter()

    // For this view
    @Binding var isToCreate: Bool
    @Binding var locationText: String
    @Binding var radiusText: String
    @Binding var memoText: String
    @Binding var regionIdentifier: String
    @Binding var selectedPlacemark: LMPlacemark?

    @State private var showError: Bool = false
    @State private var errMsg: String = ""

    @State private var showSuccess: Bool = false
    @State private var successMsg: String? = nil

    @State private var showLoading: Bool = false

    @State private var showLocationsPopover: Bool = false
    @State private var locationCandidates: [LMPlacemark] = []

    @State private var locationChanged: Bool = false

    var body: some View {
        LoadingView(isShowing: $showLoading) {
            VStack {

            Spacer()

            NavigationView {
                self.getMainView()
                .navigationBarTitle(self.isToCreate ?
                    NSLocalizedString("Create New Memo", comment: "") :
                    NSLocalizedString("Edit Memo", comment: ""))
                .navigationBarItems(trailing:
                    Button(NSLocalizedString("Save", comment: ""), action: self.saveCallback)
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

            HStack {
                Spacer()
                GADBannerViewController()
                    .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
                Spacer()
            }

            } // end of VStack
        }
    }

    func updateMemo() {
        if locationChanged && selectedPlacemark == nil {
            showErrorMsg(NSLocalizedString("Please select a location first.", comment: ""))
            return
        }

        let radius = Double(radiusText)
        if radius == nil {
            showErrorMsg(NSLocalizedString("Please enter a valid radius first.", comment: ""))
            return
        }

        if memoText.isEmpty {
            showErrorMsg(NSLocalizedString("Please write a memo first.", comment: ""))
            return
        }

        // Only if locationChanged, we need to call startMonitoring on the
        // new region, using the existing region identifier.
        var success: Bool = true
        if locationChanged {
            let region = LocationManager.shared.createRegion(
                cr: selectedPlacemark!.region,
                identifier: regionIdentifier
            )
            success = LocationManager.shared.startMonitoring(region: region)
        }

        if !success {
            showErrorMsg(NSLocalizedString("Device does not support region monitoring.", comment: ""))
        } else {
            do {
                try DataManager.shared.updateLocMemo(identifier: regionIdentifier,
                                                     locationText: locationText,
                                                     memoText: memoText,
                                                     latitude: selectedPlacemark!.region.center.latitude,
                                                     longitude: selectedPlacemark!.region.center.longitude,
                                                     radius: radius!
                                                    )

                showSuccessMsg()
                AppReviewManager.shared.promptForReview()
            } catch let error as NSError {
                showErrorMsg(String.localizedStringWithFormat(
                    NSLocalizedString("Saving memo encounterd error. Please try again. %@", comment: ""),
                    error.localizedDescription))
            }
        }
    }

    func createMemo() {
        if selectedPlacemark == nil {
            showErrorMsg(NSLocalizedString("Please select a location first.", comment: ""))
            return
        }

        let radius = Double(radiusText)
        if radius == nil {
            showErrorMsg(NSLocalizedString("Please enter a valid radius first.", comment: ""))
            return
        }

        if memoText.isEmpty {
            showErrorMsg(NSLocalizedString("Please write a memo first.", comment: ""))
            return
        }

        let identifier = UUID().uuidString
        let region = LocationManager.shared.createRegion(
            cr: selectedPlacemark!.region,
            identifier: identifier
        )
        let success = LocationManager.shared.startMonitoring(region: region)
        if !success {
            showErrorMsg(NSLocalizedString("Device does not support region monitoring.", comment: ""))
        } else {
            do {
                try DataManager.shared.saveLocMemo(identifier: identifier,
                                                   locationText: locationText,
                                                   memoText: memoText,
                                                   latitude: region.center.latitude,
                                                   longitude: region.center.longitude,
                                                   radius: radius!)

                showSuccessMsg(NSLocalizedString("Memo created.", comment: ""))
                clearInputs()
                AppReviewManager.shared.promptForReview()
            } catch let error as NSError {
                LocationManager.shared.stopMonitoring(region: region)
                showErrorMsg(String.localizedStringWithFormat(
                    NSLocalizedString("Saving memo encounterd error. Please try again. %@", comment: ""),
                    error.localizedDescription))
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
        radiusText = ""
        memoText = ""
        regionIdentifier = ""
        locationChanged = false
        selectedPlacemark = nil
    }

    func getMainView() -> some View {
        let locationTextBinding = Binding(
            get: { self.locationText },
            set: {
                self.locationText = $0
                self.locationChanged = true
            }
        )

        let radiusTextBinding = Binding(
            get: { self.radiusText },
            set: {
                self.radiusText = $0
                self.locationChanged = true
            }
        )

        return GeometryReader { geometry in Form {
            Section {
                Text(NSLocalizedString("When I arrive at location", comment: ""))
                MultilineTextField(locationTextBinding, placeholder: "", onCommit: self.locationOnCommit)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray4)))
                    .popover(isPresented: self.$showLocationsPopover) { self.getLocationsPopoverView() }

                HStack {
                    Text(NSLocalizedString("Radius (in meters)", comment: ""))
                    MultilineTextField(radiusTextBinding, placeholder: "", onCommit: self.radiusOnCommit)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray4)))
                }

                ZStack {
                    MapView(center: self.$selectedPlacemark)
                        .edgesIgnoringSafeArea(.all)
                        .frame(
                            width: geometry.size.width * 0.7,
                            height: geometry.size.width * 0.7
                        )
                }
            }
            .alert(isPresented: self.$showSuccess, content: self.getSuccessAlert)

            Section {
                Text(NSLocalizedString("Show me this memo", comment: ""))
                MultilineTextField(self.$memoText, placeholder: "", onCommit: nil)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray4)))
            }
            .alert(isPresented: self.$showError, content: self.getErrorAlert)
        } /* end of Form */ } /* end of GeometryReader */
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
            .navigationBarTitle(NSLocalizedString("Select Location", comment: ""))
            .navigationBarItems(trailing:
                Button(NSLocalizedString("Close", comment: "")) { self.showLocationsPopover = false }
            )
        }
    }

    func locationSelected(id: Int) {
        let placemark = locationCandidates[id]

        let placemarkDisplayStr = getDisplayStr(placemark)
        if !placemarkDisplayStr.isEmpty {
            locationText = placemarkDisplayStr
        } else {
            // Could not format the CLPlacemark retrieved, just leave as is.
        }

        radiusText = "\(placemark.region.radius)"

        selectedPlacemark = placemark

        showLocationsPopover = false

        LocationManager.shared.requestUserPermission()
    }

    func locationOnCommit() {
        if locationText.isEmpty {
            return
        }

        selectedPlacemark = nil
        showLoading = true
        radiusText = ""

        LocationManager.shared.getPlacemarks(
            locationText,
            completionHandler: getPlacemarksCompletionHandler
        )
    }

    func radiusOnCommit() {
        let radius = Double(radiusText)
        if radius == nil || selectedPlacemark == nil {
            return
        }
        if Int(selectedPlacemark!.region.radius) == Int(radius!) {
            return
        }

        let updatedRegion = CLCircularRegion(
            center: selectedPlacemark!.region.center,
            radius: radius!,
            identifier: selectedPlacemark!.region.identifier)
        let updatedPlacemark = LMPlacemark(
            region: updatedRegion,
            name: selectedPlacemark!.name,
            isoCountryCode: selectedPlacemark!.isoCountryCode,
            postalAddress: selectedPlacemark!.postalAddress)
        selectedPlacemark = updatedPlacemark
    }

    func getPlacemarksCompletionHandler(placemarks: [LMPlacemark]?,
                                        error: NSError?) {
        selectedPlacemark = nil
        showLoading = false

        if error != nil || placemarks == nil || placemarks!.count == 0 {
            showErrorMsg(NSLocalizedString("Invalid location. Please refine your search.", comment: ""))
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
    func getDisplayStr(_ placemark: LMPlacemark) -> String {
        var str: String = ""
        if placemark.postalAddress != nil {
            str = WriteView.ADDRESS_FORMATTER
                .string(from: placemark.postalAddress!)
                .replacingOccurrences(of: "\n", with: ", ")
        }

        if !str.isEmpty {
            return str
        }

        if placemark.name != nil {
            return placemark.name!
        }
        return ""
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
