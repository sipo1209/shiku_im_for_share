//
//  JXMsgCell.h
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXEmoji;
@class JXImageView;

//头像大小
#define HEAD_SIZE 50.0f
#define TEXT_MAX_HEIGHT 500.0f
//间距
#define INSETS 8.0f



@interface JXMsgCell : UITableViewCell
{
    JXImageView *_userHead;
    UIButton *_bubbleBg;
    JXImageView *_headMask;
    JXImageView *_chatImage;
    JXImageView *_readImage;
    JXEmoji *_messageConent;
    UILabel* _timeLabel;
    BOOL _drawed;
}

@property (nonatomic) int index;
@property (nonatomic, assign) JXMessageObject* msg;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;

-(void)setHeadImage:(UIImage*)headImage;
-(BOOL)isMeSend;
-(void)updateIsRead:(BOOL)b;

@end
