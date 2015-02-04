//
//  SearchEventDetailsViewController.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 06/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeeAllViewController.h"
#import "InviteFriendsViewController.h"
#import "REFrostedViewController.h"

@interface SearchEventDetailsViewController : UIViewController {
    
    IBOutlet UIButton *joinButton;
    IBOutlet UIButton *inviteFriendsButton;
    IBOutlet UIImageView *eventBannerImageView;
    
    IBOutlet UIButton *orgainserNameButton;
    IBOutlet UIImageView *hostImageView;
    IBOutlet UILabel *hostNameLabel;
    IBOutlet UILabel *eventNameLabel;
}

- (IBAction)organiserNameClicked:(id)sender;

- (IBAction)joinButtonClicked:(id)sender;

@property (strong, nonatomic) NSDictionary   *thisEvent;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView1;

@property (strong, nonatomic) NSString  *eventId;
@property (nonatomic) BOOL fromNotification;
@property (nonatomic) BOOL isPastEvent;
@property (strong, nonatomic) NSString  *hostName;
@property(strong,nonatomic)NSString *hostId;
@property(strong,nonatomic)NSDictionary *hostData;
@property (strong, nonatomic) NSDictionary  *statistics;
@property(strong ,nonatomic)NSMutableArray *imageViewArray;
@property (strong,nonatomic)NSMutableArray *hooThereFriends;
@property (strong,nonatomic)NSMutableArray *invitedFriends;
@property (strong,nonatomic)NSMutableArray *acceptedFriends;
@property (strong,nonatomic)UILabel *goingStatsLabel;
@end
