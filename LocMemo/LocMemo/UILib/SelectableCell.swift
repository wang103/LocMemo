//
//  SelectableCell.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/5/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct SelectableCell: View {

    let text: String
    let id: Int
    let selectedCallback: (Int) -> Void

    var body: some View {
        Text(text)
            .onTapGesture {
                self.selectedCallback(self.id)
            }
    }
}
