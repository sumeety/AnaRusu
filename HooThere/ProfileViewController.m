//
//  ProfileViewController.m
//  Hoothere
//
//  Created by Steve Sopoci on 1/19/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "ProfileViewController.h"
#import "MyProfileViewController.h"
#import "WhoThereViewController.h"
#import "HootHereViewController.h"
#import "CoreDataInterface.h"
#import "ResizeImage.h"
#import "AppDelegate.h"

@interface ProfileViewController ()<UIAlertViewDelegate>{
    BOOL friendButtonClicked;
    NSDictionary *tmpJsonDict;
}
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *friendButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *numberOfFriendsButton;

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fromProfileView" object:nil userInfo:nil];
    
        
    UIBarButtonItem *barSettingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting_white.png"] style:UIBarButtonItemStylePlain target:self action:@selector(barSettingButtonClicked)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:barSettingButton, nil];
    
    [self.tabBarController.tabBar setTintColor:[UIColor purpleColor]];
    self.tabBarController.tabBar.hidden = NO;
    
    _profileImageView.layer.masksToBounds = YES;
    _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width/2;
    
    _inviteButton.layer.cornerRadius = 3;
    _messageButton.layer.cornerRadius = 3;    
    _settingButton.layer.cornerRadius = 3;
    _friendButton.layer.cornerRadius = 3;
    
    [_numberOfFriendsButton setTitle:nil forState:UIControlStateNormal];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    if (!_isFromHootHere) {
        NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
        
        _isUser=YES;
        _friendId = userId;
        //_fromSidebar = YES;
        
        self.navigationItem.title = @"My Profile";
    }
    NSLog(@"friendId = %@",_friendId);    
    
    
    [self fetchListOfHootThereFriends];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    if (_isUser) {
        [self getUserProfile];
        [self loadProfileImage];
    } else {
        self.navigationItem.rightBarButtonItems = nil;
        [self getFriendProfile:_friendId];
        [self loadFriendProfilePic];
        
    }
}

