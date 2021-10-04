//
//  TBAlertController+Builder.m
//  TBAlertController
//
//  Created by Tanner Bennett on 10/3/21.
//  Copyright (c) 2021 Tanner. All rights reserved.
//

#import "TBAlertController+Builder.h"
#import "TBAlertController.h"

#define tb_keywordify class NSObject;
#define ctor tb_keywordify __attribute__((constructor)) void __tb_ctor_##__LINE__()
#define dtor tb_keywordify __attribute__((destructor)) void __tb_dtor_##__LINE__()

#define weakify(var) __weak __typeof(var) __weak__##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = __weak__##var; \
_Pragma("clang diagnostic pop")

@interface TBAlert ()
@property (nonatomic, readonly) TBAlertController *_controller;
@property (nonatomic, readonly) NSMutableArray<TBAlertActionBuilder *> *_actions;
@end

#define TBAlertActionMutationAssertion() \
NSAssert(!self._action, @"Cannot mutate action after retreiving underlying UIAlertAction");

@interface TBAlertActionBuilder ()
@property (nonatomic) TBAlertController *_controller;
@property (nonatomic) NSString *_title;
@property (nonatomic) UIAlertActionStyle _style;
@property (nonatomic) BOOL _disable;
@property (nonatomic) TBAlertActionBlock _handler;
@property (nonatomic) TBAlertAction *_action;
@end

@implementation TBAlert

+ (void)showAlert:(NSString *)title message:(NSString *)message from:(UIViewController *)viewController {
    [self makeAlert:^(TBAlert *make) {
        make.title(title).message(message).button(@"Dismiss").cancelStyle();
    } showFrom:viewController];
}

#pragma mark Initialization

- (instancetype)initWithController:(TBAlertController *)controller {
    self = [super init];
    if (self) {
        __controller = controller;
        __actions = [NSMutableArray new];
    }

    return self;
}

+ (TBAlertController *)make:(TBAlertBuilder)block withStyle:(UIAlertControllerStyle)style {
    TBAlertController *controller = [TBAlertController
        alertControllerWithTitle:nil message:nil preferredStyle:style
    ];
    
    // Create alert builder
    TBAlert *alert = [[self alloc] initWithController:controller];

    // Configure alert
    block(alert);

    // Add actions
    for (TBAlertActionBuilder *builder in alert._actions) {
        TBAlertAction *action = builder.action;
        switch (builder._style) {
            case UIAlertActionStyleDefault:
                [controller addAction:action];
                break;
            case UIAlertActionStyleCancel:
                [controller setCancelButton:action];
                break;
            case UIAlertActionStyleDestructive:
                [controller addAction:action];
                // I don't like this... But it's for API compat, so
                controller.destructiveButtonIndex = [controller.actions indexOfObject:action];
        }
    }

    return alert._controller;
}

+ (void)make:(TBAlertBuilder)block
   withStyle:(UIAlertControllerStyle)style
    showFrom:(UIViewController *)viewController
      source:(id)viewOrBarItem {
    TBAlertController *alert = [self make:block withStyle:style];
    alert.popoverSourceView = viewOrBarItem;
    [alert showFromViewController:viewController];
}

+ (void)makeAlert:(TBAlertBuilder)block showFrom:(UIViewController *)controller {
    [self make:block withStyle:UIAlertControllerStyleAlert showFrom:controller source:nil];
}

+ (void)makeSheet:(TBAlertBuilder)block showFrom:(UIViewController *)controller {
    [self make:block withStyle:UIAlertControllerStyleActionSheet showFrom:controller source:nil];
}

/// Construct and display an action sheet-style alert
+ (void)makeSheet:(TBAlertBuilder)block
         showFrom:(UIViewController *)controller
           source:(id)viewOrBarItem {
    [self make:block
     withStyle:UIAlertControllerStyleActionSheet
      showFrom:controller
        source:viewOrBarItem];
}

+ (TBAlertController *)makeAlert:(TBAlertBuilder)block {
    return [self make:block withStyle:UIAlertControllerStyleAlert];
}

+ (TBAlertController *)makeSheet:(TBAlertBuilder)block {
    return [self make:block withStyle:UIAlertControllerStyleActionSheet];
}

#pragma mark Configuration

- (TBAlertStringProperty)title {
    return ^TBAlert *(NSString *title) {
        if (self._controller.title) {
            self._controller.title = [self._controller.title stringByAppendingString:title ?: @""];
        } else {
            self._controller.title = title;
        }
        return self;
    };
}

- (TBAlertStringProperty)message {
    return ^TBAlert *(NSString *message) {
        if (self._controller.message) {
            self._controller.message = [self._controller.message stringByAppendingString:message ?: @""];
        } else {
            self._controller.message = message;
        }
        return self;
    };
}

- (TBAlertAddAction)button {
    return ^TBAlertActionBuilder *(NSString *title) {
        TBAlertActionBuilder *action = TBAlertActionBuilder.new.title(title);
        action._controller = self._controller;
        [self._actions addObject:action];
        return action;
    };
}

- (TBAlertStringArg)textField {
    return ^TBAlert *(NSString *placeholder) {
        [self._controller addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = placeholder;
        }];

        return self;
    };
}

- (TBAlertTextField)configuredTextField {
    return ^TBAlert *(void(^configurationHandler)(UITextField *)) {
        [self._controller addTextFieldWithConfigurationHandler:configurationHandler];
        return self;
    };
}

@end

@implementation TBAlertActionBuilder

- (TBAlertActionStringProperty)title {
    return ^TBAlertActionBuilder *(NSString *title) {
        TBAlertActionMutationAssertion();
        if (self._title) {
            self._title = [self._title stringByAppendingString:title ?: @""];
        } else {
            self._title = title;
        }
        return self;
    };
}

- (TBAlertActionProperty)destructiveStyle {
    return ^TBAlertActionBuilder *() {
        TBAlertActionMutationAssertion();
        self._style = UIAlertActionStyleDestructive;
        return self;
    };
}

- (TBAlertActionProperty)cancelStyle {
    return ^TBAlertActionBuilder *() {
        TBAlertActionMutationAssertion();
        self._style = UIAlertActionStyleCancel;
        return self;
    };
}

- (TBAlertActionBOOLProperty)enabled {
    return ^TBAlertActionBuilder *(BOOL enabled) {
        TBAlertActionMutationAssertion();
        self._disable = !enabled;
        return self;
    };
}

- (TBAlertActionHandler)handler {
    return ^TBAlertActionBuilder *(void(^handler)(NSArray<NSString *> *)) {
        TBAlertActionMutationAssertion();

        self._handler = handler;
        return self;
    };
}

- (TBAlertAction *)action {
    if (self._action) {
        return self._action;
    }

    self._action = [[TBAlertAction alloc]
        initWithTitle:self._title
        block:self._handler
    ];
    self._action.enabled = !self._disable;

    return self._action;
}

@end

