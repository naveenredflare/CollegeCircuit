//
//  AppDelegate.h
//  CollegeMatchmaker
//
//  Created by Kumar  on 21/10/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "SearchViewController.h"
#import "DashboardViewController.h"
#import "CustomAnimationController.h"
@class Reachability;
@class SWRevealViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
    Reachability* internetReachable;
    Reachability* hostReachable;
    NSUserDefaults *defaults;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SWRevealViewController *viewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, assign) BOOL internetActive;

@property (nonatomic, assign) BOOL hostActive;

@property (strong, nonatomic) HomeViewController *homeViewController;
@property (strong, nonatomic) SearchViewController *searchViewController;
@property (strong, nonatomic) UINavigationController *navController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void) checkNetworkStatus:(NSNotification *)notice;

@end
