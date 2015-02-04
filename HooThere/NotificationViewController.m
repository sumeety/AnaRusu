//
//  NotificationViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 18/11/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationHelper.h"
#import "CustomTableViewCell.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "ResizeImage.h"
#import "EventDetailsViewController.h"
#import "UIImageView+WebCache.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

@synthesize loadMoreCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications) name:@"kNotificationButtonClicked" object:nil];
    // Do any additional setup after loading the view.
    notificationView.layer.cornerRadius = 5;
    notificationView.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateNotifications];
    [_activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateNotifications {
    notificationTableView.hidden = YES;
    _listOfNotifications = [[NSMutableArray alloc] init];
    _pageCount=0;
//    _loadMore=YES;
    [self fetchListOfNotifications:@"0"];
}
- (void)fetchListOfNotifications:(NSString *)offset {
    [NotificationHelper getListOfNotifications:offset all:TRUE complettionBlock:^(BOOL success, NSMutableArray *notifications){
        [_activityIndicator stopAnimating];
        if (success) {
           [_listOfNotifications addObjectsFromArray:notifications];
            //[[NSMutableArray alloc] initWithArray:notifications];
            if (notifications.count == 20) {
                _loadMore = TRUE;
            }
            else {
                _loadMore = FALSE;
            }
            [notificationTableView reloadData];
            notificationTableView.hidden = NO;
            [[[[[self tabBarController] tabBar] items] objectAtIndex:2] setBadgeValue:nil];

        }
    }];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_loadMore) {
        return 2;
    }
    else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 1) {
        return 1;
    }
    else {
        return [_listOfNotifications count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell;
    
    if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"loadMoreCell";
        cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell.activityIndicator startAnimating];
    }
    else {
        NSDictionary *dictInfo = [_listOfNotifications objectAtIndex:indexPath.row];

        NSString *notificationType = [dictInfo objectForKey:@"type"];
        if ([notificationType isEqualToString:@"FRA"]) {
            static NSString *cellIdentifier = @"acceptFriendRequestCell";
            cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.sendFriendRequestButton.hidden = NO;
            cell.rejectFriendRequestButton.hidden = NO;
            cell.rejectFriendRequestButton.tag = indexPath.row;
            cell.sendFriendRequestButton.tag = indexPath.row;
            
            [cell.rejectFriendRequestButton addTarget:self action:@selector(rejectFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
            [cell.sendFriendRequestButton addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
            
            id imageName = [dictInfo objectForKey:@"profile_picture"];
            
            UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
            image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
            cell.leftImageView.image= image;
            
            if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
                NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,[dictInfo objectForKey:@"userId"]];
//                [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
//                 {
//                     if (success) {
//                         cell.leftImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
//                     }
//                 }];
                [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image];

            }
            
        }
        else if ([notificationType isEqualToString:@"EI"]) {
            static NSString *cellIdentifier = @"invitedCell";
            cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.sendFriendRequestButton.hidden = NO;
            cell.sendFriendRequestButton.tag = indexPath.row;
            
            [cell.sendFriendRequestButton addTarget:self action:@selector(acceptEventRequest:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            static NSString *cellIdentifier = @"statusCell";
            cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            id imageName = [[dictInfo objectForKey:@"sender"] objectForKey:@"profile_picture"];
            
            UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
            image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
            cell.leftImageView.image= image;
            
            if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
                NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,[[dictInfo objectForKey:@"sender"] objectForKey:@"id"]];
//                [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
//                 {
//                     if (success) {
//                         cell.leftImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
//                     }
//                 }];
                [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image];
            }
        }
        cell.titleLabel.text = [dictInfo objectForKey:@"message"];
        
        BOOL isRead = [[dictInfo objectForKey:@"isRead"] boolValue];
        
        if (!isRead) {
            cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        }
        else
        {
            cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        return;
    }
    
    NSMutableDictionary *dictInfo = [[_listOfNotifications objectAtIndex:indexPath.row] mutableCopy];
    
    [self markNotificationAsRead:dictInfo];
    
    NSString *type = [dictInfo objectForKey:@"type"];
    
    [dictInfo setObject:@"1" forKey:@"isRead"];
    [_listOfNotifications replaceObjectAtIndex:indexPath.row withObject:dictInfo];
    [notificationTableView reloadData];

    if ([type isEqualToString:@"FRA"] || [type isEqualToString:@"FRF"] || [type isEqualToString:@"EHT"] || [type isEqualToString:@"HFR"]) {
        
        MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
        
        myProfileView.friendId=[[dictInfo objectForKey:@"sender"] objectForKey:@"id"];
        myProfileView.title = @"User Profile";
        myProfileView.isFromNavigation = TRUE;
        if ([type isEqualToString:@"FRA"]) {
            myProfileView.frienshipStatus = @"A";
        }
        else if ([type isEqualToString:@"FRF"]) {
            myProfileView.frienshipStatus = @"F";
        }
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
        myProfileView.fromWhereCalled=@"NOTI";
        [self.navigationController pushViewController:myProfileView  animated:YES];

    }
    else {
        
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",[dictInfo objectForKey:@"eventId"]];
        
        NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
        
        if (retData.count > 0) {
            Events *eventInfo = [retData objectAtIndex:0];
            EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
            eventDetailsView.eventId = [dictInfo objectForKey:@"eventId"];
            eventDetailsView.statistics=[UtilitiesHelper stringToDictionary:[eventInfo statistics]];
            eventDetailsView.title = @"Event Details";
            eventDetailsView.hostName=[[UtilitiesHelper stringToDictionary:[eventInfo user]] objectForKey:@"firstName"];
            eventDetailsView.hostId=[[UtilitiesHelper stringToDictionary:[eventInfo user]] objectForKey:@"id"];
            eventDetailsView.hostData=[UtilitiesHelper stringToDictionary:[eventInfo user]];
            [self.navigationController pushViewController:eventDetailsView animated:YES];
        }
        
    }
}

- (void)markNotificationAsRead:(NSMutableDictionary *)dictInfo {
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/read/%@",kwebUrl,userId,[dictInfo objectForKey:@"id"]];
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         if (success) {
             NSLog(@"Json : %@",jsonDict);
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateNotificationNumber" object:nil];
     }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self fetchNumberOfNotifcations];
    
    if (indexPath.section == 1) {
        NSLog(@"indexPath.row %li... %lu....%@",(long)indexPath.row,(unsigned long)_listOfNotifications.count ,(_loadMore)?@"YES":@"NO");
        
//        if(indexPath.row == (_listOfNotifications.count - 1) ) {
//            
//            
//            NSLog(@"pagecount %i... %i..",_pageCount*10,_notificationCount );
//            _pageCount++;
//            if(_pageCount*10<_notificationCount)
//                
//                [self loadMoreNotifications];
//        }
        
        if (indexPath.row==0){//if it is the first row
            CustomTableViewCell *cell = (CustomTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
            [cell.activityIndicator startAnimating];//start animating the activity indicator view
            NSLog(@"pagecount %li... %li..",_pageCount*10,(long)_notificationCount );
            _pageCount++;
//            if(_pageCount*10<_notificationCount)
                [self loadMoreNotifications];
            return;
        }
    }
}

- (void)loadMoreNotifications {
    //NSInteger numberOfPage =_notificationCount/10;
    NSLog(@"number of Pages %li",(long)_pageCount);
    NSLog(@"%lu....%@",(long)_listOfNotifications.count ,(_loadMore)?@"YES":@"NO");
    [self fetchListOfNotifications:[NSString stringWithFormat:@"%ld",(long)_pageCount]];
}


- (void)fetchNumberOfNotifcations {
    [NotificationHelper getCountOfNotificationsWithComplettionBlock:^(BOOL success, NSString *notificationCount){
        if (success) {
            _notificationCount=[notificationCount integerValue];
            NSLog(@"notificationCount");
        }
    }];
    
}


# pragma mark Request Methods --------------

- (void)acceptEventRequest:(UIButton * )acceptEventButton {
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSMutableDictionary *eventInfo = [[_listOfNotifications objectAtIndex:acceptEventButton.tag] mutableCopy];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/event/%@/accept",kwebUrl,userId,[eventInfo objectForKey:@"eventId"]];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"INVITED",@"channel",
                                nil];
    [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         if (success) {
             [eventInfo setObject:@"1" forKey:@"isRead"];
             [_listOfNotifications removeObjectAtIndex:acceptEventButton.tag];
             [notificationTableView reloadData];
             
             NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(eventid == %@)",[eventInfo objectForKey:@"eventId"]];
             
             NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Events" andPredicate:entitySearchPredicate andSortkey:@"eventid" isSortAscending:YES];
             
             if (retData.count > 0) {
                 Events *coreEventInfo = [retData objectAtIndex:0];
                 NSMutableDictionary *statistics= [[UtilitiesHelper stringToDictionary:[coreEventInfo statistics]] mutableCopy];
                 NSInteger goingThereCount = [[statistics objectForKey:@"acceptedCount"] integerValue]+1;
                 
                 [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"acceptedCount"];
                 coreEventInfo.statistics = [NSString stringWithFormat:@"%@",statistics];
                 [CoreDataInterface saveAll];
             }
         }
     }];
}


