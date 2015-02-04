//
//  InviteFriendsViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "CustomTableViewCell.h"
#import "UtilitiesHelper.h"
#import "UIImageView+AFNetworking.h"
#import "CoreDataInterface.h"
#import "ResizeImage.h"
#import "InviteFriendsViewController.h"
#import "EventDetailsViewController.h"
#import "UIImageView+WebCache.h"

@interface InviteFriendsViewController ()

@end

@implementation InviteFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFacebookFriends) name:@"kLoadFacebookFriends" object:nil];
    
    inviteFriendsButton.layer.cornerRadius=3;
    acceptButton.layer.cornerRadius=3;
    _facebookSelected = FALSE;
    
    _listOfFriends = [[NSMutableArray alloc] init];
    _listOfFacebookFriends = [[NSMutableArray alloc] init];
    _listOfHootHereFriends = [[NSMutableArray alloc] init];
    _listOfFacebookInvites = [[NSMutableArray alloc] init];
    _listOfFriendsSelected = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    }
    else {
        _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.x-80 Xorigin:self.view.center.y -50];
    }
    [self.view addSubview:_activityIndicator];
    //[self.view bringSubviewToFront:_activityIndicator];

    
    textFieldBackground.layer.masksToBounds = YES;
    textFieldBackground.layer.cornerRadius = 15;
    // Do any additional setup after loading the view.
    
//    [self setupScrollView];
    
     [self.view setUserInteractionEnabled:YES];
    
    UISwipeGestureRecognizer *swipeRightOrange = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToRightWithGestureRecognizer:)];
    swipeRightOrange.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer *swipeLeftOrange = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToLeftWithGestureRecognizer:)];
    swipeLeftOrange.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:swipeRightOrange];
    [self.view addGestureRecognizer:swipeLeftOrange];
    
    [acceptButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [acceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    acceptButton.layer.backgroundColor=[UIColor whiteColor].CGColor;
    acceptButton.layer.borderColor=[UIColor purpleColor].CGColor;
    acceptButton.layer.borderWidth=1.0f;
    

    _listType = @"H";
    _searching = FALSE;
    [self fetchListOfHootThereFriends];
    [self loadFacebookFriends];
    [self getContactListFromCoreData];
//    [self hooThereButtonClicked:hooThereButton];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
   // [self checkFromWhereCalled];
    
}

- (void)viewDidAppear:(BOOL)animated {
    

}

- (void)fetchListOfHootThereFriends {

//    NSMutableArray *friends =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:nil andSortkey:@"firstName" isSortAscending:YES];
//       for (int i = 0; i < friends.count; i++) {
//        Friends *contactInfo = [friends objectAtIndex:i];
//        if ([[contactInfo status] isEqualToString:@"F"])  {
//            [_listOfHootHereFriends addObject:contactInfo];
//        }
//    }
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/getAll?eventId=%@",kwebUrl,userId,[_thisEvent eventid]];
    
    [UtilitiesHelper fetchListOfHootThereFriends:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict){
        
        [_activityIndicator stopAnimating];
        
        if (success) {
            //_listOfFriends = [jsonDict objectForKey:@"Friends"];
            [CoreDataInterface saveFriendList:[jsonDict objectForKey:@"Friends"]];
            
            NSMutableArray *friends =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:nil andSortkey:@"firstName" isSortAscending:YES];
            for (int i = 0; i < friends.count; i++) {
                Friends *contactInfo = [friends objectAtIndex:i];
                if ([[contactInfo status] isEqualToString:@"F"])  {
                    [_listOfHootHereFriends addObject:contactInfo];
                }
            }
            [hootHereTableView reloadData];
        }
        
    }];

}

- (IBAction)tabButtonClicked:(UIButton *)button {
    
    
    CGRect newFrame = tabLineView.frame;
    newFrame.origin.x = button.frame.origin.x;
    newFrame.size.width = button.frame.size.width;
    [UIView animateWithDuration:0.6 animations:^(void){
        tabLineView.frame = newFrame;
    }];
}



