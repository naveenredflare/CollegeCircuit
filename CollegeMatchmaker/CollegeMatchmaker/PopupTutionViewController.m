//
//  PopupTutionViewController.m
//  CollegeMatchmaker
//
//  Created by manik on 26/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import "PopupTutionViewController.h"
#import "SearchViewController.h"

@interface PopupTutionViewController () {
    NSArray *_pickerData;
}


@end

@implementation PopupTutionViewController
@synthesize pickerTution;
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
    
    _pickerData = @[@"Non-Specified", @"0K - 5K", @"5K - 15K", @"15K - 25K", @"25K - 50K", @" > 50K"];
    
    self.pickerTution.dataSource = self;
    self.pickerTution.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


// The number of columns of data
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
    NSInteger row = [self.pickerTution selectedRowInComponent:0];
    
    NSLog(@"%@", [_pickerData objectAtIndex:row]);
    
    if([self.delegate respondsToSelector:@selector(selectedTutionPickerValue:)])
    {
        [self.delegate selectedTutionPickerValue:[_pickerData objectAtIndex:row]];
    }
    
}

@end
