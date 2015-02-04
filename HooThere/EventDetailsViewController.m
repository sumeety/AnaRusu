 //
//  EventDetailsViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 10/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "EventDetailsViewController.h"
#import "EditEventViewController.h"
#import "EventHelper.h"
#import "ResizeImage.h"
#import "HomeViewController.h"
#import <MapKit/MapKit.h>
#import "UIImageView+WebCache.h"
#import "WhoThereViewController.h"

@interface EventDetailsViewController ()

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imageViewArray=[[NSMutableArray alloc]init];
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    hostImageView.layer.masksToBounds = YES;
    hostImageView.layer.cornerRadius = 20;
    
    NSLog(@"View did Load %@",self.hostName);
    if(self.hostName.length>0)
    {
        hostNameLabel.text = self.hostName;
        [self getEventDetails];}
    else
   {
       [self getEventDetailsFromApi];
       
    }
    acceptButton.layer.cornerRadius=3;
    inviteFriendsButton.layer.cornerRadius=3;
    
    [self getGuestList];
        if([self checkHostAndUserRelation])
            
        {  UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editButtonClicked)];
            self.navigationItem.rightBarButtonItem = editButton;
            
            
//            acceptButton.titleLabel.textColor=[UIColor redColor];
//            
////acceptButton.titleLabel.text=@"Cancel";
//            
//            [acceptButton setTitle:@"Check-In" forState:UIControlStateNormal];
//            [acceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            acceptButton.layer.backgroundColor=[UIColor whiteColor].CGColor;
//            acceptButton.layer.borderColor=[UIColor purpleColor].CGColor;
//            acceptButton.layer.borderWidth=1.0f;
            
            [self changeAcceptToCancelButton];
           
            
        }
    else
    {NSLog(@"hostId%@myid%@",self.hostId,[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]);
    self.navigationItem.rightBarButtonItem=nil;
        
        NSLog(@"_eventStatus %@",_eventStatus);
        if( ![_thisEvent.guestStatus isEqualToString:@"I"])
        {  acceptButton.titleLabel.textColor=[UIColor redColor];
            
            //acceptButton.titleLabel.text=@"Cancel";
            
//            [acceptButton setTitle:@"Check-In" forState:UIControlStateNormal];
//            [acceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            acceptButton.layer.backgroundColor=[UIColor whiteColor].CGColor;
//            acceptButton.layer.borderColor=[UIColor purpleColor].CGColor;
//            acceptButton.layer.borderWidth=1.0f;
            [self changeAcceptToCancelButton];
        
        }
        else{
           
            
            //acceptButton.titleLabel.text=@"Cancel";
            
            [acceptButton setTitle:@"Accept" forState:UIControlStateNormal];
            [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            acceptButton.layer.backgroundColor=[[UIColor alloc] initWithRed:0.255f green:0.815f blue:0.43f alpha:1.0f] .CGColor;
            //acceptButton.layer.borderColor=[UIColor purpleColor].CGColor;
            acceptButton.layer.borderWidth=0.0f;
        
        }
        
    }
    
    if (_isJoinButtonEnable) {
        joinButton.hidden = NO;
    } else {
        joinButton.hidden = YES;
    }

    hostImageView.image=[UIImage imageNamed:@"defaultpic_small.png"];
    [self getHostImage];
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

-(void) getEventDetailsFromApi{
    //NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/event/%@",kwebUrl,_eventId];
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [self.activityIndicator stopAnimating];
         if (success) {
             //TODO : add key according to response
             
             //[CoreDataInterface saveEventList:[NSArray ]jsonDict];
             _statistics=[jsonDict objectForKey:@"statistics"];
             _hostId=[[jsonDict objectForKey:@"user"] objectForKey:@"id"];
             _hostName=[[jsonDict objectForKey:@"user"] objectForKey:@"firstName"];
             hostNameLabel.text = self.hostName;

                          [self getEventDetails];
             
             [self.activityIndicator stopAnimating];
             ;
             //             GeofenceMonitor  * gfm = [GeofenceMonitor sharedObj];
             
         }
     }];

}
-(BOOL) checkHostAndUserRelation{
    
  
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSInteger userInt=[userId integerValue];
    NSInteger hostInt=[self.hostId integerValue];
    if(userInt==hostInt )
        return YES;
    else
        return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = NO;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editButtonClicked {
    EditEventViewController *editEventView = [self.storyboard instantiateViewControllerWithIdentifier:@"editEventView"];
    editEventView.thisEvent = _thisEvent;
    
    [self.navigationController pushViewController:editEventView animated:YES];
}

- (void)getEventDetails {
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",_eventId];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
    
    if (retData.count > 0) {
        _thisEvent = [retData objectAtIndex:0];
        eventNameLabel.text = _thisEvent.name;
        [self createCustomViewForEventDetails];
    }
}

- (void)createCustomViewForEventDetails {
    
    float yOrigin = 90;//176;
    //Creating Description label.......
    if (_thisEvent.eventDescription.length > 0) {
        CGFloat descriptionLabelHeight = [self heigthWithWidth:290 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] string:_thisEvent.eventDescription];
        [_scrollView addSubview:[self createLabelOfSize:CGRectMake(15, yOrigin, 290, descriptionLabelHeight) text:_thisEvent.eventDescription font:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
        
        yOrigin = yOrigin + descriptionLabelHeight + 15;
    }
    
    if (_thisEvent.address.length > 0) {
        [self createAddressLabelWithButton:yOrigin];
        CGFloat locationLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] string:_thisEvent.address];
        
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

    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, yOrigin);
}