- (void)getContactListFromCoreData {
    NSMutableArray *contacts =  [CoreDataInterface searchObjectsInContext:@"Contacts" andPredicate:nil andSortkey:@"userid" isSortAscending:YES];
    
    _listOfFriends = contacts;
}

- (void)loadSignInWithFacebook {
    [loginview removeFromSuperview];
    loginview = [UtilitiesHelper loadFacbookButton:CGRectMake(20, 200, 280, 43)];
    loginview.delegate = self;
    [self.view addSubview:loginview];
    loginview.hidden = YES;
    
    CGRect newFrame = CGRectMake(20, 200, 280, 43);
    loginview.frame = newFrame;
    
    CGRect newButtonFrame = CGRectMake(0, 0, 280, 43);
    [[loginview.subviews objectAtIndex:0] setFrame:newButtonFrame];
    
    NSLog(@"Array : %@",loginview.subviews);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    //    self.profilePictureView.profileID = [user objectForKey:@"id"];
    //    NSLog(@"Profile View : %@",self.profilePictureView.subviews);
    //
    //    UIImage *image = [[self.profilePictureView.subviews objectAtIndex:0] image];
    
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"You're logged in");
    
    [[loginview.subviews objectAtIndex:2] setText:@"Sign Out From Facebook"];
    loginView.hidden = YES;
    hootHereTableView.hidden = NO;
    [_activityIndicator startAnimating];
    //[self.view setUserInteractionEnabled:NO];
    [UtilitiesHelper getFacebookFriends];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"You're logged out");
    [[loginview.subviews objectAtIndex:2] setText:@"Sign Up With Facebook"];
    loginView.hidden = NO;
    hootHereTableView.hidden = YES;
}

- (void)loadFacebookFriends {
    [_activityIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];

    NSMutableArray *facebookFriends =  [CoreDataInterface searchObjectsInContext:@"Facebook" andPredicate:nil andSortkey:@"name" isSortAscending:YES];
    if (!facebookFriends.count > 0) {
        return;
    }
    _listOfFacebookFriends = facebookFriends;
}

-(void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"Test");
    }];
}

