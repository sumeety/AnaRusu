//
//  SearchLocationViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 05/12/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "CustomTableViewCell.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "EventGeoFenceViewController.h"
#import "LocationHandler.h"

@interface SearchLocationViewController ()

@end

@implementation SearchLocationViewController

@synthesize searchArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [searchBarField becomeFirstResponder];
    
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(hideKeyboard)];
//    singleTap.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:singleTap];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}


- (void)searchLocationList:(NSString *)searchText{
//    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?sensor=true&key=AIzaSyDlFXsZsC7XoYCZ1v6sEL2autBMyJehwUE&components=country:US&input=%@",searchText];
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?sensor=true&key=AIzaSyDlFXsZsC7XoYCZ1v6sEL2autBMyJehwUE&input=%@",searchText];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"POST Request: %@", request);
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *response, NSData *jsonData, NSError *requestError)
     {
         if (requestError!=nil) {
             return ;
         }
         if (jsonData == nil) {
             return ;
         }
         
         NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
         
         NSLog(@"Response : %@",responseString);
         responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
         responseString = [responseString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
         responseString = [responseString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
         
         NSData *jsonData1 = [responseString dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary *dictionary = [NSJSONSerialization
                                     JSONObjectWithData:jsonData1
                                     options:kNilOptions
                                     error:&requestError];
         self.searchArray = [[NSMutableArray alloc] init];
         self.searchArray = [dictionary objectForKey:@"predictions"];
         
         [searchTableView reloadData];
     }];
}

#pragma mark Tableview Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomTableViewCell *cell;
    static NSString *cellIdentifier = @"searchCell";
    cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
//    NSDictionary *locationInfo = [self.searchArray objectAtIndex:indexPath.row];
    
    NSMutableDictionary *locationInfo = [self getTitleAndSubtitle:[[self.searchArray objectAtIndex:indexPath.row] objectForKey:@"description"]];
    
    cell.titleLabel.text = [locationInfo objectForKey:@"title"];
    cell.subTitleLabel.text = [locationInfo objectForKey:@"subTitle"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *locationInfo = [self.searchArray objectAtIndex:indexPath.row];

    NSString *placeId = [locationInfo objectForKey:@"place_id"];
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyDlFXsZsC7XoYCZ1v6sEL2autBMyJehwUE",placeId];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [UtilitiesHelper getResponseFor:nil url:[NSURL URLWithString:urlString] requestType:@"GET" complettionBlock:^(BOOL success,NSDictionary *jsonDict)
     {
         NSDictionary *placeInfo = [jsonDict objectForKey:@"result"];
         
         NSString *locationName = [placeInfo objectForKey:@"formatted_address"];
         
         NSDictionary *locationInfo = [LocationHandler getDictionaryFromStringAddress:locationName];
         
         
         _thisEvent.venueName = [placeInfo objectForKey:@"name"];
         _thisEvent.streetName = [locationInfo objectForKey:@"street"];
         _thisEvent.city = [locationInfo objectForKey:@"city"];
         _thisEvent.country = [locationInfo objectForKey:@"country"];
         _thisEvent.state = [locationInfo objectForKey:@"state"];
         _thisEvent.zipcode = [locationInfo objectForKey:@"zip"];
         _thisEvent.latitude = [[[[placeInfo objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] stringValue];
         _thisEvent.longitude = [[[[placeInfo objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] stringValue];
         _thisEvent.address = [placeInfo objectForKey:@"formatted_address"];
         
         [CoreDataInterface saveAll];
         
         if (_isEditing) {
             NSMutableArray *navigationViewsArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
             [navigationViewsArray removeLastObject];
             [navigationViewsArray removeLastObject];
             [self.navigationController setViewControllers:navigationViewsArray animated:NO];
         }
         else {
             EventGeoFenceViewController *eventGeoFenceView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventGeoFenceView"];
             eventGeoFenceView.isEditing=NO;
             eventGeoFenceView.title = self.title;
             eventGeoFenceView.latitudeStr = [[[[placeInfo objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] stringValue];
             eventGeoFenceView.longitudeStr = [[[[placeInfo objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] stringValue];
             eventGeoFenceView.thisEvent = _thisEvent;
             [self .navigationController pushViewController:eventGeoFenceView animated:YES];
         }
         
     }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSMutableDictionary *locationInfo = [self.searchArray objectAtIndex:indexPath.row];
    
    NSMutableDictionary *locationInfo = [self getTitleAndSubtitle:[[self.searchArray objectAtIndex:indexPath.row] objectForKey:@"description"]];
    
    NSString *location = [locationInfo objectForKey:@"subTitle"];
    
    CGFloat height = [self heigthWithWidth:273 andFont:[UIFont systemFontOfSize:13] string:location];
    
    if (height > 23) {
        return height+42;
    }
    else {
        return 65;
    }
}

- (NSMutableDictionary *)getTitleAndSubtitle:(NSString *)description {
    
    NSMutableDictionary *location = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *descriptionArray = [[description componentsSeparatedByString:@","] mutableCopy];
    
    NSString *subTitle = @"";
    
    if (descriptionArray.count > 0 && descriptionArray.count < 2) {
        [location setObject:[descriptionArray objectAtIndex:0] forKey:@"title"];
        [location setObject:subTitle forKey:@"subTitle"];
    }
    else if (descriptionArray.count > 1) {
        [location setObject:[descriptionArray objectAtIndex:0] forKey:@"title"];
        [descriptionArray removeObjectAtIndex:0];
        
        subTitle = [descriptionArray objectAtIndex:0];
        
        [descriptionArray removeObjectAtIndex:0];
        for (int i = 0; i < descriptionArray.count; i++) {
            subTitle = [NSString stringWithFormat:@"%@, %@",subTitle,[descriptionArray objectAtIndex:i]];
        }
        
        [location setObject:subTitle forKey:@"subTitle"];
    }
    
    return location;
}


#pragma Mark Search Delegates-----------------

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //[searchTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"Search Button Clicked");
    [self searchLocationList:searchBarField.text];
    
    [self.view endEditing:YES];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel Clicked");
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchBar.text.length > 2) {
        [self searchLocationList:searchBarField.text];
    }
}

- (CGFloat)heigthWithWidth:(CGFloat)width andFont:(UIFont *)font string:(NSString *)string
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [string length])];
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return rect.size.height;
}


@end
