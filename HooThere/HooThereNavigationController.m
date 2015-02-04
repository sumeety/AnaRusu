//
//  HooThereNavigationController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "HooThereNavigationController.h"

@interface HooThereNavigationController ()

@end

@implementation HooThereNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePanGesture) name:@"kDisablePanGestureRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showPanGesture) name:@"kEnablePanGestureRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    if (_sideBarToShow) {
        // Dismiss keyboard (optional)
        //
        [self.view endEditing:YES];
        [self.frostedViewController.view endEditing:YES];
        
        // Present the view controller
        //
        [self.frostedViewController panGestureRecognized:sender];
    }
}

- (void)showPanGesture {
    _sideBarToShow = YES;
}


- (void)hidePanGesture {
    _sideBarToShow = NO;
}

- (void)orientationChanged:(NSNotification *)notification {
    
    if (([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) ||
        ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight))
    {
        NSLog(@"Landscape");
    } else
    {
        NSLog(@"Portrait");
    }
}

@end
