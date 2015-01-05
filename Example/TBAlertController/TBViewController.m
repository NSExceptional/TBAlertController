//
//  MasterViewController.m
//  Alert Controller Test
//
//  Created by Tanner on 12/1/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import "TBViewController.h"
#import "TBAlertController.h"

@interface MasterViewController ()
@property TBAlertControllerStyle style;
@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.isAlertViewStyle     = NO;
    self.title                = [self barTitle];
    self.destructiveIndex     = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    TBAlertController *welcome = [TBAlertController simpleOKAlertWithTitle:@"Thanks for trying TBAlertController!"
                                                                   message:@"Use the buttons in the navigation bar to change from alert view style to action sheet style, and to test destructive buttons. Use the first cell to test programmatically dismissing them all.\n\nBe warned: This example does not guard against exceptions like trying to use the destructive button on an alert view in iOS 7, or trying to present an action sheet with text fields.\n\nFeel free to contact me with suggestions!"];
    
    [welcome showFromViewController:self];
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

#pragma mark Testing

#define CANCEL @"Cancel"
#define OK @"OK"
#define LOG_CANCEL @"Cancel button pressed"
#define LOG_BUTTON @"OK button pressed"

- (IBAction)toggleStyle {
    self.isAlertViewStyle = !self.isAlertViewStyle;
    self.style = (TBAlertControllerStyle)self.isAlertViewStyle;
    self.title = [self barTitle];
}

- (IBAction)setDestructiveButtonIndex:(NSUInteger)index button:(UIBarButtonItem *)sender {
    TBAlertController *error = [TBAlertController simpleOKAlertWithTitle:@"Oops!" message:@"You didn't enter a valid value. Try again!"];
    
    TBAlertController *alert = [[TBAlertController alloc] initWithTitle:@"Set the destructive button index" message:@"Press \"Use\" to enable it." style:TBAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.destructiveIndex];
    }];
    
    [alert setCancelButtonWithTitle:@"Don't use" buttonAction:^(NSArray *textFieldStrings) {
        self.usesDestructiveButton = NO;
    }];
    [alert addOtherButtonWithTitle:@"Use" buttonAction:^(NSArray *textFieldStrings) {
        NSString *index = textFieldStrings[0];
        if (index && index.length > 0 && [index rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
            self.destructiveIndex = [index integerValue];
            self.usesDestructiveButton = YES;
        }
        else
            [error showFromViewController:self];
    }];
    
    [alert showFromViewController:self];
}

