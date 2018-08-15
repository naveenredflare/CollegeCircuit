//
//  MatchesListTableViewController.h
//  CollegeMatchmaker
//
//  Created by Kumar  on 25/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"

@interface StarsListTableViewController : UITableViewController<NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource,SWRevealViewControllerDelegate>{
    
    SWRevealViewController *revealController;
    NSMutableData *_responseData;
    NSURLConnection *connection1;
    NSURLConnection *connection2;
    NSURLConnection *connection3;
    NSUserDefaults *defaults;
    NSMutableDictionary *starsList;
    NSInteger starred_selectedIndex;
    BOOL starred;
    NSMutableArray * rowIdArray;

}

@property (nonatomic, strong) NSOperationQueue *imageDownloadingQueue;
@property (nonatomic, strong) NSCache *imageCache;
@end
