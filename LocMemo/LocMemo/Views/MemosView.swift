//
//  MemosView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct MemosView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                }

                Section {
                    Text("Hello")
                    Text("Hello")
                    Text("Hello")
                }
            }
            .navigationBarTitle("Memos")
        }
    }
}
