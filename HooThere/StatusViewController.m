//
//  StatusViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 14/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "StatusViewController.h"
#import "MenuSidebarCell.h"
#import "CoreDataInterface.h"

@interface StatusViewController ()

@end

@implementation StatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self loadStatusList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStatusList {
    
    _listOfStatus = [[NSMutableArray alloc] init];
    
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Looking for plans",@"title",@"makeplan.png",@"image", nil];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Going Out",@"title",@"going.png",@"image", nil];
    NSDictionary *dict3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Busy",@"title",@"invited.png",@"image", nil];
    
    [_listOfStatus addObject:dict1];
    [_listOfStatus addObject:dict2];
    [_listOfStatus addObject:dict3];
  

    [statusTableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [_listOfStatus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuSidebarCell *cell;
    static NSString *cellIdentifier = @"statusCell";
    cell = (MenuSidebarCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    NSDictionary *dictInfo = [_listOfStatus objectAtIndex:indexPath.row];
    
    if (indexPath.section == 0) {
        cell.leftImageView.image = [UIImage imageNamed:[dictInfo objectForKey:@"image"]];
        cell.titleLabel.text = [dictInfo objectForKey:@"title"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dictInfo = [_listOfStatus objectAtIndex:indexPath.row];
    
    NSString *statusSelected=[dictInfo objectForKey:@"title"];
    _userInformation = [CoreDataInterface getInstanceOfMyInformation];
    _userInformation.availabilityStatus=statusSelected;
    [CoreDataInterface saveAll];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"kSendStatusSelected" object:dictInfo userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [ self sendingStatusChangeRequest:statusSelected];
}

- (void)sendingStatusChangeRequest:(NSString*) statusSelected {
   
    NSDictionary *statusData = [[NSDictionary alloc] initWithObjectsAndKeys:
                              statusSelected , @"newStatus" ,
                             
                              nil];
    
    
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/%@/updateAvailabiltyStatus",kwebUrl,uid];
    
    [UtilitiesHelper getResponseFor:statusData url:[NSURL URLWithString:urlString] requestType:@"PUT" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         //[_activityIndicator stopAnimating];
         
         if (success) {
             NSLog(@"Status Changed !!");
         }
         _userInformation=[CoreDataInterface getInstanceOfMyInformation];
         _userInformation.availabilityStatus=statusSelected;
         [CoreDataInterface saveAll];
     }];
}


- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}

@end
