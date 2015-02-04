//
//  MenuViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "MenuViewController.h"
#import "HooThereNavigationController.h"
#import "HomeViewController.h"
#import "MyProfileViewController.h"
#import "MenuSidebarCell.h"
#import "CoreDataInterface.h"
#import "ResizeImage.h"
#import "GeofenceMonitor.h"
#import "SearchEventsViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.listOfMenus = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfilePicture) name:@"KLoadProfilePicture" object:self];
    [self dudeTableViewList];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"menubg.png"]]];
    
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    self.menuTableView.opaque = NO;

    
    logoutButton.layer.cornerRadius=3;
    logoutButton.layer.borderWidth=1.0f;
    logoutButton.layer.borderColor=[UIColor whiteColor].CGColor;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.cornerRadius = 50;
}

- (void)loadProfilePicture {
    UserInformation *userInfo = [CoreDataInterface getInstanceOfMyInformation];
    if (userInfo.profileImage.length > 0) {
        UIImage *image = [UIImage imageWithData:userInfo.profileImage];
        profileImageView.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(200, 200)];
    }
    else {
        UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
        profileImageView.image= [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [self loadProfilePicture];

    UserInformation *userInfo = [CoreDataInterface getInstanceOfMyInformation];
    if (userInfo.fullName.length > 0) {
        nameLabel.text = userInfo.fullName;
    }
    else {
        nameLabel.text = @"No Name";
    }
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


- (IBAction)logoutButtonClicked:(id)sender {
    [GeofenceMonitor stopMonitoringGeofencesForAllEvents];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    HooThereNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
    [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    navigationController.navigationBar.barTintColor = [UIColor colorWithRed:143/255.0 green:68/255.0 blue:173/255.0 alpha:1];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    navigationController.navigationBar.translucent = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defaults dictionaryRepresentation];
    for (id key in dict) {
        if(![key isEqualToString:@"kPushNotificationUDID"])
        [defaults removeObjectForKey:key];
        
    }
    [defaults setBool:NO forKey:@"isloggedin"];
    [defaults synchronize];
    
    [CoreDataInterface wipeOutSavedData];
    
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

- (void)dudeTableViewList {
    
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Hoo There",@"title",@"hoo-there.png",@"image", nil];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Hoot Here",@"title",@"hoot-here.png",@"image", nil];
//    NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Search Events",@"title",@"searchicon.png",@"image", nil];
    NSDictionary *dict4 = [NSDictionary dictionaryWithObjectsAndKeys:@"Settings",@"title",@"setting.png",@"image", nil];
    
    [self.listOfMenus addObject:dict1];
    [self.listOfMenus addObject:dict2];
//    [self.listOfMenus addObject:dict3];
    [self.listOfMenus addObject:dict4];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = @"Friends Online";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HooThereNavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"contentController"];
    
//    [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
//    navigationController.navigationBar.barTintColor = [UIColor colorWithRed:139/255.0 green:77/255.0 blue:174/255.0 alpha:1];
//    navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    
//    navigationController.navigationBar.translucent = NO;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        HomeViewController *homeView = [self.storyboard instantiateViewControllerWithIdentifier:@"homeView"];
        homeView.segmentIndex = 0;
        navigationController.viewControllers = @[homeView];
    }
    else if (indexPath.section == 0 && indexPath.row == 1){
        HomeViewController *homeView = [self.storyboard instantiateViewControllerWithIdentifier:@"homeView"];
        homeView.segmentIndex = 1;
        navigationController.viewControllers = @[homeView];
    }
//    else if (indexPath.section == 0 && indexPath.row == 2){
//        SearchEventsViewController *searchEventsView = [self.storyboard instantiateViewControllerWithIdentifier:@"searchEventsView"];
//        navigationController.viewControllers = @[searchEventsView];
//    }
    else if (indexPath.section == 0 && indexPath.row == 2){
        NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];

        MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
        myProfileView.isUser=YES;
        myProfileView.friendId = userId;
        myProfileView.fromSidebar = YES;
        navigationController.viewControllers = @[myProfileView];
    }
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [self.listOfMenus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuSidebarCell *cell;
    static NSString *cellIdentifier = @"menuCell";
    cell = (MenuSidebarCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    NSDictionary *dictInfo = [self.listOfMenus objectAtIndex:indexPath.row];
    
    if (indexPath.section == 0) {
        
//        cell.userImageView.layer.masksToBounds = YES;
//        cell.userImageView.layer.cornerRadius = 20;
        cell.leftImageView.image = [UIImage imageNamed:[dictInfo objectForKey:@"image"]];
        
        cell.titleLabel.text = [dictInfo objectForKey:@"title"];
    }
    
    return cell;
}

@end
