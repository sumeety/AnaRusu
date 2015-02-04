//
//  SearchEventDetailsViewController.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 06/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "SearchEventDetailsViewController.h"
#import "UtilitiesHelper.h"
#import "ResizeImage.h"
#import "EventHelper.h"
#import <MapKit/MapKit.h>
#import "HooThereNavigationController.h"
#import "HomeViewController.h"
#import "EventDetailsViewController.h"
#import "UIImageView+WebCache.h"
#import "WhoThereViewController.h"

@interface SearchEventDetailsViewController ()

@end

@implementation SearchEventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageViewArray=[[NSMutableArray alloc]init];
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    hostImageView.layer.masksToBounds = YES;
    hostImageView.layer.cornerRadius = 20;
    
    joinButton.layer.cornerRadius=3;
    
    hostImageView.image=[UIImage imageNamed:@"defaultpic_small.png"];
    [self getEventDetails];
    [self getGuestList];
    [self getHostImage];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

-(void)getHostImage{
    
    id imageName = [_hostData objectForKey:@"profile_picture" ];
    
    //    UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
    //    cell.iconImageview.image= [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    
    if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,[_hostData objectForKey:@"id"]];
        [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
         {
             if (success) {
                 hostImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
             }
         }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEventDetails {

    _hostName = [[_thisEvent objectForKey:@"user"] objectForKey:@"fullName"];
    _hostId = [[_thisEvent objectForKey:@"user"] objectForKey:@"id"];
    _hostData = [_thisEvent objectForKey:@"user"];
    _eventId = [_thisEvent objectForKey:@"id"];
    self.statistics = [_thisEvent objectForKey:@"statistics"];
    
    eventNameLabel.text = [_thisEvent objectForKey:@"name"];
    hostNameLabel.text = _hostName;
    
    [self createCustomViewForEventDetails];
}

- (void)createCustomViewForEventDetails {
    
    //createCustomViewForEventDetail
    
    float yOrigin = 90;//176;
    //Creating Description label.......
    if ([[_thisEvent objectForKey:@"eventDescription"] length] > 0) {
        CGFloat descriptionLabelHeight = [self heigthWithWidth:290 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] string:[_thisEvent objectForKey:@"eventDescription"]];
        [_scrollView addSubview:[self createLabelOfSize:CGRectMake(15, yOrigin, 290, descriptionLabelHeight) text:[_thisEvent objectForKey:@"eventDescription"] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
        
        yOrigin = yOrigin + descriptionLabelHeight + 15;
    }
    
    if ([[_thisEvent objectForKey:@"address"] length] > 0) {
        [self createAddressLabelWithButton:yOrigin];
        CGFloat locationLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] string:[_thisEvent objectForKey:@"address"]];
        
        yOrigin = yOrigin + locationLabelHeight + 25;
    }
    //Creating Place View.......
    
    // Creating Time View
    [self createTimeView:yOrigin];
    
    yOrigin = yOrigin + 20;
    
    [self createEndTimeView:yOrigin];
    
    yOrigin = yOrigin + 30;
    
    [self createHooThereView:yOrigin];
    
    yOrigin = yOrigin + 30;
    
    [_scrollView addSubview:[self createViewFor:@"H" yOrigin:yOrigin]];
    
    yOrigin = yOrigin + 60;
    
    [self createGoingThereView:yOrigin];
    
    yOrigin = yOrigin + 30;
    
    [_scrollView addSubview:[self createViewFor:@"G" yOrigin:yOrigin]];
    
    yOrigin = yOrigin + 60;
    
    [self createInvitedView:yOrigin];
    
    yOrigin = yOrigin + 30;
    
    [_scrollView addSubview:[self createViewFor:@"I" yOrigin:yOrigin]];
    
    yOrigin = yOrigin + 60;
    
    _scrollView.contentSize = CGSizeMake(320, yOrigin);
    
    if (_isPastEvent) {
        joinButton.hidden = YES;
        self.tabBarController.tabBar.hidden = NO;
//        _scrollView1 = [[UIScrollView alloc] init];
//        _scrollView1 = _scrollView;
//        CGRect newScrollFrame = _scrollView.frame;
//        newScrollFrame.size.height = newScrollFrame.size.height + 40;
//        [_scrollView1 setFrame:newScrollFrame];
//        _scrollView.hidden = YES;
//        NSLog(@"Array : %@",_scrollView1.subviews);
//        [self.view addSubview:_scrollView1];
//        _scrollView1.contentSize = CGSizeMake(320, yOrigin);
    }
    else {
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void)createAddressLabelWithButton:(float)yOrigin {
    
    if (![[_thisEvent objectForKey:@"address"] length] > 0) {
        return;
    }
    //Creating Location Button
    CGFloat locationLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] string:[NSString stringWithFormat:@"%@\n%@",[_thisEvent objectForKey:@"venueName"],[_thisEvent objectForKey:@"address"]]];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    locationButton.frame = CGRectMake(15, yOrigin, 290, locationLabelHeight);
    [locationButton addTarget:self action:@selector(locationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:locationButton];
    //Creating Location Imageview.......
    
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+3, 10, 10) image:[UIImage imageNamed:@"location.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    //Creating Location label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, locationLabelHeight) text:[NSString stringWithFormat:@"%@\n%@",[_thisEvent objectForKey:@"venueName"],[_thisEvent objectForKey:@"address"]] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] fontColor:[UIColor colorWithRed:89/255.0 green:152/255.0 blue:205/255.0 alpha:1] alignment:NSTextAlignmentLeft]];
}

