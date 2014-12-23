//
//  MasterViewController.h
//  Alert Controller Test
//
//  Created by Tanner on 12/1/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property BOOL isAlertViewStyle;


@end

