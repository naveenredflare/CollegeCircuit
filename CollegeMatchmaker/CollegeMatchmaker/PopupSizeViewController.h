//
//  PopupSizeViewController.h
//  CollegeMatchmaker
//
//  Created by manik on 26/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchViewController;

@interface PopupSizeViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIPickerView *pickerSize;
@property(nonatomic,assign) SearchViewController *delegate;
- (IBAction)doneAction:(id)sender;

@end
