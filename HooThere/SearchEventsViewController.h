//
//  SearchEventsViewController.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 05/01/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchEventsViewController : UIViewController <UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UISearchBar *searchBarField;
    IBOutlet UITableView *eventTableView;
}

@property (nonatomic) BOOL   noEvents;

@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;
@property (nonatomic, strong) NSMutableArray            *listOfEvents;

- (IBAction)joinButtonClicked:(UIButton *)button;

@end