- (void)createAddressLabelWithButton:(float)yOrigin {
    
    if (!_thisEvent.address.length > 0) {
        return;
    }
    //Creating Location Button
    CGFloat locationLabelHeight = [self heigthWithWidth:240 andFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] string:[NSString stringWithFormat:@"%@\n%@",_thisEvent.venueName,_thisEvent.address]];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    locationButton.frame = CGRectMake(15, yOrigin, 290, locationLabelHeight);
    [locationButton addTarget:self action:@selector(locationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:locationButton];
    //Creating Location Imageview.......
    
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+3, 10, 10) image:[UIImage imageNamed:@"location.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    //Creating Location label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, locationLabelHeight) text:[NSString stringWithFormat:@"%@\n%@",_thisEvent.venueName,_thisEvent.address] font:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] fontColor:[UIColor colorWithRed:89/255.0 green:152/255.0 blue:205/255.0 alpha:1] alignment:NSTextAlignmentLeft]];
}

- (void)createTimeView:(float)yOrigin {
    //Creating Time Imageview
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+5, 10, 10) image:[UIImage imageNamed:@"time.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[_thisEvent.startDateTime doubleValue]/1000.0                          ];
    
    //Creating Time label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 20) text:(_thisEvent.startDateTime.integerValue!=0)?[NSString stringWithFormat:@"%@ at %@",[EventHelper changeDateFormat:startDate],[EventHelper changeTimeFormat:startDate]]:@" " font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
}


- (void)createEndTimeView:(float)yOrigin {
    //Creating Time Imageview
    [_scrollView addSubview:[self createImageViewOfSize:CGRectMake(15, yOrigin+5, 10, 10) image:[UIImage imageNamed:@"time.png"] cornerRadius:0 alpha:1 backgroundColor:[UIColor clearColor]]];
    
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[_thisEvent.endDateTime doubleValue]/1000.0                          ];
    
    //Creating Time label.......
    [_scrollView addSubview:[self createLabelOfSize:CGRectMake(30, yOrigin, 240, 20) text:(_thisEvent.endDateTime.integerValue!=0)?[NSString stringWithFormat:@"%@ at %@",[EventHelper changeDateFormat:endDate],[EventHelper changeTimeFormat:endDate]]:@" " font:[UIFont fontWithName:@"HelveticaNeue-Light" size:12] fontColor:[UIColor grayColor] alignment:NSTextAlignmentLeft]];
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
    CLLocationDegrees latitude = [[_thisEvent latitude] doubleValue];
    CLLocationDegrees longitude =[[_thisEvent longitude] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:centerCoordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = _thisEvent.venueName;
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


-(void) setViewImage:(NSString *)friendId forSubViewAtIndex:(NSInteger) index image:(NSString *)imageName {
    UIImage* defaultImage = [UIImage imageNamed:@"defaultpic_small.png"];
    if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
        if (friendId!= nil && ![friendId isEqual:[NSNull null]]) {
            NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,friendId ];
            
            [[_imageViewArray objectAtIndex:index] sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:defaultImage];
        }
    }
    else {
        [[_imageViewArray objectAtIndex:index] setImage:defaultImage];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    InviteFriendsViewController *inviteFriendsViewController=segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"eventDetailSegue"])
    {
        
        inviteFriendsViewController.thisEvent = _thisEvent;
        inviteFriendsViewController.hostId=_hostId;
        inviteFriendsViewController.hostData=_hostData;
        inviteFriendsViewController.fromWhereCalled = 1;
        
    }
    
}

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
    myProfileView.hostId=_hostId;
    myProfileView.hostName=_hostName;
    
        [self.navigationController pushViewController:myProfileView  animated:YES];
         
}

