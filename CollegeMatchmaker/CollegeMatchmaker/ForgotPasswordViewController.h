//
//  ForgotPasswordViewController.h
//  CollegeMatchmaker
//
//  Created by kumar on 05/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "MBProgressHUD.h"

@interface ForgotPasswordViewController : UIViewController<BSKeyboardControlsDelegate,NSURLConnectionDelegate>{
    
    NSMutableData *_responseData;
    NSURLConnection *connection1;
    
}
@property (strong, nonatomic) IBOutlet UITextField *textEmail;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

- (IBAction)forgotPasswordAction:(id)sender;

@end
