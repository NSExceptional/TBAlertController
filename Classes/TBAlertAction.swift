//
//  TBAlertAction.swift
//  TBAlertController
//
//  Created by Tanner on 12/3/14.
//  Copyright (c) 2021 Tanner. All rights reserved.
//

import UIKit


// MARK: Types


/// A void returning block that takes an array of strings representing
/// the text in each of the text fields of the associated `TBAlertController`.
/// If there were no text fields, or if the alert controller style was
/// `TBAlertControllerStyleActionSheet` the array is empty and can be ignored.
typealias TBAlertActionBlock = ([String]) -> Void

/// All possible action styles (no action, block, target-selector,
/// and single-parameter target-selector).
enum TBAlertActionStyle: Int {
    case noAction = 0
    case block
}

/// This class provides a way to add actions to a `TBAlertController`,
/// similar to how actions are added to `UIAlertController`. All actions added
/// to a `TBAlertController` are converted to `TBAlertActions`. Any `TBAlertController`
/// is safe to use after being properly initialized.
@objcMembers
class TBAlertAction: NSObject {

    // MARK: Properties


    /// The style of the action.
    private(set) var style: TBAlertActionStyle = .noAction
    /// The block to be executed when the action is triggered, if it's style is `.block`.
    private(set) var block: TBAlertActionBlock?
    /// Whether or not the action is enabled.
    var enabled: Bool = true
    /// The title of the action, displayed on the button representing it.
    private(set) var title: String = ""
    /// The target of the `action` property.
    /// `nil` if it's style is not `.target` or `.targetObject`.
    private(set) var target: Any?
    /// The selector called on the `target` property when triggered.
    /// `nil` if it's style is not `.target` or `.targetObject`.
    private(set) var action: Selector?
    /// The object used when the `style` property is `.targetObject`.
    private(set) var object: Any?


    // MARK: Initializers


    /// Initializes a `TBAlertAction` with the given title.
    init(title: String) {
        super.init()
        self.title = title
        self.enabled = true
        self.style = .noAction
    }

    /// Initializes a `TBAlertAction` with the given title and a block to execute when triggered.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - block: An optional block to execute when the action is triggered.
    convenience init(title: String, block: TBAlertActionBlock?) {
        self.init(title: title)
        
        if let block = block {
            self.block = block
            self.style = .block
        }
    }


    // MARK: Triggering the Action


    /// A convenient way to programmatically trigger the action, supplied with an array of `NSStrings`. Nothing happens if the action consists only of a title.
    /// - Parameter textFieldInputStrings: An optional array of `NSStrings`. `TBAlertController` uses this method when a button is tapped on an alert view with text fields. You may pass `nil` to this parameter.
    /// - warning: Behavior is undefined if `textFieldInputStrings` contains objects other than `NSStrings`.
    func perform(_ textFieldInputStrings: [String] = []) {
        switch style {
            case .noAction:
                break
            case .block:
                block?(textFieldInputStrings)
        }
    }
}
