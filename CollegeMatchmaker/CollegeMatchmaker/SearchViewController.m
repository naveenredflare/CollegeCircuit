//
//  SearchViewController.m
//  CollegeMatchmaker
//
//  Created by kumar on 05/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//
#import "SearchViewController.h"
#import "SWRevealViewController.h"
#import "PopupSubjectViewController.h"
#import "PopupSizeViewController.h"
#import "PopupTutionViewController.h"
#import "PopupLocationViewController.h"

#import "MatchesListTableViewController.h"


@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize majorSearch, ataLabel, sizeSearch, schoolLabel, tutionSearch, tutionLabel, locationSearch, fromFlag, hideViewsCollection, locationFirstLabel, locationSecondLabel, locationThirdLabel, locationFirstOrLabel, locationSecondOrLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    revealController = [self revealViewController];
    //[self presentViewController:revealController animated:NO completion:nil];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    self.title = @"Find a College";
    
    locationCount = 0;
    
    
	UIImage *buttonImage = [UIImage imageNamed:@"menuicon.png"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
    aButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    [aButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:aBarButtonItem];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    if(fromFlag){
        [hideViewsCollection setValue:[NSNumber numberWithBool:NO] forKey:@"hidden"];
        self.navigationController.navigationBarHidden = YES;
    } else {
        [hideViewsCollection setValue:[NSNumber numberWithBool:YES] forKey:@"hidden"];
        self.navigationController.navigationBarHidden = NO;
    }

    
    [self resetAction];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //[self resetAction];
}

- (void) resetAction {
    [self.majorSearch setTitle:@"Anything" forState:UIControlStateNormal];
    [self.majorSearch sizeToFit];
    self.ataLabel.frame = CGRectMake(self.majorSearch.frame.origin.x + self.majorSearch.frame.size.width + 5, self.ataLabel.frame.origin.y, self.ataLabel.frame.size.width, self.ataLabel.frame.size.height);
    majorSearchText = @"";
    
    [self.sizeSearch setTitle:@"Small, Medium, or Large" forState:UIControlStateNormal];
    [self.sizeSearch sizeToFit];
    self.schoolLabel.frame = CGRectMake(self.sizeSearch.frame.origin.x + self.sizeSearch.frame.size.width + 5, self.schoolLabel.frame.origin.y, self.schoolLabel.frame.size.width, self.schoolLabel.frame.size.height);
    sizeSearchText = @"";
    
    [self.tutionSearch setTitle:@"Non-Specified" forState:UIControlStateNormal];
    [self.tutionSearch sizeToFit];
    self.tutionLabel.frame = CGRectMake(self.tutionSearch.frame.origin.x + self.tutionSearch.frame.size.width + 5, self.tutionLabel.frame.origin.y, self.tutionLabel.frame.size.width, self.tutionLabel.frame.size.height);
    tutionSearchText = @"";
    
    self.locationSearch.hidden = NO;
    [self.locationSearch setTitle:@"Add Location" forState:UIControlStateNormal];
    [self.locationSearch sizeToFit];
    locationSearchText = @"";
    self.locationSearch.center = CGPointMake(71, self.tutionSearch.frame.origin.y + self.tutionSearch.frame.size.height + 32);
    
    self.locationFirstLabel.text = @"";
    self.locationSecondLabel.text = @"";
    self.locationThirdLabel.text = @"";
    
    locationFirstSearchText = @"";
    locationSecondSearchText = @"";
    locationThirdSearchText = @"";
    
    self.locationFirstLabel.hidden = YES;
    self.locationSecondLabel.hidden = YES;
    self.locationThirdLabel.hidden = YES;
    
    self.locationFirstOrLabel.hidden = YES;
    self.locationSecondOrLabel.hidden = YES;
    
    locationCount = 0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)subjectPopupAction:(UIButton *)sender {
    //the view controller you want to present as popover
    [sender setTitle:majorSearch.titleLabel.text forState:UIControlStateNormal];
    [self.majorSearch sizeToFit];
    PopupSubjectViewController *controller = [[PopupSubjectViewController alloc] initWithNibName:@"PopupSubjectViewController" bundle:nil];
    controller.title = nil;
    controller.delegate = self;
    popover = [[FPPopoverController alloc] initWithViewController:controller];
    popover.contentSize = CGSizeMake(320,260);

    [popover presentPopoverFromView:sender];
    

}

