//
//  SearchEventsViewController.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 05/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import "SearchEventsViewController.h"
#import "CoreDataInterface.h"
#import "UtilitiesHelper.h"
#import "CustomTableViewCell.h"
#import "SeeAllViewController.h"
#import <MapKit/MapKit.h>
#import "EventDetailsViewController.h"
#import "SearchEventDetailsViewController.h"
#import "HooThereNavigationController.h"
#import "HomeViewController.h"
#import "MyProfileViewController.h"
#import "EventHelper.h"

@interface SearchEventsViewController ()

@end

@implementation SearchEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [searchBarField becomeFirstResponder];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_noEvents) {
        return 1;
    }
    else {
        return [_listOfEvents count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell;
    static NSString *cellIdentifier;
    if (_noEvents) {
        cellIdentifier = @"noEventsCell";
        cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    else {
        cellIdentifier = @"hooThereCell";
        cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        NSDictionary *eventInfo = [_listOfEvents objectAtIndex:indexPath.row];
        cell.eventNameLabel.text = [eventInfo objectForKey:@"name"];
        cell.eventHostNameLabel.text = [[eventInfo objectForKey:@"user"] objectForKey:@"fullName"];
        cell.hootHereButton.tag = indexPath.row;
        cell.invitedButton.tag = indexPath.row;
        cell.goingThereButton.tag = indexPath.row;
        cell.placeButton.tag = indexPath.row;
        cell.orgainserNameButton.tag = indexPath.row;
        cell.eventPlaceLabel.text = [eventInfo objectForKey:@"venueName"];
        
        NSDictionary *statistics = [eventInfo objectForKey:@"statistics"];
        
        cell.invitedLabel.text=[NSString stringWithFormat:@"%@ Invited", [statistics objectForKey:@"invitedCount"]];
        
        cell.goingLabel.text=[NSString stringWithFormat:@"%@ Going There",[statistics objectForKey:@"acceptedCount"]];
        cell.hoothereLabel.text=[NSString stringWithFormat:@"%@ Hoo There",[statistics objectForKey:@"hoothereCount"]];
        NSDate *startDateTime;
        if ([eventInfo objectForKey:@"startDateTime"] != nil && ![[eventInfo objectForKey:@"startDateTime"] isEqual:[NSNull null]]) {
            startDateTime = [NSDate dateWithTimeIntervalSince1970:[[eventInfo objectForKey:@"startDateTime"] doubleValue]/1000.0];
            cell.eventDateLabel.text = ([[eventInfo objectForKey:@"startDateTime"] integerValue]!=0)?[NSString stringWithFormat:@"%@ at %@ ",[EventHelper changeDateFormat:startDateTime],[EventHelper changeTimeFormat:startDateTime ]]:@"Date not specified";
        }
        else {
            cell.eventDateLabel.text = @"Date not specified";
        }
        
        cell.statusLabel.hidden = YES;
        cell.inviteForEventButton.hidden = YES;
        cell.inviteForEventButton.tag = indexPath.row;

        NSString *guestStatus = [eventInfo objectForKey:@"guestStatus"];
        
        if ([guestStatus isEqual:[NSNull null]] || guestStatus == nil || [guestStatus isEqualToString:@""]) {
            cell.inviteForEventButton.hidden = NO;
        }
        else if ([guestStatus isEqualToString:@"I"]) {
            cell.statusLabel.hidden = NO;
            cell.statusLabel.text = @"Invited";
//            cell.statusImage.hidden=NO;
//            cell.statusImage.image=[UIImage imageNamed:@"invited_blue.png"];
        }
        else if ([guestStatus isEqualToString:@"A"]) {
            cell.statusLabel.hidden = NO;
            cell.statusLabel.text = @"Going There";
//            cell.statusImage.hidden=NO;
//            cell.statusImage.image=[UIImage imageNamed:@"going_there_bluenew.png"];
        }
        else if([guestStatus isEqualToString:@"HT"]) {
            cell.statusLabel.hidden = NO;
            cell.statusLabel.text = @"Hoo There";
//            cell.statusImage.hidden=NO;
//            cell.statusImage.image=[UIImage imageNamed:@"hoothere_bluenew.png"];
        }
        else{
            
        }
        
        if ([eventInfo objectForKey:@"endDateTime"] != nil && ![[eventInfo objectForKey:@"endDateTime"] isEqual:[NSNull null]]) {
            
            double endDateTime = [[eventInfo objectForKey:@"endDateTime"] doubleValue];
            BOOL isPastEvent = [self checkEventIsPastEvent:endDateTime];
            if (isPastEvent) {
//                [cell.statusImage setImage:[UIImage imageNamed:@"frnd_reject_blue_new.png"]];
                cell.statusLabel.hidden = NO;
                cell.statusLabel.text = @"Past Event";
                cell.inviteForEventButton.hidden = YES;
            }
        }
    }
    return cell;
}

- (BOOL)checkEventIsPastEvent:(double)endDateTime {
    BOOL isPastEvent = FALSE;
    NSDate *date  = [NSDate date];
    double today = [date timeIntervalSince1970] * 1000;
    if (endDateTime < 0) {
        endDateTime = endDateTime * (-1);
    }
    if (today > endDateTime) {
        isPastEvent = TRUE;
    }
    return isPastEvent;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_noEvents) {
        return;
    }
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:indexPath.row];
    BOOL isPastEvent = FALSE;
    if ([eventInfo objectForKey:@"endDateTime"] != nil && ![[eventInfo objectForKey:@"endDateTime"] isEqual:[NSNull null]]) {
        isPastEvent = [self checkEventIsPastEvent:[[eventInfo objectForKey:@"endDateTime"] doubleValue]];
    }
    
    NSString *guestStatus = [eventInfo objectForKey:@"guestStatus"];
    if ([guestStatus isEqual:[NSNull null]] || guestStatus == nil || [guestStatus isEqualToString:@""] || isPastEvent) {
        
        SearchEventDetailsViewController *searchEventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"searchEventDetailsView"];
        searchEventDetailsView.title = @"Event Details";
        searchEventDetailsView.thisEvent = eventInfo;
        searchEventDetailsView.isPastEvent = isPastEvent;

        [self.navigationController pushViewController:searchEventDetailsView animated:YES];
        return;
    }
    
    EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
    eventDetailsView.eventId = [eventInfo objectForKey:@"id"];
    eventDetailsView.statistics = [eventInfo objectForKey:@"statistics"];
    eventDetailsView.hostName=[[eventInfo objectForKey:@"user"] objectForKey:@"fullName"];
    eventDetailsView.hostId= [[eventInfo objectForKey:@"user"] objectForKey:@"id"];
    eventDetailsView.eventStatus=guestStatus;
    eventDetailsView.hostData=[eventInfo objectForKey:@"user"];

