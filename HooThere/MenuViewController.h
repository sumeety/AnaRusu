//
//  MenuViewController.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "AppDelegate.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UIImageView        *profileImageView;
    IBOutlet UIButton *logoutButton;
    IBOutlet UILabel *nameLabel;
}

@property (nonatomic, strong) IBOutlet UITableView      *menuTableView;
@property (nonatomic, strong) NSMutableArray            *listOfMenus;

@property (nonatomic, retain) NSManagedObjectContext        *   managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator  *   persistentStoreCoordinator;

- (IBAction)logoutButtonClicked:(id)sender;

@end
