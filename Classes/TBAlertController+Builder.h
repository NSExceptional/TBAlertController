//
//  TBAlertController+Builder.h
//  TBAlertController
//
//  Created by Tanner Bennett on 10/3/21.
//  Copyright (c) 2021 Tanner. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TBAlert, TBAlertActionBuilder, TBAlertController, TBAlertAction, TBAlertActionBuilder;

typedef void (^TBAlertReveal)(void);
typedef void (^TBAlertBuilder)(TBAlert *make);
typedef TBAlert * _Nonnull (^TBAlertStringProperty)(NSString * _Nullable);
typedef TBAlert * _Nonnull (^TBAlertStringArg)(NSString * _Nullable);
typedef TBAlert * _Nonnull (^TBAlertTextField)(void(^configurationHandler)(UITextField *textField));
typedef TBAlertActionBuilder * _Nonnull (^TBAlertAddAction)(NSString *title);
typedef TBAlertActionBuilder * _Nonnull (^TBAlertActionStringProperty)(NSString * _Nullable);
typedef TBAlertActionBuilder * _Nonnull (^TBAlertActionProperty)(void);
typedef TBAlertActionBuilder * _Nonnull (^TBAlertActionBOOLProperty)(BOOL);
typedef TBAlertActionBuilder * _Nonnull (^TBAlertActionHandler)(void(^handler)(NSArray<NSString *> *strings));

@interface TBAlert : NSObject

/// Shows a simple alert with one button which says "Dismiss"
+ (void)showAlert:(NSString * _Nullable)title message:(NSString * _Nullable)message from:(UIViewController *)viewController;

/// Construct and display an alert
+ (void)makeAlert:(TBAlertBuilder)block showFrom:(UIViewController *)viewController;
/// Construct and display an action sheet-style alert
+ (void)makeSheet:(TBAlertBuilder)block
         showFrom:(UIViewController *)viewController
           source:(id)viewOrBarItem;

/// Construct an alert
+ (TBAlertController *)makeAlert:(TBAlertBuilder)block;
/// Construct an action sheet-style alert
+ (TBAlertController *)makeSheet:(TBAlertBuilder)block;

/// Set the alert's title.
///
/// Call in succession to append strings to the title.
@property (nonatomic, readonly) TBAlertStringProperty title;
/// Set the alert's message.
///
/// Call in succession to append strings to the message.
@property (nonatomic, readonly) TBAlertStringProperty message;
/// Add a button with a given title with the default style and no action.
@property (nonatomic, readonly) TBAlertAddAction button;
/// Add a text field with the given (optional) placeholder text.
@property (nonatomic, readonly) TBAlertStringArg textField;
/// Add and configure the given text field.
///
/// Use this if you need to more than set the placeholder, such as
/// supply a delegate, make it secure entry, or change other attributes.
@property (nonatomic, readonly) TBAlertTextField configuredTextField;

@end

@interface TBAlertActionBuilder : NSObject

/// Set the action's title.
///
/// Call in succession to append strings to the title.
@property (nonatomic, readonly) TBAlertActionStringProperty title;
/// Make the action destructive. It appears with red text.
@property (nonatomic, readonly) TBAlertActionProperty destructiveStyle;
/// Make the action cancel-style. It appears with a bolder font.
@property (nonatomic, readonly) TBAlertActionProperty cancelStyle;
/// Enable or disable the action. Enabled by default.
@property (nonatomic, readonly) TBAlertActionBOOLProperty enabled;
/// Give the button an action. The action takes an array of text field strings.
@property (nonatomic, readonly) TBAlertActionHandler handler;
/// Access the underlying TBAlertAction, should you need to change it while
/// the encompassing alert is being displayed. For example, you may want to
/// enable or disable a button based on the input of some text fields in the alert.
/// Do not call this more than once per instance.
@property (nonatomic, readonly) TBAlertAction *action;

@end

NS_ASSUME_NONNULL_END