- (IBAction)sizePopupAction:(id)sender {
    //the view controller you want to present as popover
    [sender setTitle:sizeSearch.titleLabel.text forState:UIControlStateNormal];
    [self.sizeSearch sizeToFit];
    PopupSizeViewController *controller = [[PopupSizeViewController alloc] initWithNibName:@"PopupSizeViewController" bundle:nil];
    controller.title = nil;
    controller.delegate = self;
    popover = [[FPPopoverController alloc] initWithViewController:controller];
    popover.contentSize = CGSizeMake(320,260);
    
    [popover presentPopoverFromView:sender];
}

- (IBAction)tutionPopupAction:(id)sender {
    //the view controller you want to present as popover
    [sender setTitle:tutionSearch.titleLabel.text forState:UIControlStateNormal];
    [self.tutionSearch sizeToFit];
    PopupTutionViewController *controller = [[PopupTutionViewController alloc] initWithNibName:@"PopupTutionViewController" bundle:nil];
    controller.title = nil;
    controller.delegate = self;
    popover = [[FPPopoverController alloc] initWithViewController:controller];
    popover.contentSize = CGSizeMake(320,260);
    
    [popover presentPopoverFromView:sender];
}

- (IBAction)locationPopupAction:(id)sender {
    //the view controller you want to present as popover
    [sender setTitle:locationSearch.titleLabel.text forState:UIControlStateNormal];
    [self.locationSearch sizeToFit];
    PopupLocationViewController *controller = [[PopupLocationViewController alloc] initWithNibName:@"PopupLocationViewController" bundle:nil];
    controller.title = nil;
    controller.delegate = self;
    popover = [[FPPopoverController alloc] initWithViewController:controller];
    popover.contentSize = CGSizeMake(320,260);
    
    [popover presentPopoverFromView:sender];
}

-(void)selectedPickerValue:(id)responseString
{
    NSLog(@"SELECTED ROW %@",responseString);
    
    [self.majorSearch setTitle:[responseString objectForKey:@"major_name"] forState:UIControlStateNormal];
    [self.majorSearch sizeToFit];
    self.ataLabel.frame = CGRectMake(self.majorSearch.frame.origin.x + self.majorSearch.frame.size.width + 5, self.ataLabel.frame.origin.y, self.ataLabel.frame.size.width, self.ataLabel.frame.size.height);
    
    majorSearchText = [responseString objectForKey:@"major_id"];
    
    [popover dismissPopoverAnimated:YES];
}

-(void)selectedLocationPickerValue:(id)responseString
{
    NSLog(@"SELECTED ROW %@",responseString);
    locationCount = locationCount + 1;
    self.locationSearch.hidden = NO;
    self.locationFirstLabel.hidden = YES;
    self.locationSecondLabel.hidden = YES;
    self.locationThirdLabel.hidden = YES;
    self.locationFirstOrLabel.hidden = YES;
    self.locationSecondOrLabel.hidden = YES;
    if(locationCount == 0){
        self.locationSearch.hidden = NO;
        [self.locationSearch setTitle:@"Add location" forState:UIControlStateNormal];
        locationSearchText = @"";
    } else if(locationCount == 1){
        [self.locationSearch setTitle:@"Add another location" forState:UIControlStateNormal];
        self.locationFirstLabel.text = [responseString objectForKey:@"state"];
        locationFirstSearchText = [responseString objectForKey:@"state_code"];
        locationSearchText =  locationFirstSearchText;
        self.locationSearch.hidden = NO;
        self.locationFirstLabel.hidden = NO;
        self.locationSecondLabel.hidden = YES;
        self.locationThirdLabel.hidden = YES;
        
        self.locationFirstOrLabel.hidden = YES;
        self.locationSecondOrLabel.hidden = YES;
        
        self.locationSearch.center = CGPointMake(71, self.locationFirstLabel.frame.origin.y + self.locationFirstLabel.frame.size.height + 32);
    } else if(locationCount == 2) {
        [self.locationSearch setTitle:@"Add another location" forState:UIControlStateNormal];
        self.locationSecondLabel.text = [responseString objectForKey:@"state"];
        locationSecondSearchText = [responseString objectForKey:@"state_code"];
        locationSearchText = [NSString stringWithFormat:@"%@,%@", locationFirstSearchText, locationSecondSearchText];
        self.locationSearch.hidden = NO;
        self.locationFirstLabel.hidden = NO;
        self.locationSecondLabel.hidden = NO;
        self.locationThirdLabel.hidden = YES;
        
        self.locationFirstOrLabel.hidden = NO;
        self.locationSecondOrLabel.hidden = YES;
        
        self.locationSearch.center = CGPointMake(98, self.locationSecondLabel.frame.origin.y + self.locationSecondLabel.frame.size.height + 32);
    } else if(locationCount == 3) {
        [self.locationSearch setTitle:@"Add another location" forState:UIControlStateNormal];
        self.locationThirdLabel.text = [responseString objectForKey:@"state"];
        locationThirdSearchText = [responseString objectForKey:@"state_code"];
        locationSearchText = [NSString stringWithFormat:@"%@,%@,%@", locationFirstSearchText, locationSecondSearchText,locationThirdSearchText];
        self.locationSearch.hidden = YES;
        self.locationFirstLabel.hidden = NO;
        self.locationSecondLabel.hidden = NO;
        self.locationThirdLabel.hidden = NO;
        
        self.locationFirstOrLabel.hidden = NO;
        self.locationSecondOrLabel.hidden = NO;
        
        self.locationSearch.center = CGPointMake(98, self.locationThirdLabel.frame.origin.y + self.locationThirdLabel.frame.size.height + 32);
    }
    
    [self.locationSearch sizeToFit];
    //[self.locationFirstLabel sizeToFit];
    //[self.locationSecondLabel sizeToFit];
    //[self.locationThirdLabel sizeToFit];
    
    //self.ataLabel.frame = CGRectMake(self.majorSearch.frame.origin.x + self.majorSearch.frame.size.width + 5, self.ataLabel.frame.origin.y, self.ataLabel.frame.size.width, self.ataLabel.frame.size.height);
    
    
    
    [popover dismissPopoverAnimated:YES];
}


