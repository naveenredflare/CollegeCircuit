//
//  DetailViewController.m
//  CollegeMatchmaker
//
//  Created by Kumar  on 29/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import "DetailViewController.h"
#import "ServiceURL.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize collegeId;

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view from its nib.
    isUniversityShown = false;
    isHousingShown = false;
    isStudentShown = false;
    isSupportShown = false;
    [self matchesDetail];
    
    
}

- (void) matchesDetail {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@api/services/getcollegedetails/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"college_id=%@&user_id=%@",collegeId,[defaults stringForKey:@"user_id"]];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)starTheCollege
{
    if (starred==NO){
        
        //[sender setSelected:YES];
        [self starCollege];
    }
    else{
        //[sender setSelected:NO];
        [self unStarCollege];
        
    }
    
    
}
-(void)starCollege
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/favcollege/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"user_id=%@&college_id=%@",[defaults stringForKey:@"user_id"],collegeId];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection2 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)unStarCollege
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/services/unfavcollege/",BASEURL]]];
    
    request.HTTPMethod = @"POST";
    
    NSString *stringData = [NSString stringWithFormat:@"user_id=%@&college_id=%@",[defaults stringForKey:@"user_id"],collegeId];
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    connection3 = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) addEventCalendar{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) { return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = [NSString stringWithFormat:@"Application Deadline - %@",[[[matchesDetail objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_name"]];
        event.startDate = [NSDate date]; //today
        //event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        NSDate *myDate = [df dateFromString: [[[matchesDetail objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_appl_deadline"]];
        event.endDate = myDate;
        
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
        NSLog(@"%@",savedEventId);
        [[[UIAlertView alloc] initWithTitle:nil message:@"Added successfully to calendar" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }];
    
    
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
        matchesDetail = dict;
        NSLog(@"%@",dict);
        
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            //matchesList = [NSMutableDictionary dictionaryWithDictionary:dict];
            //dict;
            
            scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            scrollview.backgroundColor = [UIColor colorWithRed:57.0/255.0 green:48.0/255.0 blue:139.0/255.0 alpha:1.0];
            [self.view addSubview:scrollview];
            
            
            
            /*------------Logo------------*/
            
            UIImage *logoImage = nil;
            UIImage *logoImageResized = nil;
            
            NSString *logoImageURL = [NSString stringWithFormat:@"%@media/images/%@",BASEURL,[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_logo"]];
            
            NSData *logoImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoImageURL]];
            
            logoImage = [UIImage imageWithData:logoImageData];
            
            logoImageResized = [self scaleImageProportionally:logoImage];
            
            logoView = [[UIImageView alloc] initWithImage:logoImageResized];
            logoView.frame = CGRectMake(95, 80, logoView.frame.size.width, logoView.frame.size.height);
            
            [scrollview addSubview:logoView];
            /*---------------------------*/
            
            
            /*------------Star Icon------------*/
            starButton = [UIButton buttonWithType:UIButtonTypeCustom];
            starButton.frame = CGRectMake(270, 80, 26, 25);
            [starButton setImage:[UIImage imageNamed:@"starIconGrey"] forState:UIControlStateNormal];
            [starButton setImage:[UIImage imageNamed:@"starIconSelected"] forState:UIControlStateSelected];
            [starButton addTarget:self action:@selector(starTheCollege) forControlEvents:UIControlEventTouchUpInside];
            [scrollview addSubview:starButton];
            
            if([[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"userStar"] intValue] == 1){
                [starButton setSelected:YES];
                starred = YES;
            } else {
                [starButton setSelected:NO];
                starred = NO;
            }
            /*---------------------------*/
            
            /*------------Main Image------------*/
            
            UIImage *mainImage = nil;
            
            NSString *mainImageURL = [NSString stringWithFormat:@"%@media/images/%@",BASEURL,[[[[[dict objectForKey:@"records"] objectAtIndex:0]  objectForKey:@"galleryImages"] objectAtIndex:0] objectForKey:@"image_path"]];
            
            NSData *mainImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:mainImageURL]];
            
            mainImage = [UIImage imageWithData:mainImageData];
            
            CGRect mainRect = CGRectMake(30, 0 ,
                                     320, 215);
            
            CGImageRef mainImageRef = CGImageCreateWithImageInRect([mainImage CGImage], mainRect);
            UIImage *newMainImage = [UIImage imageWithCGImage:mainImageRef];
            
            mainView = [[UIImageView alloc] initWithImage:newMainImage];
            
            mainView.frame = CGRectMake(0, logoView.frame.origin.y + logoView.frame.size.height + 15, 320, 215);
            
            [scrollview addSubview:mainView];

            /*---------------------------*/
            
            UIView *newBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, mainView.frame.origin.y)];
            newBGView.backgroundColor = [UIColor whiteColor];
            [scrollview addSubview:newBGView];
            [scrollview addSubview:logoView];
            [scrollview addSubview:starButton];
            
            /*------------Gradient View------------*/
            gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, logoView.frame.origin.y + logoView.frame.size.height + 15, 320, 75)];
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = gradientView.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:57.0/255.0 green:48.0/255.0 blue:139.0/255.0 alpha:1.0] CGColor], (id)[[UIColor clearColor] CGColor], nil];
            NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
            NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
            
            NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
            gradient.locations = locations;
            gradient.opacity = 1;
            [gradientView.layer insertSublayer:gradient atIndex:0];
            //gradientView.layer.opacity = 0.5;

            [scrollview addSubview:gradientView];
            /*---------------------------*/
            
            /*------------College Name------------*/
            collegeName = [[UILabel alloc] initWithFrame:CGRectMake(20, mainView.frame.origin.y + 15, 320, 20)];
            collegeName.font = [UIFont systemFontOfSize:18.0];
            collegeName.textColor = [UIColor whiteColor];
            collegeName.text = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_name"];
            [scrollview addSubview:collegeName];
            /*---------------------------*/
            
            /*------------College Address------------*/
            collegeAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, collegeName.frame.origin.y + collegeName.frame.size.height, 320, 20)];
            collegeAddress.font = [UIFont systemFontOfSize:14.0];
            collegeAddress.textColor = [UIColor whiteColor];
            collegeAddress.text = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_address"];
            [scrollview addSubview:collegeAddress];
            /*---------------------------*/
            
            /*------------Major View------------*/
            majorView = [[UIView alloc] initWithFrame:CGRectMake(0, mainView.frame.origin.y + mainView.frame.size.height, 320, 190)];
            majorView.backgroundColor = [UIColor colorWithRed:57.0/255.0 green:48.0/255.0 blue:139.0/255.0 alpha:1.0];
            [scrollview addSubview:majorView];
            
            majorText = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 320, 20)];
            majorText.font = [UIFont systemFontOfSize:14.0];
            majorText.textColor = [UIColor whiteColor];
            majorText.text = @"3 MOST POPULAR MAJORS";
            majorText.textAlignment = NSTextAlignmentCenter;
            [majorView addSubview:majorText];
            
            NSString *fmajor, *smajor, *tmajor;
            fmajor = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_majors_text"];
            smajor = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_majors_second_text"];
            tmajor = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_majors_third_text"];
            
            if([[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_majors_text"] isEqualToString:@""]){
                fmajor = @"N/A";
            }
            if([[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_majors_second_text"] isEqualToString:@""]){
                smajor = @"N/A";
            }
            if([[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_majors_third_text"] isEqualToString:@""]){
                tmajor = @"N/A";
            }
            
            majorFirst = [[UILabel alloc] initWithFrame:CGRectMake(10, majorText.frame.origin.y + majorText.frame.size.height + 15, 100, 40)];
            //majorFirst.backgroundColor = [UIColor redColor];
            majorFirst.font = [UIFont systemFontOfSize:14.0];
            majorFirst.textColor = [UIColor whiteColor];
            majorFirst.text = fmajor;
            majorFirst.textAlignment = NSTextAlignmentCenter;
            majorFirst.numberOfLines = 0;
            majorFirst.lineBreakMode = NSLineBreakByWordWrapping;
            [majorView addSubview:majorFirst];
            
            majorSecond = [[UILabel alloc] initWithFrame:CGRectMake(110, majorText.frame.origin.y + majorText.frame.size.height + 15, 100, 40)];
            //majorSecond.backgroundColor = [UIColor greenColor];
            majorSecond.font = [UIFont systemFontOfSize:14.0];
            majorSecond.textColor = [UIColor whiteColor];
            majorSecond.text = smajor;
            majorSecond.textAlignment = NSTextAlignmentCenter;
            majorSecond.numberOfLines = 0;
            majorSecond.lineBreakMode = NSLineBreakByWordWrapping;
            [majorView addSubview:majorSecond];
            
            majorThird = [[UILabel alloc] initWithFrame:CGRectMake(210, majorText.frame.origin.y + majorText.frame.size.height + 15, 100, 40)];
            //majorThird.backgroundColor = [UIColor yellowColor];
            majorThird.font = [UIFont systemFontOfSize:14.0];
            majorThird.textColor = [UIColor whiteColor];
            majorThird.text = tmajor;
            majorThird.textAlignment = NSTextAlignmentCenter;
            majorThird.numberOfLines = 0;
            majorThird.lineBreakMode = NSLineBreakByWordWrapping;
            [majorView addSubview:majorThird];
            
            m3View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"m3"]];
            m3View.frame = CGRectMake(21, majorFirst.frame.origin.y + majorFirst.frame.size.height + 15, 65, 27);
            [majorView addSubview:m3View];
            
            m2View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"m2"]];
            m2View.frame = CGRectMake(134, majorFirst.frame.origin.y + majorFirst.frame.size.height + 15, 53, 27);
            [majorView addSubview:m2View];
            
            m1View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"m1"]];
            m1View.frame = CGRectMake(247, majorFirst.frame.origin.y + majorFirst.frame.size.height + 15, 40, 27);
            [majorView addSubview:m1View];

            /*---------------------------*/
            
            /*------------Application Deadline------------*/
            
            applicationView = [[UIView alloc] initWithFrame:CGRectMake(0, majorView.frame.origin.y + majorView.frame.size.height, 320, 280)];
            [scrollview addSubview:applicationView];
            
            applicationImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appBg"]];
            applicationImage.frame = CGRectMake(0, 0, 320, 280);
            [applicationView addSubview:applicationImage];
            
            applicationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 320, 20)];
            applicationLabel.font = [UIFont systemFontOfSize:18.0];
            applicationLabel.textColor = [UIColor colorWithRed:57.0/255.0 green:48.0/255.0 blue:139.0/255.0 alpha:1.0];
            applicationLabel.text = @"Application Deadline";
            applicationLabel.textAlignment = NSTextAlignmentCenter;
            [applicationView addSubview:applicationLabel];
            
            applicationRCView = [[UIView alloc] initWithFrame:CGRectMake(90, applicationLabel.frame.origin.y + applicationLabel.frame.size.height + 10, 140, 140)];
            applicationRCView.layer.cornerRadius = 70;
            applicationRCView.backgroundColor = [UIColor colorWithRed:57.0/255.0 green:48.0/255.0 blue:139.0/255.0 alpha:1.0];
            [applicationView addSubview:applicationRCView];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyy-MM-dd"];
            NSDate *date = [dateFormat dateFromString:[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_appl_deadline"]];

            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date]; // Get necessary date components
            
            [components month]; //gives you month
            [components day]; //gives you day
            [components year]; // gives you year
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            NSString *monthName = [[df monthSymbols] objectAtIndex:([components month]-1)];
            NSString *monthInt = [NSString stringWithFormat:@"%ld",(long)[components day]];
            if([components day] == 1){
                monthInt = [NSString stringWithFormat:@"%@st",monthInt];
            } else if([components day] == 2){
                monthInt = [NSString stringWithFormat:@"%@nd",monthInt];
            } else if([components day] == 3){
                monthInt = [NSString stringWithFormat:@"%@rd",monthInt];
            } else {
                monthInt = [NSString stringWithFormat:@"%@th",monthInt];
            }
            
            applicationMonth = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 140, 20)];
            applicationMonth.font = [UIFont systemFontOfSize:18.0];
            applicationMonth.textColor = [UIColor whiteColor];
            applicationMonth.text = monthName;
            applicationMonth.textAlignment = NSTextAlignmentCenter;
            [applicationRCView addSubview:applicationMonth];
            
            applicationDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 140, 40)];
            applicationDate.font = [UIFont systemFontOfSize:36.0];
            applicationDate.textColor = [UIColor whiteColor];
            applicationDate.text = monthInt;
            applicationDate.textAlignment = NSTextAlignmentCenter;
            [applicationRCView addSubview:applicationDate];
            
            calendarButton = [UIButton buttonWithType:UIButtonTypeCustom];
            calendarButton.frame = CGRectMake(90, applicationRCView.frame.origin.y + applicationRCView.frame.size.height + 25, 140, 20);
            [calendarButton setTitle:@"+Add to Calendar" forState:UIControlStateNormal];
            calendarButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
            calendarButton.titleLabel.textColor = [UIColor whiteColor];
            [calendarButton addTarget:self action:@selector(addEventCalendar) forControlEvents:UIControlEventTouchUpInside];
            [applicationView addSubview:calendarButton];

            
            /*---------------------------*/
            
            /*------------University Button------------*/
            
            universityButton = [UIButton buttonWithType:UIButtonTypeCustom];
            universityButton.frame = CGRectMake(0, applicationView.frame.origin.y + applicationView.frame.size.height, 320, 114);
            [universityButton setBackgroundImage:[UIImage imageNamed:@"universityButton"] forState:UIControlStateNormal];
            universityButton.showsTouchWhenHighlighted = NO;
            [universityButton addTarget:self action:@selector(showUniversityView) forControlEvents:UIControlEventTouchUpInside];
            [scrollview addSubview:universityButton];
            
            universityContainerView = [[UIView alloc] init];
            universityContainerView.frame = CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 320, 0);
            universityContainerView.backgroundColor = [UIColor clearColor];
            [scrollview addSubview:universityContainerView];
            
            undergradsView = [[UIView alloc] init];
            undergradsView.frame = CGRectMake(0, 0, 320, 0);
            undergradsView.backgroundColor = [UIColor colorWithRed:87.0/255.0 green:78.0/255.0 blue:167.0/255.0 alpha:1.0];
            [universityContainerView addSubview:undergradsView];
            
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            
            undergradsValue = [[UILabel alloc] init];
            undergradsValue.frame = CGRectMake(0, 35, 320, 0);
            undergradsValue.font = [UIFont systemFontOfSize:30.0];
            undergradsValue.textColor = [UIColor whiteColor];
            undergradsValue.textAlignment = NSTextAlignmentCenter;
            undergradsValue.text = [formatter stringFromNumber:[NSNumber numberWithInteger:[[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_undergards"] integerValue]]];
            [undergradsView addSubview:undergradsValue];
            
            undergradsText = [[UILabel alloc] init];
            undergradsText.frame = CGRectMake(0, 68, 320, 0);
            undergradsText.font = [UIFont systemFontOfSize:16.0];
            undergradsText.textColor = [UIColor whiteColor];
            undergradsText.textAlignment = NSTextAlignmentCenter;
            undergradsText.text = @"Undergrads";
            [undergradsView addSubview:undergradsText];
            
            instateView = [[UIView alloc] init];
            instateView.frame = CGRectMake(0, undergradsView.frame.origin.y + undergradsView.frame.size.height, 320, 0);
            instateView.backgroundColor = [UIColor colorWithRed:103.0/255.0 green:84.0/255.0 blue:185.0/255.0 alpha:1.0];
            [universityContainerView addSubview:instateView];
            
            instateValue = [[UILabel alloc] init];
            instateValue.frame = CGRectMake(0, 35, 320, 0);
            instateValue.font = [UIFont systemFontOfSize:30.0];
            instateValue.textColor = [UIColor whiteColor];
            instateValue.textAlignment = NSTextAlignmentCenter;
            instateValue.text = [NSString stringWithFormat:@"$%@",[formatter stringFromNumber:[NSNumber numberWithInteger:[[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_in_state_tuition"]integerValue]]]];
            [instateView addSubview:instateValue];
            
            instateText = [[UILabel alloc] init];
            instateText.frame = CGRectMake(0, 68, 320, 0);
            instateText.font = [UIFont systemFontOfSize:16.0];
            instateText.textColor = [UIColor whiteColor];
            instateText.textAlignment = NSTextAlignmentCenter;
            instateText.text = @"In-State Tution";
            [instateView addSubview:instateText];
            
            outstateView = [[UIView alloc] init];
            outstateView.frame = CGRectMake(0, instateView.frame.origin.y + instateView.frame.size.height, 320, 0);
            outstateView.backgroundColor = [UIColor colorWithRed:114.0/255.0 green:105.0/255.0 blue:198.0/255.0 alpha:1.0];
            [universityContainerView addSubview:outstateView];
            
            outstateValue = [[UILabel alloc] init];
            outstateValue.frame = CGRectMake(0, 35, 320, 0);
            outstateValue.font = [UIFont systemFontOfSize:30.0];
            outstateValue.textColor = [UIColor whiteColor];
            outstateValue.textAlignment = NSTextAlignmentCenter;
            outstateValue.text = [NSString stringWithFormat:@"$%@",[formatter stringFromNumber:[NSNumber numberWithInteger:[[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_out_state_tuition"] integerValue]]]];
            [outstateView addSubview:outstateValue];
            
            outstateText = [[UILabel alloc] init];
            outstateText.frame = CGRectMake(0, 68, 320, 0);
            outstateText.font = [UIFont systemFontOfSize:16.0];
            outstateText.textColor = [UIColor whiteColor];
            outstateText.textAlignment = NSTextAlignmentCenter;
            outstateText.text = @"Out-of-State Tution";
            [outstateView addSubview:outstateText];
            
            
            /*---------------------------*/
            
            /*------------Housing Button------------*/
            
            housingButton = [UIButton buttonWithType:UIButtonTypeCustom];
            housingButton.frame = CGRectMake(0, universityContainerView.frame.origin.y + universityContainerView.frame.size.height, 320, 114);
            [housingButton setBackgroundImage:[UIImage imageNamed:@"housingButton"] forState:UIControlStateNormal];
            housingButton.showsTouchWhenHighlighted = NO;
            [housingButton addTarget:self action:@selector(showHousingView) forControlEvents:UIControlEventTouchUpInside];
            [scrollview addSubview:housingButton];
            
            housingContainerView = [[UIView alloc] init];
            housingContainerView.frame = CGRectMake(0, housingButton.frame.origin.y + housingButton.frame.size.height, 320, 0);
            housingContainerView.backgroundColor = [UIColor clearColor];
            [scrollview addSubview:housingContainerView];
            
            freshmanPopulationView = [[UIView alloc] init];
            freshmanPopulationView.frame = CGRectMake(0, 0, 320, 0);
            freshmanPopulationView.backgroundColor = [UIColor colorWithRed:160.0/255.0 green:165.0/255.0 blue:75.0/255.0 alpha:1.0];
            [housingContainerView addSubview:freshmanPopulationView];
            
            studentPopulationView = [[UIView alloc] init];
            studentPopulationView.frame = CGRectMake(0, freshmanPopulationView.frame.origin.y + freshmanPopulationView.frame.size.height, 320, 0);
            studentPopulationView.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:170.0/255.0 blue:80.0/255.0 alpha:1.0];
            [housingContainerView addSubview:studentPopulationView];
            
            freshmanPopulationValue = [[UILabel alloc] init];
            freshmanPopulationValue.frame = CGRectMake(0, 20, 320, 0);
            freshmanPopulationValue.font = [UIFont systemFontOfSize:30.0];
            freshmanPopulationValue.textColor = [UIColor whiteColor];
            freshmanPopulationValue.textAlignment = NSTextAlignmentCenter;
            freshmanPopulationValue.text = [NSString stringWithFormat:@"%@%%",[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_freshman_popl"]];
            [freshmanPopulationView addSubview:freshmanPopulationValue];
            
            freshmanPopulationText = [[UILabel alloc] init];
            freshmanPopulationText.frame = CGRectMake(40, 53, 240, 0);
            freshmanPopulationText.font = [UIFont systemFontOfSize:16.0];
            freshmanPopulationText.textColor = [UIColor whiteColor];
            freshmanPopulationText.textAlignment = NSTextAlignmentCenter;
            freshmanPopulationText.text = @"% of Freshman Population Living in Housing";
            freshmanPopulationText.numberOfLines = 0;
            freshmanPopulationText.lineBreakMode = NSLineBreakByWordWrapping;
            [freshmanPopulationView addSubview:freshmanPopulationText];
            
            studentPopulationValue = [[UILabel alloc] init];
            studentPopulationValue.frame = CGRectMake(0, 20, 320, 0);
            studentPopulationValue.font = [UIFont systemFontOfSize:30.0];
            studentPopulationValue.textColor = [UIColor whiteColor];
            studentPopulationValue.textAlignment = NSTextAlignmentCenter;
            studentPopulationValue.text = [NSString stringWithFormat:@"%@%%",[[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_tot_stud_popl"]];
            [studentPopulationView addSubview:studentPopulationValue];
            
            studentPopulationText = [[UILabel alloc] init];
            studentPopulationText.frame = CGRectMake(40, 53, 240, 0);
            studentPopulationText.font = [UIFont systemFontOfSize:16.0];
            studentPopulationText.textColor = [UIColor whiteColor];
            studentPopulationText.textAlignment = NSTextAlignmentCenter;
            studentPopulationText.text = @"% of Total Student Population Living in Housing";
            studentPopulationText.numberOfLines = 0;
            studentPopulationText.lineBreakMode = NSLineBreakByWordWrapping;
            [studentPopulationView addSubview:studentPopulationText];
            
            /*---------------------------*/
            
            /*------------Student Button------------*/
            
            studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            studentButton.frame = CGRectMake(0, housingContainerView.frame.origin.y + housingContainerView.frame.size.height, 320, 114);
            [studentButton setBackgroundImage:[UIImage imageNamed:@"studentButton"] forState:UIControlStateNormal];
            studentButton.showsTouchWhenHighlighted = NO;
            [studentButton addTarget:self action:@selector(showStudentView) forControlEvents:UIControlEventTouchUpInside];
            [scrollview addSubview:studentButton];
            
            studentContainerView = [[UIView alloc] init];
            studentContainerView.frame = CGRectMake(0, studentButton.frame.origin.y + studentButton.frame.size.height, 320, 0);
            studentContainerView.backgroundColor = [UIColor clearColor];
            [scrollview addSubview:studentContainerView];
            
            collegeActivitiesView = [[UIView alloc] init];
            collegeActivitiesView.frame = CGRectMake(0, 0, 320, 0);
            collegeActivitiesView.backgroundColor = [UIColor colorWithRed:87.0/255.0 green:78.0/255.0 blue:167.0/255.0 alpha:1.0];
            [studentContainerView addSubview:collegeActivitiesView];
            
            collegeActivitiesLabel = [[UILabel alloc] init];
            collegeActivitiesLabel.frame = CGRectMake(0, 30, 320, 0);
            collegeActivitiesLabel.font = [UIFont systemFontOfSize:16.0];
            collegeActivitiesLabel.textColor = [UIColor whiteColor];
            collegeActivitiesLabel.textAlignment = NSTextAlignmentCenter;
            collegeActivitiesLabel.text = @"ACTIVITIES & CLUBS";
            [collegeActivitiesView addSubview:collegeActivitiesLabel];
            
            NSString *college_activities = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_activites_clubs"];
            NSArray *college_activities_array = [college_activities componentsSeparatedByString:@", "];
            //NSLog(@"%@",college_activities_array);
            _collegeActivitiesLabels = [NSMutableArray array];
            ypos = 60;
            for (id object in college_activities_array) {
                // do something with object
                UILabel *collegeActivities = [[UILabel alloc] init];
                collegeActivities.frame = CGRectMake(0,collegeActivitiesLabel.frame.origin.y + collegeActivitiesLabel.frame.size.height + ypos, 320, 16);
                collegeActivities.font = [UIFont systemFontOfSize:16.0];
                collegeActivities.textColor = [UIColor whiteColor];
                collegeActivities.textAlignment = NSTextAlignmentCenter;
                collegeActivities.text = object;
                collegeActivities.hidden = YES;
                [collegeActivitiesView addSubview:collegeActivities];
                [_collegeActivitiesLabels addObject:collegeActivities];
                ypos = ypos + 20;
            }
            ypos = ypos + 30;
            
            collegeSportsView = [[UIView alloc] init];
            collegeSportsView.frame = CGRectMake(0, collegeActivitiesView.frame.origin.y + collegeActivitiesView.frame.size.height , 320, 0);
            collegeSportsView.backgroundColor = [UIColor colorWithRed:114.0/255.0 green:105.0/255.0 blue:198.0/255.0 alpha:1.0];
            [studentContainerView addSubview:collegeSportsView];
            
            collegeSportsLabel = [[UILabel alloc] init];
            collegeSportsLabel.frame = CGRectMake(0, 30, 320, 0);
            collegeSportsLabel.font = [UIFont systemFontOfSize:16.0];
            collegeSportsLabel.textColor = [UIColor whiteColor];
            collegeSportsLabel.textAlignment = NSTextAlignmentCenter;
            collegeSportsLabel.text = @"SPORTS";
            [collegeSportsView addSubview:collegeSportsLabel];
            
            NSString *college_sports = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_sports"];
            NSArray *college_sports_array = [college_sports componentsSeparatedByString:@", "];
            //NSLog(@"%@",college_activities_array);
            _collegeSportsLabels = [NSMutableArray array];
            ypos1 = 60;
            for (id object1 in college_sports_array) {
                // do something with object
                UILabel *collegeSports = [[UILabel alloc] init];
                collegeSports.frame = CGRectMake(0,collegeSportsLabel.frame.origin.y + collegeSportsLabel.frame.size.height + ypos1, 320, 16);
                collegeSports.font = [UIFont systemFontOfSize:16.0];
                collegeSports.textColor = [UIColor whiteColor];
                collegeSports.textAlignment = NSTextAlignmentCenter;
                collegeSports.text = object1;
                collegeSports.hidden = YES;
                [collegeSportsView addSubview:collegeSports];
                [_collegeSportsLabels addObject:collegeSports];
                ypos1 = ypos1 + 20;
            }
            ypos1 = ypos1 + 30;

            
            totalYpos = 50 + ypos + ypos1 + 50;
            /*---------------------------*/
            
            /*------------Support Button------------*/
            
            supportButton = [UIButton buttonWithType:UIButtonTypeCustom];
            supportButton.frame = CGRectMake(0, studentContainerView.frame.origin.y + studentContainerView.frame.size.height, 320, 114);
            [supportButton setBackgroundImage:[UIImage imageNamed:@"supportButton"] forState:UIControlStateNormal];
            supportButton.showsTouchWhenHighlighted = NO;
            [supportButton addTarget:self action:@selector(showSupportView) forControlEvents:UIControlEventTouchUpInside];
            [scrollview addSubview:supportButton];
            
            supportContainerView = [[UIView alloc] init];
            supportContainerView.frame = CGRectMake(0, supportButton.frame.origin.y + supportButton.frame.size.height, 320, 0);
            supportContainerView.backgroundColor = [UIColor colorWithRed:165.0/255.0 green:170.0/255.0 blue:80.0/255.0 alpha:1.0];
            [scrollview addSubview:supportContainerView];
            
            collegeCounsellingView = [[UIView alloc] init];
            collegeCounsellingView.frame = CGRectMake(0, 0, 320, 0);
            collegeCounsellingView.backgroundColor = [UIColor clearColor];
            [supportContainerView addSubview:collegeCounsellingView];
            
            collegeCounsellingLabel = [[UILabel alloc] init];
            collegeCounsellingLabel.frame = CGRectMake(0, 30, 320, 0);
            collegeCounsellingLabel.font = [UIFont systemFontOfSize:14.0];
            collegeCounsellingLabel.textColor = [UIColor whiteColor];
            collegeCounsellingLabel.textAlignment = NSTextAlignmentCenter;
            collegeCounsellingLabel.text = @"COUNSELING & WELLNESS";
            [collegeCounsellingView addSubview:collegeCounsellingLabel];
            
            NSString *college_counselling = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_counsel"];
            NSArray *college_counselling_array = [college_counselling componentsSeparatedByString:@", "];
            //NSLog(@"%@",college_activities_array);
            _collegeCounsellingLabels = [NSMutableArray array];
            ypos2 = 60;
            for (id object2 in college_counselling_array) {
                // do something with object
                UILabel *collegeCounselling = [[UILabel alloc] init];
                collegeCounselling.frame = CGRectMake(10,collegeCounsellingLabel.frame.origin.y + collegeCounsellingLabel.frame.size.height + ypos2, 300, 40);
                collegeCounselling.font = [UIFont systemFontOfSize:14.0];
                collegeCounselling.textColor = [UIColor whiteColor];
                collegeCounselling.textAlignment = NSTextAlignmentCenter;
                collegeCounselling.text = object2;
                collegeCounselling.hidden = YES;
                collegeCounselling.numberOfLines = 0;
                collegeCounselling.lineBreakMode =NSLineBreakByWordWrapping;
                [collegeCounsellingView addSubview:collegeCounselling];
                [_collegeCounsellingLabels addObject:collegeCounselling];
                ypos2 = ypos2 + 40;
            }
            ypos2 = ypos2 + 30;
            
            collegeSupportView = [[UIView alloc] init];
            collegeSupportView.frame = CGRectMake(0, collegeCounsellingView.frame.origin.y + collegeCounsellingView.frame.size.height, 320, 0);
            collegeSupportView.backgroundColor = [UIColor clearColor];
            [supportContainerView addSubview:collegeSupportView];
            
            collegeSupportLabel = [[UILabel alloc] init];
            collegeSupportLabel.frame = CGRectMake(0, 30, 320, 0);
            collegeSupportLabel.font = [UIFont systemFontOfSize:14.0];
            collegeSupportLabel.textColor = [UIColor whiteColor];
            collegeSupportLabel.textAlignment = NSTextAlignmentCenter;
            collegeSupportLabel.text = @"ACADEMIC SUPPORT SERVICES";
            [collegeSupportView addSubview:collegeSupportLabel];
            
            NSString *college_Support = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_support"];
            NSArray *college_support_array = [college_Support componentsSeparatedByString:@", "];
            //NSLog(@"%@",college_activities_array);
            _collegeSupportLabels = [NSMutableArray array];
            ypos3 = 60;
            for (id object3 in college_support_array) {
                // do something with object
                UILabel *collegeSupport = [[UILabel alloc] init];
                collegeSupport.frame = CGRectMake(10,collegeSupportLabel.frame.origin.y + collegeSupportLabel.frame.size.height + ypos3, 300, 40);
                collegeSupport.font = [UIFont systemFontOfSize:14.0];
                collegeSupport.textColor = [UIColor whiteColor];
                collegeSupport.textAlignment = NSTextAlignmentCenter;
                collegeSupport.text = object3;
                collegeSupport.hidden = YES;
                collegeSupport.numberOfLines = 0;
                collegeSupport.lineBreakMode =NSLineBreakByWordWrapping;
                [collegeSupportView addSubview:collegeSupport];
                [_collegeSupportLabels addObject:collegeSupport];
                ypos3 = ypos3 + 40;
            }
            ypos3 = ypos3 + 30;
            
            collegeDisabilitiesView = [[UIView alloc] init];
            collegeDisabilitiesView.frame = CGRectMake(0, collegeSupportView.frame.origin.y + collegeSupportView.frame.size.height, 320, 0);
            collegeDisabilitiesView.backgroundColor = [UIColor clearColor];
            [supportContainerView addSubview:collegeDisabilitiesView];
            
            collegeDisabilitiesLabel = [[UILabel alloc] init];
            collegeDisabilitiesLabel.frame = CGRectMake(0, 30, 320, 0);
            collegeDisabilitiesLabel.font = [UIFont systemFontOfSize:14.0];
            collegeDisabilitiesLabel.textColor = [UIColor whiteColor];
            collegeDisabilitiesLabel.textAlignment = NSTextAlignmentCenter;
            collegeDisabilitiesLabel.text = @"SERVICES FOR STUDENTS WITH DISABILITIES";
            [collegeDisabilitiesView addSubview:collegeDisabilitiesLabel];
            
            NSString *college_Disabilities = [[[dict objectForKey:@"records"] objectAtIndex:0] objectForKey:@"college_disabilities"];
            NSArray *college_disabilities_array = [college_Disabilities componentsSeparatedByString:@", "];
            //NSLog(@"%@",college_activities_array);
            _collegeDisabilitiesLabels = [NSMutableArray array];
            ypos4 = 60;
            for (id object4 in college_disabilities_array) {
                // do something with object
                UILabel *collegeDisabilities = [[UILabel alloc] init];
                collegeDisabilities.frame = CGRectMake(10,collegeDisabilitiesLabel.frame.origin.y + collegeDisabilitiesLabel.frame.size.height + ypos4, 300, 40);
                collegeDisabilities.font = [UIFont systemFontOfSize:14.0];
                collegeDisabilities.textColor = [UIColor whiteColor];
                collegeDisabilities.textAlignment = NSTextAlignmentCenter;
                collegeDisabilities.text = object4;
                collegeDisabilities.hidden = YES;
                collegeDisabilities.numberOfLines = 0;
                collegeDisabilities.lineBreakMode =NSLineBreakByWordWrapping;
                [collegeDisabilitiesView addSubview:collegeDisabilities];
                [_collegeDisabilitiesLabels addObject:collegeDisabilities];
                ypos4 = ypos4 + 40;
            }
            ypos4 = ypos4 + 30;

            totalYpos1 = 50 + ypos2 + ypos3 + 50 + 50 + ypos4;
            
            /*---------------------------*/
            
            /*------------Video------------*/
            
            NSURL *videoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/video/%@",BASEURL,[[[dict objectForKey:@"records"] objectAtIndex:0]  objectForKey:@"college_video"]]];
            NSLog(@"%@",videoUrl);
            collegeVideo = [[[dict objectForKey:@"records"] objectAtIndex:0]  objectForKey:@"college_video"];
            _videoPlayer =  [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
            if(![collegeVideo isEqualToString:@"0"]){
            _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 320, 215);
            } else {
                _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 0, 0);
            }
            // Set control style to default
            _videoPlayer.controlStyle = MPMovieControlStyleDefault;
            
            // Set shouldAutoplay to YES
            _videoPlayer.shouldAutoplay = NO;
            
            // Add _videoPlayer's view as subview to current view.
            [scrollview addSubview:_videoPlayer.view];
            
            // Set the screen to full.
            [_videoPlayer setFullscreen:NO animated:YES];

            /*---------------------------*/
            
            /*------------Gallary Image------------*/
            _collegeGallaryImages = [NSMutableArray array];
            ypos5 = 0;
            for (id object5 in [[[dict objectForKey:@"records"] objectAtIndex:0]  objectForKey:@"galleryImages"]) {
                NSLog(@"%@",[object5 objectForKey:@"image_path"]);
                
                UIImage *gallaryImage = nil;
                NSString *gallaryImageURL = [NSString stringWithFormat:@"%@media/images/%@",BASEURL,[object5 objectForKey:@"image_path"]];
                NSData *gallaryImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:gallaryImageURL]];
                
                gallaryImage = [UIImage imageWithData:gallaryImageData];
                CGRect gallaryRect = CGRectMake(30, 0 ,
                                             320, 215);
                CGImageRef gallaryImageRef = CGImageCreateWithImageInRect([gallaryImage CGImage], gallaryRect);
                UIImage *newGallaryImage = [UIImage imageWithCGImage:gallaryImageRef];
                
                UIImageView *gallaryView = [[UIImageView alloc] initWithImage:newGallaryImage];
                
                gallaryView.frame = CGRectMake(0, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height + ypos5, 320, 215);
                 [scrollview addSubview:gallaryView];
                [_collegeGallaryImages addObject:gallaryView];
                ypos5 = ypos5 + 215;
            }
            
            /*---------------------------*/
            
            scrollview.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 3000);
            
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }else if(connection == connection2){
        NSData *jsonData = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        NSLog(@"%@",dict);
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            starred = YES;
            [starButton setSelected:YES];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:[dict objectForKey:@"message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }
    else if(connection == connection3){
        NSData *jsonData = [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        
        NSLog(@"%@",dict);
        
        if([[dict objectForKey:@"status"] isEqualToString:@"1"]){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            starred = NO;
            [starButton setSelected:NO];
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

- (void)showUniversityView {
    
    if (!isUniversityShown) {
        //housingButton.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 0, 0);
        [UIView animateWithDuration:0.50
                              delay: 0
                            options: UIViewAnimationOptionTransitionCurlUp
                         animations:^{
                             universityContainerView.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 320, 342);   // move
                             undergradsView.frame = CGRectMake(0, 0, 320, 114);
                             instateView.frame = CGRectMake(0, undergradsView.frame.origin.y + undergradsView.frame.size.height, 320, 114);
                             outstateView.frame = CGRectMake(0, instateView.frame.origin.y + instateView.frame.size.height, 320, 114);
                             undergradsValue.frame = CGRectMake(0, 35, 320, 30);
                             undergradsText.frame = CGRectMake(0, 68, 320, 18);
                             instateValue.frame = CGRectMake(0, 35, 320, 30);
                             instateText.frame = CGRectMake(0, 68, 320, 18);
                             outstateValue.frame = CGRectMake(0, 35, 320, 30);
                             outstateText.frame = CGRectMake(0, 68, 320, 18);
                             
                             housingButton.frame = CGRectMake(0, universityContainerView.frame.origin.y + universityContainerView.frame.size.height, 320, 114);
                             housingContainerView.frame =  CGRectMake(0, housingButton.frame.origin.y + housingButton.frame.size.height, 320, 0);
                             freshmanPopulationView.frame = CGRectMake(0, 0, 320, 0);
                             studentPopulationView.frame = CGRectMake(0, freshmanPopulationView.frame.origin.y + freshmanPopulationView.frame.size.height, 320, 0);
                             freshmanPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             freshmanPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             studentPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             studentPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             
                             studentButton.frame = CGRectMake(0, housingContainerView.frame.origin.y + housingContainerView.frame.size.height, 320, 114);
                             studentContainerView.frame =  CGRectMake(0, studentButton.frame.origin.y + studentButton.frame.size.height, 320, 0);
                             collegeActivitiesView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeActivitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeActivitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeActivitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSportsView.frame =  CGRectMake(0, collegeActivitiesView.frame.origin.y + collegeActivitiesView.frame.size.height, 320, 0);
                             collegeSportsLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSportsLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSportsLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             
                             supportButton.frame = CGRectMake(0, studentContainerView.frame.origin.y + studentContainerView.frame.size.height, 320, 114);
                             supportContainerView.frame =  CGRectMake(0, supportButton.frame.origin.y + supportButton.frame.size.height, 320, 0);
                             collegeCounsellingView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeCounsellingLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeCounsellingLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeCounsellingLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSupportView.frame =  CGRectMake(0, collegeCounsellingView.frame.origin.y + collegeCounsellingView.frame.size.height, 320, 0);
                             collegeSupportLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSupportLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSupportLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeDisabilitiesView.frame =  CGRectMake(0, collegeSupportView.frame.origin.y + collegeSupportView.frame.size.height, 320, 0);
                             collegeDisabilitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeDisabilitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeDisabilitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             if(![collegeVideo isEqualToString:@"0"]){
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 320, 215);
                             } else {
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 0, 0);
                             }
                             int tempYpos;
                             tempYpos = 0;
                             for(int i = 0; i < _collegeGallaryImages.count; i ++)
                             {
                                 UIImageView *tempImage =  (UIImageView *)[_collegeGallaryImages objectAtIndex:i];
                                 tempImage.frame = CGRectMake(0, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height + tempYpos, 320, 215);
                                 tempYpos = tempYpos + 215;
                             }
                             
                         }
                         completion:nil];  // no completion handler
        isUniversityShown = true;
        isHousingShown = false;
        isStudentShown = false;
        isSupportShown = false;
    } else {
        [UIView animateWithDuration:0.50
                              delay: 0
                            options: UIViewAnimationOptionTransitionCurlDown
                         animations:^{
                             universityContainerView.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 320, 0);   // move
                             undergradsView.frame = CGRectMake(0, 0, 320, 0);
                             instateView.frame = CGRectMake(0, undergradsView.frame.origin.y + undergradsView.frame.size.height, 320, 0);
                             outstateView.frame = CGRectMake(0, instateView.frame.origin.y + instateView.frame.size.height, 320, 0);
                             undergradsValue.frame = CGRectMake(0, 35, 320, 0);
                             undergradsText.frame = CGRectMake(0, 68, 320, 0);
                             instateValue.frame = CGRectMake(0, 35, 320, 0);
                             instateText.frame = CGRectMake(0, 68, 320, 0);
                             outstateValue.frame = CGRectMake(0, 35, 320, 0);
                             outstateText.frame = CGRectMake(0, 68, 320, 0);
                             
                             housingButton.frame = CGRectMake(0, universityContainerView.frame.origin.y + universityContainerView.frame.size.height, 320, 114);
                             housingContainerView.frame =  CGRectMake(0, housingButton.frame.origin.y + housingButton.frame.size.height, 320, 0);
                             freshmanPopulationView.frame = CGRectMake(0, 0, 320, 0);
                             studentPopulationView.frame = CGRectMake(0, freshmanPopulationView.frame.origin.y + freshmanPopulationView.frame.size.height, 320, 0);
                             freshmanPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             freshmanPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             studentPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             studentPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             
                             studentButton.frame = CGRectMake(0, housingContainerView.frame.origin.y + housingContainerView.frame.size.height, 320, 114);
                             studentContainerView.frame =  CGRectMake(0, studentButton.frame.origin.y + studentButton.frame.size.height, 320, 0);
                             collegeActivitiesView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeActivitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeActivitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeActivitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSportsView.frame =  CGRectMake(0, collegeActivitiesView.frame.origin.y + collegeActivitiesView.frame.size.height, 320, 0);
                             collegeSportsLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSportsLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSportsLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             
                             supportButton.frame = CGRectMake(0, studentContainerView.frame.origin.y + studentContainerView.frame.size.height, 320, 114);
                             supportContainerView.frame =  CGRectMake(0, supportButton.frame.origin.y + supportButton.frame.size.height, 320, 0);
                             collegeCounsellingView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeCounsellingLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeCounsellingLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeCounsellingLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSupportView.frame =  CGRectMake(0, collegeCounsellingView.frame.origin.y + collegeCounsellingView.frame.size.height, 320, 0);
                             collegeSupportLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSupportLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSupportLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeDisabilitiesView.frame =  CGRectMake(0, collegeSupportView.frame.origin.y + collegeSupportView.frame.size.height, 320, 0);
                             collegeDisabilitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeDisabilitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeDisabilitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             if(![collegeVideo isEqualToString:@"0"]){
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 320, 215);
                             } else {
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 0, 0);
                             }
                             int tempYpos;
                             tempYpos = 0;
                             for(int i = 0; i < _collegeGallaryImages.count; i ++)
                             {
                                 UIImageView *tempImage =  (UIImageView *)[_collegeGallaryImages objectAtIndex:i];
                                 tempImage.frame = CGRectMake(0, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height + tempYpos, 320, 215);
                                 tempYpos = tempYpos + 215;
                             }
                         }
                         completion:nil];  // no completion handler
        isUniversityShown = false;
        isHousingShown = false;
        isStudentShown = false;
        isSupportShown = false;
    }
}

- (void)showHousingView {
    if (!isHousingShown) {
        //housingButton.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 0, 0);
        [UIView animateWithDuration:0.50
                              delay: 0
                            options: UIViewAnimationOptionTransitionCurlUp
                         animations:^{
                             universityContainerView.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 320, 0);   // move
                             undergradsView.frame = CGRectMake(0, 0, 320, 0);
                             instateView.frame = CGRectMake(0, undergradsView.frame.origin.y + undergradsView.frame.size.height, 320, 0);
                             outstateView.frame = CGRectMake(0, instateView.frame.origin.y + instateView.frame.size.height, 320, 0);
                             undergradsValue.frame = CGRectMake(0, 35, 320, 0);
                             undergradsText.frame = CGRectMake(0, 68, 320, 0);
                             instateValue.frame = CGRectMake(0, 35, 320, 0);
                             instateText.frame = CGRectMake(0, 68, 320, 0);
                             outstateValue.frame = CGRectMake(0, 35, 320, 0);
                             outstateText.frame = CGRectMake(0, 68, 320, 0);
                             
                             housingButton.frame = CGRectMake(0, universityContainerView.frame.origin.y + universityContainerView.frame.size.height, 320, 114);
                             housingContainerView.frame =  CGRectMake(0, housingButton.frame.origin.y + housingButton.frame.size.height, 320, 228);
                             freshmanPopulationView.frame = CGRectMake(0, 0, 320, 114);
                             studentPopulationView.frame = CGRectMake(0, freshmanPopulationView.frame.origin.y + freshmanPopulationView.frame.size.height, 320, 114);
                             freshmanPopulationValue.frame = CGRectMake(0, 20, 320, 30);
                             freshmanPopulationText.frame = CGRectMake(40, 53, 240, 50);
                             studentPopulationValue.frame = CGRectMake(0, 20, 320, 30);
                             studentPopulationText.frame = CGRectMake(40, 53, 240, 50);
                             
                             studentButton.frame = CGRectMake(0, housingContainerView.frame.origin.y + housingContainerView.frame.size.height, 320, 114);
                             studentContainerView.frame =  CGRectMake(0, studentButton.frame.origin.y + studentButton.frame.size.height, 320, 0);
                             collegeActivitiesView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeActivitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeActivitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeActivitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSportsView.frame =  CGRectMake(0, collegeActivitiesView.frame.origin.y + collegeActivitiesView.frame.size.height, 320, 0);
                             collegeSportsLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSportsLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSportsLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             
                             supportButton.frame = CGRectMake(0, studentContainerView.frame.origin.y + studentContainerView.frame.size.height, 320, 114);
                             supportContainerView.frame =  CGRectMake(0, supportButton.frame.origin.y + supportButton.frame.size.height, 320, 0);
                             collegeCounsellingView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeCounsellingLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeCounsellingLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeCounsellingLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSupportView.frame =  CGRectMake(0, collegeCounsellingView.frame.origin.y + collegeCounsellingView.frame.size.height, 320, 0);
                             collegeSupportLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSupportLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSupportLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeDisabilitiesView.frame =  CGRectMake(0, collegeSupportView.frame.origin.y + collegeSupportView.frame.size.height, 320, 0);
                             collegeDisabilitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeDisabilitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeDisabilitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             if(![collegeVideo isEqualToString:@"0"]){
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 320, 215);
                             } else {
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 0, 0);
                             }
                             int tempYpos;
                             tempYpos = 0;
                             for(int i = 0; i < _collegeGallaryImages.count; i ++)
                             {
                                 UIImageView *tempImage =  (UIImageView *)[_collegeGallaryImages objectAtIndex:i];
                                 tempImage.frame = CGRectMake(0, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height + tempYpos, 320, 215);
                                 tempYpos = tempYpos + 215;
                             }
                             
                         }
                         completion:nil];  // no completion handler
        isUniversityShown = false;
        isHousingShown = true;
        isStudentShown = false;
        isSupportShown = false;
    } else {
        [UIView animateWithDuration:0.50
                              delay: 0
                            options: UIViewAnimationOptionTransitionCurlDown
                         animations:^{
                             universityContainerView.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 320, 0);   // move
                             undergradsView.frame = CGRectMake(0, 0, 320, 0);
                             instateView.frame = CGRectMake(0, undergradsView.frame.origin.y + undergradsView.frame.size.height, 320, 0);
                             outstateView.frame = CGRectMake(0, instateView.frame.origin.y + instateView.frame.size.height, 320, 0);
                             undergradsValue.frame = CGRectMake(0, 35, 320, 0);
                             undergradsText.frame = CGRectMake(0, 68, 320, 0);
                             instateValue.frame = CGRectMake(0, 35, 320, 0);
                             instateText.frame = CGRectMake(0, 68, 320, 0);
                             outstateValue.frame = CGRectMake(0, 35, 320, 0);
                             outstateText.frame = CGRectMake(0, 68, 320, 0);
                             
                             housingButton.frame = CGRectMake(0, universityContainerView.frame.origin.y + universityContainerView.frame.size.height, 320, 114);
                             housingContainerView.frame =  CGRectMake(0, housingButton.frame.origin.y + housingButton.frame.size.height, 320, 0);
                             freshmanPopulationView.frame = CGRectMake(0, 0, 320, 0);
                             studentPopulationView.frame = CGRectMake(0, freshmanPopulationView.frame.origin.y + freshmanPopulationView.frame.size.height, 320, 0);
                             freshmanPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             freshmanPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             studentPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             studentPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             
                             studentButton.frame = CGRectMake(0, housingContainerView.frame.origin.y + housingContainerView.frame.size.height, 320, 114);
                             studentContainerView.frame =  CGRectMake(0, studentButton.frame.origin.y + studentButton.frame.size.height, 320, 0);
                             collegeActivitiesView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeActivitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeActivitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeActivitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSportsView.frame =  CGRectMake(0, collegeActivitiesView.frame.origin.y + collegeActivitiesView.frame.size.height, 320, 0);
                             collegeSportsLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSportsLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSportsLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             
                             supportButton.frame = CGRectMake(0, studentContainerView.frame.origin.y + studentContainerView.frame.size.height, 320, 114);
                             supportContainerView.frame =  CGRectMake(0, supportButton.frame.origin.y + supportButton.frame.size.height, 320, 0);
                             collegeCounsellingView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeCounsellingLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeCounsellingLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeCounsellingLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSupportView.frame =  CGRectMake(0, collegeCounsellingView.frame.origin.y + collegeCounsellingView.frame.size.height, 320, 0);
                             collegeSupportLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSupportLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSupportLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeDisabilitiesView.frame =  CGRectMake(0, collegeSupportView.frame.origin.y + collegeSupportView.frame.size.height, 320, 0);
                             collegeDisabilitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeDisabilitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeDisabilitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             if(![collegeVideo isEqualToString:@"0"]){
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 320, 215);
                             } else {
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 0, 0);
                             }
                             int tempYpos;
                             tempYpos = 0;
                             for(int i = 0; i < _collegeGallaryImages.count; i ++)
                             {
                                 UIImageView *tempImage =  (UIImageView *)[_collegeGallaryImages objectAtIndex:i];
                                 tempImage.frame = CGRectMake(0, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height + tempYpos, 320, 215);
                                 tempYpos = tempYpos + 215;
                             }
                         }
                         completion:nil];  // no completion handler
        isUniversityShown = false;
        isHousingShown = false;
        isStudentShown = false;
        isSupportShown = false;
    }

}

- (void)showStudentView {
    if (!isStudentShown) {
        //housingButton.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 0, 0);
        [UIView animateWithDuration:0.50
                              delay: 0
                            options: UIViewAnimationOptionTransitionCurlUp
                         animations:^{
                             universityContainerView.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 320, 0);   // move
                             undergradsView.frame = CGRectMake(0, 0, 320, 0);
                             instateView.frame = CGRectMake(0, undergradsView.frame.origin.y + undergradsView.frame.size.height, 320, 0);
                             outstateView.frame = CGRectMake(0, instateView.frame.origin.y + instateView.frame.size.height, 320, 0);
                             undergradsValue.frame = CGRectMake(0, 35, 320, 0);
                             undergradsText.frame = CGRectMake(0, 68, 320, 0);
                             instateValue.frame = CGRectMake(0, 35, 320, 0);
                             instateText.frame = CGRectMake(0, 68, 320, 0);
                             outstateValue.frame = CGRectMake(0, 35, 320, 0);
                             outstateText.frame = CGRectMake(0, 68, 320, 0);
                             
                             housingButton.frame = CGRectMake(0, universityContainerView.frame.origin.y + universityContainerView.frame.size.height, 320, 114);
                             housingContainerView.frame =  CGRectMake(0, housingButton.frame.origin.y + housingButton.frame.size.height, 320, 0);
                             freshmanPopulationView.frame = CGRectMake(0, 0, 320, 0);
                             studentPopulationView.frame = CGRectMake(0, freshmanPopulationView.frame.origin.y + freshmanPopulationView.frame.size.height, 320, 0);
                             freshmanPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             freshmanPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             studentPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             studentPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             
                             studentButton.frame = CGRectMake(0, housingContainerView.frame.origin.y + housingContainerView.frame.size.height, 320, 114);
                             studentContainerView.frame =  CGRectMake(0, studentButton.frame.origin.y + studentButton.frame.size.height, 320, totalYpos);
                             collegeActivitiesView.frame =  CGRectMake(0, 0, 320, ypos + 50);
                             collegeActivitiesLabel.frame = CGRectMake(0, 30, 320, 20);
                             for(int i = 0; i < _collegeActivitiesLabels.count; i ++)
                             {
                               UILabel *tempLabel =  (UILabel *)[_collegeActivitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = NO;
                             }
                             collegeSportsView.frame =  CGRectMake(0, collegeActivitiesView.frame.origin.y + collegeActivitiesView.frame.size.height, 320, ypos1 + 50);
                             collegeSportsLabel.frame = CGRectMake(0, 30, 320, 20);
                             for(int i = 0; i < _collegeSportsLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSportsLabels objectAtIndex:i];
                                 tempLabel.hidden = NO;
                             }
                             
                             
                             supportButton.frame = CGRectMake(0, studentContainerView.frame.origin.y + studentContainerView.frame.size.height, 320, 114);
                             supportContainerView.frame =  CGRectMake(0, supportButton.frame.origin.y + supportButton.frame.size.height, 320, 0);
                             collegeCounsellingView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeCounsellingLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeCounsellingLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeCounsellingLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSupportView.frame =  CGRectMake(0, collegeCounsellingView.frame.origin.y + collegeCounsellingView.frame.size.height, 320, 0);
                             collegeSupportLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSupportLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSupportLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeDisabilitiesView.frame =  CGRectMake(0, collegeSupportView.frame.origin.y + collegeSupportView.frame.size.height, 320, 0);
                             collegeDisabilitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeDisabilitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeDisabilitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             if(![collegeVideo isEqualToString:@"0"]){
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 320, 215);
                             } else {
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 0, 0);
                             }
                             int tempYpos;
                             tempYpos = 0;
                             for(int i = 0; i < _collegeGallaryImages.count; i ++)
                             {
                                 UIImageView *tempImage =  (UIImageView *)[_collegeGallaryImages objectAtIndex:i];
                                 tempImage.frame = CGRectMake(0, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height + tempYpos, 320, 215);
                                 tempYpos = tempYpos + 215;
                             }
                         }
                         completion:nil];  // no completion handler
        isUniversityShown = false;
        isHousingShown = false;
        isStudentShown = true;
        isSupportShown = false;
    } else {
        [UIView animateWithDuration:0.50
                              delay: 0
                            options: UIViewAnimationOptionTransitionCurlDown
                         animations:^{
                             universityContainerView.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 320, 0);   // move
                             undergradsView.frame = CGRectMake(0, 0, 320, 0);
                             instateView.frame = CGRectMake(0, undergradsView.frame.origin.y + undergradsView.frame.size.height, 320, 0);
                             outstateView.frame = CGRectMake(0, instateView.frame.origin.y + instateView.frame.size.height, 320, 0);
                             undergradsValue.frame = CGRectMake(0, 35, 320, 0);
                             undergradsText.frame = CGRectMake(0, 68, 320, 0);
                             instateValue.frame = CGRectMake(0, 35, 320, 0);
                             instateText.frame = CGRectMake(0, 68, 320, 0);
                             outstateValue.frame = CGRectMake(0, 35, 320, 0);
                             outstateText.frame = CGRectMake(0, 68, 320, 0);
                             
                             housingButton.frame = CGRectMake(0, universityContainerView.frame.origin.y + universityContainerView.frame.size.height, 320, 114);
                             housingContainerView.frame =  CGRectMake(0, housingButton.frame.origin.y + housingButton.frame.size.height, 320, 0);
                             freshmanPopulationView.frame = CGRectMake(0, 0, 320, 0);
                             studentPopulationView.frame = CGRectMake(0, freshmanPopulationView.frame.origin.y + freshmanPopulationView.frame.size.height, 320, 0);
                             freshmanPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             freshmanPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             studentPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             studentPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             
                             studentButton.frame = CGRectMake(0, housingContainerView.frame.origin.y + housingContainerView.frame.size.height, 320, 114);
                             studentContainerView.frame =  CGRectMake(0, studentButton.frame.origin.y + studentButton.frame.size.height, 320, 0);
                             collegeActivitiesView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeActivitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeActivitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeActivitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSportsView.frame =  CGRectMake(0, collegeActivitiesView.frame.origin.y + collegeActivitiesView.frame.size.height, 320, 0);
                             collegeSportsLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSportsLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSportsLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             
                             supportButton.frame = CGRectMake(0, studentContainerView.frame.origin.y + studentContainerView.frame.size.height, 320, 114);
                             supportContainerView.frame =  CGRectMake(0, supportButton.frame.origin.y + supportButton.frame.size.height, 320, 0);
                             collegeCounsellingView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeCounsellingLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeCounsellingLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeCounsellingLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSupportView.frame =  CGRectMake(0, collegeCounsellingView.frame.origin.y + collegeCounsellingView.frame.size.height, 320, 0);
                             collegeSupportLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSupportLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSupportLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeDisabilitiesView.frame =  CGRectMake(0, collegeSupportView.frame.origin.y + collegeSupportView.frame.size.height, 320, 0);
                             collegeDisabilitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeDisabilitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeDisabilitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             if(![collegeVideo isEqualToString:@"0"]){
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 320, 215);
                             } else {
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 0, 0);
                             }
                             int tempYpos;
                             tempYpos = 0;
                             for(int i = 0; i < _collegeGallaryImages.count; i ++)
                             {
                                 UIImageView *tempImage =  (UIImageView *)[_collegeGallaryImages objectAtIndex:i];
                                 tempImage.frame = CGRectMake(0, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height + tempYpos, 320, 215);
                                 tempYpos = tempYpos + 215;
                             }
                         }
                         completion:nil];  // no completion handler
        isUniversityShown = false;
        isHousingShown = false;
        isStudentShown = false;
        isSupportShown = false;
    }

}

