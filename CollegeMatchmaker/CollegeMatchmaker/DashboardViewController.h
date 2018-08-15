//
//  DashboardViewController.h
//  CollegeMatchmaker
//
//  Created by kumar on 06/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>{
    UINavigationController *navController;
}
@property (strong, nonatomic) IBOutlet UITableView *dashboardTableView;

@end
