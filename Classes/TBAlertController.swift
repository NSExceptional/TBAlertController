//
//  TBAlertController.swift
//  TBAlertController
//
//  Created by Tanner on 9/22/14.
//  Copyright (c) 2021 Tanner. All rights reserved.
//

import UIKit

enum TBAlertControllerStyle: Int {
    case actionSheet
    case alert
    
    init(style: UIAlertController.Style) {
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

extension UIAlertController.Style {
    init(style: TBAlertControllerStyle) {
        switch style {
            case .actionSheet:
                self = .actionSheet
            case .alert:
                self = .alert
        }
    }
}

@objcMembers
class TBAlertController: NSObject {
    
    public enum PopoverSource {
        case none
        case view(UIView)
        case barItem(UIBarButtonItem)
    }
    
    private var inCaseOfManualDismissal: UIAlertController?
    private var cancelAction: TBAlertAction?
    private var buttons: [TBAlertAction] = []
    private var textFieldHandlers: [(UITextField) -> Void] = []
    private weak var currentPresentation: UIAlertController?
    private var completion: (() -> Void)?
    
    /// An array of `NSStrings` containing the text in each of the alert controller's text views *after* it has been dismissed.
    /// This array is passed to each `TBAlertActionBlock`, so it is only necessary to access this property if you for some reason need to keep it around for later use.
    private var textFieldInputStrings: [String] = []

    // MARK: Properties

    /// The style of the alert controller, representing action sheet style or alert view style.
    private(set) var style: TBAlertControllerStyle = .actionSheet
    
    /// Setting this property has the same effect on iOS 7 and 8 as `UIAlertViewStyle` does on `UIAlertView`.
    /// Any additional text views added manually are added after the text views added by the specified style,
    /// even if you add them before setting this property.
    var alertViewStyle: UIAlertViewStyle = .default {
        didSet {
            assert(self.style == .alert,
                "Text fields can only be added to alert controllers of style .alert"
            )
        }
    }
    
    /// The title of the alert controller.
    var title: String = "" {
        didSet {
            self.currentPresentation?.title = self.title
        }
    }
    
    /// The message of the alert controller.
    var message: String = "" {
        didSet {
            self.currentPresentation?.message = self.message
        }
    }
    
    /// The reference view for UIPopoverViewController on iPad
    public var popoverSource: PopoverSource = .none
    
    /// Defaults to `NSNotFound`. Values greater than the number of buttons are allowed but will be ignored and discarded.
    var destructiveButtonIndex: Int = NSNotFound
    
    /// - Returns: The number of "other buttons" added + the cancel button, if you added one.
    var numberOfButtons: Int {
        if self.cancelAction != nil {
            return self.buttons.count + 1
        }

        return self.buttons.count
    }
    
    /// - Returns: An array of `TBAlertActions` representing all "other button" actions and the cancel button action,
    /// if you added one. Gauranteed to never be `nil`.
    var actions: [TBAlertAction] {
        if let cancelAction = self.cancelAction {
            var temp: [TBAlertAction] = self.buttons
            temp.append(cancelAction)
            return temp 
        }
        
        return self.buttons;
    }


    // MARK: Initializers

    /// A convenience method for `initWithTitle:message:style:` where `style` is `TBAlertControllerStyleAlert`.
    /// - Returns: A `TBAlertController` with no actions.
    class func alertView(withTitle title: String, message: String) -> TBAlertController {
        return TBAlertController(title: title, message: message, style: .alert)
    }

    /// A convenience method for `initWithTitle:message:style:` where `style` is `TBAlertControllerStyleActionSheet`.
    /// - Returns: A `TBAlertController` with no actions.
    class func actionSheet(withTitle title: String, message: String) -> TBAlertController {
        return TBAlertController(title: title, message: message, style: .actionSheet)
    }

    /// A convenience method for creating an alert view style alert controller with a single "OK" button.
    /// - Returns: A `TBAlertController` with an "OK" button to dismiss it.
    class func simpleOKAlert(withTitle title: String, message: String) -> TBAlertController {
        let alert = TBAlertController.alertView(withTitle: title, message: message)
        alert.addOtherButton("OK")
        return alert
    }

    /// Initializer that creates a `TBAlertController` in the specified style with no actions, title, or message.
    init(style: TBAlertControllerStyle = .alert) {
        super.init()
        self.style = style
    }

    /// Initializer that creates a `TBAlertController` in the specified style with the given title and message.
    convenience init(title: String?, message: String?, style: TBAlertControllerStyle = .alert) {
        self.init(style: style)
        self.title = title ?? ""
        self.message = message ?? ""
    }

    // MARK: Cancel button

    /// Adds a cancel button via a `TBAlertAction`.
    func setCancelButton(action: TBAlertAction) {
        self.cancelAction = action
    }

    /// Adds an actionless cancel button with the given title.
    func setCancelButton(title: String) {
        self.cancelAction = TBAlertAction(title: title)
    }

    /// Adds a cancel button with a block to be executed when triggered.
    /// - Parameters:
    ///   - title: The button title
    ///   - buttonBlock: The `TBAlertActionBlock` to be executed when the button is triggered.
    func setCancelButtonWithTitle(_ title: String, buttonAction buttonBlock: @escaping TBAlertActionBlock) {
        self.cancelAction = TBAlertAction(title: title, block: buttonBlock)
    }

    /// - warning: This is a feature of `UIAlertAction` and is only available on iOS 8.
    func setCancelButtonEnabled(_ enabled: Bool) {
        assert(self.cancelAction != nil, "Cancel button was never set, cannot enable or disable it.")
        self.cancelAction?.enabled = enabled
    }

    /// Removes the cancel button.
    func removeCancelButton() {
        self.cancelAction = nil
    }


    // MARK: Other buttons

    /// Same as `add(button:)` but for API compatibility with `UIAlertController`
    func addAction(_ action: TBAlertAction) {
        self.addButton(action)
    }

    /// Adds a button via a `TBAlertAction`.
    func addButton(_ button: TBAlertAction) {
        self.buttons.append(button)
    }

    /// Adds an actionless button with the given title.
    func addOtherButton(_ title: String) {
        assert(title != "", "Invalid parameter not satisfying: title != \"\"")

        let button = TBAlertAction(title: title)
        self.buttons.append(button)
    }

    /// Adds a button with a block to be executed when triggered.
    /// - Parameters:
    ///   - title: The button title.
    ///   - buttonBlock: The `TBAlertActionBlock` to be executed when the button is triggered.
    func addOtherButton(with title: String, action buttonBlock: @escaping (_ textFieldStrings: [String]) -> Void) {
        assert(title != "", "Invalid parameter not satisfying: title != ",file: "")
        
        self.buttons.append(.init(title: title, block: buttonBlock))
    }

    /// - note: You can also use this to enable or disable the cancel button if you have one set.
    func setButtonEnabled(_ enabled: Bool, at buttonIndex: Int) {
        // Cancel button
        if buttonIndex == self.buttons.count {
            assert(self.cancelAction != nil, "Invalid button index; out of bounds.")
            self.cancelAction!.enabled = enabled
        } else {
            self.buttons[buttonIndex].enabled = enabled
        }
    }

    /// Removes a button.
    /// - note: You can also use this to remove the cancel button if you have one set.
    func removeButton(at buttonIndex: Int) {
        if buttonIndex == self.buttons.count {
            assert(self.cancelAction != nil, "Invalid button index; out of bounds.")
            removeCancelButton()
        } else {
            self.buttons.remove(at: buttonIndex)
        }
    }

    
    // MARK: Text Fields

    /// - seealso: Equivalent to `addTextFieldWithConfigurationHandler:` on `UIAlertController`.
    /// - note: The text fields for the `alertViewStyle` property will always come out on top of any fields added here.
    func addTextField(withConfigurationHandler configurationHandler: @escaping (_ textField: UITextField) -> Void) {
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
    func show(from viewController: UIViewController) {
        self.show(from: viewController, animated: true)
    }

    /// Presents the alert controller from the given view controller.
    /// - Parameters:
    ///   - viewController: The view controller that should present the alert controller.
    ///   - animated: Whether or not to animate the presentation. This value is ignored on iOS 7.
    ///   - completion: An optional block to execute when the alert controller has been presented.
    ///                 You may pass `nil` to this parameter.
    func show(from viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
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

        for handler in self.textFieldHandlers {
            alertController.addTextField(configurationHandler: handler)
        }

        // "Other button" actions
        var i = 0;
        for button in buttons {
            let style = self.styleForButton(at: i)
            actions.append(self.action(from: button, with: style, controller: alertController))
            i += 1
        }

        // Cancel action
        if let cancelAction = self.cancelAction {
            actions.append(
                self.action(
                    from: cancelAction,
                    with: .cancel,
                    controller: alertController
                )
            )
        }

        // Add actions to alert controller
        for action in actions {
            alertController.addAction(action)
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
    func dismiss(buttonIndex index: Int) {
        // Button 0 with no actions defaults to [self dismiss]
        if index == 0 && self.buttons.count == 0 {
            self.dismiss()
            return
        }

        let action = self.actions[index]
        self.dismiss()
        
        if action.enabled {
            action.perform(self.textFieldInputStrings)
        }
    }

    /// - seealso: Equivalent to calling `dismissAnimated:completion` on `UIAlertController`.
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.currentPresentation = nil
        self.collectText(from: self.inCaseOfManualDismissal?.textFields)
        
        inCaseOfManualDismissal?.dismiss(
            animated: animated,
            completion: completion
        )
    }

    // MARK: Button actions

    func button(at buttonIndex: Int) -> TBAlertAction {
        // Cancel button
        if buttonIndex == (self.buttons.count ) {
            assert(cancelAction != nil, "Invalid button index; out of bounds.")
            return cancelAction!
        }

        return buttons[buttonIndex]
    }

    // MARK: UIAlertAction convenience (kinda wanna make this a category, can't because they call getTextFromTextFields)

    func action(from button: TBAlertAction, with style: UIAlertAction.Style, controller: UIAlertController) -> UIAlertAction {
        let action: UIAlertAction

        switch button.style {
            case .noAction:
                action = UIAlertAction(title: button.title, style: style)
            case .block:
                action = UIAlertAction(title: button.title, style: style,
                    handler: { [weak self, weak controller] _ in
                        guard let self = self else { return }
                        self.collectText(from: controller?.textFields ?? [])
                        button.perform(self.textFieldInputStrings)
                    }
                )
        }

        action.isEnabled = button.enabled
        return action
    }
}

extension TBAlertController {
    fileprivate func styleForButton(at index: Int) -> UIAlertAction.Style {
        return (index == destructiveButtonIndex)
            ? .destructive
            : .default
    }
}
