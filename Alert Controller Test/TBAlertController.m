//
//  TBAlertController.m
//  TBAlertController
//
//  Created by Tanner on 9/22/14.
//
//

#import "TBAlertController.h"

#if ! __has_feature(objc_arc)
#error This file requires ARC! Add "-fobjc-arc" in Build Phases -> Compile Sources -> Compiler Flags.
#endif

#pragma mark - TBAlertView - DO NOT USE
#pragma mark Created to use itself as the delegate for iOS 7 and earlier.


@protocol TBAlert <NSObject>

- (void)didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
// AlertView
@interface TBAlertView : UIAlertView <UIAlertViewDelegate>
@property (nonatomic) id<TBAlert> controller;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message controller:(id<TBAlert>)controller;
@end
@implementation TBAlertView
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message controller:(id<TBAlert>)controller
{
    self = [super init];
    if (self) {
        self.controller = controller;
        self.title      = title;
        self.message    = message;
        self.delegate   = self;
    }
    
    return self;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.controller didDismissWithButtonIndex:buttonIndex];
}
@end

#pragma mark - TBAlertView - DO NOT USE
#pragma mark Created to use itself as the delegate for iOS 7 and earlier.

// ActionSheet
@interface TBActionSheet : UIActionSheet <UIActionSheetDelegate>
@property (nonatomic) id<TBAlert> controller;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message controller:(id<TBAlert>)controller;
@end
@implementation TBActionSheet
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message controller:(id<TBAlert>)controller
{
    self = [super init];
    if (self) {
        self.controller = controller;
        self.delegate   = self;
        if (message)
            self.title  = [NSString stringWithFormat:@"%@\n\n%@", title, message];
        else
            self.title  = title;
    }
    
    return self;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.controller didDismissWithButtonIndex:buttonIndex];
}
@end

#pragma mark - TBAlertController

@interface TBAlertController () <TBAlert>

@property (nonatomic      ) TBAlertAction     *cancelAction;
@property (nonatomic      ) NSMutableArray    *buttons;
@property (nonatomic, copy) void              (^completion)();

@end

@implementation TBAlertController

- (instancetype)initWithStyle:(TBAlertControllerStyle)style
{
    self = [super init];
    if (self) {
        _style = style;
        _buttons = [NSMutableArray new];
        _destructiveButtonIndex = NSNotFound;
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message style:(TBAlertControllerStyle)style
{
    self = [self initWithStyle:style];
    if (self) {
        _title   = title;
        _message = message;
    }
    
    return self;
}

#pragma mark Cancel button

- (void)setCancelButtonWithTitle:(NSString *)title
{
    self.cancelAction = [[TBAlertAction alloc] initWithTitle:title];
}

- (void)setCancelButtonWithTitle:(NSString *)title buttonAction:(void(^)())buttonBlock
{
    self.cancelAction = [[TBAlertAction alloc] initWithTitle:title block:buttonBlock];
}

- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self.cancelAction = [[TBAlertAction alloc] initWithTitle:title target:target action:action];
}

- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(id)object
{
    self.cancelAction = [[TBAlertAction alloc] initWithTitle:title target:target action:action object:object];
}

#pragma mark Destructive button

- (void)setDestructiveButtonIndex:(NSInteger)destructiveButtonIndex
{
    if (![UIAlertController class])
        NSAssert(self.style == TBAlertControllerStyleActionSheet, @"Only action sheets can have destructive buttons on iOS 7.");
    
    _destructiveButtonIndex = destructiveButtonIndex;
}

#pragma mark Other buttons

- (void)addOtherButtonWithTitle:(NSString *)title
{
    NSParameterAssert(title);
    
    TBAlertAction *button = [[TBAlertAction alloc] initWithTitle:title];
    [self.buttons addObject:button];
}

- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    NSParameterAssert(title); NSParameterAssert(target); NSParameterAssert(action);
    
    TBAlertAction *button = [[TBAlertAction alloc] initWithTitle:title target:target action:action];
    [self.buttons addObject:button];
}

- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(id)object
{
    NSParameterAssert(title); NSParameterAssert(target); NSParameterAssert(action);
    
    if (object)
    {
        TBAlertAction *button = [[TBAlertAction alloc] initWithTitle:title target:target action:action object:object];
        [self.buttons addObject:button];
    }
    else
    {
        [self addOtherButtonWithTitle:title target:target action:action];
    }
}

- (void)addOtherButtonWithTitle:(NSString *)title buttonAction:(void(^)())buttonBlock
{
    NSParameterAssert(title); NSParameterAssert(buttonBlock);
    
    TBAlertAction *button = [[TBAlertAction alloc] initWithTitle:title block:buttonBlock];
    [self.buttons addObject:button];
}

#pragma mark Displaying (iOS 8)

- (void)showFromViewController:(UIViewController *)viewController
{
    [self showFromViewController:viewController animated:YES completion:nil];
}

