//
//  DashboardViewController.m
//  CollegeMatchmaker
//
//  Created by kumar on 06/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import "DashboardViewController.h"
#import "SWRevealViewController.h"
#import "SearchViewController.h"
#import "HomeViewController.h"
#import "StarsListTableViewController.h"
#import "SettingsViewController.h"

@interface DashboardViewController ()
{
    NSInteger _presentedRow;
}
@end

@implementation DashboardViewController
@synthesize dashboardTableView = _dashboardTableView;

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
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSInteger row = indexPath.row;
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
	
    NSString *text = nil;
    NSString *img = nil;
    
    if(row == 0){
        cell.userInteractionEnabled = NO;
        
        
    }
    else if (row == 1)
    {
        text = @"Home";
        img = @"homeSettings.png";
    }
    else if (row == 2)
    {
        text = @"Stars";
        img = @"starSettings.png";
    }
    else if (row == 3)
    {
        text = @"Settings";
        img = @"settingSettings.png";
    }
    else if (row == 4)
    {
        text = @"Logout";
        img = @"logoutSettings.png";
    }
    
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(27, 16, [UIImage imageNamed:img].size.width, [UIImage imageNamed:img].size.height)];
    iconView.userInteractionEnabled = YES;
    iconView.image = [UIImage imageNamed:img];
    [cell addSubview:iconView];
    
    UILabel *lblMsg = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 100, 20)];
    lblMsg.backgroundColor = [UIColor clearColor];
    lblMsg.font = [UIFont systemFontOfSize:14.0];
    lblMsg.text = NSLocalizedString( text,nil );
    lblMsg.textColor = [UIColor colorWithRed:97.0/255.0 green:88.0/255.0 blue:147.0/255.0 alpha:1.0];
    [cell addSubview:lblMsg];
    
    cell.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:232.0/255.0 blue:243.0/255.0 alpha:1.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
    SWRevealViewController *revealController = self.revealViewController;
    
    // selecting row
    NSInteger row = indexPath.row;
    
    // if we are trying to push the same row or perform an operation that does not imply frontViewController replacement
    // we'll just set position and return
    
    if ( row == _presentedRow )
    {
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        return;
    }
    
    
    // otherwise we'll create a new frontViewController and push it with animation
    
    UIViewController *newFrontController = nil;
    if (row == 0){
        
    }
    else if (row == 1)
    {
        newFrontController = [[SearchViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
        [revealController pushFrontViewController:navigationController animated:YES];
        
        _presentedRow = row;  // <- store the presented row

    }
    else if (row == 2)
    {
        newFrontController = [[StarsListTableViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
        [revealController pushFrontViewController:navigationController animated:YES];
        
        _presentedRow = row;  // <- store the presented row

    }
    else if (row == 3)
    {
        newFrontController = [[SettingsViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
        [revealController pushFrontViewController:navigationController animated:YES];
        
        _presentedRow = row;  // <- store the presented row

    }
    else if (row == 4)
    {
        UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:@"" message:@"Are sure you want to Logout?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Logout",@"Cancel", nil];
        [alert show];
        
        
        
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex==0) {
        
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
        
        
        [data setObject:@"" forKey:@"user_email"];
        [data setObject:@"" forKey:@"user_name"];
        [data setObject:@"" forKey:@"user_id"];
        
        [data writeToFile: path atomically:YES];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_id"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_name"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_email"];
        [NSUserDefaults resetStandardUserDefaults];
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        
        HomeViewController *homeVC = [[HomeViewController alloc] init];
        homeVC.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        navController = [[UINavigationController alloc] initWithRootViewController:homeVC];
        [self.view.window addSubview:navController.view];

        //[self.navigationController pushViewController:homeVC animated:NO];
        
    }
}

@end
