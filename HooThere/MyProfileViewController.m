//
//  MyProfileViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "MyProfileViewController.h"
#import "REFrostedViewController.h"
#import "CoreDataInterface.h"
#import "ResizeImage.h"
#import "HomeViewController.h"
#import "SeeAllViewController.h"
#import "EventDetailsViewController.h"
#import "GeofenceMonitor.h"

@interface MyProfileViewController ()

@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_isFromNavigation) {
        NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
        
        _isUser=YES;
        _friendId = userId;
        _fromSidebar = YES;
        
        UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonClicked)];
        self.navigationItem.leftBarButtonItem = logout;
    }
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    if (_fromSidebar) {
//        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"slider_menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showMenu)];
//        self.navigationItem.leftBarButtonItem = menuButton;
        self.navigationItem.hidesBackButton = YES;
    }
}

- (void)checkUserAndSetDetailsAccordingly {
    if(self.isUser){
        [self hideShow:NO];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSatus:) name:@"kSendStatusSelected" object:nil];
        
        // Do any additional setup after loading the view.
        saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveAll)];
        
        pickerController = [[UIImagePickerController alloc]  init];
        pickerController.allowsEditing = YES;
        pickerController.delegate = self;
        
        nameTextField.enabled = NO;
        numberTextField.enabled = NO;
        _userInformation=[CoreDataInterface getInstanceOfMyInformation];
        [self getUserProfile];
        [self loadUserData];
    }
    else{
        
        self.title=@"User Profile";
        [self hideShow:YES];
        sendRequestButton.layer.borderWidth=1.0f;
        sendRequestButton.layer.borderColor=[UIColor purpleColor].CGColor;
        [sendRequestButton removeTarget:self action:@selector(sendRequestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self getFriendProfile:_friendId];
        [self loadFriendProfilePic];
    }
    
    // sendRequestButton.frame=CGRectMake(20,445 ,284 ,39);
    [sendRequestButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    sendRequestButton.layer.borderColor=[UIColor darkGrayColor].CGColor;
    rejectButton.hidden=YES;
    [_acceptButton setHidden:YES];
}

- (void)setButtonActionForFriend {
    if ([_frienshipStatus isEqualToString:@"P"]) {
        sendRequestButton.hidden = NO;
        [sendRequestButton setTitle:@"Pending Request" forState:UIControlStateNormal];
        sendRequestButton.enabled = NO;
    }
    else if ([_frienshipStatus isEqualToString:@"A"]) {
        [sendRequestButton setHidden:YES];
        [_acceptButton setHidden:NO];
        [rejectButton setHidden:NO];
        _acceptButton.layer.cornerRadius=3;
        rejectButton.layer.cornerRadius=3;
        rejectButton.layer.borderColor=[UIColor purpleColor].CGColor;
        rejectButton.layer.borderWidth=1.0f;
        
        [_acceptButton addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if (_isFriend==YES){
        
        sendRequestButton.layer.borderWidth=1.0f;
        sendRequestButton.layer.borderColor=[UIColor darkGrayColor].CGColor;
        [sendRequestButton setHidden:NO];
        
        [sendRequestButton setTitle:@"Remove Friend" forState:UIControlStateNormal];
        [sendRequestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [sendRequestButton addTarget:self action:@selector(removeFriend:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else{
        [sendRequestButton addTarget:self action:@selector(sendRequestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)logoutButtonClicked {
    [GeofenceMonitor stopMonitoringGeofencesForAllEvents];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defaults dictionaryRepresentation];
    for (id key in dict) {
        if(![key isEqualToString:@"kPushNotificationUDID"])
            [defaults removeObjectForKey:key];
        
    }
    [defaults setBool:NO forKey:@"isloggedin"];
    [defaults synchronize];
    
    [CoreDataInterface wipeOutSavedData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kLogoutButtonClicked" object:nil];
}


-(void)removeFriend:(UIButton *)removeButton{
    [_activityIndicator startAnimating];
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/remove/%@",kwebUrl,userId,_friendId ];
    
    NSLog(@"Rejecting Request to %@",urlString);
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"DELETE"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     { [_activityIndicator stopAnimating];
         if (success) {
             
             
             NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",_friendId];
             
             NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
             if ([retData count] > 0)
             {
                 [CoreDataInterface deleteThisFriend:[retData objectAtIndex:0]];
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"This user is removed from your friend list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alertView show];
                 NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                 [navigationViewsArray removeLastObject];
                 [navigationViewsArray removeLastObject];
                 [self moveToLastView ];

                 
             }
             //[self updateFriendsTableView];
         }
     }];




}

-(void)acceptFriendRequest:(UIButton * )sendFriendButton {
    [_activityIndicator startAnimating];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/accept/%@",kwebUrl,userId,_friendId ];
    
    NSLog(@"accept %@",urlString);
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",_friendId];
         
         NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
         [_activityIndicator stopAnimating];
         
         if (success) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"This user has been added to your friend list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
//             sendRequestButton.hidden = NO;
//             rejectButton.hidden=YES;
//             sendRequestButton.frame=CGRectMake(20,445 ,284 ,39);
             [sendRequestButton setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
             sendRequestButton.layer.borderColor=[UIColor darkGrayColor].CGColor;

             [sendRequestButton setTitle:@"Pending Request" forState:UIControlStateNormal];
             sendRequestButton.enabled = NO;
             
             Friends *friend=[retData objectAtIndex:0];
             friend.status=@"F";
             [CoreDataInterface saveAll];
             NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
             [navigationViewsArray removeLastObject];
             [navigationViewsArray removeLastObject];
             [self moveToLastView ];
             
                     }
     }];
}



-(void)moveToLastView{

    if([_fromWhereCalled isEqualToString:@"ED"])
    {
        EventDetailsViewController *eventDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetailsView"];
        eventDetail.eventId=_eventId;
        eventDetail.hostName=_hostName;
        eventDetail.hostId=_hostId;
        eventDetail.statistics=_statistics;
        [self.navigationController pushViewController:eventDetail  animated:YES];
    }
    else if([_fromWhereCalled isEqualToString:@"HH"] || [_fromWhereCalled isEqualToString:@"HT"])
    {
        HomeViewController *homeView = [self.storyboard instantiateViewControllerWithIdentifier:@"homeView"];
        [self.navigationController pushViewController:homeView  animated:YES];
    }
    else if([_fromWhereCalled isEqualToString:@"SA"])
    {
        SeeAllViewController *seeView = [self.storyboard instantiateViewControllerWithIdentifier:@"seeAllView"];
        seeView.tag=_tag;
        seeView.statistics=_statistics;
        seeView.eventId=_eventId;
        [self.navigationController pushViewController:seeView  animated:YES];
    }

}
-(void) loadUserData{
    
    //[self getUserData];
    if(self.isUser){
    [self loadProfileImage];
    nameTextField.text= _userInformation.fullName;
    numberTextField.text=_userInformation.mobile;

        emailLabel.text=_userInformation.email;
    }
}

    

-(void) changeStatus:(NSString *)status{

    
    if (status.length > 0 ) {
        availabilityLabel.text= status;
    }
    else if([status isEqualToString:@"<null>"])
    {
        availabilityLabel.text=@"Looking for plans";
        status=@"Looking for plans";
    }
    else {
        availabilityLabel.text = @"Looking for plans";
     status= @"Looking for plans";
    }
    
    if([status isEqualToString:@"Going Out"])
    statusImageView.image=[UIImage imageNamed:@"going.png"];
    else     if([status isEqualToString:@"Looking for plans"])
    statusImageView.image=[UIImage imageNamed:@"makeplan.png"];
    else
    statusImageView.image=[UIImage imageNamed:@"invited.png"];
    
    
    NSLog(@"availability label text %@",availabilityLabel.text);
    
}    


-(NSString *)checkName:(NSString *)name
{
    if (name == nil || [name isEqual:[NSNull null]]) {
        return @"";
    }
    else {
        if ([name isEqualToString:@"<null>"]) {
            return @"";
        }
        return name;
    }
}

//-(void) loadprofilePic{
//
//    NSString *profilePicUrl=[_userInformation profile_picture];
//    if (profilePicUrl.length > 0) {
//        NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserImage"];
//        if(imageData){
//            UIImage* image = [UIImage imageWithData:imageData];
//            profilePicImageView.image= [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
//        }
//    }
//    else {
//        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
//        profilePicImageView.image= [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
//    }
//    
//}
-(void) loadFriendProfilePic{

    id imageName = [_friendData objectForKey:@"profile_picture"];
    
    UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
    profilePicImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    
    if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/image",kwebUrl,_friendId];
        [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
         {
             if (success) {
                profilePicImageView.image  = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
             }
         }];
    }

}

-(void)viewWillAppear:(BOOL)animated {
    if (!_fromPickerViewCamera) {
        [self checkUserAndSetDetailsAccordingly];
        
        [self setButtonActionForFriend];
    }
        [self.navigationController setNavigationBarHidden:NO animated:NO];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kEnablePanGestureRequest" object:nil userInfo:nil];
    if(self.isUser)
    {
    [self changeStatus:_userInformation.availabilityStatus];
    }
}

-(void) hideShow:(BOOL)flagToHideShow{
    
    [editImage setHidden:flagToHideShow];
    [cameraButton setHidden:flagToHideShow];
    [cameraIcon setHidden:flagToHideShow];
    
    [editNameImage setHidden:flagToHideShow];
    [viewToHidePassword setHidden:flagToHideShow];
    [nameTextField setEnabled:!flagToHideShow];
    
    [sendRequestButton setHidden:!flagToHideShow];
    
    if(self.isFriend){
        [viewToHide setHidden:!flagToHideShow];
        [sendRequestButton setHidden:flagToHideShow];
        [emailIconImage setHidden:!flagToHideShow];
        [editNumberImage setHidden:flagToHideShow];
        [numberTextField setEnabled:!flagToHideShow];
        [sendRequestButton setHidden:!flagToHideShow];
    }
    else
    {
        [statusImageView setHidden:flagToHideShow];
        [availabilityLabel setHidden:flagToHideShow];
        [viewToHide setHidden:flagToHideShow];
        [sendRequestButton setHidden:!flagToHideShow];
        [emailIconImage setHidden:flagToHideShow];
        
    }
}


-(void)getFriendProfile:(NSString *)friendId{
    
    NSString *friedshipStatus;
    
    NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",friendId];
    
    NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
    NSLog(@"%@",friendId);
    NSLog(@"retData friend %@",retData);
    if([retData count]>0)
    {
        Friends *friend = [retData objectAtIndex:0];
        
        //NSDictionary *friend=[UtilitiesHelper stringToDictionary:[[retData objectAtIndex:0] friend ]];
        //NSDictionary *friend=[UtilitiesHelper stringToDictionary:self.friendData];
        
//        NSDictionary *friend=self.friendData;
        NSLog(@"friend............ %@",friend);

        nameTextField.text= friend.fullName;
        numberTextField.text= friend.mobile;
        
        if ([[self checkName:friend.availabilityStatus] length ]>0 ) {
           // availabilityLabel.text= [friend objectForKey:@"availabilityStatus"];
           [self changeStatus:friend.availabilityStatus]
            ;
        }
        else {
            availabilityLabel.text = @"Looking for plans";
            statusImageView.image=[UIImage imageNamed:@"makeplan.png"];
        }
        emailLabel.text=friend.email;
  
        friedshipStatus=[[retData objectAtIndex:0] status];
    }
    else
    {  NSLog(@"friendData **** %@",_friendData);
        nameTextField.text=[NSString  stringWithFormat:@"%@ %@ %@",
                         [self checkName:[_friendData objectForKey:@"firstName"]],[self checkName:[_friendData objectForKey:@"middleName"]],[self checkName:[_friendData objectForKey:@"lastName"]]];
        
    
        [statusImageView setHidden:YES];
    }
    
    if([friedshipStatus isEqualToString: @"F"])
        self.isFriend=YES;
    else
        self.isFriend=NO;
}

- (void)updateSatus:(NSNotification *)notification {
    NSDictionary *statusInfo = notification.object;
    
    statusImageView.image = [UIImage imageNamed:[statusInfo objectForKey:@"image"]];
    availabilityLabel.text = _userInformation.availabilityStatus;
    
    //[self saveAll];
}

- (IBAction)showMenu
{
    // Dismiss keyboard (optional)
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    // Present the view controller
    [self.frostedViewController presentMenuViewController];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveAll {
    if (!nameTextField.text.length > 0 || !numberTextField.text.length > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter the name and number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [self.view endEditing:YES];
    bgImageView.hidden = YES;
    statusView.hidden = YES;
    numberTextField.enabled = NO;
    numberTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.enabled = NO;
    nameTextField.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = nil;
    [self sendingUpdateProfileRequest];
}

- (IBAction)profilePicClicked:(id)sender {
    
}

- (IBAction)editButtonClicked:(UIButton *)button {
    //[self saveAll];
    if (button.tag == 10) {
        nameTextField.enabled = YES;
        nameTextField.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
        [nameTextField becomeFirstResponder];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    else if (button.tag == 20) {
        StatusViewController *statusView = [self.storyboard instantiateViewControllerWithIdentifier:@"statusView"];
        
        [self presentViewController:statusView animated:YES completion:nil];
    
    }
    else if (button.tag == 30) {
        numberTextField.enabled = YES;
        numberTextField.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
        [numberTextField becomeFirstResponder];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
}

- (IBAction)changePasswordButtonClicked:(id)sender {
    
}

- (IBAction)sendRequestButtonClicked:(id)sender {
  
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
       NSMutableDictionary *userInfo = [_friendData mutableCopy];
    
 
    NSString *_requestToId = _friendId;
    
    NSLog(@"%@",_requestToId);
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/add/%@",kwebUrl,userId,_requestToId];
    
    NSLog(@"sending Request to %@",urlString);
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         
         if (success) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Your friend request has been sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
             [userInfo setObject:@"P" forKey:@"status"];
             [userInfo setObject:_friendId forKey:@"id"];
             
             NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
             [navigationViewsArray removeLastObject];
             [navigationViewsArray removeLastObject];
             [self moveToLastView ];

             
             [CoreDataInterface saveFriendList:[NSArray arrayWithObject:userInfo]];
             [CoreDataInterface saveAll];
             
         }
     }];
 
    
    
}

- (IBAction)rejectButtonClicked:(id)sender {
    
     [_activityIndicator startAnimating];
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
   
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/reject/%@",kwebUrl,userId,_friendId ];
    
    NSLog(@"Rejecting Request to %@",urlString);
   
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     { [_activityIndicator stopAnimating];
         if (success) {
            
             
             NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",_friendId];
             
             NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
             if ([retData count] > 0)
             {
                 
                 [CoreDataInterface deleteThisFriend:[retData objectAtIndex:0]];
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hoothere" message:@"This user is removed from your friend list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alertView show];
                 [CoreDataInterface saveAll];
                 NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                 [navigationViewsArray removeLastObject];
                 [navigationViewsArray removeLastObject];
                 [self moveToLastView ];

             }
         }
     }];

}

- (IBAction)cameraButtonClicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose from Library", @"Take Picture", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        _fromPickerViewCamera = TRUE;
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerController animated:YES completion:nil];
    }
    else if (buttonIndex == 1) {
        _fromPickerViewCamera = TRUE;
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    //    UIImage *resizeImg = [self imageWithImage:img withWidth:320 withHeight:320];
    UIImage *finalImg = [self imageWithImage:img scaledToWidth:320];
    
    profilePicImageView.image = finalImg;
    _fromPickerViewCamera = FALSE;
    [UtilitiesHelper uploadImage:UIImagePNGRepresentation(profilePicImageView.image)];
    
    UserInformation *userInfo = [CoreDataInterface getInstanceOfMyInformation];
    userInfo.profileImage = UIImagePNGRepresentation(profilePicImageView.image);
    [CoreDataInterface saveAll];
    
    //NSLog(@"Image Size after Saved %f X %f ",img.size.width,img.size.height );
    
   // NSLog(@"final Image Size  %f X %f ",finalImg.size.width,finalImg.size.height );
    [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(img) forKey:@"UserImage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    [self dismissViewControllerAnimated:pickerController completion:nil];
}

-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma Textfield Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        CGRect frame = self.view.frame;
        frame.origin.y = 0.00;
        [self.view setFrame:frame];
        [UIView commitAnimations];
        //        self.title = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        CGRect frame = self.view.frame;
        frame.origin.y = 64.00;
        [self.view setFrame:frame];
        [UIView commitAnimations];
    }
}
- (void)hideKeyboard {
    nameTextField.enabled=NO;
    nameTextField.backgroundColor = [UIColor whiteColor];
    numberTextField.enabled=NO;
    numberTextField.backgroundColor=[UIColor whiteColor];
    [self.view endEditing:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
   
            [self hideKeyboard];
   
    
    return YES;
}



- (void)sendingUpdateProfileRequest {
    [_activityIndicator startAnimating];
    [self.view endEditing:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oldTokenId = [userDefaults objectForKey:@"kPushNotificationUDID"];
    
    NSMutableArray* nameArray = [[nameTextField.text componentsSeparatedByString: @" "] mutableCopy];
    NSString *firstName = @"";
    NSString* middleName = @"";
    NSString *lastName = @"";
    
    if (nameArray.count > 1) {
        firstName = [nameArray firstObject];
        lastName = [nameArray lastObject];
        [nameArray removeLastObject];
        [nameArray removeObjectAtIndex:0];
        if (nameArray.count > 0) {
            middleName=[nameArray objectAtIndex:0];
            for (int i=1; i <nameArray.count; i++) {
                
                middleName = [NSString stringWithFormat:@"%@ %@",middleName,[nameArray objectAtIndex:i]];
                
            }
        }
    }
    else if(nameArray.count == 1) {
        firstName = [nameArray firstObject];
    }
    NSLog(@"Middle Name :- %@" ,middleName);
      _userInformation = [CoreDataInterface getInstanceOfMyInformation];
    
//    NSDictionary *userChangedData=[[NSDictionary alloc]initWithObjectsAndKeys:[name objectAtIndex:0],@"firstName",middleName,@"middleName",lastName,@"lastName",numberTextField.text,@"mobile",availabilityLabel.text,@"availablityStatus", oldTokenId,@"deviceId",nil];
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/user/edit/%@",kwebUrl,userId];
    
    _userInformation.firstName= firstName;
    _userInformation.lastName=lastName;
    _userInformation.middleName=middleName;
    _userInformation.mobile=numberTextField.text;
    _userInformation.availabilityStatus=availabilityLabel.text;
    _userInformation.deviceId = oldTokenId;
    [CoreDataInterface saveAll];
    
    NSDictionary *userChangedData= [UtilitiesHelper setUserDetailsDictionaryFromCoreDataWithInfo:_userInformation type:nil];
    NSLog(@"userChangedData ...%@",userChangedData);
    
    [UtilitiesHelper getResponseFor:userChangedData url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
                  if (success) {
             NSString *userId=[jsonDict objectForKey:@"id"];
             if(userId) {
                 [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"UserId"];
                
                 
                 [CoreDataInterface saveUserInformation:jsonDict];
                 _userInformation =[CoreDataInterface getInstanceOfMyInformation];
                 NSLog(@"Updated ....");
             }
         }
     }];
}


-(void)loadProfileImage{
    UserInformation *userInfo = [CoreDataInterface getInstanceOfMyInformation];
    if (userInfo.profileImage.length > 0) {
        UIImage *image = [UIImage imageWithData:userInfo.profileImage];
        profilePicImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(200, 200)];
    }
    else {
        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        profilePicImageView.image= [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    }
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
                          profilePicImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(200, 200)];
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

@end
