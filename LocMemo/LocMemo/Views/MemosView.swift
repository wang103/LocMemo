//
//  MemosView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct MemosView: View {

    // For write view
    @Binding var writeViewIsToCreate: Bool
    @Binding var writeViewLocationText: String
    @Binding var writeViewMemoText: String
    @Binding var writeViewRegionIdentifier: String

    @State private var showError: Bool = false
    @State private var errMsg: String = ""

    @State private var showSuccess: Bool = false
    @State private var successMsg: String? = nil

    @State private var showMemoPopover: Bool = false

    @State private var showMemoActionSheet = false
    @State private var lastSelectedMemoIndex: Int = -1

    @State private var locMemos: [LocMemoData] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(locMemos.enumerated().map({$0}), id: \.element.id) { index, locMemo in
                    SelectableCell(id: index, selectedCallback: self.locMemoSelected) {
                        self.getCellContent(locMemo: locMemo)
                    }
                    .actionSheet(isPresented: self.$showMemoActionSheet) { self.getMemoActionSheet() }
                }
            }
            .navigationBarTitle("Memos (\(locMemos.count))")
            .alert(isPresented: self.$showSuccess, content: self.getSuccessAlert)
        }
        .alert(isPresented: self.$showError, content: self.getErrorAlert)
        .onAppear(perform: { self.locMemos = self.getAllLocMemos() })
        .popover(isPresented: self.$showMemoPopover) { self.getMemoPopoverView() }
    }

    func getCellContent(locMemo: LocMemoData, lineLimit: Int? = 3) -> some View {
        return VStack(alignment: .leading, spacing: 5) {
            Text("location:").bold()
            Text(locMemo.locationText)
                .lineLimit(lineLimit)

            Text("memo:").bold()
            Text(locMemo.memoText)
                .lineLimit(lineLimit)
        }
    }

    func locMemoSelected(index: Int) {
        lastSelectedMemoIndex = index
        showMemoActionSheet = true
    }

    func getMemoActionSheet() -> ActionSheet {
        return ActionSheet(title: Text("What to do?"),
                           message: nil,
                           buttons: [.default(Text("View"), action: viewMemoCallback),
                                     .default(Text("Edit"), action: editMemoCallback),
                                     .destructive(Text("Delete"), action: deleteMemoCallback),
                                     .cancel()]
        )
    }

    func getMemoPopoverView() -> some View {
        return NavigationView {
            List {
                getCellContent(locMemo: locMemos[lastSelectedMemoIndex],
                               lineLimit: nil)
            }
            .navigationBarTitle("Memo")
            .navigationBarItems(trailing:
                Button("Close") { self.showMemoPopover = false }
            )
        }
    }

    func viewMemoCallback() {
        if lastSelectedMemoIndex < 0 {
            return
        }

        self.showMemoPopover = true
    }

    func editMemoCallback() {
        if lastSelectedMemoIndex < 0 {
            return
        }

        let locMemo = locMemos[lastSelectedMemoIndex]

        writeViewIsToCreate = false
        writeViewLocationText = locMemo.locationText
        writeViewMemoText = locMemo.memoText
        writeViewRegionIdentifier = locMemo.id
        ExternalSettings.shared.contentViewSelectedView = 1
    }

    func deleteMemoCallback() {
        if lastSelectedMemoIndex < 0 {
            return
        }

        LocationManager.shared.stopMonitoring(identifier: locMemos[lastSelectedMemoIndex].id)

        do {
            try DataManager.shared.delete(locMemos[lastSelectedMemoIndex].obj)

            showSuccessMsg()
            self.locMemos = self.getAllLocMemos()
        } catch let error as NSError {
            showErrorMsg("Deleting memo encountered error. Please try again. \(error.localizedDescription)")
        }
    }

    func getAllLocMemos() -> [LocMemoData] {
        do {
            return try DataManager.shared.getAllLocMemos()
        } catch let error as NSError {
            showErrorMsg("Reading saved memos encountered error. \(error.localizedDescription)")
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
