//
//  JXCell.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXCell.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "AppDelegate.h"

@implementation JXCell
@synthesize title,subtitle,rightTitle,bottomTitle,headImage,bage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle  = UITableViewCellSelectionStyleBlue;
        
        UIFont* f0 = [UIFont systemFontOfSize:14];
        UIFont* f1 = [UIFont boldSystemFontOfSize:15];
        
        int n = 60;
        UIView* v = [[UIView alloc]initWithFrame:CGRectMake(0,0, 320, n)];
        v.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        self.selectedBackgroundView = v;
        [v release];
        
        JXImageView* iv = [[JXImageView alloc] init];
        iv.frame = CGRectMake(0,n-1,320,1);
        iv.image = [UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"new_line@2x.png"]];
        iv.userInteractionEnabled = NO;
        [self.contentView addSubview:iv];
        [iv release];
        
        iv = [[JXImageView alloc]init];
        iv.userInteractionEnabled = NO;
        iv.delegate = self;
        iv.didTouch = @selector(actionUser:);
        iv.frame = CGRectMake(3,5,50,50);
        iv.layer.cornerRadius = 6;
        iv.layer.masksToBounds = YES;
        [self.contentView addSubview:iv];
        [iv release];
        iv.image = [UIImage imageNamed:[JXUserObject getHeadImage:self.headImage]];
        
        JXLabel* lb;
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(65, 5, 145, 20)];
        lb.textColor = [UIColor blackColor];
        lb.userInteractionEnabled = NO;
        lb.backgroundColor = [UIColor clearColor];
        lb.font = f1;
        [self.contentView addSubview:lb];
        [lb release];
        [lb setText:self.title];
        
        
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(65, 25, 320-65, 35)];
        lb.textColor = [UIColor lightGrayColor];
        lb.userInteractionEnabled = NO;
        lb.backgroundColor = [UIColor clearColor];
        lb.font = f0;
        [self.contentView addSubview:lb];
        [lb release];
        [lb setText:self.subtitle];
        
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(210, 5, 100, 20)];
        lb.textColor = [UIColor lightGrayColor];
        lb.userInteractionEnabled = NO;
        lb.backgroundColor = [UIColor clearColor];
        lb.textAlignment = UITextAlignmentRight;
        lb.font = f0;
        [self.contentView addSubview:lb];
        [lb release];
        [lb setText:self.bottomTitle];

        bageImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tabbar_badge"]];
        bageImage.frame = CGRectMake(35, 8-10, 25, 25);
        bageImage.backgroundColor = [UIColor clearColor];
        
        bageNumber=[[UILabel alloc]initWithFrame:CGRectZero];
        bageNumber.userInteractionEnabled = NO;
        bageNumber.frame = CGRectMake(0,0, 25, 25);
        bageNumber.backgroundColor = [UIColor clearColor];
        bageNumber.textAlignment = UITextAlignmentCenter;
        bageNumber.text  = bage;
        bageNumber.textColor = [UIColor whiteColor];
        bageNumber.font = f0;

        if([bage intValue]>0){
            [self.contentView addSubview:bageImage];
            [bageImage addSubview:bageNumber];
        }
    }
    return self;
}

-(void)dealloc{
    [bageImage release];
    [bageNumber release];
    [super dealloc];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setBage:(NSString *)s{
    bageImage.hidden = [s intValue]<=0;
    bageNumber.hidden = [s intValue]<=0;
    bageNumber.text = s;
    bage = s;
}

@end
