//
//  CountryListViewController.m
//  Movebee
//
//  Created by Mayank Tyagi on 19/08/12.
//  Copyright (c) 2012 mayank.tyagi@gmail.com. All rights reserved.
//

#import "CountryListViewController.h"

@interface CountryListViewController ()

@end

@implementation CountryListViewController

@synthesize language;
@synthesize delegate ;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        language = [[NSString alloc] initWithString:[[NSLocale preferredLanguages] objectAtIndex:0]];
//        searchData = [[NSMutableArray alloc] init];


    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"SelectCountry", nil);
    
    UIColor * backGroundColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"PlainBackgroundWithoutText.png"]];
	self.view.backgroundColor=backGroundColor;
    
    lblTopMovebee.text = NSLocalizedString(@"AppName", nil);
    lblTopMovebee.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:20];

       [btnBack setTitle:NSLocalizedString(@"btnBackTitle", nil) forState:UIControlStateNormal];
    
    NSString *pathToFile = [[NSBundle mainBundle] pathForResource:@"telephoneNumbers" ofType:@"csv"];
    
    NSError *error;
    NSString *content =  [NSString stringWithContentsOfFile:pathToFile encoding:NSASCIIStringEncoding error:&error];
    NSArray *contentArray = [content componentsSeparatedByString:@"\n"]; // CSV ends with ACSI 13 CR (if stored on a Mac Excel 2008)

    
    //NSLog(@"Language  %@",language);

    countryList = [[NSMutableArray alloc]init];
    countryListCode = [[NSMutableDictionary alloc]init];

    for (NSString *item in contentArray) {
        NSArray *itemArray = [item componentsSeparatedByString:@","];
        // log first item
     
        NSString *countryCode = [itemArray objectAtIndex:1];
        
        
        NSLocale *locale = [NSLocale currentLocale];
        
        NSString *country = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
        if (country == NULL) {
            continue;
        }

        [countryList addObject:country];
        
        [countryListCode setValue:[itemArray objectAtIndex:2] forKey:country];
         
//        if ([language rangeOfString:@"en"].location!=NSNotFound) {
//     
//            char alphabet = [country characterAtIndex:0];
//            NSString *uniChar = [NSString stringWithFormat:@"%c", alphabet];
//            if (![countryListIndex containsObject:uniChar])
//            {
//                [countryListIndex addObject:uniChar];
//            }
//        }
//        else if ([language isEqualToString:@"zh-Hans"] || [language isEqualToString:@"zh-Hant"]){
//        }
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterface_fixed:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return [countryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
    
    if ([language rangeOfString:@"en"].location!=NSNotFound){
        
        if ([countryList count]>0) {
            
            //---extract the relevant state from the states object---
            NSString *cellValue = [countryList objectAtIndex:indexPath.row];
            cell.textLabel.text = cellValue;
            
        }
    }else {
        NSString *cellValue = [countryList objectAtIndex:indexPath.row];
        cell.textLabel.text = cellValue;
    }
    
    // Set up the cell...
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [delegate countryListReturnedValues:[countryList objectAtIndex:[indexPath row]] andCode: [countryListCode objectForKey:[countryList objectAtIndex: [indexPath row]]]];
    [self.navigationController popViewControllerAnimated:NO];
}

@end
