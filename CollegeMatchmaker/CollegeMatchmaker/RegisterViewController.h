//
//  RegisterViewController.h
//  Caredots
//
//  Created by kumar on 13/10/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"

@class SWRevealViewController;

@interface RegisterViewController : UIViewController<BSKeyboardControlsDelegate,NSURLConnectionDelegate>{
    
    NSMutableData *_responseData;
    NSURLConnection *connection1;
    NSURLConnection *connection2;
    NSUserDefaults *defaults;
    
}

@property (strong, nonatomic) IBOutlet UITextField *textUsername;
@property (strong, nonatomic) IBOutlet UITextField *textEmail;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong, nonatomic) SWRevealViewController *viewController;
@property (strong, nonatomic) UINavigationController *navController;

- (IBAction)registrationAction:(id)sender;
- (IBAction)loginAction:(id)sender;
- (IBAction)termsAction:(id)sender;
@end
