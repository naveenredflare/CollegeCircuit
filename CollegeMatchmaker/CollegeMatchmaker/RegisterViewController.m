//
//  RegisterViewController.m
//  Caredots
//
//  Created by kumar on 13/10/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "BSKeyboardControls.h"
#import "DashboardViewController.h"
#import "SearchViewController.h"
#import "ServiceURL.h"

@interface RegisterViewController ()<SWRevealViewControllerDelegate>

@end

@implementation RegisterViewController
@synthesize textUsername,textEmail,textPassword,navController;
@synthesize viewController = _viewController;

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
    self.navigationController.navigationBar.hidden = YES;
    self.textUsername.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    NSArray *fields = @[ self.textUsername, self.textEmail, self.textPassword];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registrationAction:(id)sender {
    
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [[[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/createuser/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"fullname=%@&username=%@&password=%@&email=%@&device_id=%@",self.textUsername.text,self.textUsername.text,self.textPassword.text,self.textEmail.text,@"0"];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)loginProcessingAction {
    [self.view endEditing:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/login/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"username=%@&password=%@",self.textUsername.text,self.textPassword.text];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection2 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (IBAction)loginAction:(id)sender {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)termsAction:(id)sender {
    NSLog(@"terms");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://collegecircuit.org/terms.html"]];
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
    } else if (!(self.textPassword.text.length >= 1)){
        errorMessage = @"Please enter a password";
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
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        NSLog(@"%@",dict);
        
        
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            [[[UIAlertView alloc] initWithTitle:nil message:@"You have been registered successfully" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            
            //LoginViewController *loginVC = [[LoginViewController alloc] init];
            //[self.navigationController pushViewController:loginVC animated:YES];
            [self loginProcessingAction];
            
            
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    } else if(connection == connection2){
        NSData *jsonData = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        NSLog(@"%@",dict);
        
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
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
            
            
            [data setObject:[[dict objectForKey:@"records"] objectForKey:@"user_email"] forKey:@"user_email"];
            [data setObject:[[dict objectForKey:@"records"] objectForKey:@"user_name"] forKey:@"user_name"];
            [data setObject:[[dict objectForKey:@"records"] objectForKey:@"user_id"] forKey:@"user_id"];
            
            [data writeToFile: path atomically:YES];
            
            defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[[dict objectForKey:@"records"] objectForKey:@"user_name"] forKey:@"user_name"];
            [defaults setObject:[[dict objectForKey:@"records"] objectForKey:@"user_id"] forKey:@"user_id"];
            [defaults setObject:[[dict objectForKey:@"records"] objectForKey:@"user_email"] forKey:@"user_email"];
            [defaults synchronize];
            
            //SearchViewController *searchVC = [[SearchViewController alloc] init];
            
            //self.navController = [[UINavigationController alloc] initWithRootViewController:searchVC];
            
            SearchViewController *frontViewController = [[SearchViewController alloc] init];
            frontViewController.fromFlag = 1;
            DashboardViewController *rearViewController = [[DashboardViewController alloc] init];
            
            UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
            UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
            
            SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
            revealController.delegate = self;
            
            self.viewController = revealController;
            self.view.window.rootViewController = self.viewController;
            
            [self.view.window addSubview:self.navController.view];
            
            
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