- (IBAction)acceptButtonClicked:(id)sender {
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/event/%@/accept",kwebUrl,uid,_eventId];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"INVITED",@"channel",
                                nil];
    if(![self checkHostAndUserRelation]){
        NSString *invitedStatus = _thisEvent.guestStatus;
        NSLog(@"invited status ******* %@",invitedStatus);
        if ([invitedStatus isEqualToString:@"I"]) {
            [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
             {
                 
                 if (success) {
                     [self changeAcceptToCancelButton];
                     NSInteger count=[[self.statistics objectForKey:@"acceptedCount"] integerValue]+1;
                     
                     [_goingStatsLabel setText:[NSString stringWithFormat:@"%li Going There" ,(long)count]];
                     // _goingStatsLabel.text=[NSString stringWithFormat:@"%i " ,count];
                     NSMutableDictionary *statistics= [self.statistics mutableCopy];
                     NSInteger goingThereCount = [[statistics objectForKey:@"acceptedCount"] integerValue]+1;
                     
                     [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"acceptedCount"];
                     _thisEvent.statistics = [NSString stringWithFormat:@"%@",statistics];
                     _thisEvent.guestStatus = @"A";
                     [CoreDataInterface saveAll];
//                     [self getGuestList];

                     [self updateEventDetails];
                 }
             }];
        }
        else {
            [self checkInButtonclicked];
        }
    }
    else
    {
        [self checkInButtonclicked];
    }
}

- (IBAction)joinButtonClicked:(id)sender {
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    //NSString * eventId = [NSString stringWithFormat:@"%ld",(long)button.tag];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/event/%@/accept",kwebUrl,uid,_eventId];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"SELF",@"channel",
                                nil];
    
    [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         
         if (success) {
             
             [_activityIndicator stopAnimating];
             self.view.userInteractionEnabled = YES;
             
             //[self getUpcomingEvents];
             _isJoinButtonEnable = NO;
             
             [self viewDidLoad];
             [self viewWillAppear:YES];
             
         }
     }];
}

- (void)updateEventDetails {
    EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
    eventDetailsView.eventId = _thisEvent.eventid;
    eventDetailsView.statistics=[UtilitiesHelper stringToDictionary:[_thisEvent statistics]];
    eventDetailsView.hostName=[[UtilitiesHelper stringToDictionary:[_thisEvent user]] objectForKey:@"firstName"];
    
    eventDetailsView.hostId=[[UtilitiesHelper stringToDictionary:[_thisEvent user]] objectForKey:@"id"];
    eventDetailsView.eventStatus=_thisEvent.guestStatus;
    eventDetailsView.hostData=[UtilitiesHelper stringToDictionary:[_thisEvent user]];
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
    [self.navigationController setViewControllers:newArray animated:NO];
}

- (BOOL)checkEventIsStartedOrNot:(double)startDateTime {
    BOOL isEventStart = FALSE;
    NSDate *date  = [NSDate date];
    double today = [date timeIntervalSince1970] * 1000;
    if (today > startDateTime) {
        isEventStart = TRUE;
    }
    return isEventStart;
}

