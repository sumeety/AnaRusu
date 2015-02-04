//
//  SeeAllViewController.m
//  HooThere
//
//  Created by Jasmeet Kaur on 15/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "SeeAllViewController.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "ResizeImage.h"
//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"

@interface SeeAllViewController ()

@end

@implementation SeeAllViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    _userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    self.listOfSeeAll = [[NSMutableArray alloc] init];
    _listOfNewConnections = [[NSMutableArray alloc] init];
    _newConnections = FALSE;
    self.seeAllTableView.delegate=self;
    self.seeAllTableView.dataSource = self;
    self.seeAllTableView.opaque = NO;
    
    [self setTitleBar];

    [self getListOfFriends];
    
    // Do any additional setup after loading the view.
}
- (void)getListOfFriends {
    [_activityIndicator startAnimating];
        
    NSDictionary *postDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"0",@"pageIndex",
                                    @"1000",@"pageSize",
                                    _friendsListType,@"status"
                                    , nil];
    NSString *urlString = [NSString stringWithFormat:@"%@/event/%@/getGuests",kwebUrl,_eventId];
    [UtilitiesHelper getResponseFor:postDictionary url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         if (success) {
             NSMutableArray *allFriends = [[jsonDict objectForKey:_friendsListType] mutableCopy];
             
             NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES];
             
             NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
             
             _allFriendsSortedArray = [allFriends sortedArrayUsingDescriptors:sortDescriptors];
             
             [self reloadSeeAllTableView];
         }
     }];
}

- (void)reloadSeeAllTableView {
    NSDictionary *friendsDictionary = [CoreDataInterface getNewConnections:[NSMutableArray arrayWithArray:_allFriendsSortedArray]];
    
    _listOfNewConnections = [friendsDictionary objectForKey:@"new"];
    _listOfSeeAll = [friendsDictionary objectForKey:@"friends"];
    //[_listOfSeeAll addObjectsFromArray:_listOfNewConnections];
    [_seeAllTableView reloadData];
}

-(void) setTitleBar{
    if (self.tag<=1000) {
        self.title = [NSString stringWithFormat:@"%@ Hoo There",[self.statistics objectForKey:@"hoothereCount"]];
        _friendsListType = @"Hoothere";
       
    }
    else if(self.tag<=2000) {
        self.title = [NSString stringWithFormat:@"%@ Going There",[self.statistics objectForKey:@"acceptedCount"]];
        _friendsListType = @"Accepted";
        
       
    }
    else if(self.tag<=3000) {
        self.title = [NSString stringWithFormat:@"%@ Invited",[self.statistics objectForKey:@"invitedCount"]];
        _friendsListType = @"Invited";
        NSLog(@"Invited Count %lu",(unsigned long)self.listOfSeeAll.count);
    }
}

- (IBAction)segementControllerClicked:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        _newConnections = FALSE;
    }
    else {
        _newConnections = TRUE;
    }
    [_seeAllTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendFriendRequest:(id)sender {
    NSLog(@"Sending Friend Request");
}

#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (_newConnections) {
        return _listOfNewConnections.count;
    }
    else {
        return _listOfSeeAll.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuSidebarCell *cell;
    static NSString *cellIdentifier = @"seeAllCell";
  
    cell = (MenuSidebarCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSMutableArray *friendsArray;
    NSDictionary *userInfo;

    if (_newConnections) {
       friendsArray = _listOfNewConnections;
        cell.subTitleLabel.hidden = YES;
       userInfo=[friendsArray objectAtIndex:indexPath.row];
        
        
        cell.rightButton.hidden = NO;
        cell.statusImageView.hidden=YES;
     
        
        cell.youImageView.hidden=YES;
        
        cell.rightButton.layer.cornerRadius = cell.rightButton.bounds.size.width/2.0;
        [cell.rightButton setBackgroundImage:[UIImage imageNamed:@"add_frnd_blue.png"] forState:UIControlStateNormal];
        cell.rightButton.tag = indexPath.row;
    }
    else {
        friendsArray = _listOfSeeAll;
        cell.subTitleLabel.hidden = NO;
        cell.statusImageView.hidden=NO;
        cell.rightButton.hidden = YES;
        cell.youImageView.hidden = YES;
        userInfo =[friendsArray objectAtIndex:indexPath.row];
        
       NSString *availabliltyStatus = [userInfo objectForKey:@"availabilityStatus"];
        
        if ([[userInfo objectForKey:@"status"] isEqualToString:@"F"]) {
            //cell.rightButton.hidden = NO;
            cell.subTitleLabel.hidden = NO;
            if (availabliltyStatus == nil || [availabliltyStatus isEqual:[NSNull null]]) {
                cell.subTitleLabel.text = @"Looking for plans";
                cell.statusImageView.image=[UIImage imageNamed:@"makeplan.png"];
            }
            else {
                cell.subTitleLabel.text = availabliltyStatus;
                cell.statusImageView.image=[UIImage imageNamed:[UtilitiesHelper setStatusIcon:availabliltyStatus for:@"status"]];
            }
        }
        else {
            cell.rightButton.hidden = YES;
            cell.subTitleLabel.hidden = YES;
            cell.youImageView.image = [UIImage imageNamed:@"pending_blue.png"];
            cell.youImageView.hidden = NO;
        }
    }
    

    cell.leftImageView.layer.masksToBounds = YES;
    cell.leftImageView.layer.cornerRadius = 15;
    
    NSString *fullName;;
    id imageName;
    UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
    image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    cell.leftImageView.image = image;
    
    NSString *guestId;
    if(![userInfo objectForKey:@"user"] )
    {
        fullName = [userInfo objectForKey:@"fullName"];
        guestId = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"guestId"]];
        imageName = [userInfo objectForKey:@"profile_picture"];
    }
    else {
        fullName = [[userInfo objectForKey:@"user"] objectForKey:@"fullName"];
        guestId = [NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"user"] objectForKey:@"id"]];
        imageName = [[userInfo objectForKey:@"user"] objectForKey:@"profile_picture"];
    }
    
    if (fullName == nil || [fullName isEqual:[NSNull null]]) {
        cell.titleLabel.text = @"No Name";
    }
    else {
        cell.titleLabel.text = fullName;
    }
    
    NSString *userId=[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"] ];

    if ([userId isEqualToString:guestId]) {
        cell.youImageView.image = [UIImage imageNamed:@"you.png"];
    }
    
    if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,guestId];
        [cell.leftImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image];
    }
    
    return cell;
}