-(void)selectedSizePickerValue:(NSString *)responseString
{
    NSLog(@"SELECTED ROW %@",responseString);
    [self.sizeSearch setTitle:responseString forState:UIControlStateNormal];
    [self.sizeSearch sizeToFit];
    self.schoolLabel.frame = CGRectMake(self.sizeSearch.frame.origin.x + self.sizeSearch.frame.size.width + 5, self.schoolLabel.frame.origin.y, self.schoolLabel.frame.size.width, self.schoolLabel.frame.size.height);
    
    sizeSearchText = [responseString lowercaseString];
    
    [popover dismissPopoverAnimated:YES];
}

-(void)selectedTutionPickerValue:(NSString *)responseString
{
    NSLog(@"SELECTED ROW %@",responseString);
    [self.tutionSearch setTitle:responseString forState:UIControlStateNormal];
    [self.tutionSearch sizeToFit];
    self.tutionLabel.frame = CGRectMake(self.tutionSearch.frame.origin.x + self.tutionSearch.frame.size.width + 5, self.tutionLabel.frame.origin.y, self.tutionLabel.frame.size.width, self.tutionLabel.frame.size.height);
    
    tutionSearchText = [responseString lowercaseString];
    
    [popover dismissPopoverAnimated:YES];
}

- (IBAction)resetButtonAction:(id)sender {
    [self resetAction];
}

- (IBAction)viewMatchesButtonAction:(id)sender {
    MatchesListTableViewController *matchesListVC = [[MatchesListTableViewController alloc] init];
    matchesListVC.majorSearchText = majorSearchText;
    if([sizeSearchText isEqualToString:@"small-sized"]){
        matchesListVC.sizeSearchText = @"1";
    } else if([sizeSearchText isEqualToString:@"medium-sized"]){
        matchesListVC.sizeSearchText = @"2";
    } else if([sizeSearchText isEqualToString:@"large-sized"]){
        matchesListVC.sizeSearchText = @"3";
    } else {
        matchesListVC.sizeSearchText = @"";
    }
    
    if([tutionSearchText isEqualToString:@"0k - 5k"]){
        matchesListVC.tutionSearchText = @"1";
    } else if([tutionSearchText isEqualToString:@"5k - 15k"]){
        matchesListVC.tutionSearchText = @"2";
    } else if([tutionSearchText isEqualToString:@"15k - 25k"]){
        matchesListVC.tutionSearchText = @"3";
    } else if([tutionSearchText isEqualToString:@"25k - 50k"]){
        matchesListVC.tutionSearchText = @"4";
    }  else if([tutionSearchText isEqualToString:@"> 50k"]){
        matchesListVC.tutionSearchText = @"5";
    } else {
        matchesListVC.tutionSearchText = @"";
    }
    
    matchesListVC.locationSearchText = locationSearchText;
    
    [self.navigationController pushViewController:matchesListVC animated:YES];
}

- (IBAction)okAction:(id)sender {
    [hideViewsCollection setValue:[NSNumber numberWithBool:YES] forKey:@"hidden"];
    self.navigationController.navigationBarHidden = NO;
}
@end
