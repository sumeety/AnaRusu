//
//  SelectLocationTypeViewController.h
//  Hoothere
//
//  Created by Abhishek Tyagi on 18/12/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataInterface.h"

@interface SelectLocationTypeViewController : UIViewController {
    
    IBOutlet UIButton               *manualSearchButton;
    IBOutlet UIButton               *googleSearchButton;
}

- (IBAction)manualSearchButtonClicked:(id)sender;
- (IBAction)googleSearchButtonClicked:(id)sender;

@property (strong, nonatomic) Events    *thisEvent;
@property (nonatomic)BOOL isEditing;

@end
