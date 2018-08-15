//
//  SearchViewController.h
//  CollegeMatchmaker
//
//  Created by kumar on 05/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "FPPopoverController.h"

@interface SearchViewController : UIViewController<SWRevealViewControllerDelegate,FPPopoverControllerDelegate> {
    
    SWRevealViewController *revealController;
    
    FPPopoverController *popover;
    
    NSString *majorSearchText;
    NSString *sizeSearchText;
    NSString *tutionSearchText;
    NSString *locationSearchText;
    
    NSString *locationFirstSearchText;
    NSString *locationSecondSearchText;
    NSString *locationThirdSearchText;
    
    int locationCount;
    
}
@property (strong, nonatomic) IBOutlet UIButton *majorSearch;
@property (strong, nonatomic) IBOutlet UILabel *ataLabel;
@property (strong, nonatomic) IBOutlet UIButton *sizeSearch;
@property (strong, nonatomic) IBOutlet UILabel *schoolLabel;
@property (strong, nonatomic) IBOutlet UIButton *tutionSearch;
@property (strong, nonatomic) IBOutlet UILabel *tutionLabel;
@property (strong, nonatomic) IBOutlet UIButton *locationSearch;
@property (weak, nonatomic) IBOutlet UILabel *locationFirstLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationSecondLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationThirdLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationFirstOrLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationSecondOrLabel;

-(void)selectedPickerValue:(id)responseString;
-(void)selectedSizePickerValue:(NSString *)responseString;
-(void)selectedTutionPickerValue:(NSString *)responseString;
-(void)selectedLocationPickerValue:(id)responseString;


- (IBAction)subjectPopupAction:(UIButton *)sender;
- (IBAction)resetButtonAction:(id)sender;
- (IBAction)viewMatchesButtonAction:(id)sender;
- (IBAction)sizePopupAction:(id)sender;
- (IBAction)tutionPopupAction:(id)sender;
- (IBAction)locationPopupAction:(id)sender;


/*----------Hide View Collection------------*/
- (IBAction)okAction:(id)sender;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *hideViewsCollection;
@property BOOL fromFlag;
/*--------------------------------------------------*/


@end
