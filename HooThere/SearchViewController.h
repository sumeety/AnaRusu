//
//  SearchViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 29/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    IBOutlet UISearchBar *searchBarField;
    IBOutlet UITableView *searchTableView;
}

@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSString *requestToId;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;

@property (strong, nonatomic) IBOutlet UILabel *noResultFoundLabel;


@end