-(void) changeAcceptToCancelButton{
    [acceptButton setTitle:@"Check-In" forState:UIControlStateNormal];
    [acceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    acceptButton.layer.backgroundColor=[UIColor whiteColor].CGColor;
    acceptButton.layer.borderWidth=1.0f;
    
    double startDateTime = [_thisEvent.startDateTime doubleValue];
    BOOL isEventStart = [self checkEventIsStartedOrNot:startDateTime];
    if (!isEventStart) {
        acceptButton.alpha = 1;
        acceptButton.enabled = YES;
        acceptButton.layer.borderColor=[UIColor grayColor].CGColor;
    }
    else {
        acceptButton.alpha = 1;
        acceptButton.enabled = YES;
        acceptButton.layer.borderColor=[UIColor purpleColor].CGColor;
    }
    
    if ([_thisEvent.guestStatus isEqualToString:@"HT"]) {
        [acceptButton setTitle:@"Checked-In" forState:UIControlStateNormal];
        acceptButton.alpha = 0.5;
        acceptButton.enabled = NO;
        acceptButton.layer.borderColor=[UIColor grayColor].CGColor;
    }
}

- (void)checkInButtonclicked {
    double startDateTime = [_thisEvent.startDateTime doubleValue];
    BOOL isEventStart = [self checkEventIsStartedOrNot:startDateTime];
    if (!isEventStart) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Check-In not allowed" message:@"This event is not started yet." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [_activityIndicator startAnimating];
//    [self.navigationController popViewControllerAnimated:YES];
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/checkin",kwebUrl,_thisEvent.eventid];
    
    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              uid ,@"id",
                              @"MANUAL",@"checkInType",
                              nil];

    [UtilitiesHelper getResponseFor:postDict url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         if (success) {
             NSMutableDictionary *statistics= [[UtilitiesHelper stringToDictionary:[_thisEvent statistics]] mutableCopy];
             NSInteger goingThereCount = [[statistics objectForKey:@"acceptedCount"] integerValue];
             NSInteger hooThereCount = [[statistics objectForKey:@"hoothereCount"] integerValue];
             if ([_thisEvent.guestStatus isEqualToString:@"A"]) {
                 goingThereCount = goingThereCount - 1;
             }

             hooThereCount = hooThereCount + 1;
             
             [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"acceptedCount"];
             [statistics setObject:[NSString stringWithFormat:@"%ld",(long)hooThereCount] forKey:@"hoothereCount"];

             _thisEvent.statistics = [NSString stringWithFormat:@"%@",statistics];
             _thisEvent.guestStatus = @"HT";
             
             NSString *message = [NSString stringWithFormat:@"You have successfully checked into %@",_thisEvent.name];
             
             [acceptButton setTitle:@"Checked-In" forState:UIControlStateNormal];
             acceptButton.alpha = 0.5;
             acceptButton.enabled = NO;
             acceptButton.layer.borderColor=[UIColor grayColor].CGColor;
             
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alertView show];
             
             [self updateEventDetails];
         }
         [CoreDataInterface saveAll];
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
        [self setViewImage:[_invitedFriends objectAtIndex:i] forSubViewAtIndex:i+4 image:profilePicture];
    }
    
    for(int i=0;i<invitedCount;i++)
    {
        [_acceptedFriends addObject:[[[[jsonDict objectForKey:@"Invited"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"id" ]];
        NSString *profilePicture = [[[[jsonDict objectForKey:@"Invited"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"profile_picture" ];
        [self setViewImage:[_acceptedFriends objectAtIndex:i] forSubViewAtIndex:i+8 image:profilePicture];
    }

    for(int i=0;i<hooThereCount;i++)
    {
        [_hooThereFriends addObject:[[[[jsonDict objectForKey:@"Hoothere"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"id" ]];
        NSString *profilePicture = [[[[jsonDict objectForKey:@"Hoothere"] objectAtIndex:i ] objectForKey:@"user"]objectForKey:@"profile_picture" ];
        [self setViewImage:[_hooThereFriends objectAtIndex:i] forSubViewAtIndex:i image:profilePicture];
    }
    
}

@end
