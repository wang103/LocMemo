//
//  MemosView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct MemosView: View {

    @State private var showError: Bool = false
    @State private var errMsg: String = ""

    var body: some View {
        let locMemos = getAllLocMemos()

        return NavigationView {
            List {
                ForEach(0..<locMemos.count) { index in
                    Text(locMemos[index].locationText)
                }
            }
            .navigationBarTitle("Memos")
        }
        .alert(isPresented: self.$showError, content: self.getErrorAlert)
    }

    func getAllLocMemos() -> [LocMemoData] {
        do {
            return try DataManager.shared.getAllLocMemos()
        } catch let error as NSError {
            showErrorMsg("Unable to read saved memos. Please try again. \(error.localizedDescription)")
            return []
        }
    }

    func showErrorMsg(_ msg: String) {
        errMsg = msg
        showError = true
    }

    func getErrorAlert() -> Alert {
        return Alert(title: Text("Error!"),
                     message: Text(errMsg),
                     dismissButton: .default(Text("OK")))
    }
}
