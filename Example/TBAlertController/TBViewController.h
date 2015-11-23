//
//  MasterViewController.h
//  Alert Controller Test
//
//  Created by Tanner on 12/1/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController, TBAlertController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property BOOL isAlertViewStyle;
@property BOOL willDismissProgrammaticallyAfterDelay;
@property BOOL usesDestructiveButton;
@property NSUInteger destructiveIndex;
@property NSUInteger dismissIndex;

- (IBAction)toggleStyle;
- (IBAction)setDestructiveButtonIndex:(NSUInteger)index button:(UIBarButtonItem *)sender;
- (void)toggleDismissProgrammaticallyAfterDelay:(UITableViewCell *)sender;
- (TBAlertController *)withCancelButtonMessage:(NSString *)message;
- (TBAlertController *)withCancelButtonBlock;
- (TBAlertController *)withCancelButtonTargetAction;
- (TBAlertController *)withCancelButtonTargetActionObject;
- (TBAlertController *)withBlock;
- (TBAlertController *)withBlockWithoutCancel;
- (TBAlertController *)withTargetAction;
- (TBAlertController *)withTargetActionObject;
- (TBAlertController *)withAddedTextFields;
- (TBAlertController *)withLoginAndPasswordStyle;
- (TBAlertController *)WithPlainTextStyleAndAdditionalTextField;
- (TBAlertController *)byRemovingButtons;

@end

