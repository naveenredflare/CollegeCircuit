//
//  DetailViewController.h
//  CollegeMatchmaker
//
//  Created by Kumar  on 29/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MBProgressHUD.h"

@interface DetailViewController : UIViewController<NSURLConnectionDelegate,UIScrollViewDelegate>{
    UIScrollView *scrollview;
    NSMutableData *_responseData;
    NSURLConnection *connection1;
    NSURLConnection *connection2;
    NSURLConnection *connection3;
    UIImageView *logoView;
    UIButton *starButton;
    UIImageView *mainView;
    UIView* gradientView;
    UILabel *collegeName;
    UILabel *collegeAddress;
    UIView *majorView;
    UILabel *majorText;
    UILabel *majorFirst;
    UILabel *majorSecond;
    UILabel *majorThird;
    UIImageView *m1View;
    UIImageView *m2View;
    UIImageView *m3View;
    UIView *applicationView;
    UIImageView *applicationImage;
    UILabel *applicationLabel;
    UIView *applicationRCView;
    UILabel *applicationMonth;
    UILabel *applicationDate;
    UIButton *calendarButton;
    UIButton *universityButton;
    UIButton *housingButton;
    UIButton *studentButton;
    UIButton *supportButton;
    UIView *universityContainerView;
    UIView *housingContainerView;
    UIView *studentContainerView;
    UIView *supportContainerView;
    UIView *undergradsView;
    UIView *instateView;
    UIView *outstateView;
    UILabel *undergradsValue;
    UILabel *undergradsText;
    UILabel *instateValue;
    UILabel *instateText;
    UILabel *outstateValue;
    UILabel *outstateText;
    UIView *freshmanPopulationView;
    UIView *studentPopulationView;
    UILabel *freshmanPopulationValue;
    UILabel *studentPopulationValue;
    UILabel *freshmanPopulationText;
    UILabel *studentPopulationText;
    UILabel *collegeActivitiesLabel;
    UIView *collegeActivitiesView;
    NSMutableArray *_collegeActivitiesLabels;
    UILabel *collegeSportsLabel;
    UIView *collegeSportsView;
    NSMutableArray *_collegeSportsLabels;
    UILabel *collegeCounsellingLabel;
    UIView *collegeCounsellingView;
    NSMutableArray *_collegeCounsellingLabels;
    UILabel *collegeSupportLabel;
    UIView *collegeSupportView;
    NSMutableArray *_collegeSupportLabels;
    UILabel *collegeDisabilitiesLabel;
    UIView *collegeDisabilitiesView;
    NSMutableArray *_collegeDisabilitiesLabels;
    NSMutableArray *_collegeGallaryImages;
    NSUserDefaults *defaults;
    
    bool isUniversityShown;
    bool isHousingShown;
    bool isStudentShown;
    bool isSupportShown;
    
    int ypos;
    int ypos1;
    int totalYpos;
    
    int ypos2;
    int ypos3;
    int ypos4;
    int totalYpos1;
    
    int ypos5;
    
    BOOL starred;
    
    NSMutableDictionary *matchesDetail;
    NSString *collegeVideo;

    
}

// Create a object of MPMoviePlayerController
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;

@property (nonatomic, retain) NSString *collegeId;


@end
