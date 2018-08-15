//
//  PopupLocationViewController.m
//  CollegeMatchmaker
//
//  Created by manik on 26/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import "PopupLocationViewController.h"
#import "SearchViewController.h"
#import "ServiceURL.h"

@interface PopupLocationViewController (){
    NSArray *_pickerData;
}

@end

@implementation PopupLocationViewController
@synthesize pickerLocation;
@synthesize delegate=_delegate;

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
    pickerDataComplete = [NSMutableArray array];
    [self locationDetail];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel *label = [[UILabel alloc] init];
    CGRect frame = CGRectMake(10,0,265,40);
    label.frame = frame;
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:18.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    
    if(component == 0)
    {
        label.text = [_pickerData objectAtIndex:row];
    }
    return label;
}

- (void) locationDetail {
    
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/getallstate/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@""];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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
    if(connection == connection1){
        NSData *jsonData = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSMutableDictionary *dict = nil;
        dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        NSLog(@"%@",dict);
        
        

        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            NSMutableArray *pickerArray;
            pickerArray = [NSMutableArray array];
            [pickerArray addObject:@"Any State"];
            NSMutableDictionary *firstDict = [[NSMutableDictionary alloc]initWithCapacity:0];
            [firstDict setObject:@"" forKey:@"state_code"];
            [firstDict setObject:@"Any State" forKey:@"state"];
            [pickerDataComplete addObject:firstDict];
            for(id obj in [dict objectForKey:@"records"]){
                [pickerArray addObject:[obj objectForKey:@"state"]];
                [pickerDataComplete addObject:obj];
            }
            _pickerData = pickerArray;
            
            self.pickerLocation.dataSource = self;
            self.pickerLocation.delegate = self;
            
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Ch
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //[FPPopoverController :YES];
    
    
    return _pickerData[row];
}

- (IBAction)doneAction:(id)sender {
    NSInteger row = [self.pickerLocation selectedRowInComponent:0];
    
    NSLog(@"%@", [_pickerData objectAtIndex:row]);
    NSLog(@"%@",[pickerDataComplete objectAtIndex:row]);
    
    if([self.delegate respondsToSelector:@selector(selectedLocationPickerValue:)])
    {
        [self.delegate selectedLocationPickerValue:[pickerDataComplete objectAtIndex:row]];
    }
    
}

@end