//    NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
//    NSMutableArray *newArray = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < navigationViewsArray.count ; i++) {
//        UIViewController *viewController = [navigationViewsArray objectAtIndex:i];
//        [newArray addObject:viewController];
//        
//        if ([viewController isKindOfClass:[HomeViewController class]]) {
//            NSLog(@"yes");
//            break;
//        }
//    }
//    [newArray addObject:eventDetailsView];
    [self.navigationController pushViewController:eventDetailsView animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_noEvents) {
        return 44;
    }
    return 136;
}

#pragma Mark Search Delegates-----------------

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //[searchTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"Search Button Clicked");
//    [self.activityIndicator startAnimating];
//    [self searchEventsList:searchBar.text];
    
    [self.view endEditing:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel Clicked");
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length > 2) {
        [self searchEventsList:searchBar.text];
    }
    else {
        _listOfEvents = nil;
        [eventTableView reloadData];
    }
}

-(void)searchEventsList:(NSString *)searchText{
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/event/search?name=%@&mode=EI&userId=%@&pageSize=500&pageIndex=0",kwebUrl,searchText,uid];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {         
         if (success) {
             
             _listOfEvents = [[NSMutableArray alloc] initWithArray:[jsonDict objectForKey:@"Events"]];
             
             if (!_listOfEvents.count > 0) {
                 _noEvents = TRUE;
             }
             else {
                 _noEvents = FALSE;
             }
             [eventTableView reloadData];
             NSLog(@"List of friends %@",_listOfEvents);
             [self.activityIndicator stopAnimating];
         }
     }];
}

#pragma Mark Button Methods --------------


