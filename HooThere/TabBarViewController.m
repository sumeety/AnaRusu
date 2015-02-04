//
//  TabBarViewController.m
//  Hoothere
//
//  Created by Steve Sopoci on 1/23/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "TabBarViewController.h"
#import "AppDelegate.h"

@interface TabBarViewController ()<UITabBarDelegate>

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    switch (item.tag) {
        case 0:{
            NSLog(@"selected    --------- 0");
            appDelegate.selectedFriendId = nil;    // for browsing user's events
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pressedEventTab" object:nil userInfo:nil];
        }
            break;
        case 1:{
            appDelegate.isFromMe = NO;
            NSLog(@"selected    --------- 1");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pressedFriendTab" object:nil userInfo:nil];
        }
            break;
        case 2:{
            NSLog(@"selected    --------- 2");
        }
            break;
        case 3:{
            NSLog(@"selected    --------- 3");
            appDelegate.selectedFriendId = nil;
            appDelegate.isFromMe = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pressedMeTab" object:nil userInfo:nil];
        }
            break;
            
        default:
            break;
    }
}

@end
