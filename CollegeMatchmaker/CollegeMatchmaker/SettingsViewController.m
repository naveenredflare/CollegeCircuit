//
//  RegisterViewController.m
//  Caredots
//
//  Created by kumar on 13/10/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import "SettingsViewController.h"
#import "BSKeyboardControls.h"
#import "SWRevealViewController.h"
#import "ServiceURL.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize textUsername,textEmail,textPassword,textRepeatPassword,navController;

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
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = NO;
    self.textUsername.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textRepeatPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    NSArray *fields = @[ self.textUsername, self.textEmail, self.textPassword, self.textRepeatPassword];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.textUsername.text = [defaults stringForKey:@"user_name"];
    self.textEmail.text = [defaults stringForKey:@"user_email"];
    
    
    revealController = [self revealViewController];
    revealController.delegate = self;
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
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
    
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(updateAction)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.title = @"Settings";

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateAction {
    
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [[[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/updateuser/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"user_id=%@&username=%@&password=%@&email=%@",[defaults stringForKey:@"user_id"],self.textUsername.text,self.textPassword.text,self.textEmail.text];
    NSLog(@"%@",stringData);
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}



- (NSString *)validateForm {
    NSString *errorMessage;
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (!(self.textUsername.text.length >= 1)){
        errorMessage = @"Please enter a username";
    } else if (!(self.textEmail.text.length >= 1)){
        errorMessage = @"Please enter a email address";
    } else if (![emailPredicate evaluateWithObject:self.textEmail.text]){
        errorMessage = @"Please enter a valid email address";
    } else if (![self.textPassword.text isEqualToString:self.textRepeatPassword.text]){
        errorMessage = @"Your password and repeat password does not match";
    }
    
    return errorMessage;
}

#pragma mark -
#pragma mark Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
}

- (void)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
}

#pragma mark -
#pragma mark Keyboard Controls Delegate

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [self.view endEditing:YES];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    //_responseData = data;
    [_responseData appendData:data];
    
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    if (connection == connection1){
        NSData *jsonData = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON Output: %@", jsonString);
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        NSLog(@"%@",dict);
        
        
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            [[[UIAlertView alloc] initWithTitle:nil message:@"You have upated successfully" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            
            NSError *error;
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
            
            NSString *documentsDirectory = [paths objectAtIndex:0]; //2
            
            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"UserInfo.plist"]; //3
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath: path]) //4
                
            {
                
                NSString *bundle = [[NSBundle mainBundle] pathForResource:@"UserInfo" ofType:@"plist"]; //5
                
                [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
                
            }
            
            NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
            
            //here add elements to data file and write data to file
            
            
            [data setObject:[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"user_email"] forKey:@"user_email"];
            [data setObject:[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"user_name"] forKey:@"user_name"];
            [data setObject:[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"user_id"] forKey:@"user_id"];
            
            [data writeToFile: path atomically:YES];
            
            [defaults setObject:[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"user_name"] forKey:@"user_name"];
            [defaults setObject:[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"user_id"] forKey:@"user_id"];
            [defaults setObject:[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"user_email"] forKey:@"user_email"];
            [defaults synchronize];
            
            self.textPassword.text = @"";
            self.textRepeatPassword.text = @"";
            
            
            
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Ch
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}




@end
