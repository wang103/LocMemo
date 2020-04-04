//
//  NewView.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/3/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct NewView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("When I arrive at location")
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
    }
}
