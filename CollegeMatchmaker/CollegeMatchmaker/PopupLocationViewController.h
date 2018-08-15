//
//  PopupLocationViewController.h
//  CollegeMatchmaker
//
//  Created by manik on 26/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchViewController;

@interface PopupLocationViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,NSURLConnectionDelegate>{
    NSMutableData *_responseData;
    NSURLConnection *connection1;
    NSMutableArray *pickerDataComplete;
}
@property (strong, nonatomic) IBOutlet UIPickerView *pickerLocation;
@property(nonatomic,assign) SearchViewController *delegate;
- (IBAction)doneAction:(id)sender;


@end
