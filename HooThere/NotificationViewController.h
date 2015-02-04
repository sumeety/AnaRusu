//
//  NotificationViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 18/11/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIView         *notificationView;
    IBOutlet UITableView    *notificationTableView;
    UITableViewCell *loadMoreCell;
}


@property (nonatomic) BOOL loadMore;
@property (nonatomic, strong) NSMutableArray    *listOfNotifications;
@property (nonatomic)NSInteger notificationCount;
@property (nonatomic)NSInteger pageCount;
@property (nonatomic, strong) UITableViewCell *loadMoreCell;
@property (strong, nonatomic) UIActivityIndicatorView   *activityIndicator;

@end
