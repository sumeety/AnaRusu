//
//  SelectLocationTypeViewController.m
//  Hoothere
//
//  Created by Abhishek Tyagi on 18/12/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "SelectLocationTypeViewController.h"
#import "EventLocationViewController.h"
#import "SearchLocationViewController.h"

@interface SelectLocationTypeViewController ()

@end

@implementation SelectLocationTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)manualSearchButtonClicked:(id)sender {
    EventLocationViewController *eventLocationView = [self.storyboard instantiateViewControllerWithIdentifier:@"eventLocationView"];
    eventLocationView.title = _thisEvent.name;
    eventLocationView.thisEvent = _thisEvent;
    if (_isEditing) {
        eventLocationView.isEditing = YES;
    }
    [self.navigationController pushViewController:eventLocationView animated:YES];
}

- (IBAction)googleSearchButtonClicked:(id)sender {
    SearchLocationViewController *searchLocationView = [self.storyboard instantiateViewControllerWithIdentifier:@"searchLocationView"];
    searchLocationView.title = _thisEvent.name;
    searchLocationView.thisEvent = _thisEvent;
    if (_isEditing) {
        searchLocationView.isEditing = YES;
    }
    [self.navigationController pushViewController:searchLocationView animated:NO];
}

@end
