//
//  ScanTextView.swift
//  SwiftPackage
//
//  Created by Stewart Lynch on 2021-10-01.
//

import SwiftUI

/// A replacement for the TextEditor view that includes a scannable text button
/// and an optional placeholder text parameter
public struct ScanTextEditor: UIViewRepresentable {
    /// Optional text used as a placeholder
    public let placeholder: String
    /// text string bound to the view
    @Binding public var text: String
    // Style Propeties
    var backgroundColor: UIColor
    var borderColor: UIColor
    var borderWidth: CGFloat
    var cornerRadius: CGFloat
    /// SwiftUI Version of Scannable TextView
    /// - Parameters:
    ///   - placeholder: Optional text used as a placeholder
    ///   - text: text string bound to the view
    ///   - backgroundColor: color of text view background (clear if not specified)
    ///   - borderColor: if used by a style, set to quaternaryLabel color otherwise clear
    ///   - borderWidth: if used by a style, set 1 otherwise 0
    ///   - cornerRadius: if used by a style, set 0 otherwise 4
    public init(_ placeholder: String = "",
                text: Binding<String>,
                backgroundColor: UIColor = .clear,
                borderColor: UIColor = .clear,
                borderWidth: CGFloat = 0,
                cornerRadius: CGFloat = 0) {
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self._text = text
    }

    public func makeUIView(context: Context) -> some UIView {
        let textFromCamera = UIAction.captureTextFromCamera(responder: context.coordinator, identifier: nil)
        let image = UIImage(systemName: "text.viewfinder")
        let textFromCameraItem = UIBarButtonItem(title: nil, image: image, primaryAction: textFromCamera, menu: nil)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let dismissImage = UIImage(systemName: "keyboard.chevron.compact.down")
        let dismissKeyboard = UIAction { _ in
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                                            to: nil,from: nil, for: nil
            )
        }
        let dismissKeyboardItem = UIBarButtonItem(title: nil,
                                                  image: dismissImage,
                                                  primaryAction: dismissKeyboard,
                                                  menu: nil)
        let bar = UIToolbar()
        bar.items = [textFromCameraItem, flexSpace, dismissKeyboardItem]
        bar.sizeToFit()
        let textView = UITextView()
        textView.inputAccessoryView = bar
        let borderColor: UIColor = UIColor.quaternaryLabel
        let padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = padding
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.text = placeholder
        textView.backgroundColor = backgroundColor
        textView.textColor = .placeholderText
        textView.layer.borderWidth = borderWidth
        textView.layer.borderColor = borderColor.cgColor
        textView.layer.cornerRadius = cornerRadius
        return textView
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        if let uiView = uiView as? UITextView {
            if !text.isEmpty || uiView.textColor == .label {
                uiView.text = text
                uiView.textColor = .label
            }
            uiView.delegate = context.coordinator
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    public class Coordinator: UIResponder, UIKeyInput, UITextViewDelegate {
        var parent: ScanTextEditor
        public init(_ parent: ScanTextEditor) {
            self.parent = parent
        }
        public var hasText: Bool {
            true
        }
        public func insertText(_ text: String) {
            parent.text = text
        }
        public func deleteBackward() { }
        public func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        public func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .placeholderText {
                textView.text = ""
                textView.textColor = .label
            }
        }
        public func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .placeholderText
            }
        }
    }
}

extension ScanTextEditor {
    /// Possible Styles to apply to the ScanTexxtView
    public enum ScanTextEditorStyle {
        /// 1 pixel border with a cornerRadius of 4 around the view
        case roundedBorder
        /// 1 pixel border with a cornerRadius of 4 around the view with
        /// s backround color added
        case roundedBorderWithBackground(UIColor)
        /// A scan text edtior style with no decoration
        case plain
    }
    /// Modifier to apply to a ScanTextEdtior to style presentation
    /// - Parameter style: The type of style
    /// - Returns: a new ScanTextEditor with the style applied
     public func scanTextEditorStyle(_ style: ScanTextEditorStyle) -> ScanTextEditor {
         var view = self
         switch style {
         case .roundedBorder:
             view.borderWidth = 1
             view.borderColor = .quaternaryLabel
             view.cornerRadius = 4
         case .roundedBorderWithBackground(let bgColor):
             view.borderWidth = 1
             view.borderColor = .quaternaryLabel
             view.backgroundColor = bgColor
             view.cornerRadius = 4
         default: break
         }
         return view
     }
}
