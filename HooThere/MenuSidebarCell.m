//
//  MenuSidebarCell.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "MenuSidebarCell.h"

@implementation MenuSidebarCell

@synthesize titleLabel, subTitleLabel, leftImageView;

- (void)awakeFromNib {
    
    //titleLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