- (IBAction)addFriendButtonClicked:(UIButton *)sendFriendButton {
    [_activityIndicator startAnimating];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSLog(@"%ld",(long)sendFriendButton.tag);
    
    NSMutableDictionary *userInfo = [[_listOfNewConnections objectAtIndex:sendFriendButton.tag] mutableCopy];
    NSString *requestToId = [[userInfo objectForKey:@"user"] objectForKey:@"id"];
    
    NSLog(@"%@",requestToId);
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/add/%@",kwebUrl,userId,requestToId];
    
    NSLog(@"sending Request to %@",urlString);
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         
         if (success) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Your friend request has been sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
             [userInfo setObject:@"P" forKey:@"status"];
             [userInfo setObject:requestToId forKey:@"id"];
             NSDictionary *friendInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[userInfo objectForKey:@"user"],@"friend",@"P",@"status", nil];
             [CoreDataInterface saveFriendList:[NSArray arrayWithObject:friendInfo]];
//             [_listOfNewConnections removeObjectAtIndex:sendFriendButton.tag];
//             [_listOfSeeAll addObject:userInfo];
//             [_seeAllTableView reloadData];
             [self reloadSeeAllTableView];
         }
     }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
   // NSDictionary *dictInfo = [self.listOfSeeAll objectAtIndex:indexPath.row];
    NSMutableArray *friendsArray;
    myProfileView.isFromNavigation = TRUE;

    myProfileView.isUser=NO;
    if (_newConnections) {
        friendsArray = _listOfNewConnections;
        NSDictionary *dictInfo=[[friendsArray objectAtIndex:indexPath.row] objectForKey:@"user"];
        myProfileView.isFriend=NO;
        myProfileView.friendData=dictInfo;
          myProfileView.friendId=[dictInfo objectForKey:@"id"];
       // cell.subTitleLabel.hidden = YES;
        NSLog(@"dictInfo new connection %@",dictInfo);
    }
    else {
         friendsArray = _listOfSeeAll;
        NSDictionary *dictInfo = [friendsArray objectAtIndex:indexPath.row];
       
       
        if([dictInfo objectForKey:@"user"])
        {   myProfileView.isUser=YES;
            myProfileView.isFriend=NO;
        }
        else
        { myProfileView.isUser=NO;
            if([[dictInfo objectForKey:@"status"] isEqualToString:@"F"])
                myProfileView.isFriend=YES;
            else
                myProfileView.isFriend=NO;
            
            myProfileView.friendData=dictInfo;
            myProfileView.friendId=[dictInfo objectForKey:@"guestId"];
        }
    }
    
    
    
    
    myProfileView.fromWhereCalled=@"SA";
    myProfileView.tag=_tag;
    myProfileView.eventId=_eventId;
    myProfileView.statistics=_statistics;
//    seeAllView.tag=(unsigned long)button.tag;
//    seeAllView.eventId = _eventId;
//    seeAllView.statistics=_statistics;
//    self.navigationItem.title=@"";
    [self.navigationController pushViewController:myProfileView  animated:YES];
    
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

