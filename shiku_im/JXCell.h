//
//  JXCell.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JXCell : UITableViewCell{
    UIImageView* bageImage;
    UILabel* bageNumber;
}
@property (nonatomic,retain) NSString*  title;
@property (nonatomic,retain) NSString*  subtitle;
@property (nonatomic,retain) NSString*  rightTitle;
@property (nonatomic,retain) NSString*  bottomTitle;
@property (nonatomic,retain) NSString*  headImage;
@property (nonatomic,assign) NSString*  bage;


@end
