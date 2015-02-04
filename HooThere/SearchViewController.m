//
//  SearchViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 29/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "SearchViewController.h"
#import "CoreDataInterface.h"
#import "CustomTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UtilitiesHelper.h"
#import "ResizeImage.h"
#import "MyProfileViewController.h"
#import "UIImageView+WebCache.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _activityIndicator = [UtilitiesHelper loadCustomActivityIndicatorWithYorigin:self.view.center.y -80 Xorigin:self.view.center.x-50];
    [self.view addSubview:_activityIndicator];
    [self.view bringSubviewToFront:_activityIndicator];
    
    [searchBarField becomeFirstResponder];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];

    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)hideKeyboard {
    [self.view endEditing:YES];
}


-(void) searchFriendsList:(NSString *)searchText{
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/search?name=%@",kwebUrl,uid,searchText];
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         //
         
         if (success) {
             
             
             
             _searchArray = [[NSMutableArray alloc] initWithArray:[[jsonDict objectForKey:@"Result"] objectForKey:@"Name"]];
             
             if (_searchArray.count > 0) {
                 searchTableView.hidden = NO;
                 
                 //[searchTableView reloadData];
             }
             else {
                 searchTableView.hidden = YES;
                 [self.noResultFoundLabel setText:@"No Results Found"];
                 
             }
             
             [searchTableView reloadData];
             NSLog(@"List of friends %@",self.searchArray);
             [self.activityIndicator stopAnimating];
         }
     }];
    
    
    
    
    
}






#pragma mark Tableview Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{       NSLog(@"%lu",[_searchArray count]);
    return [_searchArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell;
    static NSString *cellIdentifier = @"contactsCell";
    cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.iconImageview.layer.masksToBounds = YES;
    cell.iconImageview.layer.cornerRadius = 15;
    
    NSMutableDictionary *contactInfo = [_searchArray objectAtIndex:indexPath.row];
    
    NSLog(@"Contact Info ......%@",contactInfo);
    
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                            (![[contactInfo objectForKey:@"firstName"] isEqual:[NSNull null]] && [contactInfo objectForKey:@"firstName"] !=nil)?[contactInfo objectForKey:@"firstName"]:@"",
                            
                            (![[contactInfo objectForKey:@"middleName"] isEqual:[NSNull null]] && [contactInfo objectForKey:@"middleName"] !=nil)?[contactInfo objectForKey:@"middleName"]:@"",
                            (![[contactInfo objectForKey:@"lastName"] isEqual:[NSNull null]] && [contactInfo objectForKey:@"lastName"] !=nil)?[contactInfo objectForKey:@"lastName"]:@"" ];
    
    cell.sendFriendRequestButton.tag=indexPath.row;
    cell.rejectFriendRequestButton.tag=indexPath.row;
    id imageName = [contactInfo objectForKey:@"profile_picture"];
    
    UIImage* image = [UIImage imageNamed:@"defaultpic.png"];
    image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    cell.iconImageview.image= image;
    
    if (imageName != nil && ![imageName isEqual:[NSNull null]]) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@/user/%@/thumbnail",kwebUrl,[contactInfo objectForKey:@"userId"]];