- (void)showSupportView {
    if (!isSupportShown) {
        //housingButton.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 0, 0);
        [UIView animateWithDuration:0.50
                              delay: 0
                            options: UIViewAnimationOptionTransitionCurlUp
                         animations:^{
                             universityContainerView.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 320, 0);   // move
                             undergradsView.frame = CGRectMake(0, 0, 320, 0);
                             instateView.frame = CGRectMake(0, undergradsView.frame.origin.y + undergradsView.frame.size.height, 320, 0);
                             outstateView.frame = CGRectMake(0, instateView.frame.origin.y + instateView.frame.size.height, 320, 0);
                             undergradsValue.frame = CGRectMake(0, 35, 320, 0);
                             undergradsText.frame = CGRectMake(0, 68, 320, 0);
                             instateValue.frame = CGRectMake(0, 35, 320, 0);
                             instateText.frame = CGRectMake(0, 68, 320, 0);
                             outstateValue.frame = CGRectMake(0, 35, 320, 0);
                             outstateText.frame = CGRectMake(0, 68, 320, 0);
                             
                             housingButton.frame = CGRectMake(0, universityContainerView.frame.origin.y + universityContainerView.frame.size.height, 320, 114);
                             housingContainerView.frame =  CGRectMake(0, housingButton.frame.origin.y + housingButton.frame.size.height, 320, 0);
                             freshmanPopulationView.frame = CGRectMake(0, 0, 320, 0);
                             studentPopulationView.frame = CGRectMake(0, freshmanPopulationView.frame.origin.y + freshmanPopulationView.frame.size.height, 320, 0);
                             freshmanPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             freshmanPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             studentPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             studentPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             
                             studentButton.frame = CGRectMake(0, housingContainerView.frame.origin.y + housingContainerView.frame.size.height, 320, 114);
                             studentContainerView.frame =  CGRectMake(0, studentButton.frame.origin.y + studentButton.frame.size.height, 320, 0);
                             collegeActivitiesView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeActivitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeActivitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeActivitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSportsView.frame =  CGRectMake(0, collegeActivitiesView.frame.origin.y + collegeActivitiesView.frame.size.height, 320, 0);
                             collegeSportsLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSportsLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSportsLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             
                             supportButton.frame = CGRectMake(0, studentContainerView.frame.origin.y + studentContainerView.frame.size.height, 320, 114);
                             supportContainerView.frame =  CGRectMake(0, supportButton.frame.origin.y + supportButton.frame.size.height, 320, totalYpos1);
                             collegeCounsellingView.frame =  CGRectMake(0, 0, 320, ypos2 + 50);
                             collegeCounsellingLabel.frame = CGRectMake(0, 30, 320, 20);
                             for(int i = 0; i < _collegeCounsellingLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeCounsellingLabels objectAtIndex:i];
                                 tempLabel.hidden = NO;
                             }
                             collegeSupportView.frame =  CGRectMake(0, collegeCounsellingView.frame.origin.y + collegeCounsellingView.frame.size.height, 320, ypos3 + 50);
                             collegeSupportLabel.frame = CGRectMake(0, 30, 320, 20);
                             for(int i = 0; i < _collegeSupportLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSupportLabels objectAtIndex:i];
                                 tempLabel.hidden = NO;
                             }
                             collegeDisabilitiesView.frame =  CGRectMake(0, collegeSupportView.frame.origin.y + collegeSupportView.frame.size.height, 320, ypos4 + 50);
                             collegeDisabilitiesLabel.frame = CGRectMake(0, 30, 320, 20);
                             for(int i = 0; i < _collegeDisabilitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeDisabilitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = NO;
                             }
                             if(![collegeVideo isEqualToString:@"0"]){
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 320, 215);
                             } else {
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 0, 0);
                             }
                             int tempYpos;
                             tempYpos = 0;
                             for(int i = 0; i < _collegeGallaryImages.count; i ++)
                             {
                                 
                                 UIImageView *tempImage =  (UIImageView *)[_collegeGallaryImages objectAtIndex:i];
                                 tempImage.frame = CGRectMake(0, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height + tempYpos, 320, 215);
                                 tempYpos = tempYpos + 215;
                             }
                         }
                         completion:nil];  // no completion handler
        isUniversityShown = false;
        isHousingShown = false;
        isStudentShown = false;
        isSupportShown = true;
    } else {
        [UIView animateWithDuration:0.50
                              delay: 0
                            options: UIViewAnimationOptionTransitionCurlDown
                         animations:^{
                             universityContainerView.frame =  CGRectMake(0, universityButton.frame.origin.y + universityButton.frame.size.height, 320, 0);   // move
                             undergradsView.frame = CGRectMake(0, 0, 320, 0);
                             instateView.frame = CGRectMake(0, undergradsView.frame.origin.y + undergradsView.frame.size.height, 320, 0);
                             outstateView.frame = CGRectMake(0, instateView.frame.origin.y + instateView.frame.size.height, 320, 0);
                             undergradsValue.frame = CGRectMake(0, 35, 320, 0);
                             undergradsText.frame = CGRectMake(0, 68, 320, 0);
                             instateValue.frame = CGRectMake(0, 35, 320, 0);
                             instateText.frame = CGRectMake(0, 68, 320, 0);
                             outstateValue.frame = CGRectMake(0, 35, 320, 0);
                             outstateText.frame = CGRectMake(0, 68, 320, 0);
                             
                             housingButton.frame = CGRectMake(0, universityContainerView.frame.origin.y + universityContainerView.frame.size.height, 320, 114);
                             housingContainerView.frame =  CGRectMake(0, housingButton.frame.origin.y + housingButton.frame.size.height, 320, 0);
                             freshmanPopulationView.frame = CGRectMake(0, 0, 320, 0);
                             studentPopulationView.frame = CGRectMake(0, freshmanPopulationView.frame.origin.y + freshmanPopulationView.frame.size.height, 320, 0);
                             freshmanPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             freshmanPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             studentPopulationValue.frame = CGRectMake(0, 20, 320, 0);
                             studentPopulationText.frame = CGRectMake(40, 53, 240, 0);
                             
                             studentButton.frame = CGRectMake(0, housingContainerView.frame.origin.y + housingContainerView.frame.size.height, 320, 114);
                             studentContainerView.frame =  CGRectMake(0, studentButton.frame.origin.y + studentButton.frame.size.height, 320, 0);
                             collegeActivitiesView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeActivitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeActivitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeActivitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSportsView.frame =  CGRectMake(0, collegeActivitiesView.frame.origin.y + collegeActivitiesView.frame.size.height, 320, 0);
                             collegeSportsLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSportsLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSportsLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             
                             supportButton.frame = CGRectMake(0, studentContainerView.frame.origin.y + studentContainerView.frame.size.height, 320, 114);
                             supportContainerView.frame =  CGRectMake(0, supportButton.frame.origin.y + supportButton.frame.size.height, 320, 0);
                             collegeCounsellingView.frame =  CGRectMake(0, 0, 320, 0);
                             collegeCounsellingLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeCounsellingLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeCounsellingLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeSupportView.frame =  CGRectMake(0, collegeCounsellingView.frame.origin.y + collegeCounsellingView.frame.size.height, 320, 0);
                             collegeSupportLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeSupportLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeSupportLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             collegeDisabilitiesView.frame =  CGRectMake(0, collegeSupportView.frame.origin.y + collegeSupportView.frame.size.height, 320, 0);
                             collegeDisabilitiesLabel.frame = CGRectMake(0, 30, 320, 0);
                             for(int i = 0; i < _collegeDisabilitiesLabels.count; i ++)
                             {
                                 UILabel *tempLabel =  (UILabel *)[_collegeDisabilitiesLabels objectAtIndex:i];
                                 tempLabel.hidden = YES;
                             }
                             if(![collegeVideo isEqualToString:@"0"]){
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 320, 215);
                             } else {
                                 _videoPlayer.view.frame = CGRectMake(0, supportContainerView.frame.origin.y + supportContainerView.frame.size.height, 0, 0);
                             }
                             int tempYpos;
                             tempYpos = 0;
                             for(int i = 0; i < _collegeGallaryImages.count; i ++)
                             {
                                 UIImageView *tempImage =  (UIImageView *)[_collegeGallaryImages objectAtIndex:i];
                                 tempImage.frame = CGRectMake(0, _videoPlayer.view.frame.origin.y + _videoPlayer.view.frame.size.height + tempYpos, 320, 215);
                                 tempYpos = tempYpos + 215;
                             }
                         }
                         completion:nil];  // no completion handler
        isUniversityShown = false;
        isHousingShown = false;
        isStudentShown = false;
        isSupportShown = false;
    }

}