-(void)acceptFriendRequest:(UIButton * )sendFriendButton {
//    [_activityIndicator startAnimating];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSMutableDictionary *userInfo = [[_listOfNotifications objectAtIndex:sendFriendButton.tag] mutableCopy];
    NSString *toUserID = [[userInfo objectForKey:@"sender"] objectForKey:@"id"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/accept/%@",kwebUrl,userId,toUserID ];
    
    NSLog(@"accepting Request to %@",urlString);
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
//         [_activityIndicator stopAnimating];
         
         if (success) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"This user is added to your friend list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
             NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",toUserID];
             
             NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
             
             if (retData.count > 0) {
                 Friends *friendInfo = [retData objectAtIndex:0];
                 friendInfo.status = @"F";
                 [CoreDataInterface saveAll];
             }
             [_listOfNotifications removeObjectAtIndex:sendFriendButton.tag];
             [notificationTableView reloadData];
         }
     }];
}

-(void)rejectFriendRequest:(UIButton * )rejectFriendButton {
//    [_activityIndicator startAnimating];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSMutableDictionary *userInfo = [[_listOfNotifications objectAtIndex:rejectFriendButton.tag] mutableCopy];
    NSString *toUserID = [[userInfo objectForKey:@"sender"] objectForKey:@"id"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/reject/%@",kwebUrl,userId,toUserID ];
    
    NSLog(@"Rejecting Request to %@",urlString);
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
//         [_activityIndicator stopAnimating];
         
         if (success) {
             NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",toUserID];
             
             NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
             if ([retData count] > 0)
             {
                 [CoreDataInterface deleteThisFriend:[retData objectAtIndex:0]];
             }
             [_listOfNotifications removeObjectAtIndex:rejectFriendButton.tag];
             [notificationTableView reloadData];
         }
     }];
}

@end
