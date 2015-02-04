//
//  SeeAllViewController.h
//  HooThere
//
//  Created by Jasmeet Kaur on 15/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuSidebarCell.h"
#import "MYProfileViewController.h"

@interface SeeAllViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *seeAllTableView;

@property (nonatomic, strong) NSMutableArray            *listOfSeeAll;
@property (nonatomic, strong) NSMutableArray            *listOfNewConnections;
@property (nonatomic ) BOOL            newConnections;
@property (strong, nonatomic) IBOutlet UIImageView *youImageView;

@property (nonatomic)  NSUInteger tag;
@property (strong, nonatomic) NSDictionary  *statistics;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentContoller;
@property (strong, nonatomic) NSString *friendsListType;
@property (strong, nonatomic) NSString *eventId;
@property (strong,nonatomic) NSString *userId;
@property (strong, nonatomic) NSArray *allFriendsSortedArray;

- (IBAction)segementControllerClicked:(UISegmentedControl *)sender;
- (IBAction)addFriendButtonClicked:(UIButton *)sender;
@end
