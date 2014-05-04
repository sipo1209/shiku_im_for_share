//
//  JXChatViewController.h
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AVFoundation/AVFoundation.h>
#import "PullRefreshTableViewController.h"


@class JXEmoji;
@class JXSelectImageView;

@interface JXChatViewController : PullRefreshTableViewController<UIImagePickerControllerDelegate>
{
    NSMutableArray *_array;
    NSMutableArray *_pool;
    UITextField *messageText;
    UIImageView *inputBar;
    UIButton* _recordBtn;
    UIButton* _recordBtnLeft;
    UIImage *_myHeadImage,*_userHeadImage;
    JXSelectImageView *_shareMoreView;
    UIButton* _btnFace;
    emojiViewController* _faceView;
    JXEmoji* _messageConent;

    BOOL recording;
    NSTimer *peakTimer;
    
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
	NSURL *pathURL;
    UIView* talkView;
    NSString* _lastRecordFile;
    NSString* _lastPlayerFile;
    NSTimeInterval _lastPlayerTime;
    int _lastIndex;

    double lowPassResults;
    NSTimeInterval _timeLen;
    int _refreshCount;
}
- (IBAction)sendIt:(id)sender;
- (IBAction)shareMore:(id)sender;
- (void)refresh;

@property (nonatomic,retain) JXUserObject *chatPerson;
@property (nonatomic,retain) NSString* roomName;
@end
