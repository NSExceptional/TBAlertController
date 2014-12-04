//
//  TBAlertAction.m
//  Alert Controller Test
//
//  Created by Tanner on 12/3/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import "TBAlertAction.h"

@implementation TBAlertAction

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _title   = title;
        _enabled = YES;
        _style   = TBAlertActionStyleNoAction;
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title block:(void (^)())block
{
    self = [self initWithTitle:title];
    if (self) {
        _block = block;
        _style = TBAlertActionStyleBlock;
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    self = [self initWithTitle:title];
    if (self) {
        _target = target;
        _action = action;
        _style = TBAlertActionStyleTarget;
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action object:(id)object
{
    self = [self initWithTitle:title target:target action:action];
    if (self) {
        _object = object;
        _style = TBAlertActionStyleTargetObject;
    }
    
    return self;
}

@end