//        [UtilitiesHelper getImageFromServer:[NSURL URLWithString:imageUrl] complettionBlock:^(BOOL success,UIImage *image)
//         {
//             if (success) {
//                 cell.iconImageview.image = [ResizeImage squareImageWithImage:image scaledToSize:CGSizeMake(100, 100)];
//             }
//         }];
        [cell.iconImageview sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image];
        
    }
    
    
    NSString *status = [CoreDataInterface checkUserStatus:contactInfo];
    
    if ([status isEqualToString:@"P"]) {
        cell.sendFriendRequestButton.hidden = YES;
        cell.rejectFriendRequestButton.hidden=YES;
        cell.statusImage.hidden = NO;
        
    }
    else if ([status isEqualToString:@"N"]) {
        cell.sendFriendRequestButton.hidden = NO;
        [cell.sendFriendRequestButton addTarget:self action:@selector(sendFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        [cell.sendFriendRequestButton setBackgroundImage:[UIImage imageNamed:@"add_frnd_blue.png"] forState:UIControlStateNormal];
        cell.rejectFriendRequestButton.hidden=YES;
        cell.statusImage.hidden = YES;
    }
    else if ([status isEqualToString:@"A"]) {
        cell.sendFriendRequestButton.hidden = NO;
        
        [cell.sendFriendRequestButton addTarget:self action:@selector(acceptFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        [cell.sendFriendRequestButton setBackgroundImage:[UIImage imageNamed:@"frnd_accept_blue_new.png"] forState:UIControlStateNormal];
        [cell.rejectFriendRequestButton addTarget:self action:@selector(rejectFriendRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.statusImage.hidden = YES;
    }
    else {
        cell.sendFriendRequestButton.hidden = YES;
        cell.rejectFriendRequestButton.hidden=YES;
        cell.statusImage.hidden = NO;
        cell.statusImage.image=[UIImage imageNamed:@"friend.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    //
    //
    //
    //        MyProfileViewController *myProfileView = [self.storyboard instantiateViewControllerWithIdentifier:@"myProfileView"];
    //
    //
    //        NSDictionary *contactInfo = [_searchArray objectAtIndex:indexPath.row];
    //
    //
    //        myProfileView.isUser=NO;
    //
    //        NSString *status = [CoreDataInterface checkUserStatus:contactInfo];
    //
    //        if([status isEqualToString:@"F"])
    //            myProfileView.isFriend=YES;
    //        else
    //            myProfileView.isFriend=NO;
    //
    //        myProfileView.friendId = [contactInfo objectForKey:@"userId"];
    //        self.navigationItem.title=@"User Profile";
    //        [self.navigationController pushViewController:myProfileView  animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


#pragma Mark Search Delegates-----------------

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSString *dictionaryKey = @"name";
    NSPredicate *entitySearchPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", dictionaryKey, searchText];
    
    NSArray *filteredarray =  [CoreDataInterface searchObjectsInContext:@"Facebook" andPredicate:entitySearchPredicate andSortkey:@"name" isSortAscending:YES];
    NSLog(@"%@", filteredarray);
    
    // _searchArray = [[NSMutableArray alloc] initWithArray:filteredarray];
    
    if (_searchArray.count > 0) {
        searchTableView.hidden = NO;
        //[searchTableView reloadData];
    }
    else {
        searchTableView.hidden = YES;
    }
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //[searchTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"Search Button Clicked");
    [self.activityIndicator startAnimating];
    [self searchFriendsList:searchBarField.text];
    
    [self.view endEditing:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel Clicked");
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    [self filterContentForSearchText:searchBar.text
//                               scope:nil];
    if (searchBar.text.length > 2) {
        [self searchFriendsList:searchBarField.text];
    }
}

-(void)sendFriendRequest:(UIButton * )sendFriendButton {
    
    [_activityIndicator startAnimating];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSLog(@"%ld",(long)sendFriendButton.tag);
    
    NSMutableDictionary *userInfo = [[_searchArray objectAtIndex:sendFriendButton.tag] mutableCopy];
    _requestToId = [userInfo objectForKey:@"userId"];
    
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
             [userInfo setObject:[userInfo objectForKey:@"userId"] forKey:@"id"];
             NSDictionary *friendInfo = [[NSDictionary alloc] initWithObjectsAndKeys:userInfo,@"friend",@"P",@"status", nil];
             [CoreDataInterface saveFriendList:[NSArray arrayWithObject:friendInfo]];
             [self searchFriendsList:searchBarField.text];
         }
     }];
}

-(void)rejectFriendRequest:(UIButton * )rejectFriendButton {
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    NSLog(@"%ld",(long)rejectFriendButton.tag);
    
    NSMutableDictionary *userInfo = [[_searchArray objectAtIndex:rejectFriendButton.tag] mutableCopy];
    
    NSString *toUserID = [userInfo objectForKey:@"userId"];
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/reject/%@",kwebUrl,userId,toUserID ];
    
    NSLog(@"Rejecting Request to %@",urlString);
    [_activityIndicator startAnimating];
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         if (success) {
             [_activityIndicator stopAnimating];
             
             NSPredicate* entitySearchPredicate = [NSPredicate predicateWithFormat:@"(friendId == %@)",toUserID];
             
             NSArray *retData =  [CoreDataInterface searchObjectsInContext:@"Friends" andPredicate:entitySearchPredicate andSortkey:@"friendId" isSortAscending:YES];
             if ([retData count] > 0)
             { UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"This friend has been removed from your friend list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alertView show];
                 [CoreDataInterface deleteThisFriend:[retData objectAtIndex:0]];
             }
             [userInfo setObject:@"N" forKey:@"status"];
             
             [self searchFriendsList:searchBarField.text];
         }
     }];
}


-(void)acceptFriendRequest:(UIButton * )sendFriendButton {
    [_activityIndicator startAnimating];
    
    NSString *userId=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSMutableDictionary *userInfo = [[_searchArray objectAtIndex:sendFriendButton.tag] mutableCopy];
    NSString *toUserID = [userInfo objectForKey:@"userId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/friends/%@/accept/%@",kwebUrl,userId,toUserID ];
    
    NSLog(@"accepting Request to %@",urlString);
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString: urlString] requestType:@"PUT"
                                complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         [_activityIndicator stopAnimating];
         
         if (success) {
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"HooThere" message:@"This user is added to your friend list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
             [userInfo setObject:@"F" forKey:@"status"];
             [userInfo setObject:[userInfo objectForKey:@"userId"] forKey:@"id"];
             NSDictionary *friendInfo = [[NSDictionary alloc] initWithObjectsAndKeys:userInfo,@"friend",@"F",@"status", nil];
             [CoreDataInterface saveFriendList:[NSArray arrayWithObject:friendInfo]];
             
         }
     }];
}
@end
