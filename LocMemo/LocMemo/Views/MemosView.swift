//
//  MemosView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import GoogleMobileAds
import SwiftUI

struct MemosView: View {

    @ObservedObject var externalSettings = ExternalSettings.shared

    // For write view
    @Binding var writeViewIsToCreate: Bool
    @Binding var writeViewLocationText: String
    @Binding var writeViewMemoText: String
    @Binding var writeViewRegionIdentifier: String

    @State private var showError: Bool = false
    @State private var errMsg: String = ""

    @State private var showSuccess: Bool = false
    @State private var successMsg: String? = nil

    @State private var showMemoActionSheet = false

    @State private var locMemos: [LocMemoData] = []

    var body: some View {
        VStack {

        NavigationView {
            List {
                ForEach(locMemos.enumerated().map({$0}), id: \.element.id) { index, locMemo in
                    SelectableCell(id: index, selectedCallback: self.locMemoSelected) {
                        self.getCellContent(locMemo: locMemo)
                    }
                    .actionSheet(isPresented: self.$showMemoActionSheet) { self.getMemoActionSheet() }
                }
            }
            .navigationBarTitle(String.localizedStringWithFormat(
                NSLocalizedString("Memos (%d)", comment: ""), locMemos.count))
            .alert(isPresented: self.$showSuccess, content: self.getSuccessAlert)
        }
        .alert(isPresented: self.$showError, content: self.getErrorAlert)
        .onAppear(perform: { self.locMemos = self.getAllLocMemos() })
        .popover(isPresented: self.$externalSettings.memosViewShowMemoPopover) { self.getMemoPopoverView() }

        HStack {
            Spacer()
            GADBannerViewController()
                .frame(width: kGADAdSizeBanner.size.width, height: kGADAdSizeBanner.size.height)
            Spacer()
        }

        } // end of VStack
    }

    func getCellContent(locMemo: LocMemoData, lineLimit: Int? = 3) -> some View {
        return VStack(alignment: .leading, spacing: 5) {
            Text(NSLocalizedString("location:", comment: "")).bold()
            Text(locMemo.locationText)
                .lineLimit(lineLimit)

            Text(NSLocalizedString("memo:", comment: "")).bold()
            Text(locMemo.memoText)
                .lineLimit(lineLimit)
        }
    }

    func locMemoSelected(index: Int) {
        ExternalSettings.shared.memosViewLastSelectedMemoIndex = index
        showMemoActionSheet = true
    }

    func getMemoActionSheet() -> ActionSheet {
        return ActionSheet(title: Text(NSLocalizedString("What to do?", comment: "")),
                           message: nil,
                           buttons: [.default(Text(NSLocalizedString("View", comment: "")), action: viewMemoCallback),
                                     .default(Text(NSLocalizedString("Edit", comment: "")), action: editMemoCallback),
                                     .destructive(Text(NSLocalizedString("Delete", comment: "")), action: deleteMemoCallback),
                                     .cancel()]
        )
    }

    // Assume lastSelectedMemoIndex or memosViewSelectedId is set properly.
    func getMemoPopoverView() -> some View {
        var externalIndex = -1
        let lastSelectedMemoIndex = externalSettings.memosViewLastSelectedMemoIndex
        if lastSelectedMemoIndex < 0 {
            externalIndex = locMemos.firstIndex(
                where: { $0.id == externalSettings.memosViewSelectedId }
            )!
        }

        return NavigationView {
            List {
                getCellContent(locMemo: locMemos[lastSelectedMemoIndex < 0 ? externalIndex : lastSelectedMemoIndex ],
                               lineLimit: nil)
            }
            .navigationBarTitle(NSLocalizedString("Memo", comment: ""))
            .navigationBarItems(trailing:
                Button(NSLocalizedString("Close", comment: "")) {
                    ExternalSettings.shared.memosViewShowMemoPopover = false
                }
            )
        }
    }

    func viewMemoCallback() {
        if externalSettings.memosViewLastSelectedMemoIndex < 0 {
            return
        }

        ExternalSettings.shared.memosViewShowMemoPopover = true
    }

    func editMemoCallback() {
        if externalSettings.memosViewLastSelectedMemoIndex < 0 {
            return
        }

        let locMemo = locMemos[externalSettings.memosViewLastSelectedMemoIndex]

        writeViewIsToCreate = false
        writeViewLocationText = locMemo.locationText
        writeViewMemoText = locMemo.memoText
        writeViewRegionIdentifier = locMemo.id
        ExternalSettings.shared.contentViewSelectedView = 1
    }

    func deleteMemoCallback() {
        let lastSelectedMemoIndex = externalSettings.memosViewLastSelectedMemoIndex
        if lastSelectedMemoIndex < 0 {
            return
        }

        LocationManager.shared.stopMonitoring(identifier: locMemos[lastSelectedMemoIndex].id)

        do {
            try DataManager.shared.delete(locMemos[lastSelectedMemoIndex].obj)

            showSuccessMsg()
            self.locMemos = self.getAllLocMemos()
        } catch let error as NSError {
            showErrorMsg(String.localizedStringWithFormat(
                NSLocalizedString("Deleting memo encountered error. Please try again. %@", comment: ""),
                error.localizedDescription))
        }
    }

    func getAllLocMemos() -> [LocMemoData] {
        do {
            return try DataManager.shared.getAllLocMemos()
        } catch let error as NSError {
            showErrorMsg(String.localizedStringWithFormat(
                NSLocalizedString("Reading saved memos encountered error. %@", comment: ""),
                error.localizedDescription))
            return []
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
