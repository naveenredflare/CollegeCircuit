//
//  PopupSubjectViewController.h
//  CollegeMatchmaker
//
//  Created by kumar on 13/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchViewController;

@interface PopupSubjectViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, NSURLConnectionDelegate>{
    NSMutableData *_responseData;
    NSURLConnection *connection1;
    NSMutableArray *pickerDataComplete;
}
@property (strong, nonatomic) IBOutlet UIPickerView *pickerSubject;
@property(nonatomic,assign) SearchViewController *delegate;
- (IBAction)doneAction:(id)sender;

@end
