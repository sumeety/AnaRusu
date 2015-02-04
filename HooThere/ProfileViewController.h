//
//  ProfileViewController.h
//  Hoothere
//
//  Created by Steve Sopoci on 1/19/15.
//  Copyright (c) 2015 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInformation.h"

@interface ProfileViewController : UIViewController{
    
}

@property (nonatomic)BOOL isUser;
@property (nonatomic)BOOL isFromHootHere;
@property (nonatomic,strong)NSString *friendId;
@property (nonatomic,strong)NSDictionary *friendData;
@property (nonatomic, strong) NSMutableArray    *listOfFriends;
@property (nonatomic,strong)UserInformation *userInformation;
@property (nonatomic)BOOL isMyFriend;

@end
