//
//  CircleView.m
//  TSCircleView
//
//  Created by Tomasz Szulc  on 15/07/14.
//  Copyright (c) 2014 Tomasz Szulc. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {//143, 68, 173
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:143/255.0 green:68/255.0 blue:173/255.0 alpha:0.4].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:143/255.0 green:68/255.0 blue:173/255.0 alpha:0.4].CGColor);
    CGContextSetLineWidth(context, 5);
    
    CGRect insetRect = CGRectInset(self.bounds, 5, 5);
    insetRect.origin = CGPointMake(5, 5);
    
    CGContextFillEllipseInRect(context, insetRect);
    CGContextStrokeEllipseInRect(context, insetRect);
}


@end