- (UIImage *)scaleImageProportionally:(UIImage *)image {
    
        CGFloat targetWidth = 0;
        CGFloat targetHeight = 0;
    
        CGFloat ratio = image.size.width / image.size.height;
        targetWidth = 130;
        targetHeight = roundf(130 / ratio);
        
        CGSize targetSize = CGSizeMake(targetWidth, targetHeight);
        
        UIImage *sourceImage = image;
        UIImage *newImage = nil;
        
        CGSize imageSize = sourceImage.size;
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        
        targetWidth = targetSize.width;
        targetHeight = targetSize.height;
        
        CGFloat scaleFactor = 0.0;
        CGFloat scaledWidth = targetWidth;
        CGFloat scaledHeight = targetHeight;
        
        CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
        
        if (!CGSizeEqualToSize(imageSize, targetSize)) {
            
            CGFloat widthFactor = targetWidth / width;
            CGFloat heightFactor = targetHeight / height;
            
            if (widthFactor < heightFactor)
                scaleFactor = widthFactor;
            else
                scaleFactor = heightFactor;
            
            scaledWidth = roundf(width * scaleFactor);
            scaledHeight = roundf(height * scaleFactor);
            
            // center the image
            if (widthFactor < heightFactor) {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            } else if (widthFactor > heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
        
        UIGraphicsBeginImageContext(targetSize);
        
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [sourceImage drawInRect:thumbnailRect];
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (newImage == nil) NSLog(@"could not scale image");
        
        return newImage;
}

@end
