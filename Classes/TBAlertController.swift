//
//  TBAlertController.swift
//  TBAlertController
//
//  Created by Tanner on 9/22/14.
//  Copyright (c) 2021 Tanner. All rights reserved.
//

import UIKit

public extension UIAlertController.Style {
    init(style: TBAlertController.Style) {
        switch style {
            case .actionSheet:
                self = .actionSheet
            case .alert:
                self = .alert
        }
    }
}

@objcMembers
public class TBAlertController: NSObject {
    
    public enum PopoverSource {
        case none
        case view(UIView)
        case barItem(UIBarButtonItem)
    }
    
    public enum Style: Int {
        case actionSheet
        case alert
        
        public init(style: UIAlertController.Style) {
            switch style {
                case .actionSheet:
                    self = .actionSheet
                case .alert:
                    self = .alert
                @unknown default:
                    self = .alert
            }
        }
    }
    
    private var inCaseOfManualDismissal: UIAlertController?
    private var textFieldHandlers: [(UITextField) -> Void] = []
    private weak var currentPresentation: UIAlertController?
    private var completion: (() -> Void)?
    
    /// An array of `NSStrings` containing the text in each of the alert controller's text views *after* it has been dismissed.
    /// This array is passed to each `TBAlertActionBlock`, so it is only necessary to access this property if you for some reason need to keep it around for later use.
    private var textFieldInputStrings: [String] = []

    // MARK: Properties

    /// The style of the alert controller, representing action sheet style or alert view style.
    private(set) var style: Style = .actionSheet
    
    /// Setting this property has the same effect on iOS 7 and 8 as `UIAlertViewStyle` does on `UIAlertView`.
    /// Any additional text views added manually are added after the text views added by the specified style,
    /// even if you add them before setting this property.
    public var alertViewStyle: UIAlertViewStyle = .default {
        didSet {
            assert(self.style == .alert,
                "Text fields can only be added to alert controllers of style .alert"
            )
        }
    }
    
    /// The title of the alert controller.
    public var title: String = "" {
        didSet {
            self.currentPresentation?.title = self.title
        }
    }
    
    /// The message of the alert controller.
    public var message: String = "" {
        didSet {
            self.currentPresentation?.message = self.message
        }
    }
    
    /// The reference view for UIPopoverViewController on iPad
    public var popoverSource: PopoverSource = .none
    
    /// The array of `TBAlertActions` that comprise the alert / sheet.
    public var buttons: [TBAlertAction] = []
    public var preferredAction: TBAlertAction? = nil


    // MARK: Initializers

    /// A convenience method for `initWithTitle:message:style:` where `style` is `TBAlertController.Style.alert`.
    /// - Returns: A `TBAlertController` with no actions.
    public class func alertView(withTitle title: String, message: String) -> TBAlertController {
        return TBAlertController(title: title, message: message, style: .alert)
    }

    /// A convenience method for `initWithTitle:message:style:` where `style` is `TBAlertController.Style.actionSheet`.
    /// - Returns: A `TBAlertController` with no actions.
    public class func actionSheet(withTitle title: String, message: String) -> TBAlertController {
        return TBAlertController(title: title, message: message, style: .actionSheet)
    }

    /// A convenience method for creating an alert view style alert controller with a single "OK" button.
    /// - Returns: A `TBAlertController` with an "OK" button to dismiss it.
    public class func simpleOKAlert(withTitle title: String, message: String) -> TBAlertController {
        let alert = TBAlertController.alertView(withTitle: title, message: message)
        alert.addOtherButton("OK")
        return alert
    }

    /// Initializer that creates a `TBAlertController` in the specified style with no actions, title, or message.
    public init(style: Style = .alert) {
        super.init()
        self.style = style
    }

    /// Initializer that creates a `TBAlertController` in the specified style with the given title and message.
    public convenience init(title: String?, message: String?, style: Style = .alert) {
        self.init(style: style)
        self.title = title ?? ""
        self.message = message ?? ""
    }


    // MARK: Other buttons

    /// Same as `add(button:)` but for API compatibility with `UIAlertController`
    public func addAction(_ action: TBAlertAction) {
        self.addButton(action)
    }

    /// Adds a button via a `TBAlertAction`.
    public func addButton(_ button: TBAlertAction) {
        self.buttons.append(button)
    }

    /// Adds an actionless button with the given title.
    public func addOtherButton(_ title: String, style: UIAlertAction.Style = .default) {
        let button = TBAlertAction(title: title, style: style)
        self.buttons.append(button)
    }

    /// Adds a button with a block to be executed when triggered.
    /// - Parameters:
    ///   - title: The button title.
    ///   - buttonBlock: The `TBAlertActionBlock` to be executed when the button is triggered.
    public func addOtherButton(_ title: String, style: UIAlertAction.Style = .default,
                               action: @escaping (_ textFieldStrings: [String]) -> Void) {
        self.buttons.append(.init(title: title, block: action))
    }

