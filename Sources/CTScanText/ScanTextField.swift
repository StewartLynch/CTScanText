import SwiftUI

/// A replacement for the TextField view that includes a scannable text button
public struct ScanTextField: UIViewRepresentable {
    /// Optional text used as a placeholder
    public let placeholder: String
    // Style Propeties
    var backgroundColor: UIColor
    var borderColor: UIColor
    var borderWidth: CGFloat
    var cornerRadius: CGFloat
    var contentType: UITextContentType?
    var keyboardType: UIKeyboardType
    /// text string bound to the view
    @Binding public var text: String
    /// SwiftUI version of a scannable TextField
     /// - Parameters:
    ///   - placeholder: Text used as a placeholder
    ///   - text: text string bound to the view
    ///   - backgroundColor:color of text field background (clear if not specified)
    ///   - borderColor: if used by a style, set toa quaternaryLabel color otherwise clear
    ///   - borderWidth: if used by a style, set 1 otherwise 0
    ///   - cornerRadius: if used by a style, set 0 otherwise 4
    ///   - contentType: a constant that identifies the semantic meaning for a text-entry area.
    ///   - keyboardType: a constant that specifies the type of keyboard to display for a text-based view
    public init(_ placeholder: String,
                text: Binding<String>,
                backgroundColor: UIColor = .clear,
                borderColor: UIColor = .clear,
                borderWidth: CGFloat = 0,
                cornerRadius: CGFloat = 0,
                contentType: UITextContentType? = nil,
                keyboardType: UIKeyboardType = .default) {
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.contentType = contentType
        self.keyboardType = keyboardType
        self._text = text
    }
    
    public func makeUIView(context: Context) -> some UIView {
        var barItems = [UIBarButtonItem]()
        let specialContent: [UITextContentType] = [.URL, .emailAddress, .telephoneNumber, .fullStreetAddress, .flightNumber, .dateTime, .shipmentTrackingNumber]
        if contentType == nil || (contentType != nil &&  !specialContent.contains(contentType!)) {
            let textFromCamera = UIAction.captureTextFromCamera(responder: context.coordinator, identifier: nil)
            let image = UIImage(systemName: "text.viewfinder")
            let textFromCameraItem = UIBarButtonItem(title: nil, image: image, primaryAction: textFromCamera, menu: nil)
            barItems.append(textFromCameraItem)
        }
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        barItems.append(flexSpace)
        let dismissImage = UIImage(systemName: "keyboard.chevron.compact.down")
        let dismissKeyboard = UIAction { _ in
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil
            )
        }
        let dismissKeyboardItem = UIBarButtonItem(title: nil,
                                                  image: dismissImage,
                                                  primaryAction: dismissKeyboard,
                                                  menu: nil)
        barItems.append(dismissKeyboardItem)
        let bar = UIToolbar()
        bar.items = barItems
        bar.sizeToFit()
        let textField = UITextField()
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 15))
        textField.inputAccessoryView = bar
        textField.textRect(forBounds: textField.layer.bounds)
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.text = text
        textField.textContentType = contentType
        textField.keyboardType = keyboardType
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.rightView = paddingView
        textField.leftView = paddingView
        textField.backgroundColor = backgroundColor
        textField.layer.borderWidth = borderWidth
        textField.layer.cornerRadius = cornerRadius
        textField.layer.borderColor = borderColor.cgColor
        return textField
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        if let uiView = uiView as? UITextField {
            uiView.text = text
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: UIResponder, UIKeyInput, UITextFieldDelegate {
        public let parent: ScanTextField
        
        public var hasText: Bool {
            !parent.text.isEmpty
        }
        
        public init(_ parent: ScanTextField) {
            self.parent = parent
        }
        
        public func insertText(_ text: String) {
            parent.text = text
        }
        
        public func deleteBackward() { }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}

extension ScanTextField {
    /// Possible styles to apply to the ScanTextField
    public enum ScanTextFieldStyle {
        /// 1 pixel border with a cornerRadius of 4 around the view
         case roundedBorder
        /// 1 pixel border with a cornerRadius of 4 around the view with
        /// s backround color added
         case roundedBorderWithBackground(UIColor)
        /// A scan text edtior style with no decoration
         case plain // The Default
     }
    
    /// Modifier to apply to a ScanTextField to style presentation
    /// - Parameter style: The type of style
    /// - Returns: a new ScanTextField with the style applied
     public func textFieldStyle(_ style: ScanTextFieldStyle) -> ScanTextField {
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
    
    /// Type of content expected for the ScanTextField
    /// - Parameter contentType: a constant that identifies the semantic meaning for a text-entry area
    /// - Returns: a new ScanTextField with the contentType specified
     public func textContentType(_ contentType: UITextContentType) -> ScanTextField {
         var view = self
         view.contentType = contentType
         return view
     }
    
    /// Type of keyboard to use for the ScanTextField
    /// - Parameter keyboardType: a constant that specifies the type of keyboard to display for a text-based view
    /// - Returns: a new ScanTextField with the keyboardType specified
     public func keyboardType(_ keyboardType: UIKeyboardType) -> ScanTextField {
         var view = self
         view.keyboardType = keyboardType
         return view
     }
}
