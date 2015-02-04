//
//  HomeViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 23/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "HomeViewController.h"
#import "REFrostedViewController.h"
#import "UtilitiesHelper.h"
#import "ResizeImage.h"
#import "NotificationHelper.h"
#import "GeofenceMonitor.h"
#import "NotificationViewController.h"
#import "HooThereNavigationController.h"
#import "WhoThereViewController.h"
#import "CreateEventViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize statusLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfileImage) name:@"KLoadProfilePicture" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationRecieved:) name:@"kPushNotificationReceivedForeground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotification) name:@"kPushNotificationReceivedBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchNumberOfNotifcations) name:@"kUpdateNotificationNumber" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopActivityIndicator) name:@"kStopActivityIndicator" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startMonitorinfForEvents) name:@"kStartMonitorinfForEvents" object:nil];

    createEventView.hidden = YES;
    notificationsView.hidden = YES;
    
    
    
    if (_segmentIndex != 1) {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
        [self.view addSubview:_activityIndicator];
        [self.view bringSubviewToFront:_activityIndicator];
        [_activityIndicator startAnimating];
    }
    
    _segmentContoller.selectedSegmentIndex = _segmentIndex;
    [self segementControllerClicked:nil];
    
    [self loadNavigationBarLeftButtons];
    [self loadNavigationBarRightButtons];
    
}

- (void)startMonitorinfForEvents {
    GeofenceMonitor  * gfm = [GeofenceMonitor sharedObj];
}

- (void)stopActivityIndicator {
    [_activityIndicator stopAnimating];
}

- (void)pushNotification {
    HooThereNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    navigationController.navigationBar.barTintColor = [UIColor colorWithRed:143/255.0 green:68/255.0 blue:173/255.0 alpha:1];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    navigationController.navigationBar.translucent = NO;
    
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
    
    HomeViewController *homeView = [self.storyboard instantiateViewControllerWithIdentifier:@"homeView"];
    
    NotificationViewController *notificationView1 = [self.storyboard instantiateViewControllerWithIdentifier:@"notificationView"];
    notificationView1.title = @"My Notifications";
    [self.navigationController setViewControllers:[NSArray arrayWithObjects:homeView, notificationView1,nil]];
}

- (IBAction)showMenu
{
    // Dismiss keyboard (optional)
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    // Present the view controller
    [self.frostedViewController presentMenuViewController];
}

- (void)loadNavigationBarRightButtons {
    
    leftItemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
//    leftItemView.layer.borderWidth=1.0f;
//    leftItemView.layer.backgroundColor=[UIColor redColor].CGColor;
//
//    UIButton *createEventButton = [UIButton  buttonWithType:UIButtonTypeCustom];
//    createEventButton.frame = CGRectMake(45, 0, 35, 30);
//    [createEventButton addTarget:self action:@selector(createEventButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIImageView *createEventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 7, 35, 20)];
//    createEventImageView.contentMode = UIViewContentModeScaleAspectFit;
//    createEventImageView.image = [UIImage imageNamed:@"create-event.png"];
//    
//    [leftItemView addSubview:createEventButton];
//    [leftItemView addSubview:createEventImageView];
//    
//    UIButton *notificationButton = [UIButton  buttonWithType:UIButtonTypeCustom];
//    notificationButton.frame = CGRectMake(0, 0, 35, 40);
//    [notificationButton addTarget:self action:@selector(notificationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    notificationButton.layer.borderColor = [[UIColor whiteColor] CGColor];
//    notificationButton.layer.borderWidth =1;
//    [notificationButton insertSubview:numberBadge atIndex:0];
    //[notificationButton setImage:[UIImage imageNamed:@"gray_owl.png"] forState:UIControlStateNormal];
    
    notificationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(278, 6, 30, 26)];
    notificationImageView.backgroundColor = self.navigationController.navigationBar.barTintColor;
    notificationImageView.contentMode = UIViewContentModeScaleAspectFit;
    notificationImageView.image = [UIImage imageNamed:@"gray_owl.png"];
//
//    [leftItemView addSubview:notificationButton];
//    [leftItemView addSubview:notificationImageView];
//    
//    UIBarButtonItem *notificationButton = [[UIBarButtonItem alloc] initWithCustomView:leftItemView];
    
    UIBarButtonItem *notificationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gray_owl.png"] style:UIBarButtonItemStylePlain target:self action:@selector(notificationButtonClicked)];
    
    UIBarButtonItem *createEventButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"create-event.png"] style:UIBarButtonItemStylePlain target:self action:@selector(createEventButtonClicked)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:notificationButton, createEventButton, nil];
    [self.navigationController.navigationBar addSubview:notificationImageView];

}

- (void)createEventButtonClicked {
//    NSLog(@"Create Event 1");
//    
//    notificationsView.hidden = YES;
//    
//    if (createEventView.hidden == YES) {
//         createEventView.hidden=NO;
//        [self.view bringSubviewToFront:createEventView];
//       
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"kcreateEventButtonClicked" object:nil userInfo:nil];
//        NSLog(@"createEventShouldApper");
//    }
//    else {
//        createEventView.hidden = YES;
//        [self.view endEditing:YES];
//    }
    CreateEventViewController *createEvent = [self .storyboard instantiateViewControllerWithIdentifier:@"createEventView"];
    createEvent.title = @"What's Happening?";
    [self.navigationController pushViewController:createEvent animated:NO];
}

- (void)notificationButtonClicked {
    NSLog(@"Notifications 1");
    
    createEventView.hidden = YES;
    
    NotificationViewController *notificationView1 = [self.storyboard instantiateViewControllerWithIdentifier:@"notificationView"];
    notificationView1.title = @"My Notifications";
    [self.navigationController pushViewController:notificationView1 animated:NO];

}

