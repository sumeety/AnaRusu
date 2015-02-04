//
//  WhoThereViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 23/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNumberBadgeView.h"
#import <FacebookSDK/FacebookSDK.h>

@interface WhoThereViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView            *eventTableView;
     FBLoginView                 *loginview;
    MKNumberBadgeView       *numberBadge;
    UIView                  *leftItemView;
    
}

@property (nonatomic, strong) NSMutableArray        *listOfEvents;
@property (nonatomic, strong) NSMutableArray        *listOfCheckedInEvents;

@property (nonatomic) BOOL   noEvents;
@property (nonatomic) BOOL   noRequest;

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *createAndInviteLabel;
@property (strong, nonatomic) IBOutlet UILabel *aloneLabel;
@property (strong, nonatomic) IBOutlet UIButton *organiserNameButton;

- (IBAction)hootHereButtonClicked:(UIButton *)sender;
- (IBAction)goingThereButtonClicked:(UIButton *)sender;
- (IBAction)invitedButtonClicked:(UIButton *)sender;

- (IBAction)placeButtonClicked:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *aloneImage;
@property (nonatomic)BOOL isRefreshed;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic,strong)NSDictionary *friendToInviteInfo;
@property (nonatomic,strong)NSString * fromWhereCalled;

@end
