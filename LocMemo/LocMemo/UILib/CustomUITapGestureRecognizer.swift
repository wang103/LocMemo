//
//  CustomUITapGestureRecognizer.swift
//  LocMemo
//
//  Created by Tianyi Wang on 7/12/20.
//  Copyright © 2020 hyperware. All rights reserved.
//

class CustomUITapGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touchedView = touches.first?.view, touchedView is UIControl {
            state = .cancelled
        } else if let touchedView = touches.first?.view as? UITextView, touchedView.isEditable {
            state = .cancelled
        } else {
            super.touchesBegan(touches, with: event)
        }
    }
}
