//
//  HooThereNavigationController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"

@interface HooThereNavigationController : UINavigationController

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender;

@property (nonatomic) BOOL sideBarToShow;

@end