// 0
- (void)toggleDismissProgrammaticallyAfterDelay:(UITableViewCell *)sender {
    TBAlertController *error = [TBAlertController simpleOKAlertWithTitle:@"Oops!" message:@"You didn't enter a valid value. Try again!"];
    
    TBAlertController *alert = [[TBAlertController alloc] initWithTitle:@"Dismiss Programmatically" message:@"Enter a button index to trigger, or -1 to not trigger any." style:TBAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.dismissIndex];
    }];
    
    [alert setCancelButtonWithTitle:@"Don't enable" buttonAction:^(NSArray *textFieldStrings) {
        self.willDismissProgrammaticallyAfterDelay = NO;
        sender.accessoryType = UITableViewCellAccessoryNone;
    }];
    [alert addOtherButtonWithTitle:@"Enable" buttonAction:^(NSArray *textFieldStrings) {
        NSString *index = textFieldStrings[0];
        if (index && index.length > 0 && [index rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
            self.willDismissProgrammaticallyAfterDelay = YES;
            self.dismissIndex = [index integerValue];
            sender.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
            [error showFromViewController:self];
    }];
    
    [alert showFromViewController:self];
}
// 1
- (TBAlertController *)withCancelButtonMessage:(NSString *)message {
    TBAlertController *alert = [[TBAlertController alloc] initWithTitle:@"Cancel Button" message:message style:self.style];
    [alert setCancelButtonWithTitle:CANCEL];
    return alert;
}
// 2
- (TBAlertController *)withCancelButtonBlock {
    TBAlertController *alert = [self withCancelButtonMessage:@"block"];
    [alert setCancelButtonWithTitle:CANCEL buttonAction:^(NSArray *textFieldStrings) {
        [self log:LOG_CANCEL];
    }];
    return alert;
}
// 3
- (TBAlertController *)withCancelButtonTargetAction {
    TBAlertController *alert = [self withCancelButtonMessage:@"target-action"];
    [alert setCancelButtonWithTitle:CANCEL target:self action:@selector(log)];
    return alert;
}
// 4
- (TBAlertController *)withCancelButtonTargetActionObject {
    TBAlertController *alert = [self withCancelButtonMessage:@"target-action-object"];
    [alert setCancelButtonWithTitle:CANCEL target:self action:@selector(log:) withObject:@"target-action-object success!"];
    return alert;
}
// 5
- (TBAlertController *)withBlockWithoutCancel {
    TBAlertController *alert = [self withBlock];
    [alert removeCancelButton];
    return alert;
}
// 6
- (TBAlertController *)withBlock {
    TBAlertController *alert = [self withCancelButtonMessage:@"block"];
    alert.title = @"Button";
    [alert addOtherButtonWithTitle:OK buttonAction:^(NSArray *textFieldStrings) {
        [self log:LOG_BUTTON];
    }];
    return alert;
}
// 7
- (TBAlertController *)withTargetAction {
    TBAlertController *alert = [self withCancelButtonMessage:@"target-action"];
    alert.title = @"Button";
    [alert addOtherButtonWithTitle:@"OK" target:self action:@selector(log)];
    return alert;
}
// 8
- (TBAlertController *)withTargetActionObject {
    TBAlertController *alert = [self withCancelButtonMessage:@"target-action-object"];
    alert.title = @"Button";
    [alert addOtherButtonWithTitle:OK target:self action:@selector(log:) withObject:@"target-action-object success!"];
    return alert;
}
// 9
- (TBAlertController *)withAddedTextFields {
    TBAlertController *alert = [self withCancelButtonMessage:@"two text fields"];
    alert.title = @"Text Fields";
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"First field";
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Second field";
    }];
    [alert addOtherButtonWithTitle:@"OK" buttonAction:^(NSArray *textFieldStrings) {
        [self logStrings:textFieldStrings];
    }];
    return alert;
}
// 10
- (TBAlertController *)withLoginAndPasswordStyle {
    TBAlertController *alert = [self withCancelButtonMessage:@"login and password style"];
    alert.title = @"Text Fields";
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert addOtherButtonWithTitle:@"OK" buttonAction:^(NSArray *textFieldStrings) {
        [self logStrings:textFieldStrings];
    }];
    return alert;
}
// 11
- (TBAlertController *)WithPlainTextStyleAndAdditionalTextField {
    TBAlertController *alert = [self withCancelButtonMessage:@"secure text + additional field"];
    alert.title = @"Text Fields";
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Additional field (textField.secureTextEntry = YES)";
        textField.secureTextEntry = YES;
    }];
    [alert addOtherButtonWithTitle:@"OK" buttonAction:^(NSArray *textFieldStrings) {
        [self logStrings:textFieldStrings];
    }];
    return alert;
}
// 12
- (TBAlertController *)byRemovingButtons {
    TBAlertController *alert = [self withCancelButtonMessage:@"added and removed some buttons"];
    alert.title = @"Removed 0,0,2,3";
    [alert addOtherButtonWithTitle:@"First"];
    [alert addOtherButtonWithTitle:@"Second"];
    [alert addOtherButtonWithTitle:@"Third" buttonAction:^(NSArray *textFieldStrings) {
        [self log:@"Third pressed"];
    }];
    [alert addOtherButtonWithTitle:@"Fourth"];
    [alert addOtherButtonWithTitle:@"Fifth" target:self action:@selector(log)];
    [alert setCancelButton:[[TBAlertAction alloc] initWithTitle:@"TBAlertAction cancel"]];
    [alert addOtherButtonWithTitle:@"Sixth"];
    
    [alert removeButtonAtIndex:0]; // first removed
    [alert removeButtonAtIndex:0]; // second removed
    [alert removeButtonAtIndex:2]; // fifth removed
    [alert removeButtonAtIndex:3]; // cancel remove
    [alert setButtonEnabled:NO atIndex:1]; // fourth disabled
    [alert setCancelButton:[[TBAlertAction alloc] initWithTitle:@"TBAlertAction cancel"]];
    
    return alert;
}

- (TBAlertController *)modifiedAlert:(TBAlertController *)alert {
    if (self.usesDestructiveButton)
        alert.destructiveButtonIndex = self.destructiveIndex;
    if (self.willDismissProgrammaticallyAfterDelay)
        [self performSelector:@selector(dismissAlert:) withObject:alert afterDelay:2];
    
    return alert;
}

- (void)dismissAlert:(TBAlertController *)alert {
    [alert dismissWithButtonIndex:self.dismissIndex];
}

- (void)log {
    [self log:@"Target-action success!"];
}

- (void)logStrings:(NSArray *)strings {
    for (NSString *string in strings)
        [self log:string];
}
- (void)log:(NSString *)output {
    if (!output)
        output = @"(nil)";
    
    NSLog(@"Selector called with object: %@", output);
}

#pragma mark Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            [self toggleDismissProgrammaticallyAfterDelay:[self.tableView cellForRowAtIndexPath:indexPath]];
            break;
        }
        case 1:
            [[self modifiedAlert:[self withCancelButtonMessage:@"with no action"]] showFromViewController:self];
            break;
        case 2:
            [[self modifiedAlert:[self withCancelButtonBlock]] showFromViewController:self];
            break;
        case 3:
            [[self modifiedAlert:[self withCancelButtonTargetAction]] showFromViewController:self];
            break;
        case 4:
            [[self modifiedAlert:[self withCancelButtonTargetActionObject]] showFromViewController:self];
            break;
        case 5:
            [[self modifiedAlert:[self withBlockWithoutCancel]] showFromViewController:self];
            break;
        case 6:
            [[self modifiedAlert:[self withBlock]] showFromViewController:self];
            break;
        case 7:
            [[self modifiedAlert:[self withTargetAction]] showFromViewController:self];
            break;
        case 8:
            [[self modifiedAlert:[self withTargetActionObject]] showFromViewController:self];
            break;
        case 9:
            [[self modifiedAlert:[self withAddedTextFields]] showFromViewController:self];
            break;
        case 10:
            [[self modifiedAlert:[self withLoginAndPasswordStyle]] showFromViewController:self];
            break;
        case 11:
            [[self modifiedAlert:[self WithPlainTextStyleAndAdditionalTextField]] showFromViewController:self];
            break;
        case 12:
            [[self modifiedAlert:[self byRemovingButtons]] showFromViewController:self];
            break;
    }
}

@end
