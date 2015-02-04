//
//  StatusViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 14/10/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UtilitiesHelper.h"
#import "UserInformation.h"

@interface StatusViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet    UITableView         *statusTableView;
}

@property (nonatomic, strong) NSMutableArray    *listOfStatus;
@property (nonatomic, strong) UserInformation   *userInformation;

@end