- (void) getAndDisplayOfListOfFriend{
    
    NSInteger numberOfFriends = [[tmpJsonDict objectForKey:@"Friends"] count];
    [_numberOfFriendsButton setTitle:[NSString stringWithFormat:@"%ld",(long)numberOfFriends] forState:UIControlStateNormal];
    
    if (_isMyFriend) {
        _friendButton.backgroundColor = [UIColor purpleColor];
        [_friendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_friendButton setTitle:@"Friends" forState:UIControlStateNormal];
        [_friendButton addTarget:self action:@selector(removeFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        _friendButton.layer.borderColor = [UIColor purpleColor].CGColor;
        _friendButton.layer.borderWidth = 1.0;
        _friendButton.backgroundColor = [UIColor whiteColor];
        [_friendButton setTitle:@"Add Friend +" forState:UIControlStateNormal];
        [_friendButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [_friendButton addTarget:self action:@selector(sendFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)onNumberOfFriendsButtonClicked:(id)sender {
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    [CoreDataInterface deleteAllObject:@"Friends" andManagedOBC:appDelegate.managedObjectContext];
    [CoreDataInterface saveFriendList:[tmpJsonDict objectForKey:@"Friends"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fetchedFriendsList" object:nil userInfo:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)removeFriendRequest:(UIButton * )sendFriendButton{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"Are you sure to remove this friend from your friend list?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel",nil];
    alertView.delegate = self;
    [alertView show];
}

-(void) removeFriend{
    
    [_activityIndicator startAnimating];
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/remove/%@",kwebUrl,userId,_friendId ];
    
    NSLog(@"Rejecting Request to %@",urlString);
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"DELETE"
                   complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     { [_activityIndicator stopAnimating];
         if (success) {
             
             [self viewDidLoad];
             [self viewWillAppear:YES];
             
             
             NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",_friendId];
             
             NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
             if ([retData count] > 0)
             {
                 [CoreDataInterface deleteThisFriend:[retData objectAtIndex:0]];
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"This user is removed from your friend list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alertView show];
                 /*
                  NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                  [navigationViewsArray removeLastObject];
                  [navigationViewsArray removeLastObject];
                  [self moveToLastView ];
                  */
                 [self.navigationController popViewControllerAnimated:YES];
             }
             //[self updateFriendsTableView];
             
         }
     }];

}

-(void)sendFriendRequest:(UIButton * )sendFriendButton {
    
    [_activityIndicator startAnimating];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/add/%@",kwebUrl,userId,_friendId];
    
    NSLog(@"sending Request to %@",urlString);
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                   complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         
         if (success) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Your friend request has been sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
             /*
             [userInfo setObject:@"P" forKey:@"status"];
             [userInfo setObject:[userInfo objectForKey:@"userId"] forKey:@"id"];
             NSDictionary *friendInfo = [[NSDictionary alloc] initWithObjectsAndKeys:userInfo,@"friend",@"P",@"status", nil];
             [CoreDataInterface saveFriendList:[NSArray arrayWithObject:friendInfo]];
             [self searchFriendsList:searchBarField.text];*/
             
             [self viewDidLoad];
             [self viewWillAppear:YES];
         }
     }];
}

- (IBAction)onInviteButtonClicked:(id)sender {
    
    WhoThereViewController *whoThereView=[self.storyboard instantiateViewControllerWithIdentifier:@"whoThereView"];
    //whoThereView.friendToInviteInfo=dictionaryInfo;
    //whoThereView.fromWhereCalled=@"HT";
    self.navigationItem.title = @"";
    
    whoThereView.title = @"My Upcoming Events";
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    appDelegate.selectedFriendId = nil;
    whoThereView.fromWhereCalled = @"HT";
    [self.navigationController pushViewController:whoThereView  animated:YES];    
    
}

- (void)barSettingButtonClicked {
    MyProfileViewController *myProfileViewController = [self .storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
    //createEvent.title = @"What's Happening?";
    [self.navigationController pushViewController:myProfileViewController animated:NO];
}

- (void)fetchListOfHootThereFriends {
    //[_activityIndicator startAnimating];
    [self.view endEditing:YES];
    
    //NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSLog(@"22222222 friendId = %@", _friendId);
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/getAll?page=0",kwebUrl,_friendId];
    
    [UtilitiesHelper fetchListOfHootThereFriends:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict){
        
        [_activityIndicator stopAnimating];
        
        if (success) {
            //_listOfFriends = [jsonDict objectForKey:@"Friends"];
            tmpJsonDict = [[NSDictionary alloc] initWithDictionary:jsonDict];
            //[CoreDataInterface saveFriendList:[jsonDict objectForKey:@"Friends"]];
            [self getAndDisplayOfListOfFriend];
        }
        
    }];
}


-(void)getUserProfile{
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@",kwebUrl, [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]];
    
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         
         if (success) {
             NSString *userId=[jsonDict objectForKey:@"id"];
             if(userId) {
                 [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                 [CoreDataInterface saveUserInformation:jsonDict];
                 _userInformation =[CoreDataInterface getInstanceOfMyInformation];
                 NSLog(@"new Info....");
             }
             id imageName = [jsonDict objectForKey:@"profile_picture"];
             
             if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
                 NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/image",kwebUrl,[jsonDict objectForKey:@"id"]];
                 [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
                  {
                      if (success) {
                          _profileImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(80, 80)];
                          [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"UserImage"];
                          [[NSUserDefaults standardUserDefaults] synchronize];
                          
                          if (_userInformation) {
                              _userInformation.profileImage =[NSData dataWithData:UIImagePNGRepresentation(image)];
                          }
                      }
                  }];
             }
         }
     }];
}



-(void)getFriendProfile:(NSString *)friendId{
    
    NSString *friedshipStatus;
    
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",friendId];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
    NSLog(@"friendId = %@",friendId);
    NSLog(@"retData friend %@",retData);
    if([retData count]>0)
    {
        Friends *friend = [retData objectAtIndex:0];        
        
        NSLog(@"friend............ %@",friend);
        
        self.navigationItem.title = friend.fullName;
        
        friedshipStatus=[[retData objectAtIndex:0] status];
    }
}

-(void) loadFriendProfilePic{
    
    id imageName = [_friendData objectForKey:@"profile_picture"];
    
    UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
    _profileImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(80, 80)];
    
    if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
        //_friendId = @"4";
        NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/image",kwebUrl,_friendId];
        [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
         {
             if (success) {
                 _profileImageView.image  = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(80, 80)];
             }
         }];
    }
    
}

-(void)loadProfileImage{
    UserInformation *userInfo = [CoreDataInterface getInstanceOfMyInformation];
    if (userInfo.profileImage.length > 0) {
        UIImage *image = [UIImage imageWithData:userInfo.profileImage];
        _profileImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(80, 80)];
    }
    else {
        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        _profileImageView.image= [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(80, 80)];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self removeFriend];
    }
}

@end