- (void)createTimeView:(float)yOrigin {
    //Creating Time Imageview
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+5, 10, 10) image:[UIImage imageNamed:@"time.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[[_thisEvent objectForKey:@"startDateTime"] doubleValue]/1000.0];
    
    //Creating Time label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 20) text:([[_thisEvent objectForKey:@"startDateTime"] doubleValue]!=0)?[NSString stringWithFormat:@"%@ at %@",[EventHelper changeDateFormat:startDate],[EventHelper changeTimeFormat:startDate]]:@" " font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
}


- (void)createEndTimeView:(float)yOrigin {
    //Creating Time Imageview
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+5, 10, 10) image:[UIImage imageNamed:@"time.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[[_thisEvent objectForKey:@"endDateTime"] doubleValue]/1000.0];
    
    //Creating Time label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 20) text:([[_thisEvent objectForKey:@"endDateTime"] doubleValue]!=0)?[NSString stringWithFormat:@"%@ at %@",[EventHelper changeDateFormat:endDate],[EventHelper changeTimeFormat:endDate]]:@" " font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
}

- (void)createHooThereView:(float)yOrigin {
    //Creating Time Imageview
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+5, 10, 10) image:[UIImage imageNamed:@"hoot.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    //Creating Time label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 20) text:[NSString stringWithFormat:@"%@ Hoo There",[self.statistics objectForKey:@"hoothereCount"]] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
}

- (void)createGoingThereView:(float)yOrigin {
    //Creating Time Imageview
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+5, 10, 10) image:[UIImage imageNamed:@"going.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    //Creating Time label.......
    
    _goingStatsLabel=[[UILabel alloc] initWithFrame:CGRectMake(30, yOrigin, 240, 20)];
    _goingStatsLabel.text=[NSString stringWithFormat:@"%@ Going There" ,[self.statistics objectForKey:@"acceptedCount"]];
    _goingStatsLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    _goingStatsLabel.textColor=[UIColor grayColor];
    
    [_scrollView addSubview:_goingStatsLabel];
    //    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 20) text:[NSString stringWithFormat:@"%@ Going There" ,[self.statistics objectForKey:@"acceptedCount"]] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
}

- (void)createInvitedView:(float)yOrigin {
    //Creating Time Imageview
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+5, 10, 10) image:[UIImage imageNamed:@"invited.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    //Creating Time label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 20) text:[NSString stringWithFormat:@"%@ Invited" ,[self.statistics objectForKey:@"invitedCount"]] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
}

