//
//  OverViewViewController.m
//  HooThere
//
//  Created by Abhishek Tyagi on 17/09/14.
//  Copyright (c) 2014 Quovantis Technologies. All rights reserved.
//

#import "OverViewViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "FacebookSignUpViewController.h"
#import "EventGeoFenceViewController.h"
#import "UtilitiesHelper.h"
#import "CoreDataInterface.h"
#import "HomeViewController.h"
#import "SearchLocationViewController.h"
#import "MyProfileViewController.h"
#import "WhoThereViewController.h"

@interface OverViewViewController ()

@end

@implementation OverViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *colors = [NSArray arrayWithObjects:[UIColor whiteColor], nil];
    for (int i = 0; i < colors.count; i++) {
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *subview = [[UIImageView alloc] initWithFrame:CGRectMake((self.scrollView.frame.size.width * i) +30, 60, 260, 200)];
        subview.image = [UIImage imageNamed:@"newlogo.png"];
        subview.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:subview];
    }
    
    _pageControl.hidden = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL loggedIn = [defaults boolForKey:@"isloggedin"];
    [defaults synchronize];
    NSLog(@"logginIn %s",(loggedIn?"YES":"NO"));
    if (loggedIn) {
        WhoThereViewController *whoThereView = [self.storyboard instantiateViewControllerWithIdentifier:@"whoThereView"];
//        NSMutableArray *navigationArray = [self.navigationController.viewControllers mutableCopy];
//        [navigationArray removeLastObject];
//        [navigationArray addObject:whoThereView];
        [self.navigationController pushViewController:whoThereView animated:NO];//[NSArray arrayWithObjects:whoThereView, nil] animated:NO];
    }
    else {
        self.tabBarController.tabBar.hidden = YES;
    }
    
  
    hooThereLoginButton.layer.borderWidth=1.0f;
     hooThereLoginButton.layer.borderColor=[UIColor purpleColor].CGColor;
    hooThereLoginButton.layer.cornerRadius=3;
    
    getStartedButton.layer.cornerRadius=3;
    
    
//    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * colors.count, self.scrollView.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDisablePanGestureRequest" object:nil userInfo:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}



- (IBAction)loginButtonClicked:(id)sender {
    LoginViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    [self .navigationController pushViewController:loginView animated:YES];
//    SearchLocationViewController *searchLocationView = [self.storyboard instantiateViewControllerWithIdentifier:@"searchLocationView"];
//    [self presentViewController:searchLocationView animated:YES completion:nil];
}

- (IBAction)gettingStartedButtonClicked:(id)sender {
    
    //    SignUpModel *signUpModel = [SignUpModel getInstance];
    //
    //    UIImage *image = [[self.profilePictureView.subviews objectAtIndex:0] image];
    //
    //    signUpModel.userpicture = image;
    //
    SignUpViewController *signUpView = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpView"];
    
//    [self setTransitionView:kCATransitionFromTop];
    [self .navigationController pushViewController:signUpView animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    _pageControlBeingUsed = YES;
}

- (void)setTransitionView:(NSString *)subType {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = subType;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
}

@end
