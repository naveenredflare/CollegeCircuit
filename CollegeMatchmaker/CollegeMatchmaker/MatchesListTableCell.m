//
//  MatchesListTableCell.m
//  CollegeMatchmaker
//
//  Created by Kumar  on 25/11/14.
//  Copyright (c) 2014 Org. All rights reserved.
//

#import "MatchesListTableCell.h"

@implementation MatchesListTableCell
@synthesize collegeStar, gradientView;

- (void)awakeFromNib {
    // Initialization code
    [collegeStar setImage:[UIImage imageNamed:@"starIcon"] forState:UIControlStateNormal];
    [collegeStar setImage:[UIImage imageNamed:@"starIconSelected"] forState:UIControlStateSelected];
    
    /*------------Gradient View------------*/
    //gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, logoView.frame.origin.y + logoView.frame.size.height + 15, 320, 75)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    gradient.locations = locations;
    gradient.opacity = 1;
    [gradientView.layer insertSublayer:gradient atIndex:0];
    //gradientView.layer.opacity = 0.5;
    
    //[scrollview addSubview:gradientView];
    /*---------------------------*/

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