- (void)locationButtonClicked {
    CLLocationDegrees latitude = [[_thisEvent objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[_thisEvent objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:centerCoordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = [_thisEvent objectForKey:@"venueName"];
    [item openInMapsWithLaunchOptions:nil];
}

- (void)friendsPictureClicked:(UIButton *)button {
    NSLog(@"Tag : %ld",(long)button.tag);
}

- (void)seeAllButtonClicked:(UIButton *)button {
    
    NSLog(@"Tag : %ld",(long)button.tag);
    
    SeeAllViewController *seeAllView = [self.storyboard instantiateViewControllerWithIdentifier:@"seeAllView"];
    seeAllView.tag=(unsigned long)button.tag;
    seeAllView.eventId = _eventId;
    seeAllView.statistics=_statistics;
    [self.navigationController pushViewController:seeAllView animated:YES];
}

#pragma Mark Custom Methods ------------------

- (UIView *)createViewFor:(NSString *)viewType yOrigin:(float)yOrigin {
    
    UIView *view = [[UIScrollView alloc] init];
    view.frame = CGRectMake(30, yOrigin, 290, 49);
    view.tag = 8000;
    NSInteger scrollViewWidth = 0;
    NSArray *colors = [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor blackColor], [UIColor darkGrayColor], [UIColor darkGrayColor], [UIColor darkGrayColor], nil];
    
    for (int i = 0; i < colors.count; i++) {
        CGRect frame;
        if (i == 0) {
            frame.origin.x = 49 * i;
            scrollViewWidth = scrollViewWidth + 49;
        }
        else if (i == 4) {
            frame.origin.x = 53 * i;
            scrollViewWidth = scrollViewWidth + 49 + 4;
            frame.origin.y = 0;
            frame.size = view.frame.size;
            UIButton *seeAllButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            seeAllButton.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
            [seeAllButton setTitle:@"See All" forState:UIControlStateNormal];
            [seeAllButton setTitleColor:[UIColor colorWithRed:89/255.0 green:152/255.0 blue:205/255.0 alpha:1] forState:UIControlStateNormal];
            seeAllButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
            seeAllButton.frame = CGRectMake(frame.origin.x, 0, 49, frame.size.height);
            [seeAllButton addTarget:self action:@selector(seeAllButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            if ([viewType isEqualToString:@"H"]) {
                seeAllButton.tag = 1000;
            }
            else if ([viewType isEqualToString:@"G"]) {
                seeAllButton.tag = 2000;
            }
            else if ([viewType isEqualToString:@"I"]) {
                seeAllButton.tag = 3000;
            }
            [view addSubview:seeAllButton];
            
            continue;
        }
        else {
            frame.origin.x = 53 * i;
            scrollViewWidth = scrollViewWidth + 49 + 4;
        }
        frame.origin.y = 0;
        frame.size = view.frame.size;
        
        //        friendsPictureClicked:
        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        UIImageView *subView=[[UIImageView alloc]initWithFrame:CGRectMake(frame.origin.x, 0, 49, frame.size.height)];
        subView.image=[ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
        [view addSubview:subView];
        [_imageViewArray addObject:subView];
        
        
        UIButton *profileButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        profileButton.frame = CGRectMake(frame.origin.x, 0, 49, frame.size.height);
        [profileButton addTarget:self action:@selector(friendsPictureClicked:) forControlEvents:UIControlEventTouchUpInside];
        if ([viewType isEqualToString:@"H"]) {
            profileButton.tag = i;
            
            
        }
        
        [view addSubview:profileButton];
    }
    return view;
}


-(void) setViewImage:(NSString *)friendId forSubViewAtIndex:(NSInteger) index{
    
    
    if (friendId!= nil && ![friendId isEqual:[NSNull null]]) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,friendId ];
        UIImage* defaultImage = [UIImage imageNamed:@"defaultpic_small.png"];

        [[_imageViewArray objectAtIndex:index] sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:defaultImage];
    }
    
    
}
- (UILabel*)createLabelOfSize:(CGRect)frame text:(NSString *)text font:(UIFont *)font fontColor:(UIColor *)fColor alignment:(NSTextAlignment)alignment{
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    if (text.length > 0) {
        label.text = text;
    }
    label.textColor = fColor;
    label.font = font;
    label.textAlignment = alignment;
    label.numberOfLines = 0;
    return label;
}

- (UIImageView *)createImageViewOfSize:(CGRect)frame image:(UIImage*)image cornerRadius:(CGFloat)cornerRadius alpha:(CGFloat)alpha backgroundColor:(UIColor*)bColor{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.alpha = alpha;
    imageView.backgroundColor = bColor;
    imageView.layer.masksToBounds = YES;
    imageView.image = image;
    imageView.layer.cornerRadius = cornerRadius;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (CGFloat)heigthWithWidth:(CGFloat)width andFont:(UIFont *)font string:(NSString *)string
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [string length])];
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return rect.size.height;
}


#pragma Mark for Segue ------------------

- (IBAction)organiserNameClicked:(id)sender {
    
    
    
    MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
    
    
    myProfileView.friendData=self.hostData;
    myProfileView.isFromNavigation = TRUE;
    myProfileView.friendId=[myProfileView.friendData objectForKey:@"id"];
    if([myProfileView.friendId integerValue]==[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] integerValue]){
        myProfileView.isUser=YES;
        
    }
    else
    {
        myProfileView.isUser=NO;
        
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",myProfileView.friendId];
        
        NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
        
        if(retData.count>0)
            myProfileView.isFriend=YES;
        else
            myProfileView.isFriend=NO;
    }
    NSLog(@"hostData .... %@",myProfileView.friendData);
    //        self.navigationItem.title=@"";
    myProfileView.fromWhereCalled=@"ED";
    myProfileView.eventId=_eventId;
    myProfileView.statistics=_statistics;
    myProfileView.hostId=[_hostData objectForKey:@"id"];
    myProfileView.hostName= [_hostData objectForKey:@"fullName"];
    
    [self.navigationController pushViewController:myProfileView  animated:YES];
    
}

