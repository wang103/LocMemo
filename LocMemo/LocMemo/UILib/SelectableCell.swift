//
//  SelectableCell.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/5/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

struct SelectableCell<Content>: View where Content: View {

    let id: Int
    let selectedCallback: (Int) -> Void
    var content: () -> Content

    var body: some View {
        content()
            .onTapGesture {
                self.selectedCallback(self.id)
            }
    }
}
