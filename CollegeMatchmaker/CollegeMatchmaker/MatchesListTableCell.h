//
//  MatchesListTableCell.h
//  CollegeMatchmaker
//
//  Created by Kumar  on 25/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchesListTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *collegeImage;
@property (weak, nonatomic) IBOutlet UILabel *collegeName;
@property (weak, nonatomic) IBOutlet UILabel *collegeAddress;
@property (weak, nonatomic) IBOutlet UILabel *collegeDeadline;
@property (strong, nonatomic) IBOutlet UIButton *collegeStar;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UILabel *viewsCount;
@property (weak, nonatomic) IBOutlet UILabel *starsCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewsWidthCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starsWidthCount;

@end
