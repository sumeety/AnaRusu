//
//  HomeViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 23/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNumberBadgeView.h"
#import "UtilitiesHelper.h"
#import "InviteFriendsViewController.h"
#import "StatusViewController.h"
#import "UserInformation.h"

@interface HomeViewController : UIViewController <NavigationButtonDelegate> {
    
    MKNumberBadgeView       *numberBadge;
    UIView                  *leftItemView;
    UIImageView *notificationImageView;
    IBOutlet UIView     *notificationsView;
    IBOutlet UIView     *createEventView;
    IBOutlet UIView     *hooThereView;
    IBOutlet UIView     *hootHereView;
    UILabel             *statusLabel;
        UIView                  *rightItemView;
    UIImageView  *statusImageView;
}
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentContoller;
@property (strong,nonatomic)UserInformation *userInformation;
@property (nonatomic)NSInteger segmentIndex;
@property (strong, nonatomic) UILabel             *statusLabel;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;


@property (strong,nonatomic)UIImageView *profilePicView;
- (IBAction)segementControllerClicked:(UISegmentedControl *)sender;

@end
