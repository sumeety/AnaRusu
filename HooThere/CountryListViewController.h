//
//  CountryListViewController.h
//  Movebee
//
//  Created by Mayank Tyagi on 19/08/12.
//  Copyright (c) 2012 mayank.tyagi@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol countryListDelegate;

//@class RegisterByPhoneViewControllerViewController;
@interface CountryListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
    IBOutlet UITableView *countryListTableView;
    IBOutlet UIButton *btnBack;
     IBOutlet UILabel *lblTopMovebee;
    NSMutableArray              *countryList;

    NSMutableDictionary              *countryListCode;
    NSString *language;
    //id <countryListDelegate> delegate_;
    __unsafe_unretained id delegate;


}

@property(nonatomic,retain) NSString *language;
@property (nonatomic, assign) id <countryListDelegate> delegate;


//-(IBAction)actionBtnBackClicked:(id)sender;


@end

@protocol countryListDelegate <NSObject>

-(void)countryListReturnedValues:(NSString *)countryName andCode:(NSString *) countryCode;

@end
