//
//  JXMsgCell.m
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXMsgCell.h"
#import "JXEmoji.h"
#import "SCGIFImageView.h"
#import "JXImageView.h"



#define CELL_HEIGHT self.contentView.frame.size.height
#define CELL_WIDTH self.contentView.frame.size.width


@implementation JXMsgCell
@synthesize index,delegate,didTouch,msg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        _drawed = NO;
        _userHead =[[JXImageView alloc]initWithFrame:CGRectZero];
        _headMask =[[JXImageView alloc]initWithFrame:CGRectZero];
        _chatImage=[[JXImageView alloc]initWithFrame:CGRectZero];
        
        _bubbleBg =[UIButton buttonWithType:UIButtonTypeCustom];
        
        _messageConent=[[JXEmoji alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        _messageConent.backgroundColor = [UIColor clearColor];
        _messageConent.userInteractionEnabled = NO;
        _messageConent.numberOfLines = 0;
        _messageConent.lineBreakMode = UILineBreakModeWordWrap;
        _messageConent.font = [UIFont systemFontOfSize:15];
        _messageConent.offset = -12;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.font = [UIFont systemFontOfSize:8];
        
        [self.contentView addSubview:_bubbleBg];
        [self.contentView addSubview:_userHead];
        [self.contentView addSubview:_headMask];
        [self.contentView addSubview:_messageConent];
        [self.contentView addSubview:_chatImage];
        [self.contentView addSubview:_timeLabel];
        
        _messageConent.hidden = YES;
        [_chatImage setHidden:YES];
        [_messageConent setHidden:YES];
        
        [_chatImage setBackgroundColor:[UIColor redColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [_headMask setImage:[[UIImage imageNamed:@"UserHeaderImageBox"]stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
        [_userHead setImage:[UIImage imageNamed:@"3.jpeg"]];
        
    }
    return self;
}

-(void)dealloc{
    NSLog(@"JXMsgCell.dealloc");
//    [msg release];
    [_readImage release];
    [_userHead release];
    [_headMask release];
    [_chatImage release];
    [_messageConent release];
    [_timeLabel release];
    [super release];
}

-(BOOL)isMeSend{
#ifdef IS_TEST_VERSION
    return fmod(index, 2);
#else
    return [msg.fromUserId isEqualToString:[[NSUserDefaults standardUserDefaults]stringForKey:kMY_USER_ID]];
#endif
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self draw];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)setMsg:(JXMessageObject *)aMessage
{
    msg = aMessage;
    if([aMessage.type intValue] == kWCMessageTypeText)
        _messageConent.text = aMessage.content;
}

-(void)setHeadImage:(UIImage*)headImage
{
    if(headImage)
        [_userHead setImage:headImage];
}
-(void)setChatImage:(UIImage *)chatImage
{
    [_chatImage setImage:chatImage];
}

-(void)setIndex:(int)value{
    index = value;
    _userHead.tag = index;
    _bubbleBg.tag = index;
    _messageConent.tag= index;
    _headMask.tag = index;
    _chatImage.tag = index;
    _messageConent.tag = index;
}

-(void)setDelegate:(NSObject *)value{
    delegate = value;
    
    _userHead.delegate = value;
    _messageConent.delegate= value;
    _headMask.delegate = value;
    _chatImage.delegate = value;
    _messageConent.delegate = value;
    if(delegate && didTouch)
        [_bubbleBg addTarget:delegate action:didTouch forControlEvents:UIControlEventTouchUpInside];
}

-(void)setDidTouch:(SEL)value{
    didTouch = value;
    _userHead.didTouch = value;
    _messageConent.didTouch= value;
    _headMask.didTouch = value;
    _chatImage.didTouch = value;
    _messageConent.didTouch = value;
    if(delegate && didTouch)
        [_bubbleBg addTarget:delegate action:didTouch forControlEvents:UIControlEventTouchUpInside];
}

-(void)updateIsRead:(BOOL)b{
    if(b)
        _readImage.hidden = YES;
    else{
        if(_readImage==nil)
            _readImage=[[JXImageView alloc]initWithImage:[UIImage imageNamed:@"VoiceNodeUnread"]];
        _readImage.hidden = NO;
        if([self isMeSend]){
            _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x-15, _bubbleBg.frame.origin.y+5, 11, 11);
        }
        else{
            _readImage.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+1, _bubbleBg.frame.origin.y+5, 11, 11);
        }
        
        [self.contentView addSubview:_readImage];
    }
}

-(void)draw{
    if(_drawed)
        return;
    _drawed = YES;
    NSLog(@"draw_%d",self.tag);
    BOOL isMe=[self isMeSend];
    CGSize textSize = _messageConent.frame.size;
    
    NSString* s;
    
    if(isMe){
        s = msg.fromUserId;
        [_userHead setFrame:CGRectMake(CELL_WIDTH-INSETS-HEAD_SIZE, INSETS,HEAD_SIZE , HEAD_SIZE)];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"SenderTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"SenderTextNodeBkgHL"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];
        
        _timeLabel.frame = CGRectMake(160, 0, 80, 8);
        _timeLabel.textAlignment = UITextAlignmentRight;
    }else{
        s = msg.toUserId;
        [_userHead setFrame:CGRectMake(INSETS, INSETS,HEAD_SIZE , HEAD_SIZE)];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"ReceiverTextNodeBkg"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateNormal];
        [_bubbleBg setBackgroundImage:[[UIImage imageNamed:@"ReceiverTextNodeBkgHL"]stretchableImageWithLeftCapWidth:20 topCapHeight:30] forState:UIControlStateHighlighted];
        
        _timeLabel.frame = CGRectMake(80, 0, 80, 8);
        _timeLabel.textAlignment = UITextAlignmentLeft;
    }
    [self setHeadImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:s]]]];
    _headMask.frame=CGRectMake(_userHead.frame.origin.x-3, _userHead.frame.origin.y-1, HEAD_SIZE+6, HEAD_SIZE+6);
    
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    [f setDateFormat:@"MM-dd HH:mm"];
    _timeLabel.text = [f stringFromDate:msg.timeSend];
    [f release];
    
    if([msg.type intValue]==kWCMessageTypeText){
        if(isMe){
            [_messageConent setHidden:NO];
            [_messageConent setFrame:CGRectMake(CELL_WIDTH-INSETS*2-HEAD_SIZE-textSize.width-15, (CELL_HEIGHT-textSize.height)/2, textSize.width, textSize.height)];
            _bubbleBg.frame=CGRectMake(_messageConent.frame.origin.x-15, _messageConent.frame.origin.y-12, textSize.width+30, textSize.height+30);
        }else
        {
            [_messageConent setHidden:NO];
            [_messageConent setFrame:CGRectMake(2*INSETS+HEAD_SIZE+15, (CELL_HEIGHT-textSize.height)/2, textSize.width, textSize.height)];
            _bubbleBg.frame=CGRectMake(_messageConent.frame.origin.x-15, _messageConent.frame.origin.y-12, textSize.width+30, textSize.height+30);
        }
    }
    
    
    if([msg.type intValue]==kWCMessageTypeImage){
        if(isMe)
        {
            [_chatImage setHidden:NO];
            [_chatImage setFrame:CGRectMake(CELL_WIDTH-INSETS*2-HEAD_SIZE-110, INSETS*2, 100, 100)];
            _bubbleBg.frame=CGRectMake(_chatImage.frame.origin.x-15, INSETS, 100+30, 100+30);
        }
        else
        {
            [_chatImage setHidden:NO];
            [_chatImage setFrame:CGRectMake(2*INSETS+HEAD_SIZE+15, INSETS*2,100,100)];
            _bubbleBg.frame=CGRectMake(_chatImage.frame.origin.x-15, INSETS, 100+30, 100+30);
        }
        [self setChatImage:[UIImage imageWithData:msg.fileData]];
    }
    
    
    if([msg.type intValue]==kWCMessageTypeVoice){
        float w = (320-HEAD_SIZE-INSETS*2-50)/30;
        w = 50+w*[msg.timeLen intValue];
        if(w<50)
            w = 50;
        if(w>200)
            w = 200;
        
        UIImageView* iv = [[UIImageView alloc] init];
        iv.image =  [UIImage imageNamed:@"VoiceNodePlaying@2x.png"];
        
        UILabel* p = [[UILabel alloc] init];
        p.text = [NSString stringWithFormat:@"%d''",[msg.timeLen intValue]];
        p.backgroundColor = [UIColor clearColor];
        p.textColor = [UIColor grayColor];
        p.font = [UIFont systemFontOfSize:11];
        
        if(isMe){
            _bubbleBg.frame=CGRectMake(320-w-HEAD_SIZE-INSETS*2, 15, w, 45);
            iv.frame = CGRectMake(_bubbleBg.frame.size.width-35, 10, 19, 19);
            p.frame = CGRectMake(_bubbleBg.frame.origin.x-50, 30, 50, 15);
            p.textAlignment = UITextAlignmentRight;
        }
        else{
            _bubbleBg.frame=CGRectMake(INSETS*2+HEAD_SIZE, 15, w, 45);
            iv.frame = CGRectMake(15, 10, 19, 19);
            p.frame = CGRectMake(_bubbleBg.frame.origin.x+_bubbleBg.frame.size.width+3, 30, 50, 15);
            p.textAlignment = UITextAlignmentLeft;
            [self updateIsRead:[msg.isRead boolValue]];
        }
        
        [self.contentView addSubview:p];
        [_bubbleBg addSubview:iv];
#ifdef IS_TEST_VERSION
        [self updateIsRead:[msg.isRead boolValue]];
#endif
    }
    
    
    if ([msg.type intValue]==kWCMessageTypeGif){
        [_bubbleBg setHidden:YES];
        NSString* path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[msg.fileName lastPathComponent]];
        SCGIFImageView* iv = [[SCGIFImageView alloc] initWithGIFFile:path];
        if(isMe)
            iv.frame = CGRectMake(180, 0, 80, 80);//185
        else
            iv.frame = CGRectMake(INSETS*2+HEAD_SIZE, 0, 80, 80);
        [self.contentView addSubview:iv];
        [iv release];
    }
}

@end