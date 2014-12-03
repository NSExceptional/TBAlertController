//
//  MasterViewController.m
//  Alert Controller Test
//
//  Created by Tanner on 12/1/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import "MasterViewController.h"
#import "TBAlertController.h"

@implementation MasterViewController

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        self.clearsSelectionOnViewWillAppear = NO;
//        self.preferredContentSize = CGSizeMake(320.0, 600.0);
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.isAlertViewStyle = YES;
    self.title = [self barTitle];
}

- (void)targetedAction
{
    NSLog(@"Targeted Action worked");
}

- (void)targetedActionWithObject:(id)object
{
    NSLog(@"Targeted Action worked with object:%@", object);
}

- (NSString *)barTitle
{
    return [NSString stringWithFormat:@"%@ %@", [self state], [self version]];
}

- (NSString *)state
{
    if (self.isAlertViewStyle)
        return @"Alert Style";
    return @"Action Sheet Style";
}

- (NSString *)version
{
    if ([UIAlertController class])
        return @"iOS 8";
    return @"iOS 7";
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TBAlertController *alert;
    TBAlertControllerStyle style = (TBAlertControllerStyle)self.isAlertViewStyle;
    
    switch (indexPath.row) {
        case 0:
            self.isAlertViewStyle = !self.isAlertViewStyle;
            self.title = [self barTitle];
            break;
        // Alert Views
            // 1 button
        case 1:
            alert = [[TBAlertController alloc] initWithStyle:style];
            alert.title = @"Alert";
            alert.message = @"show\n1 button";
            [alert addOtherButtonWithTitle:@"OK"];
            [alert showFromViewController:self];
            break;
            // 1 normal, cancel
        case 2:
            alert = [[TBAlertController alloc] initWithStyle:style];
            alert.title = @"Alert";
            alert.message = @"1 normal, cancel";
            [alert addOtherButtonWithTitle:@"OK"];
            [alert setCancelButtonWithTitle:@"Canc3l"];
            [alert showFromViewController:self];
            break;
            // 1 normal, cancel with block
        case 3:
            alert = [[TBAlertController alloc] initWithStyle:style];
            alert.title = @"Alert";
            alert.message = @"1 normal, cancel with block";
            [alert addOtherButtonWithTitle:@"OK"];
            [alert setCancelButtonWithTitle:@"Canc3l" buttonAction:^{
                NSLog(@"cancel tapped, cell 3");
            }];
            [alert showFromViewController:self];
            break;
            // 1 normal, cancel with target
        case 4:
            alert = [[TBAlertController alloc] initWithStyle:style];
            alert.title = @"Alert";
            alert.message = @"1 normal, cancel with target";
            [alert addOtherButtonWithTitle:@"OK"];
            [alert setCancelButtonWithTitle:@"Canc3l" target:self action:@selector(targetedAction)];
            [alert showFromViewController:self animated:YES completion:nil];
            break;
            // 1 normal, cancel with target and object
        case 5:
            alert = [[TBAlertController alloc] initWithStyle:style];
            alert.title = @"Alert";
            alert.message = @"1 normal, cancel with target and object";
            [alert addOtherButtonWithTitle:@"OK"];
            [alert setCancelButtonWithTitle:@"Canc3l" target:self action:@selector(targetedActionWithObject:) withObject:@"[ object, success ]"];
            [alert showFromViewController:self animated:YES completion:^{NSLog(@"completion");}];
            break;
            // 1 normal with target
        case 6:
            alert = [[TBAlertController alloc] initWithStyle:style];
            alert.title = @"Alert";
            alert.message = @"1 normal with target";
            [alert addOtherButtonWithTitle:@"OK" target:self action:@selector(targetedAction)];
            [alert showFromViewController:self];
            break;
            // 1 normal with target and object
        case 7:
            alert = [[TBAlertController alloc] initWithStyle:style];
            alert.title = @"Alert";
            alert.message = @"1 normal with target and object";
            [alert addOtherButtonWithTitle:@"OK" target:self action:@selector(targetedActionWithObject:) withObject:@"[ object, success ]"];
            [alert showFromViewController:self];
            break;
            // destructive button: 1
        case 8:
            alert = [[TBAlertController alloc] initWithStyle:style];
            alert.title = @"Alert";
            alert.message = @"destructive button: 1";
            [alert addOtherButtonWithTitle:@"OK"];
            [alert addOtherButtonWithTitle:@"Destructive"];
            [alert addOtherButtonWithTitle:@"OK"];
            alert.destructiveButtonIndex = 1;
            [alert showFromViewController:self];
        default:
            break;
    }
}

@end
