//
//  LoginViewController.h
//  CollegeMatchmaker
//
//  Created by Kumar  on 21/10/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"

@class SWRevealViewController;

@interface LoginViewController : UIViewController<BSKeyboardControlsDelegate,NSURLConnectionDelegate,UIGestureRecognizerDelegate,NSURLConnectionDataDelegate>{
    
    NSMutableData *_responseData;
    NSURLConnection *connection1;
    NSUserDefaults *defaults;
    
}

@property (strong, nonatomic) IBOutlet UITextField *textUsername;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) SWRevealViewController *viewController;

- (IBAction)loginAction:(id)sender;
- (IBAction)registerationAction:(id)sender;
- (IBAction)forgotPasswordAction:(id)sender;

@end
