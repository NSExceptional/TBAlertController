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

@property (nonatomic, copy) NSString          *cancelButtonTitle;
@property (nonatomic, copy) void              (^cancelButtonBlock)();
@property (nonatomic      ) id                cancelButtonTarget;
@property (nonatomic      ) SEL               cancelButtonAction;
@property (nonatomic      ) id                cancelButtonObject;
@property (nonatomic)       NSMutableArray    *buttons;
@property (nonatomic, copy) void              (^completion)();

@end

@implementation TBAlertController

- (instancetype)initWithStyle:(TBAlertControllerStyle)style
{
    self = [super init];
    if (self) {
        _buttons = [NSMutableArray new];
        _style = style;
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
    [self clearCancelButtonData];
    self.cancelButtonTitle = title;
}

- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    [self clearCancelButtonData];
    
    self.cancelButtonTitle  = title;
    self.cancelButtonTarget = target;
    self.cancelButtonAction = action;
}

- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(id)object
{
    [self clearCancelButtonData];
    
    self.cancelButtonTitle  = title;
    self.cancelButtonTarget = target;
    self.cancelButtonAction = action;
    self.cancelButtonObject = object;
}

- (void)setCancelButtonWithTitle:(NSString *)title buttonAction:(void(^)())buttonBlock
{
    [self clearCancelButtonData];

    self.cancelButtonTitle  = title;
    self.cancelButtonBlock  = [buttonBlock copy];
}

- (void)clearCancelButtonData
{
    self.cancelButtonTitle  = nil;
    self.cancelButtonTarget = nil;
    self.cancelButtonAction = nil;
    self.cancelButtonObject = nil;
    self.cancelButtonBlock  = nil;
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
    
    NSDictionary *button = @{@"title" : title};
    [self.buttons addObject:button];
}

- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    NSParameterAssert(title); NSParameterAssert(target); NSParameterAssert(action);
    
    NSDictionary *button = @{@"title" : title, @"target" : target, @"action" : [NSValue valueWithPointer:action]};
    [self.buttons addObject:button];
}

- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(id)object
{
    if (!object)
    {
        [self addOtherButtonWithTitle:title target:target action:action];
        return;
    }
    
    NSParameterAssert(title); NSParameterAssert(target); NSParameterAssert(action);
    
    NSDictionary *button = @{@"title" : title, @"target" : target, @"action" : [NSValue valueWithPointer:action], @"object" : object};
    [self.buttons addObject:button];
}

- (void)addOtherButtonWithTitle:(NSString *)title buttonAction:(void(^)())buttonBlock
{
    NSParameterAssert(title); NSParameterAssert(buttonBlock);
    
    NSDictionary *button = @{@"title" : title, @"block" : buttonBlock};
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
        
        // Create actions
        for (NSDictionary *button in self.buttons)
        {
            NSString *title              = button[@"title"];
            TBAlertControllerBlock block = button[@"block"];
            id target                    = button[@"target"];
            UIAlertActionStyle style     = (i == self.destructiveButtonIndex) ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault;
            i++;
            
            // Targeted action
            if (target)
            {
                SEL selector  = [button[@"action"] pointerValue];
                id object     = button[@"object"];
                UIAlertAction *action;
                
                // With object
                if (object)
                    action = [TBAlertController actionWithTitle:title
                                                          style:style
                                                         target:target
                                                       selector:selector
                                                         object:object];
                // Without object
                else
                    action = [TBAlertController actionWithTitle:title
                                                          style:style
                                                         target:target
                                                       selector:selector];
                
                [actions addObject:action];
            }
            // Block action or no action
            else
            {
                UIAlertAction *action = [UIAlertAction actionWithTitle:title style:style handler:block];
                [actions addObject:action];
            }
            
        }
        // Cancel action
        if (self.cancelButtonTitle)
        {
            // Targeted action
            if (self.cancelButtonTarget)
            {
                UIAlertAction *action;
                
                // With object
                if (self.cancelButtonObject)
                    action = [TBAlertController actionWithTitle:self.cancelButtonTitle
                                                          style:UIAlertActionStyleCancel
                                                         target:self.cancelButtonTarget
                                                       selector:self.cancelButtonAction
                                                         object:self.cancelButtonObject];
                // Without object
                else
                    action = [TBAlertController actionWithTitle:self.cancelButtonTitle
                                                          style:UIAlertActionStyleCancel
                                                         target:self.cancelButtonTarget
                                                       selector:self.cancelButtonAction];
                
                [actions addObject:action];
            }
            // Block action or no action
            else
            {
                UIAlertAction *action = [UIAlertAction actionWithTitle:self.cancelButtonTitle style:UIAlertActionStyleCancel handler:self.cancelButtonBlock];
                [actions addObject:action];
            }
            
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

#pragma mark Displaying (iOS 7)

- (void)show
{
    NSAssert(self.style == TBAlertControllerStyleAlert, @"You can only call \"show\" using the alert style, and recommended on iOS 7.");
    
    TBAlertView *alert = [[TBAlertView alloc] initWithTitle:self.title message:self.message controller:self];
    
    // Add buttons
    for (NSDictionary *button in self.buttons)
    {
        NSString *title = [button objectForKey:@"title"];
        [alert addButtonWithTitle:title];
    }
    // Add cancel button
    if (self.cancelButtonTitle)
    {
        [alert addButtonWithTitle:self.cancelButtonTitle];
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
    for (NSDictionary *button in self.buttons)
    {
        NSString *title = button[@"title"];
        [actionSheet addButtonWithTitle:title];
    }
    // Cancel button
    if (self.cancelButtonTitle)
    {
        [actionSheet addButtonWithTitle:self.cancelButtonTitle];
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
    NSDictionary *button         = [self buttonAtIndex:buttonIndex];
    TBAlertControllerBlock block = button[@"block"];
    id target                    = button[@"target"];
    
    // Block action
    if (block)
    {
        block();
    }
    // Targeted action
    else if (target)
    {
        SEL action = [button[@"action"] pointerValue];
        id object  = button[@"object"];
        
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

- (NSDictionary *)buttonAtIndex:(NSUInteger)buttonIndex
{
    if (buttonIndex == [self.buttons count] && !self.cancelButtonTitle)
        NSAssert(self.cancelButtonTitle, @"Invalid button index; out of bounds.");

    
    // Cancel button
    if (buttonIndex == [self.buttons count])
    {
        NSMutableDictionary *button = [NSMutableDictionary new];
        [button setValue:self.cancelButtonTitle forKey:@"title"];
        if (self.cancelButtonAction)
            [button setObject:[NSValue valueWithPointer:self.cancelButtonAction] forKey:@"action"];
        if (self.cancelButtonBlock)
            [button setObject:self.cancelButtonBlock forKey:@"block"];
        if (self.cancelButtonObject)
            [button setObject:self.cancelButtonObject forKey:@"object"];
        if (self.cancelButtonTarget)
            [button setObject:self.cancelButtonTarget forKey:@"target"];
        
        return [button copy];
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


