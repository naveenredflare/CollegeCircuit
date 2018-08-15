//
//  MatchesListTableViewController.h
//  CollegeMatchmaker
//
//  Created by Kumar  on 25/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MatchesListTableViewController : UITableViewController<NSURLConnectionDelegate,UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableData *_responseData;
    NSURLConnection *connection1;
    NSURLConnection *connection2;
    NSURLConnection *connection3;
    NSUserDefaults *defaults;
    NSMutableDictionary *matchesList;
    NSInteger starred_selectedIndex;
    BOOL starred;
    NSMutableArray * rowIdArray;
    
}

@property (nonatomic, strong) NSOperationQueue *imageDownloadingQueue;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, retain) NSString *majorSearchText;
@property (nonatomic, retain) NSString *tutionSearchText;
@property (nonatomic, retain) NSString *sizeSearchText;
@property (nonatomic, retain) NSString *locationSearchText;
@end
