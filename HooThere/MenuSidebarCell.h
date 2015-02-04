//
//  MenuSidebarCell.h
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuSidebarCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel      *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel      *subTitleLabel;
@property (nonatomic, strong) IBOutlet UIImageView  *leftImageView;

@property (strong, nonatomic) IBOutlet UIImageView *rightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *statusImageView;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;

@property (strong, nonatomic) IBOutlet UIImageView *youImageView;



@end
