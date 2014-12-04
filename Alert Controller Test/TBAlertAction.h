//
//  TBAlertAction.h
//  Alert Controller Test
//
//  Created by Tanner on 12/3/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TBAlertActionStyle) {
    TBAlertActionStyleNoAction = 0,
    TBAlertActionStyleBlock,
    TBAlertActionStyleTarget,
    TBAlertActionStyleTargetObject
};

@interface TBAlertAction : NSObject

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title block:(void(^)())block;
- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action;
- (instancetype)initWithTitle:(NSString *)title target:(id)target action:(SEL)action object:(id)object;

@property (nonatomic, readonly      ) TBAlertActionStyle style;
@property (nonatomic                ) BOOL               enabled; // Only applies to iOS 8
@property (nonatomic, readonly, copy) NSString           *title;
@property (nonatomic, readonly, copy) void               (^block)();
@property (nonatomic, readonly      ) id                 target;
@property (nonatomic, readonly      ) SEL                action;
@property (nonatomic, readonly      ) id                 object;

@end