- (void)pushNotificationRecieved:(NSNotification *)notification {
    [self fetchNumberOfNotifcations];
    
    NSDictionary *notificationInfo = notification.object;
    
    NSString *notificationType = [notificationInfo objectForKey:@"category"];
    if ([notificationType isEqualToString:@"EI"] || [notificationType isEqualToString:@"EU"] || [notificationType isEqualToString:@"EA"] || [notificationType isEqualToString:@"EHT"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushUpdateEventList" object:notificationInfo];
    }
    else if ([notificationType isEqualToString:@"FRA"] || [notificationType isEqualToString:@"FRF"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kPushUpdateFriendList" object:notificationInfo];
    }
}

- (void)fetchNumberOfNotifcations {
    [NotificationHelper getCountOfNotificationsWithComplettionBlock:^(BOOL success, NSString *notificationCount){
        if (success) {
            [numberBadge removeFromSuperview];
            
            if (notificationCount.integerValue > 0) {
                if ([[self.navigationController.viewControllers lastObject] isKindOfClass:[HomeViewController class]]) {
                    numberBadge = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(278, 0, 34,15)];
                    numberBadge.value = notificationCount.integerValue;
                    [self.navigationController.navigationBar addSubview:numberBadge];
                }
            }
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:notificationCount.integerValue];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    numberBadge.hidden = YES;
    notificationImageView.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    
}

- (void)viewWillAppear:(BOOL)animated {
    numberBadge.hidden = NO;
    notificationImageView.hidden = NO;
    [self.navigationController.navigationBar bringSubviewToFront:notificationImageView];
    [self.navigationController.navigationBar bringSubviewToFront:numberBadge];

    _userInformation=[CoreDataInterface getInstanceOfMyInformation];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kEnablePanGestureRequest" object:nil userInfo:nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateHooThereEvents" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideExtraView) name:@"kCancelButtonClicked" object:nil];
    
    [self fetchNumberOfNotifcations];
    [self reloadStatusAndProfilePic];
    [self.view endEditing:YES];
}

- (void)hideExtraView {
    notificationsView.hidden = YES;
    createEventView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)reloadStatusAndProfilePic{
    _userInformation=[CoreDataInterface getInstanceOfMyInformation];
    [self loadProfileImage];
    
    if (_userInformation.availabilityStatus.length > 0) {
        statusLabel.text= _userInformation.availabilityStatus;
    }
    else {
        statusLabel.text = @"Select you status";
    }
}

- (IBAction)segementControllerClicked:(UISegmentedControl *)sender {
    switch (_segmentContoller.selectedSegmentIndex)
    {
        case 0:
            hooThereView.hidden = NO;
            
            hootHereView.hidden = YES;
             [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateHooThereEvents" object:nil userInfo:nil];
            break;
        case 1:
            hooThereView.hidden = YES;
            
            hootHereView.hidden = NO;
            break;
        default: 
            break; 
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    InviteFriendsViewController *inviteFriendsViewController=segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"homeViewSegue"])
    {
        
        
        inviteFriendsViewController.fromWhereCalled = 0;
        
    }
    
}

- (void)loadNavigationBarLeftButtons {
    rightItemView = [[UIView alloc] initWithFrame:CGRectMake(0, -5, 50, 30)];//160
    UIButton *slidingMenuButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    slidingMenuButton.frame = CGRectMake(0, 0, 35, 30);
    [slidingMenuButton addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *slidingMenuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 30, 25)];
    slidingMenuImageView.contentMode = UIViewContentModeScaleAspectFit;
    slidingMenuImageView.image = [UIImage imageNamed:@"slider_menu.png"];
    
    [rightItemView addSubview:slidingMenuButton];
    [rightItemView addSubview:slidingMenuImageView];
    
//    UIButton *statusButton = [UIButton  buttonWithType:UIButtonTypeCustom];
//    statusButton.frame = CGRectMake(42, 0, 155, 35);
//    [statusButton addTarget:self action:@selector(statusButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(42, 5, 20, 20)];
//    statusImageView.contentMode = UIViewContentModeScaleAspectFit;
//    //statusImageView.image= [UIImage imageNamed:@"1980279_10152047276111848_2058157_o.jpg"];
//    statusImageView.layer.masksToBounds = YES;
//    statusImageView.layer.cornerRadius = 10;
//
//   
//
//    
//    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 120, 30)];
//    statusLabel.text = [_userInformation availabilityStatus];
//    statusLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
//    statusLabel.textColor = [UIColor whiteColor];
    
//    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(170, 10, 10, 10)];
//    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
//    arrowImageView.image = [UIImage imageNamed:@"downArrow.png"];
//    
//    [rightItemView addSubview:arrowImageView];
    
//    [rightItemView addSubview:statusButton];
//    [rightItemView addSubview:statusImageView];
//    [rightItemView addSubview:statusLabel];
    
    UIBarButtonItem *notificationButtonBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightItemView];
    self.navigationItem.leftBarButtonItem = notificationButtonBarButton;
}

-(void)loadProfileImage{
    UserInformation *userInfo = [CoreDataInterface getInstanceOfMyInformation];
    if (userInfo.profileImage.length > 0) {
        UIImage *image = [UIImage imageWithData:userInfo.profileImage];
        statusImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(200, 200)];
    }
    else {
        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        statusImageView.image= [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    }
}

- (void)statusButtonClicked {
    StatusViewController *statusView = [self.storyboard instantiateViewControllerWithIdentifier:@"statusView"];
    [self presentViewController:statusView animated:YES completion:nil];
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end