-(void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer{
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"Test");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetSearch {
    _searching = FALSE;
    [self.view endEditing:YES];
    searchBarField.text = @"";
    searchBarField.showsCancelButton = NO;
    _searchArray = [[NSMutableArray alloc] init];
}

- (IBAction)hooThereButtonClicked:(id)sender {
    [self resetSearch];
    
    CGRect newFrame = tabLineView.frame;
    newFrame.origin.x = hooThereButton.frame.origin.x;
    newFrame.size.width = hooThereButton.frame.size.width;
    NSLog(@"Origin X : %f",newFrame.origin.x);
    if (newFrame.origin.x < 0) {
        return;
    }
    [UIView animateWithDuration:0.6 animations:^(void){
        tabLineView.frame = newFrame;
      }];
    _listType = @"H";
    hootHereTableView.hidden = NO;
    loginview.hidden = YES;
    [hootHereTableView reloadData];
    _facebookSelected = FALSE;
}

- (IBAction)facebookButtonClicked:(id)sender {
    [self resetSearch];

    [self performSelector:@selector(facebookFriends) withObject:nil afterDelay:0.5];
}

- (void)facebookFriends {
    
    if (!_facebookSelected) {
        CGRect newFrame = tabLineView.frame;
        newFrame.origin.x = 107;
        newFrame.size.width = facebookButton.frame.size.width;
        NSLog(@"Origin X : %f",newFrame.origin.x);
        if (newFrame.origin.x < 0) {
            return;
        }
        [UIView animateWithDuration:0.6 animations:^(void){
            tabLineView.frame = newFrame;
            NSLog(@"Hihihihi");
        }];
        _listType = @"F";
        if (![FBSession activeSession].isOpen) {
            [self loadSignInWithFacebook];
            loginview.hidden = NO;
            hootHereTableView.hidden = YES;
        }
        else {
            loginview.hidden = YES;
        }
        _facebookSelected = TRUE;
        [hootHereTableView reloadData];
    }
}

- (IBAction)contactsButtonClicked:(id)sender {
    [self resetSearch];
    CGRect newFrame = tabLineView.frame;
    newFrame.origin.x = contactsButton.frame.origin.x;
    newFrame.size.width = contactsButton.frame.size.width;
    NSLog(@"Origin X : %f",newFrame.origin.x);
    if (newFrame.origin.x < 0) {
        return;
    }
    [UIView animateWithDuration:0.6 animations:^(void){
        tabLineView.frame = newFrame;
     }];   
    _listType = @"C";
    hootHereTableView.hidden = NO;
    loginview.hidden = YES;
    [hootHereTableView reloadData];
    _facebookSelected = FALSE;
}

#pragma mark Tableview Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows;
    if (_searching) {
        numberOfRows = [_searchArray count];
    }
    else {
        if ([_listType isEqualToString:@"F"]) {
            numberOfRows = [_listOfFacebookFriends count];
        }
        else if ([_listType isEqualToString:@"C"]) {
            numberOfRows = [_listOfFriends count];
        }
        else {
            numberOfRows = _listOfHootHereFriends.count ;
        }
    }
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell;
    static NSString *cellIdentifier = @"contactsCell";
    cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.iconImageview.layer.masksToBounds = YES;
    cell.iconImageview.layer.cornerRadius = 15;
    
    id contactInfo;
    if (_searching) {
        contactInfo = [_searchArray objectAtIndex:indexPath.row];
    }
    else {
        if ([_listType isEqualToString:@"F"]) {
            contactInfo = [_listOfFacebookFriends objectAtIndex:indexPath.row];
        }
        else if ([_listType isEqualToString:@"C"]) {
            contactInfo = [_listOfFriends objectAtIndex:indexPath.row];
        }
        else {
            contactInfo = [_listOfHootHereFriends objectAtIndex:indexPath.row];
        }
        
    }
    cell.eventPlaceLabel.hidden = YES;
    cell.titleLabel.hidden = NO;
    if ([_listType isEqualToString:@"F"]) {
          cell.titleLabel.text = [contactInfo name];
        cell.statusImage.hidden=YES;
        [cell.iconImageview setHidden:NO];
        [cell.subTitleLabel setHidden:YES];
        [cell.statusIcon setHidden:YES];
        [ cell.backgroundImageview setHidden:NO];
        
        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        
        if (![[contactInfo imageurl] isEqual:[NSNull null]] && [contactInfo imageurl] != nil) {
            NSURL *url = [[NSURL alloc] initWithString:[contactInfo imageurl]];
            [cell.iconImageview setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
        }
        else {
            cell.iconImageview.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
        }
//        NSURL *url = [[NSURL alloc] initWithString:[contactInfo imageurl]];
//        [cell.iconImageview setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile-image-placeholder"]];
        
        if ([_listOfFacebookInvites containsObject:contactInfo]) {
            cell.backgroundImageview.image = [UIImage imageNamed:@"select_blue.png"];
        }
        else {
            cell.backgroundImageview.image = [UIImage imageNamed:@"invite-border.png"];
        }
    }
    else if ([_listType isEqualToString:@"C"]) {
          cell.titleLabel.text = [contactInfo name];
         cell.statusImage.hidden=YES;
        [cell.iconImageview setHidden:YES];
        [cell.subTitleLabel setHidden:NO];
        [cell.backgroundImageview setHidden:NO];
        if ([[contactInfo number] length] > 0) {
            cell.subTitleLabel.text = [contactInfo number];
            [cell.statusIcon setFrame:CGRectMake(cell.statusIcon.frame.origin.x, cell.statusIcon.frame.origin.y, 8,12)];
            cell.statusIcon.image=[UIImage imageNamed:[UtilitiesHelper setStatusIcon:nil for:@"phone"]];
        }
        else if ([[contactInfo email] length] > 0){
            cell.subTitleLabel.text = [contactInfo email];
            [cell.statusIcon setFrame:CGRectMake(cell.statusIcon.frame.origin.x, cell.statusIcon.frame.origin.y, 12,8)];
            cell.statusIcon.image=[UIImage imageNamed:[UtilitiesHelper setStatusIcon:nil for:@"email"]];
        }
        else {
            cell.subTitleLabel.text = @"";
        }
        if ([_listOfFriendsSelected containsObject:contactInfo]) {
            cell.backgroundImageview.image = [UIImage imageNamed:@"select_blue.png"];
        }
        else {
            cell.backgroundImageview.image = [UIImage imageNamed:@"invite-border.png"];
        }
//        cell.titleLabel = []
    }
    else {
        cell.statusLabel.hidden = YES;
        cell.eventPlaceLabel.hidden = NO;
        cell.titleLabel.hidden = YES;
        [cell.statusIcon setFrame:CGRectMake(cell.statusIcon.frame.origin.x, cell.statusIcon.frame.origin.y, 10,10)];
        
        cell.eventPlaceLabel.text = [contactInfo fullName];
        
        cell.iconImageview.hidden = NO;
        cell.backgroundImageview.hidden = YES;
        cell.statusIcon.hidden=YES;
        
        
        
        id imageName = [contactInfo profile_picture];
        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
        cell.iconImageview.image= image;
        
        if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
            NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,[contactInfo friendId]];
//            [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
//             {
//                 if (success) {
//                     cell.iconImageview.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
//                 }
//             }];
            [cell.iconImageview sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image];

        }
        
        [cell.subTitleLabel setHidden:YES];
//        NSString *availabilityStatus = [contactInfo availabilityStatus];
//        if (availabilityStatus !=  nil && ![availabilityStatus isEqual:[NSNull null]] && ![availabilityStatus isEqualToString:@"<null>"]) {
//            cell.subTitleLabel.text = availabilityStatus;
//            cell.statusIcon.image=[UIImage imageNamed:[UtilitiesHelper setStatusIcon:availabilityStatus for:@"status"]];
//            
//        }
//        else {
//            cell.subTitleLabel.text = @"Looking for plans";
//            cell.statusIcon.image=[UIImage imageNamed:@"makeplan.png"];
//        }

        cell.statusImage.hidden = YES;
        
        if ([[contactInfo eventGuestStatus] isEqualToString:@""]) {
            cell.backgroundImageview.hidden = NO;
            if ([_listOfFriendsSelected containsObject:contactInfo])
            {
                cell.backgroundImageview.image = [UIImage imageNamed:@"select_blue.png"];
            }
            else
            {
                cell.backgroundImageview.image = [UIImage imageNamed:@"invite-border.png"];
            }
        }
        else if ([[contactInfo eventGuestStatus] isEqualToString:@"A"])
        {
            cell.statusImage.hidden=NO;
            cell.statusImage.image=[UIImage imageNamed:@"going_there_bluenew.png"];
        }
        else if([[contactInfo eventGuestStatus] isEqualToString:@"HT"]) {
            cell.statusImage.hidden=NO;
            cell.statusImage.image=[UIImage imageNamed:@"hoothere_bluenew.png"];
        }
        else{
        
            cell.statusImage.hidden=NO;
            cell.statusImage.image=[UIImage imageNamed:@"invited_blue.png"];
        }


        
        
    }

    return cell;
}


