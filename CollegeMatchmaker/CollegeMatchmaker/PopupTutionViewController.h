//
//  PopupTutionViewController.h
//  CollegeMatchmaker
//
//  Created by manik on 26/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchViewController;

@interface PopupTutionViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *pickerTution;
@property(nonatomic,assign) SearchViewController *delegate;
- (IBAction)doneAction:(id)sender;


@end
