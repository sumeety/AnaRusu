//
//  MyProfileViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusViewController.h"
#import "UserInformation.h"

@interface MyProfileViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UITextFieldDelegate> {
    
    UIImagePickerController     *pickerController;
    IBOutlet    UIImageView     *profilePicImageView;
    IBOutlet    UIImageView     *statusImageView;
    
    IBOutlet UIImageView *cameraIcon;
    IBOutlet UIButton *cameraButton;
    IBOutlet    UILabel         *nameLabel;
    IBOutlet    UILabel         *numberLabel;
    IBOutlet    UILabel         *emailLabel;
    IBOutlet    UILabel         *availabilityLabel;
    
    IBOutlet UIButton *sendRequestButton;
    IBOutlet UIButton *rejectButton;
    IBOutlet UIImageView *editNumberImage;
    IBOutlet UIImageView *editNameImage;
    IBOutlet UIImageView *editImage;
    
    IBOutlet UIImageView *emailIconImage;
    
    
    IBOutlet    UITextField     *nameTextField;
    IBOutlet    UITextField     *numberTextField;
    
    
    IBOutlet    UIView          *statusView;
    IBOutlet    UIImageView     *bgImageView;
    
    IBOutlet UIView *viewToHide;
    
    IBOutlet UIView *viewToHidePassword;

    UIBarButtonItem *saveButton;
}

@property (nonatomic)BOOL fromSidebar;
@property (nonatomic)BOOL isUser;
@property (nonatomic)BOOL isFriend;
@property (nonatomic)BOOL isHost;
@property (nonatomic,strong)NSDictionary *friendData;
@property (nonatomic,strong)NSString *friendId;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;

@property (nonatomic,strong)NSString *frienshipStatus;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic,strong)UserInformation *userInformation;
@property (nonatomic,strong)NSString *fromWhereCalled;
@property (nonatomic) BOOL fromPickerViewCamera;

@property (nonatomic)NSInteger tag;
@property (nonatomic,strong)NSString *eventId;
@property (nonatomic,strong)NSDictionary *statistics;
@property (nonatomic,strong)NSString *hostId;
@property (nonatomic,strong)NSString *hostName;
@property (nonatomic)BOOL isFromNavigation;;

- (IBAction)sendRequestButtonClicked:(id)sender;
- (IBAction)rejectButtonClicked:(id)sender;

- (IBAction)cameraButtonClicked:(id)sender;
- (IBAction)profilePicClicked:(id)sender;
- (IBAction)editButtonClicked:(UIButton *)button;
- (IBAction)changePasswordButtonClicked:(id)sender;

@end
