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


@interface SettingsViewController : UIViewController<BSKeyboardControlsDelegate,NSURLConnectionDelegate,SWRevealViewControllerDelegate>{
    
    NSMutableData *_responseData;
    NSURLConnection *connection1;
    NSUserDefaults *defaults;
    SWRevealViewController *revealController;
    
}

@property (strong, nonatomic) IBOutlet UITextField *textUsername;
@property (strong, nonatomic) IBOutlet UITextField *textEmail;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;
@property (strong, nonatomic) IBOutlet UITextField *textRepeatPassword;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong, nonatomic) UINavigationController *navController;

@end
