//
//  TBAlertAction.h
//  Alert Controller Test
//
//  Created by Tanner on 12/3/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

///-------------------
/// @name Block types
///-------------------

/**
 A void returning block that takes no parameters.
 */
typedef void (^TBAlertActionBlock)();
/**
 A void returning block that takes an array of strings representing the text in each of the text fields of the associated `TBAlertController`.
 If there were no text fields, or if the alert controller style was `TBAlertControllerStyleActionSheet` the array is empty and can be ignored.
 */
typedef void (^TBAlertActionTextFieldsBlock)(NSArray *textFieldStrings);

/**
 All possible action styles (no action, block, target-selector, and single-parameter target-selector).
 */
typedef NS_ENUM(NSInteger, TBAlertActionStyle) {
    TBAlertActionStyleNoAction = 0,
    TBAlertActionStyleBlock,
    TBAlertActionStyleTarget,
    TBAlertActionStyleTargetObject
};

/**
 This class provides a way to add actions to a `TBAlertController` similar to how actions are added to `UIAlertController`.
 All actions added to a `TBAlertController` are converted to `TBAlertAction`s. Any `TBAlertController` is safe to use after being properly initialized.
 */
@interface TBAlertAction : NSObject

///------------------
/// @name Properties
///------------------

/**
 The style of the action.
*/
@property (nonatomic, readonly      ) TBAlertActionStyle style;
/**
 Whether or not the action is enabled.
 @warning This is a feature of `UIAlertAction` and is ignored on iOS 7.
 */
@property (nonatomic                ) BOOL               enabled;
/**
 The title of the action, displayed on the button representing it.
 */
@property (nonatomic, readonly, copy) NSString           *title;
/**
 The block to be executed when the action is triggered, if it's style is `TBAlertActionStyleBlock`.
 */
@property (nonatomic, readonly, copy) void               (^block)();
/**
 The target of the `action` property. `nil` if it's style is not `TBAlertActionStyleTarget` or `TBAlertActionStyleTargetObject`.
 */
@property (nonatomic, readonly      ) id                 target;
/**
 The selector called on the `target` property when triggered. `nil` if it's style is not `TBAlertActionStyleTarget` or `TBAlertActionStyleTargetObject`.
 */
@property (nonatomic, readonly      ) SEL                action;
/**
 The object used when the `style` property is `TBAlertActionStyleTargetObject`.
 */
@property (nonatomic, readonly      ) id                 object;


///--------------------
/// @name Initializers
///--------------------

/**
 Initializes a `TBAlertAction` with the given title.
 */
- (id)initWithTitle:(NSString *)title;
/**
 Initializes a `TBAlertAction` with the given title and a block to execute when triggered.
 
 @param title The title of the button.
 @param block An optional block to execute when the action is triggered.
 */
- (id)initWithTitle:(NSString *)title block:(TBAlertActionBlock)block;
/**
 Initializes a `TBAlertAction` with the given title and a target-selector style action to execute when triggered.
 
 @param title The button title
 @param target The object to perform the `action` selector on when the action is triggered.
 @param action A selector to perform on the `target` object when the action is triggered.
 */
- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;
/**
 Initializes a `TBAlertAction` with the given title and a target-selector style action which takes a single parameter to execute when triggered.
 
 @param title The button title
 @param target The object to perform the `action` selector on when the action is triggered.
 @param action A selector to perform on the `target` object when the action is triggered.
 @param object An object to pass to `action`. Behavior is undefined for `nil` values.
 */
- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action object:(id)object;

///-----------------------------
/// @name Triggering the Action
///-----------------------------

/**
 A convenient way to programmatically trigger the action. Nothing happens if the action consists only of a title.
 
 @note This is equivalent to calling perform: and passing an empty array.
 */
- (void)perform;
/**
 A convenient way to programmatically trigger the action, supplied with an array of `NSString`s. Nothing happens if the action consists only of a title.
 
 @param textFieldInputStrings An optional array of `NSString`s. `TBAlertController` uses this method when a button is tapped on an alert view with text fields. You may pass `nil` to this parameter.
 @warning Behavior is undefined if `textFieldInputStrings` contains objects other than `NSString`s.
 */
- (void)perform:(NSArray *)textFieldInputStrings;

@end
