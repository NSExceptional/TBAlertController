//
//  TBAlertController+Builder.swift
//  TBAlertController
//
//  Created by Tanner Bennett on 10/3/21.
//  Copyright (c) 2021 Tanner. All rights reserved.
//

import UIKit

typealias TBAlertReveal = () -> Void
typealias TBAlertBuilder = (TBAlert) -> Void
typealias TBAlertStringProperty = (String?) -> TBAlert
typealias TBAlertStringArg = (String?) -> TBAlert
typealias TBAlertTextField = (((UITextField) -> Void)) -> TBAlert
typealias TBAlertAddAction = (String) -> TBAlertActionBuilder
typealias TBAlertActionStringProperty = (String?) -> TBAlertActionBuilder
typealias TBAlertActionProperty = () -> TBAlertActionBuilder
typealias TBAlertActionBOOLProperty = (Bool) -> TBAlertActionBuilder
typealias TBAlertActionHandler = ((([String]) -> Void)) -> TBAlertActionBuilder

@objcMembers
class TBAlert: NSObject {
    
    private var controller: TBAlertController
    private var actions: [TBAlertActionBuilder] = []
    
    /// Set the alert's title.
    ///
    /// Call in succession to append strings to the title.
    func title(_ title: String?) -> Self {
        guard let title = title else { return self }
        
        self.controller.title += title
        return self
    }
    
    /// Set the alert's message.
    ///
    /// Call in succession to append strings to the message.
    func message(_ message: String?) -> Self {
        guard let message = message else { return self }
        
        self.controller.message += message
        return self
    }
    
    /// Add a button with a given title with the default style and no action.
    func button(_ title: String?) -> TBAlertActionBuilder {
        let action = TBAlertActionBuilder(self.controller).title(title)
        actions.append(action)
        return action
    }
    
    /// Add a text field with the given (optional) placeholder text.
    func textField(_ placeholder: String?) -> Self {
        self.controller.addTextField(withConfigurationHandler: { textField in
            textField.placeholder = placeholder
        })

        return self
    }
    
    /// Add and configure the given text field.
    ///
    /// Use this if you need to more than set the placeholder, such as
    /// supply a delegate, make it secure entry, or change other attributes.
    func configuredTextField(_ configurationHandler: @escaping (UITextField) -> Void) -> Self {
        self.controller.addTextField(withConfigurationHandler: configurationHandler)
        return self
    }
    

    /// Shows a simple alert with one button which says "Dismiss"
    class func show(_ title: String, message: String, from viewController: UIViewController) {
        self.make({ make in
            make.title(title).message(message).button("Dismiss").cancelStyle()
        }, showFrom: viewController)
    }

    // MARK: Initialization

    init(controller: TBAlertController) {
        self.controller = controller
        super.init()
    }

    class func make(_ block: TBAlertBuilder, with style: UIAlertController.Style) -> TBAlertController {
        let controller = TBAlertController(
            title: nil,
            message: nil,
            style: .init(style: style)
        )

        // Create alert builder
        let alert = TBAlert(controller: controller)

        // Configure alert
        block(alert)

        // Add actions
        for builder in alert.actions {
            let action = builder.action
            switch builder.style {
            case .default:
                controller.addAction(action)
            case .cancel:
                controller.setCancelButton(action: action)
            case .destructive:
                controller.addAction(action)
                
                // I don't like this... But it's for API compat, so
                controller.destructiveButtonIndex = controller.actions.firstIndex(of: action) ?? NSNotFound
            default:
                break
            }
        }

        return alert.controller
    }

    class func make(
        _ block: TBAlertBuilder,
        style: UIAlertController.Style,
        showFrom viewController: UIViewController,
        source: TBAlertController.PopoverSource = .none
    ) {
        let alert = self.make(block, with: style)
        alert.popoverSource = source
        alert.show(from: viewController)
    }

    /// Construct and display an alert
    class func make(_ block: TBAlertBuilder, showFrom controller: UIViewController) {
        self.make(block, style: .alert, showFrom: controller)
    }

    class func makeSheet(_ block: TBAlertBuilder, showFrom controller: UIViewController) {
        self.make(block, style: .actionSheet, showFrom: controller)
    }

    /// Construct and display an action sheet-style alert
    class func makeSheet(
        _ block: TBAlertBuilder,
        showFrom controller: UIViewController,
        source: TBAlertController.PopoverSource = .none
    ) {
        self.make(block, style: .actionSheet, showFrom: controller, source: source)
    }

    /// Construct an alert
    class func make(_ block: TBAlertBuilder) -> TBAlertController {
        return self.make(block, with: .alert)
    }

    /// Construct an action sheet-style alert
    class func makeSheet(_ block: TBAlertBuilder) -> TBAlertController {
        return self.make(block, with: .actionSheet)
    }
}

@objcMembers
class TBAlertActionBuilder: NSObject {
    fileprivate var controller: TBAlertController
    fileprivate var title: String = ""
    fileprivate var style: (UIAlertAction.Style) = .default
    fileprivate var disable: Bool = false
    fileprivate var handler: TBAlertActionBlock? = nil
    private var _action: TBAlertAction? = nil
    
    private func MutationAssertion() {
        assert(_action == nil, "Cannot mutate action after retreiving underlying UIAlertAction")
    }
    
    init(_ controller: TBAlertController) {
        self.controller = controller
        super.init()
    }
    
    /// Access the underlying `TBAlertAction`, should you need to change it while
    /// the encompassing alert is being displayed. For example, you may want to
    /// enable or disable a button based on the input of some text fields in the alert.
    /// Do not call this more than once per instance.
    lazy private(set) var action: TBAlertAction = {
        let a = TBAlertAction(
            title: self.title,
            block: self.handler
        )
        a.enabled = !disable
        
        _action = a
        return a
    }()
    
    /// Set the action's title.
    ///
    /// Call in succession to append strings to the title.
    @discardableResult
    func title(_ title: String?) -> Self {
        MutationAssertion()
        self.title += (title ?? "")
        return self
    }
    
    /// Make the action destructive. It appears with red text.
    @discardableResult
    func destructiveStyle() -> Self {
        MutationAssertion()
        self.style = .destructive
        return self
    }
    
    /// Make the action cancel-style. It appears with a bolder font.
    @discardableResult
    func cancelStyle() -> Self {
        MutationAssertion()
        self.style = .cancel
        return self
    }
    
    /// Enable or disable the action. Enabled by default.
    @discardableResult
    func enabled(_ enabled: Bool) -> Self {
        MutationAssertion()
        self.disable = !enabled
        return self
    }
    
    /// Give the button an action. The action takes an array of text field strings.
    @discardableResult
    func handler(_ handler: @escaping ([String]) -> Void) -> Self {
        MutationAssertion()
        self.handler = handler
        return self
    }
}