- (IBAction)hootHereButtonClicked:(UIButton *)sender {
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:sender.tag];
    NSString *eventId = [NSString stringWithFormat:@"%@",[eventInfo objectForKey:@"id"]];
    [self loadSeeAllViewForEventId:eventId statistics:[eventInfo objectForKey:@"statistics"] tag:1000];
}
- (IBAction)goingThereButtonClicked:(UIButton *)sender {
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:sender.tag];
    
    NSString *eventId = [NSString stringWithFormat:@"%@",[eventInfo objectForKey:@"id"]];
    [self loadSeeAllViewForEventId:eventId statistics:[eventInfo objectForKey:@"statistics"] tag:2000];
}
- (IBAction)invitedButtonClicked:(UIButton *)sender {
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:sender.tag];
    
    NSString *eventId = [NSString stringWithFormat:@"%@",[eventInfo objectForKey:@"id"]];
    [self loadSeeAllViewForEventId:eventId statistics:[eventInfo objectForKey:@"statistics"] tag:3000];
}

- (IBAction)joinButtonClicked:(UIButton *)button {
    
    [_activityIndicator startAnimating];
    self.view.userInteractionEnabled = NO;
    NSMutableDictionary *eventInfo = [[_listOfEvents objectAtIndex:button.tag] mutableCopy];
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/event/%@/accept",kwebUrl,uid,[eventInfo objectForKey:@"id"]];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"SELF",@"channel",
                                nil];
    
    [UtilitiesHelper getResponseFor:dictionary url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         
         if (success) {
             
             [_activityIndicator stopAnimating];
             self.view.userInteractionEnabled = YES;
             
             NSMutableDictionary *statistics= [[eventInfo objectForKey:@"statistics"] mutableCopy];
             NSInteger goingThereCount = [[statistics objectForKey:@"acceptedCount"] integerValue]+1;
             
             [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"acceptedCount"];
             
             [eventInfo setObject:statistics forKey:@"statistics"];
             [eventInfo setObject:@"A" forKey:@"guestStatus"];

             [_listOfEvents replaceObjectAtIndex:button.tag withObject:eventInfo];
             [eventTableView reloadData];
             
             [CoreDataInterface saveEventList:[NSArray arrayWithObjects:eventInfo, nil]];
             
             [CoreDataInterface saveAll];
             
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"You have joined this event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alertView show];
         }
     }];
}

- (void)loadSeeAllViewForEventId:(NSString *)eventId statistics:(NSDictionary *)statistics tag:(NSInteger)tag {
    SeeAllViewController *seeAllView = [self.storyboard instantiateViewControllerWithIdentifier:@"seeAllView"];
    seeAllView.tag=tag;
    seeAllView.eventId = eventId;
    seeAllView.statistics = statistics;
    [self.navigationController pushViewController:seeAllView animated:YES];
}

- (IBAction)organiserNameClicked:(UIButton *)button {
    MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
    
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:button.tag];
    
    myProfileView.friendData=[eventInfo objectForKey:@"user"];
    myProfileView.isFromNavigation = TRUE;
    myProfileView.friendId=[[eventInfo objectForKey:@"user"] objectForKey:@"id"];
    //     NSLog(@"friend %i , my id %i",[myProfileView.friendId integerValue],[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] integerValue]);
    if([myProfileView.friendId integerValue]==[[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] integerValue]){
        myProfileView.isUser=YES;
    }
    else
    {
        myProfileView.isUser=NO;
        NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",[[eventInfo objectForKey:@"user"] objectForKey:@"id"]];
        
        NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
        
        if(retData.count>0)
            myProfileView.isFriend=YES;
        else
            myProfileView.isFriend=NO;
    }
    NSLog(@"hostData .... %@",myProfileView.friendData);
    //        self.navigationItem.title=@"";
    myProfileView.fromWhereCalled=@"HD";
    [self.navigationController pushViewController:myProfileView  animated:YES];
}

- (IBAction)placeButtonClicked:(UIButton *)button {
    NSDictionary *eventInfo = [_listOfEvents objectAtIndex:button.tag];
    
    CLLocationDegrees latitude = [[eventInfo objectForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[eventInfo objectForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:centerCoordinate addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = [eventInfo objectForKey:@"venueName"];
    [item openInMapsWithLaunchOptions:nil];
    //    NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/?ll=%@,%@&z=13",eventInfo.latitude,eventInfo.longitude];
    //    NSURL *url = [NSURL URLWithString:urlString];
    //    [[UIApplication sharedApplication] openURL:url];
}

@end
