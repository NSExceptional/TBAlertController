//
//  TBAlertController.h
//  TBAlertController
//
//  Created by Tanner on 9/22/14.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^TBAlertControllerBlock)();

typedef NS_ENUM(NSInteger, TBAlertControllerStyle) {
    TBAlertControllerStyleActionSheet = 0,
    TBAlertControllerStyleAlert
};


@interface TBAlertController : NSObject

@property (nonatomic, assign) TBAlertControllerStyle style;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *message;
// -1 means no destructive button
// Indexes greater than the number of buttons will be ignored.
@property (nonatomic, assign) NSInteger destructiveButtonIndex;

- (id)initWithStyle:(TBAlertControllerStyle)style;
- (id)initWithTitle:(NSString *)title message:(NSString *)message style:(TBAlertControllerStyle)style;

- (void)setCancelButtonWithTitle:(NSString *)title;
- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (void)setCancelButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(id)object;
- (void)setCancelButtonWithTitle:(NSString *)title onTapped:(void(^)())tappedBlock;

- (void)addOtherButtonWithTitle:(NSString *)title;
- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (void)addOtherButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action withObject:(id)object;
- (void)addOtherButtonWithTitle:(NSString *)title onTapped:(void(^)())tappedBlock;

- (void)showFromViewController:(UIViewController *)viewController;
// "animated" only applies to iOS 8
- (void)showFromViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)())completion;
- (void)showInView:(UIView *)view NS_DEPRECATED_IOS(7_0, 8_0);
- (void)show NS_DEPRECATED_IOS(7_0, 8_0);

- (void)didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
