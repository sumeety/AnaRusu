//
//  InviteFriendsViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AddressBook.h"
#import "CoreDataInterface.h"

@interface InviteFriendsViewController : UIViewController <FBFriendPickerDelegate, UIScrollViewDelegate, FBLoginViewDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIView         *tabLineView;
    IBOutlet UITableView    *hootHereTableView;
    IBOutlet UIImageView    *textFieldBackground;
    IBOutlet UIScrollView   *scrollView;
    FBLoginView                 *loginview;
    
    IBOutlet UIImageView *searchIcon;
    IBOutlet UIImageView *contactsIcon;
    IBOutlet UIImageView *facebookIcon;
    IBOutlet UIImageView *hoothereIcon;
    IBOutlet UIButton       *hooThereButton;
    IBOutlet UIButton       *facebookButton;
    IBOutlet UIButton       *contactsButton;
    IBOutlet UIButton *buttonGroup;
    IBOutlet UIView *inviteFriendView;
    
    IBOutlet UIButton *acceptButton;
    IBOutlet UIButton *inviteFriendsButton;
    IBOutlet UIImageView *imageBar2;
    IBOutlet UIImageView *imageBar1;
    
    IBOutlet UISearchBar *searchBarField;
    
    
}
@property (nonatomic, strong) NSMutableArray    *searchArray;
@property (nonatomic, strong) NSMutableArray    *listOfFriends;
@property (nonatomic, strong) NSMutableArray    *listOfFacebookFriends;
@property (nonatomic, strong) NSMutableArray    *listOfHootHereFriends;
@property (nonatomic, strong) NSMutableArray    *listOfFacebookInvites;
@property (nonatomic, strong) NSMutableArray    *listOfFriendsSelected;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic, strong) NSString          *listType;
@property (nonatomic) BOOL                      facebookSelected;
@property (nonatomic) NSInteger fromWhereCalled;
@property (nonatomic) BOOL                      searching;
@property (strong, nonatomic) Events    *thisEvent;
@property(strong,nonatomic)NSString *hostId;
@property(strong,nonatomic)NSDictionary *hostData;

- (IBAction)hooThereButtonClicked:(id)sender;
- (IBAction)facebookButtonClicked:(id)sender;
- (IBAction)contactsButtonClicked:(id)sender;
- (IBAction)tabButtonClicked:(UIButton *)button;
- (IBAction)inviteButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end