-(NSString *)setStatusIcon:(NSString *)status{
    if([status isEqualToString:@"Going Out"])
        return @"going.png";
    else if([status isEqualToString:@"Looking for plans"])
        return @"makeplan.png";
    else
        return @"invited.png";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"Selected");
    
    CustomTableViewCell *cell = (CustomTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    id contactInfo;
    if (_searching) {
        contactInfo = [_searchArray objectAtIndex:indexPath.row];
    }
    else {
        if ([_listType isEqualToString:@"F"]) {
            contactInfo = [_listOfFacebookFriends objectAtIndex:indexPath.row];
//            contactInfo=[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:contactInfo type:nil];
//            
//            [contactInfo removeObjectForKey:@"imageurl"];
//            NSLog(@"facebook friend Selected *** %@",contactInfo);
            
        }
        else if ([_listType isEqualToString:@"C"]) {
            contactInfo = [_listOfFriends objectAtIndex:indexPath.row];
           
          
//            contactInfo=[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:contactInfo type:nil];
//            
//            [contactInfo removeObjectForKey:@"imageData"];
//              NSLog(@"contactInfo Selected *** %@",contactInfo);

        }
        else {
            contactInfo = [_listOfHootHereFriends objectAtIndex:indexPath.row];
        }
        
    }
    
    if( [_listType isEqualToString:@"H"]){
    if (![[contactInfo eventGuestStatus] isEqualToString:@""]) {
        return;
    }
    }
    
    if ([_listOfFriendsSelected containsObject:contactInfo]) {
        [_listOfFriendsSelected removeObject:contactInfo];
        cell.backgroundImageview.image = [UIImage imageNamed:@"invite-border.png"];
    }
    else {
        [_listOfFriendsSelected addObject:contactInfo];
        cell.backgroundImageview.image = [UIImage imageNamed:@"select_blue.png"];
    }
    
    if ([_listType isEqualToString:@"F"]) {
        if ([_listOfFacebookInvites containsObject:contactInfo]) {
            [_listOfFacebookInvites removeObject:contactInfo];
        }
        else {
            [_listOfFacebookInvites addObject:contactInfo];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 50;
}

- (void)sendFacebookMessage {
    
    NSString *toUserIds = @"";
    for (int i = 0; i < _listOfFacebookInvites.count; i++) {
        
        Facebook *userInfo = [_listOfFacebookInvites objectAtIndex:i];
        NSString *userId;
        if (i == _listOfFacebookInvites.count - 1) {
            userId = [NSString stringWithFormat:@"%@",[userInfo name]];
        }
        else {
            userId = [NSString stringWithFormat:@",%@",[userInfo name]];
        }
        toUserIds = [NSString stringWithFormat:@"%@%@",toUserIds, userId];
    }
    
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                
                // Optional parameter for sending request directly to user
                // with UID. If not specified, the MFS will be invoked
                toUserIds,@"to",
                @"1486697814943402",@"app_id",
                //@"1486697814943402",@"app_id",
                // Give the action object request information
                @"send", @"action_type",
//                @"YOUR_OBJECT_ID", @"object_id",
                
                nil];
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Making a test for invitation"
     title:@"Send Invite"
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
     
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                 }
             }
         }
     }
     ];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (IBAction)inviteButtonClicked:(id)sender {
    NSMutableArray *finalContacts = [[NSMutableArray alloc] init];
    NSMutableArray *finalFacebookFriends = [[NSMutableArray alloc] init];
    NSMutableArray *finalhooThereFriends = [[NSMutableArray alloc] init];
    NSLog(@"%@",_listOfFriendsSelected);
    
    if (_listOfFriendsSelected.count > 0) {
        UIButton *button=(UIButton *)sender;
        [button setEnabled:NO]; // disables
        
        [button setTitle:@"Inviting..." forState:UIControlStateNormal];
        [_activityIndicator startAnimating];
        
        for (int i = 0; i < _listOfFriendsSelected.count; i++) {
            id objectInfo = [_listOfFriendsSelected objectAtIndex:i];
            NSMutableDictionary *friendInfo = [[UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:objectInfo type:nil] mutableCopy];
            if ([objectInfo isKindOfClass:[Friends class]]) {
                [finalhooThereFriends addObject:friendInfo];
            }
            else if ([objectInfo isKindOfClass:[Facebook class]]) {
                [finalFacebookFriends addObject:friendInfo];
            }
            else  {
                [friendInfo removeObjectForKey:@"imageData"];
                [finalContacts addObject:friendInfo];
                
            }
        }
        
        
        
        NSDictionary *dictionaryInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        finalContacts,@"contacts",
                                        finalFacebookFriends,@"facebook",
                                        finalhooThereFriends,@"hoothere",
                                        nil];
        
        NSLog(@"dictionary Info %@",dictionaryInfo );
        //NSLog(@"invitation info %@",dictionaryInfo);
        NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];

        NSString *urlString = [NSString stringWithFormat:@"%@/event/invite/%@/%@",kwebUrl,_thisEvent.eventid,uid];
        [UtilitiesHelper getResponseFor:dictionaryInfo url:[NSURL URLWithString:urlString] requestType:@"POST" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
         {
             if (success) {
                 
                 NSMutableDictionary *statistics= [[UtilitiesHelper stringToDictionary:[_thisEvent statistics]] mutableCopy];
                 NSInteger goingThereCount = [[statistics objectForKey:@"invitedCount"] integerValue]+ [[dictionaryInfo objectForKey:@"hoothere"] count];
                 
                 [statistics setObject:[NSString stringWithFormat:@"%ld",(long)goingThereCount] forKey:@"invitedCount"];
                 _thisEvent.statistics = [NSString stringWithFormat:@"%@",statistics];
                 [CoreDataInterface saveAll];
                 
                 
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"An invitation is sent successfully to your friends." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alertView show];
                  [_activityIndicator stopAnimating];
                 EventDetailsViewController *eventDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
                 eventDetailsView.eventId = _thisEvent.eventid;
               
                 
                 eventDetailsView.thisEvent=_thisEvent;
                 
                 NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                 [navigationViewsArray removeLastObject];
                 [navigationViewsArray removeLastObject];
                 [navigationViewsArray addObject:eventDetailsView];
                 eventDetailsView.hostData=_hostData;
                 eventDetailsView.hostId=_hostId;
                 [self.navigationController setViewControllers:navigationViewsArray animated:YES];
                 
                 
             }
         }];

    }
}

