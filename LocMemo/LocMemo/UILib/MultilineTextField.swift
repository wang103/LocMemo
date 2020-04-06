//
//  MultilineTextField.swift
//  LocMemo
//
//  Created by Tianyi Wang on 4/6/20.
//  Copyright © 2020 x. All rights reserved.
//

import SwiftUI

fileprivate struct UITextViewWrapper: UIViewRepresentable {

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>)
            -> UITextView {
        let uiTextView = UITextView()
        uiTextView.delegate = context.coordinator

        uiTextView.isEditable = true
        uiTextView.font = UIFont.preferredFont(forTextStyle: .body)
        uiTextView.isSelectable = true
        uiTextView.isUserInteractionEnabled = true
        uiTextView.isScrollEnabled = false
        uiTextView.backgroundColor = UIColor.clear
        if onDone != nil {
            uiTextView.returnKeyType = .done
        }

        uiTextView.setContentCompressionResistancePriority(
            .defaultLow, for: .horizontal)
        return uiTextView
    }

    func updateUIView(_ uiView: UITextView,
                      context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        UITextViewWrapper.recalculateHeight(view: uiView,
                                            result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView,
                                              result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(
            CGSize(width: view.frame.size.width,
                   height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                 // Must be called asynchronously
                result.wrappedValue = newSize.height
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textView(_ textView: UITextView,
                      shouldChangeTextIn range: NSRange,
                      replacementText text: String) -> Bool {
            if self.onDone != nil && text == "\n" {
                textView.resignFirstResponder()
                self.onDone!()
                return false
            }
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
            UITextViewWrapper.recalculateHeight(view: textView,
                                                result: calculatedHeight)
        }
    }
}

struct MultilineTextField: View {

    private var placeholder: String
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 100
    @State private var showingPlaceholder = false

    init (_ text: Binding<String>,
          placeholder: String = "",
          onCommit: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText,
                          calculatedHeight: $dynamicHeight,
                          onDone: onCommit)
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
            .background(placeholderView, alignment: .topLeading)
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
                    .padding(.top, 8)
            }
        }
    }
}