- (IBAction)joinButtonClicked:(id)sender {
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/event/%@/accept",kwebUrl,uid,_eventId];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"SELF",@"channel",
                                nil];
    
    [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         self.view.userInteractionEnabled = YES;
         
         if (success) {
             
             [CoreDataInterface saveEventList:[NSArray arrayWithObjects:jsonDict, nil]];
             NSMutableDictionary *eventInfo = [_thisEvent mutableCopy];
             
             NSMutableDictionary *statistics= [[eventInfo objectForKey:@"statistics"] mutableCopy];
             NSInteger goingThereCount = [[statistics objectForKey:@"acceptedCount"] integerValue]+1;
             
             [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"acceptedCount"];
             
             [eventInfo setObject:statistics forKey:@"statistics"];
             [eventInfo setObject:@"A" forKey:@"guestStatus"];
             
             [CoreDataInterface saveEventList:[NSArray arrayWithObjects:eventInfo, nil]];
             
             [CoreDataInterface saveAll];
             
             EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
             eventDetailsView.eventId = [eventInfo objectForKey:@"id"];
             eventDetailsView.statistics=[eventInfo objectForKey:@"statistics"];
             eventDetailsView.hostName= [[eventInfo objectForKey:@"user"]objectForKey:@"fullName"];
             
             eventDetailsView.hostId=[[eventInfo objectForKey:@"user"] objectForKey:@"id"];
             eventDetailsView.hostData=[eventInfo objectForKey:@"user"];
             eventDetailsView.eventStatus = @"A";

             NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
             NSMutableArray *newArray = [[NSMutableArray alloc] init];
             
             for (int i = 0; i < navigationViewsArray.count ; i++) {
                 UIViewController *viewController = [navigationViewsArray objectAtIndex:i];
                 [newArray addObject:viewController];
                 
                 if ([viewController isKindOfClass:[WhoThereViewController class]]) {
                     NSLog(@"yes");
                     break;
                 }
             }
             [newArray addObject:eventDetailsView];
             [self.navigationController setViewControllers:newArray animated:YES];
         }
     }];
}


-(void)getGuestList{
    [_activityIndicator startAnimating];
    
    NSDictionary *postDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"0",@"pageIndex",
                                    @"4",@"pageSize",
                                    @"All",@"status"
                                    , nil];
    NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/getGuests",kwebUrl,_eventId];
    [UtilitiesHelper getResponseFor:postDictionary url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         if (success) {
             
             [self getAllProileUrl:jsonDict];
             //[_listOfSeeAll addObjectsFromArray:_listOfNewConnections];
             // [_seeAllTableView reloadData];
         }
     }];
}

-(void)getAllProileUrl:(NSDictionary *)jsonDict{
    NSInteger invitedCount=[[[jsonDict objectForKey:@"Invited"] mutableCopy] count];
    NSInteger acceptedCount=[[[jsonDict objectForKey:@"Accepted"] mutableCopy] count];
    NSInteger hooThereCount=[[[jsonDict objectForKey:@"Hoothere"] mutableCopy] count];
    _acceptedFriends=[[NSMutableArray alloc]init];
    _invitedFriends=[[NSMutableArray alloc]init];
    _hooThereFriends=[[NSMutableArray alloc]init];
    
    for(int i=0;i<acceptedCount;i++)
    {
        [_invitedFriends addObject:[[[[jsonDict objectForKey:@"Accepted"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"id" ]];
        NSString *profilePicture = [[[[jsonDict objectForKey:@"Accepted"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"profile_picture" ];
        if (profilePicture != nil && ![profilePicture isEqual:[NSNull null]]) {
            [self setViewImage:[_invitedFriends objectAtIndex:i] forSubViewAtIndex:i+4];
        }
    }
    
    for(int i=0;i<invitedCount;i++)
    {
        [_acceptedFriends addObject:[[[[jsonDict objectForKey:@"Invited"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"id" ]];
        NSString *profilePicture = [[[[jsonDict objectForKey:@"Invited"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"profile_picture" ];
        if (profilePicture != nil && ![profilePicture isEqual:[NSNull null]]) {
            [self setViewImage:[_acceptedFriends objectAtIndex:i] forSubViewAtIndex:i+8];
        }
        
    }
    
    for(int i=0;i<hooThereCount;i++)
    {
        [_hooThereFriends addObject:[[[[jsonDict objectForKey:@"Hoothere"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"id" ]];
        NSString *profilePicture = [[[[jsonDict objectForKey:@"Hoothere"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"profile_picture" ];
        if (profilePicture != nil && ![profilePicture isEqual:[NSNull null]]) {
            [self setViewImage:[_hooThereFriends objectAtIndex:i] forSubViewAtIndex:i];
        }
    }
}

@end