// "animated" only applies to iOS 8
- (void)showFromViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion
{
    // iOS 8+
    if ([UIAlertController class])
    {
        NSInteger i = 0;
        NSMutableArray *actions = [NSMutableArray new];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message
                                                                          preferredStyle:(UIAlertControllerStyle)self.style];
        
        // "Other button" actions
        for (TBAlertAction *button in self.buttons)
        {
            UIAlertActionStyle style = (i == self.destructiveButtonIndex) ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault;
            [actions addObject:[self actionFromAlertAction:button withStyle:style]];
            i++;
        }
        // Cancel action
        if (self.cancelAction)
        {
            [actions addObject:[self actionFromAlertAction:self.cancelAction withStyle:UIAlertActionStyleCancel]];
        }
        
        // Add actions to alert controller
        for (UIAlertAction *action in actions)
             [alertController addAction:action];
        
        [viewController presentViewController:alertController animated:animated completion:completion];
        
    }
    // iOS 7 or less
    else
    {
        self.completion = [completion copy];
        
        // Alert view
        if (self.style == TBAlertControllerStyleAlert)
            [self show];
        
        // Action sheet
        else if (self.style == TBAlertControllerStyleActionSheet)
            [self showInView:[viewController.view window]];
    }
}

- (UIAlertAction *)actionFromAlertAction:(TBAlertAction *)button withStyle:(UIAlertActionStyle)style
{
    switch (button.style) {
        case TBAlertActionStyleNoAction:
        case TBAlertActionStyleBlock:
        {
            return [UIAlertAction actionWithTitle:button.title style:style handler:button.block];
        }
            break;
            
        case TBAlertActionStyleTargetObject:
        case TBAlertActionStyleTarget:
        {
            UIAlertAction *action;
            
            // With object
            if (button.object)
                action = [TBAlertController actionWithTitle:button.title
                                                      style:style
                                                     target:button.target
                                                   selector:button.action
                                                     object:button.object];
            // Without object
            else
                action = [TBAlertController actionWithTitle:button.title
                                                      style:style
                                                     target:button.target
                                                   selector:button.action];
            
            return action;
        }
    }
}

#pragma mark Displaying (iOS 7)

- (void)show
{
    NSAssert(self.style == TBAlertControllerStyleAlert, @"You can only call \"show\" using the alert style, and recommended on iOS 7.");
    
    TBAlertView *alert = [[TBAlertView alloc] initWithTitle:self.title message:self.message controller:self];
    
    // Add buttons
    for (TBAlertAction *button in self.buttons)
    {
        NSString *title = button.title;
        [alert addButtonWithTitle:title];
    }
    // Add cancel button
    if (self.cancelAction)
    {
        [alert addButtonWithTitle:self.cancelAction.title];
        [alert setCancelButtonIndex:alert.numberOfButtons-1];
    }
    
    [alert show];
    
    // Completion block
    if (self.completion)
        self.completion();
}

- (void)showInView:(UIView *)view
{
    NSAssert(self.style == TBAlertControllerStyleActionSheet, @"You can only call \"showInView:\" using the action sheet style, and recommended on iOS 7.");
    
    TBActionSheet *actionSheet = [[TBActionSheet alloc] initWithTitle:self.title message:self.message controller:self];
    
    // Add buttons
    for (TBAlertAction *button in self.buttons)
    {
        NSString *title = button.title;
        [actionSheet addButtonWithTitle:title];
    }
    // Cancel button
    if (self.cancelAction)
    {
        [actionSheet addButtonWithTitle:self.cancelAction.title];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    }
    // Destructive button index
    if (self.destructiveButtonIndex > -1)
        actionSheet.destructiveButtonIndex = self.destructiveButtonIndex;
    
    // show
    [actionSheet showInView:view];
    
    // Completion block
    if (self.completion)
        self.completion();
}

#pragma mark Button actions (iOS 7)

- (void)didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    TBAlertAction *button         = [self buttonAtIndex:buttonIndex];
    TBAlertControllerBlock block = button.block;
    id target                    = button.target;
    
    // Block action
    if (block)
    {
        block();
    }
    // Targeted action
    else if (target)
    {
        SEL action = button.action;
        id object  = button.object;
        
        if (object)
        {
            IMP imp = [target methodForSelector:action];
            void (*func)(id, SEL, id) = (void *)imp;
            
            if ([target respondsToSelector:action])
                func(target, action, object);
        }
        else
        {
            IMP imp = [target methodForSelector:action];
            void (*func)(id, SEL) = (void *)imp;
            
            if ([target respondsToSelector:action])
                func(target, action);
        }
    }
}

- (TBAlertAction *)buttonAtIndex:(NSUInteger)buttonIndex
{
    // Cancel button
    if (buttonIndex == [self.buttons count])
    {
        NSAssert(self.cancelAction, @"Invalid button index; out of bounds.");
        return self.cancelAction;
        
    }
    
    return self.buttons[buttonIndex];
}

#pragma mark Block UIAlertActions (kinda wanna make this a category)

+ (UIAlertAction *)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style target:(id)target selector:(SEL)selector
{
    __weak id weakTarget = target;
    
    IMP imp = [target methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *aciton)
                             {
                                 if ([weakTarget respondsToSelector:selector])
                                     func(weakTarget, selector);
                             }];
    
    return action;
}

+ (UIAlertAction *)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style target:(id)target selector:(SEL)selector object:(id)object
{
    __weak id weakTarget = target;
    __weak id weakObject = object;
    
    IMP imp = [target methodForSelector:selector];
    void (*func)(id, SEL, id) = (void *)imp;
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction *aciton)
                             {
                                 if ([weakTarget respondsToSelector:selector])
                                     func(weakTarget, selector, weakObject);
                             }];
    
    return action;
}

@end