#pragma mark Search Delegates-----------------

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSString *dictionaryKey = @"name";
    NSPredicate *entitySearchPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", dictionaryKey, searchText];
    
    
    
    NSArray *filteredarray = [[NSArray alloc] init];
    
    if ([_listType isEqualToString:@"F"]) {
        filteredarray =  [CoreDataInterface searchObjectsInContext:@"Facebook" andPredicate:entitySearchPredicate andSortkey:@"name" isSortAscending:YES];
        NSLog(@"%@", filteredarray);
    }
    else if ([_listType isEqualToString:@"C"]) {
        filteredarray =  [CoreDataInterface searchObjectsInContext:@"Contacts" andPredicate:entitySearchPredicate andSortkey:@"name" isSortAscending:YES];
        NSLog(@"%@", filteredarray);
    }
    else {
        NSString *dictionaryKey1 = @"firstName";
        NSPredicate *entitySearchPredicate1 = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", dictionaryKey1, searchText];
        NSString *dictionaryKey2 = @"status";
        NSPredicate *entitySearchPredicateforStatus = [NSPredicate predicateWithFormat:@"%K = %@", dictionaryKey2, @"F"];
        
        NSPredicate * andPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:entitySearchPredicate1,entitySearchPredicateforStatus,nil]];
        
        filteredarray =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:andPredicate andSortkey:@"firstName" isSortAscending:YES];
        NSLog(@"%@", filteredarray);
    }
    
    
    _searchArray = [[NSMutableArray alloc] initWithArray:filteredarray];
    
    NSLog(@"Search Array : %@",_searchArray);
    
    if (_searchArray.count > 0) {
        hootHereTableView.hidden = NO;
        [hootHereTableView reloadData];
    }
    else {
        hootHereTableView.hidden = YES;
    }
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    hootHereTableView.hidden = NO;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    _searching = TRUE;
    [hootHereTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [self.view endEditing:YES];
//    searchBar.showsCancelButton = NO;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel Clicked");
    [self resetSearch];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterContentForSearchText:searchBar.text
                               scope:nil];
}

@end
