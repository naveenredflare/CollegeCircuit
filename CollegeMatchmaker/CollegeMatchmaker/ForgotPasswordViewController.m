//
//  ForgotPasswordViewController.m
//  CollegeMatchmaker
//
//  Created by kumar on 05/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "ServiceURL.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController
@synthesize textEmail;

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
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    self.textEmail.autocorrectionType = UITextAutocorrectionTypeNo;
    
    NSArray *fields = @[ self.textEmail];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)validateForm {
    NSString *errorMessage;
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (!(self.textEmail.text.length >= 1)){
        errorMessage = @"Please enter a email address";
    } else if (![emailPredicate evaluateWithObject:self.textEmail.text]){
        errorMessage = @"Please enter a valid email address";
    }
    return errorMessage;
}

- (IBAction)forgotPasswordAction:(id)sender {
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [[[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/forgotpassword/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"forgot_email=%@",self.textEmail.text];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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
    if (connection == connection1){
        NSData *jsonData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        NSLog(@"%@",dict);
        
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
}


@end