    // MARK: Text Fields

    /// - seealso: Equivalent to `addTextFieldWithConfigurationHandler:` on `UIAlertController`.
    /// - note: The text fields for the `alertViewStyle` property will always come out on top of any fields added here.
    public func addTextField(with configurationHandler: @escaping (_ textField: UITextField) -> Void) {
        assert(style == .alert, "Text fields can only be added to alert controllers of style .alert")
        self.textFieldHandlers.append(configurationHandler)
    }

    private func collectText(from textFields: [UITextField]?) {
        for textField in textFields ?? [] {
            self.textFieldInputStrings.append(textField.text ?? "")
        }
    }

    
    // MARK: Displaying

    /// Presents the alert controller from the given view controller.
    /// - Parameter viewController: The view controller that should present the alert controller.
    public func show(from viewController: UIViewController) {
        self.show(from: viewController, animated: true)
    }

    /// Presents the alert controller from the given view controller.
    /// - Parameters:
    ///   - viewController: The view controller that should present the alert controller.
    ///   - animated: Whether or not to animate the presentation. This value is ignored on iOS 7.
    ///   - completion: An optional block to execute when the alert controller has been presented.
    ///                 You may pass `nil` to this parameter.
    public func show(from viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        var actions: [UIAlertAction] = []
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .init(style: self.style)
        )
        
        self.inCaseOfManualDismissal = alertController

        // Add text fields
        switch alertViewStyle {
            case .loginAndPasswordInput:
                // Login
                alertController.addTextField(configurationHandler: { textField in
                    textField.placeholder = "Login"
                })
                alertController.addTextField(configurationHandler: { textField in
                    textField.placeholder = "Password"
                    textField.isSecureTextEntry = true
                })
                
            case .plainTextInput:
                // Plaintext
                alertController.addTextField(configurationHandler: nil)
                
            case .secureTextInput:
                // Secure text
                alertController.addTextField(configurationHandler: { textField in
                    textField.isSecureTextEntry = true
                })
                
            case .default:
                break
            @unknown default:
                break
        }

        // Add text fields
        for handler in self.textFieldHandlers {
            alertController.addTextField(configurationHandler: handler)
        }

        // Create actions
        for button in self.buttons {
            actions.append(self.action(from: button, controller: alertController))
        }

        // Add actions to alert controller
        for action in actions {
            alertController.addAction(action)
        }
        
        // Add preferred action
        if let preferred = self.preferredAction, let idx = self.buttons.firstIndex(of: preferred) {
            alertController.preferredAction = actions[idx]
        }

        // Handle source view / bar item for action sheets
        switch self.popoverSource {
            case .barItem(let item):
                alertController.popoverPresentationController?.barButtonItem = item
            case .view(let view):
                alertController.popoverPresentationController?.sourceView = view
                alertController.popoverPresentationController?.sourceRect = view.bounds
            case .none:
                break
        }

        self.currentPresentation = alertController
        viewController.present(alertController, animated: animated, completion: completion)
    }

    // MARK: Dismissing

    /// Convenience method for programmatically dismissing the alert controller by trigger
    /// a specific button. The action, if any, will be performed.
    /// - Parameter index: The button index to trigger. It is always safe to pass `0` to this parameter.
    /// - warning: Behavior is undefied for values of `index` greater than or equal to `numberOfButtons`.
    public func dismiss(buttonIndex index: Int) {
        // Button 0 with no actions defaults to [self dismiss]
        if index == 0 && self.buttons.count == 0 {
            self.dismiss()
            return
        }

        let action = self.buttons[index]
        self.dismiss()
        
        if action.enabled {
            action.perform(self.textFieldInputStrings)
        }
    }

    /// - seealso: Equivalent to calling `dismissAnimated:completion` on `UIAlertController`.
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.currentPresentation = nil
        self.collectText(from: self.inCaseOfManualDismissal?.textFields)
        
        inCaseOfManualDismissal?.dismiss(
            animated: animated,
            completion: completion
        )
    }

    // MARK: UIAlertAction convenience (kinda wanna make this a category, can't because they call getTextFromTextFields)

    public func action(from button: TBAlertAction, controller: UIAlertController) -> UIAlertAction {
        let action: UIAlertAction

        switch button.kind {
            case .noAction:
                action = UIAlertAction(title: button.title, style: button.style)
            case .block:
                action = UIAlertAction(title: button.title, style: button.style,
                    handler: { [weak controller] _ in
                        guard let controller = controller else { return }
                        let strings = controller.textFields?.map { $0.text ?? "" } ?? []
                        button.perform(strings)
                    }
                )
        }

        action.isEnabled = button.enabled
        button._action = action
        
        return action
    }
}
