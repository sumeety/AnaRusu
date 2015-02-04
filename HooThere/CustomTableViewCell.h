//
//  CustomTableViewCell.h
//  HooThere
//
//  Created by Abhishek Tyagi on 23/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel        *eventPlaceLabel;
@property (nonatomic, weak) IBOutlet UILabel        *eventNameLabel;
@property (nonatomic, weak) IBOutlet UILabel        *eventDateLabel;
@property (nonatomic, weak) IBOutlet UILabel        *eventHostNameLabel;
@property (nonatomic, weak) IBOutlet UILabel        *placeNameLabel;
@property (nonatomic, weak) IBOutlet UILabel        *hootHereLabel;
@property (nonatomic, weak) IBOutlet UILabel        *invitedFirendsLabel;
@property (nonatomic, weak) IBOutlet UILabel        *goingThereLabel;
@property (strong, nonatomic) IBOutlet UILabel *invitedLabel;
@property (strong, nonatomic) IBOutlet UILabel *goingLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoothereLabel;
@property (strong, nonatomic) IBOutlet UIImageView *statusIcon;

@property (nonatomic, weak) IBOutlet UIButton       *hootHereButton;
@property (nonatomic, weak) IBOutlet UIButton       *goingThereButton;
@property (nonatomic, weak) IBOutlet UIButton       *invitedButton;
@property (strong, nonatomic) IBOutlet UILabel *hostNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *leftImageView;
@property (strong, nonatomic) IBOutlet UIButton *rejectFriendRequestButton;
@property (strong, nonatomic) IBOutlet UIButton *orgainserNameButton;
@property (strong, nonatomic) IBOutlet UIButton *placeButton;
@property (strong, nonatomic) IBOutlet UIButton *inviteForEventButton;

@property (strong, nonatomic) IBOutlet UIImageView *statusImage;

@property (nonatomic, weak) IBOutlet UIImageView    *backgroundImageview;
@property (nonatomic, weak) IBOutlet UIImageView    *eventImageview;

@property (nonatomic, weak) IBOutlet UIScrollView   *scrollView;

@property (strong, nonatomic) IBOutlet UILabel        *statusLabel;
@property (nonatomic, weak) IBOutlet UILabel        *subTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel        *titleLabel;
//@property (nonatomic, weak) IBOutlet UIImageView    *statusImageview;
@property (nonatomic, weak) IBOutlet UIImageView    *iconImageview;

@property (strong, nonatomic) IBOutlet UIButton *sendFriendRequestButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
