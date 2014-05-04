//
//  JXChatViewController.m
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXChatViewController.h"
#import "XMPPMessage.h"
#import "JXMsgCell.h"
#import "ChatCacheFileUtil.h"
#import "VoiceConverter.h"
#import "Photo.h"
#import "NSData+XMPP.h"
#import "AppDelegate.h"
#import "JXEmoji.h"
#import "FaceViewController.h"
#import "emojiViewController.h"
#import "SCGIFImageView.h"
#import "JXImageView.h"
#import "JXSelectImageView.h"
#import "emojiViewController.h"
#import "JXLoginViewController.h"

#define height_Top   44
#define height_Toolbar   49
#define height_table JX_SCREEN_HEIGHT-height_Toolbar-height_Top-20

@implementation JXChatViewController
@synthesize roomName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pool = [[NSMutableArray alloc]init];
//        _array = [[NSMutableArray alloc]init];
        self.heightHeader = 44;
        self.heightFooter = 44;
        [self createHeadAndFoot];
//        _table = self.tableView;
        _table.backgroundColor = [UIColor whiteColor];
        _table.separatorStyle  = UITableViewCellSeparatorStyleNone;

        _myHeadImage   = [UIImage imageNamed:[JXUserObject getHeadImage:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]]];
//        _userHeadImage = [UIImage imageNamed:[JXUserObject getHeadImage:_chatPerson.userId]];
        
        _shareMoreView =[[JXSelectImageView alloc]init];
        [_shareMoreView setFrame:CGRectMake(0, 0, 320, 218)];
        [_shareMoreView setDelegate:self];
        [self initAudio];
        
        inputBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ToolViewBkg_Black.png"]];
//        inputBar.frame = CGRectMake(0, JX_SCREEN_HEIGHT-44-44, 320, 44);
        inputBar.frame = CGRectMake(0, 0, 320, 44);
        inputBar.userInteractionEnabled = YES;
        [self.tableFooter addSubview:inputBar];
        [inputBar release];
        
        messageText = [[UITextField alloc] initWithFrame:CGRectMake(45, 7, 205, 30)];
        messageText.delegate = self;
        messageText.autocorrectionType = UITextAutocorrectionTypeNo;
        messageText.autocapitalizationType = UITextAutocapitalizationTypeNone;
        messageText.enablesReturnKeyAutomatically = YES;
        messageText.borderStyle = UITextBorderStyleRoundedRect;
        messageText.returnKeyType = UIReturnKeySend;
        messageText.clearButtonMode = UITextFieldViewModeWhileEditing;
        [inputBar addSubview:messageText];
        [messageText release];
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(290, 7, 30, 30);
        btn.showsTouchWhenHighlighted = YES;
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"TypeSelectorBtn_Black.png"]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(shareMore:) forControlEvents:UIControlEventTouchUpInside];
        [inputBar addSubview:btn];
        
        btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(45, 7, 205, 30);
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn setTitle:@"按住  说话" forState:UIControlStateNormal];
        [btn setTitle:@"松开  结束" forState:UIControlEventTouchDown];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btn setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleShadowOffset:CGSizeMake(1, 1)];
        [inputBar addSubview:btn];
        [btn addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(recordStop:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(recordCancel:) forControlEvents:UIControlEventTouchUpOutside];
        btn.selected = NO;
        _recordBtn = btn;
        _recordBtn.hidden = YES;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 7, 30, 30);
        btn.showsTouchWhenHighlighted = YES;
        NSString* s2 = [NSString stringWithFormat:@"%@ToolViewInputVoice.png",[g_App imageFilePath]];
        NSString* s1 = [NSString stringWithFormat:@"%@keyboard_n@2x.png",[g_App imageFilePath]];
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:s2] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:s1] forState:UIControlStateSelected];
        btn.selected = NO;
        [inputBar addSubview:btn];
        [btn addTarget:self action:@selector(recordSwitch:) forControlEvents:UIControlEventTouchUpInside];
        _recordBtnLeft = btn;
        
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(252, 7, 30, 30);
        s2 = [NSString stringWithFormat:@"%@ToolViewEmotion.png",[g_App imageFilePath]];
        s1 = [NSString stringWithFormat:@"%@keyboard_n@2x.png",[g_App imageFilePath]];
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:s2] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:s1] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(actionFace:) forControlEvents:UIControlEventTouchUpInside];
        [inputBar addSubview:btn];
        _btnFace = btn;
        _btnFace.selected = NO;
        
        _messageConent=[[JXEmoji alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
        _messageConent.backgroundColor = [UIColor clearColor];
        _messageConent.userInteractionEnabled = NO;
        _messageConent.numberOfLines = 0;
        _messageConent.lineBreakMode = UILineBreakModeWordWrap;
        _messageConent.font = [UIFont systemFontOfSize:15];
        _messageConent.offset = -12;
 
        UIButton* _btn = [g_App createFooterButton:@"返回" action:@selector(actionQuit) target:self];
        _btn.frame = CGRectMake(5, (49-33)/2, 53, 66/2);
        [self.tableHeader addSubview:_btn];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)initAudio{
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)unInitAudio{
//    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    //添加监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kXMPPNewMsgNotifaction object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

-(void)refresh:(JXMessageObject*)msg
{
    [messageText setInputView:nil];
    [messageText resignFirstResponder];
    BOOL b=YES;
    if(msg == nil){
        if(_array==nil){
//            [_array release];
            _array = [[NSMutableArray alloc]init];
        }
        NSMutableArray* temp = [[NSMutableArray alloc]init];
        NSMutableArray* p;
        if([self.roomName length]>0)
            p = [JXMessageObject fetchMessageListWithUser:self.roomName byPage:_page];
        else
            p = [JXMessageObject fetchMessageListWithUser:_chatPerson.userId byPage:_page];
        b = p.count>0;
        [temp addObjectsFromArray:p];
        [temp addObjectsFromArray:_array];
        [_array addObjectsFromArray:temp];
        [temp release];
        p = nil;
    }else
        [_array addObject:msg];
    
    if (b) {
        [self free:_pool];
        _refreshCount++;
        [_table reloadData];
        if(msg || _page == 0)
            [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_array.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)free:(NSMutableArray*)array{
    for(int i=[array count]-1;i>=0;i--){
        id p = [array objectAtIndex:i];
        [array removeObjectAtIndex:i];
        [p release];
    }
}

- (void)dealloc {
    NSLog(@"JXChatViewController.dealloc");
    [self hideKeyboard];
    [self free:_pool];
    [self unInitAudio];
    [_pool release];
    [_array release];
    [_messageConent release];
    _faceView.delegate = nil;
    [_table release];
    [_shareMoreView release];
    _shareMoreView=nil;
    [audioPlayer stop];
    [audioPlayer release];
    [super dealloc];
}


#pragma mark ---触摸关闭键盘----
-(void)handleTap:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}


#pragma mark ----键盘高度变化------
-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    return;
    //获取到键盘frame 变化之前的frame
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
    deltaY=-endRect.size.height;
    
    NSLog(@"deltaY:%f",deltaY);
    [CATransaction begin];
    [UIView animateWithDuration:0.4f animations:^{
//        [self.view setFrame:CGRectMake(0, 0+deltaY+218+65, self.view.frame.size.width, self.view.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
    }];
    [CATransaction commit];
}

- (IBAction)sendIt:(id)sender {
    if(![JXXMPP sharedInstance].isLogined){
        JXLoginViewController* vc = [[JXLoginViewController alloc]init];
        [g_App.window addSubview:vc.view];
        return;
    }
        
    NSString *message = messageText.text;
    
    
    if (message.length > 0) {
        JXMessageObject *msg=[[JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
        if([self.roomName length]>0)
            msg.toUserId = self.roomName;
        else
            msg.toUserId     = _chatPerson.userId;
        msg.content      = message;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeText];
        msg.isSend       = [NSNumber numberWithBool:NO];
        msg.isRead       = [NSNumber numberWithBool:YES];
        msg.fileSize     = [NSNumber numberWithInt:0];
        msg.timeLen      = [NSNumber numberWithInt:0];

        [[JXXMPP sharedInstance] sendMessage:msg roomName:roomName];//发送消息
        [msg release];
    }
    [messageText setText:nil];
}


-(void)sendImage:(UIImage *)aImage
{
    if(![JXXMPP sharedInstance].isLogined){
        JXLoginViewController* vc = [[JXLoginViewController alloc]init];
        [g_App.window addSubview:vc.view];
        return;
    }
    
    [g_App showAlert:@"文件正在传送中..."];
    
    NSData *data = [Photo image2Data:aImage];

    if (data.length > 0) {
        JXMessageObject *msg=[[JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
        if([self.roomName length]>0)
            msg.toUserId = self.roomName;
        else
            msg.toUserId     = _chatPerson.userId;
        msg.fileData     = data;
        msg.fileName     = nil;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeImage];
        msg.isSend       = [NSNumber numberWithBool:NO];
        msg.isRead       = [NSNumber numberWithBool:YES];
        msg.fileSize     = [NSNumber numberWithInt:[msg.fileData length]];
        msg.timeLen      = [NSNumber numberWithInt:0];
        
        [[JXXMPP sharedInstance] sendMessage:msg roomName:roomName];//发送消息
        [msg release];
    }
}



- (IBAction)shareMore:(id)sender {
    [messageText setInputView:messageText.inputView?nil: _shareMoreView];
    [messageText reloadInputViews];
    [messageText becomeFirstResponder];
}



#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXMessageObject *msg=[_array objectAtIndex:indexPath.row];
//    NSLog(@"msg0=%d",msg.retainCount);
    NSString * identifier= [NSString stringWithFormat:@"friendCell_%d_%d",_refreshCount,indexPath.row];
    JXMsgCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell=[[JXMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [_pool addObject:cell];
        
//        NSLog(@"bb=%d",[msg.type intValue]);
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.index    = indexPath.row;
        cell.delegate = self;
        cell.didTouch = @selector(onSelect:);
        cell.msg      = msg;
        
        if([cell isMeSend])
            [cell setHeadImage:_myHeadImage];
        else
            [cell setHeadImage:[UIImage imageNamed:[JXUserObject getHeadImage:msg.fromUserId]]];
//        NSLog(@"msg1=%d",msg.retainCount);
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXMessageObject *msg=[_array objectAtIndex:indexPath.row];
    int n = [msg.type intValue];
    if(n == kWCMessageTypeImage)
        return 66+70;
    else
        if( n == kWCMessageTypeVoice)
            return 66;
        else
            if( n == kWCMessageTypeGif)
                return 80;
            else{
                _messageConent.frame = CGRectMake(0, 0, 200, 20);
                _messageConent.text   = [_array[indexPath.row]content];
                n=_messageConent.frame.size.height;
                NSLog(@"heightForRowAtIndexPath_%d,%d:=%@",indexPath.row,n,_messageConent.text);
                if(n<66)
                    n = 66;
                return n;
            }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
}

-(void)onHideKeyboard{
    [self hideKeyboard];
}

-(void)initPlayer{
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    audioSession = nil;
}

-(void)recordPlay:(JXMessageObject*)msg{
    NSString *fileName = msg.fileName;
    NSString *fullPath = [[[ChatCacheFileUtil sharedInstance] userDocPath] stringByAppendingPathComponent:fileName];
    
    if([_lastPlayerFile isEqualToString:fileName]){
        if([audioPlayer isPlaying]){
            _lastPlayerTime = audioPlayer.currentTime;
            [audioPlayer pause];
        }
        else
            [audioPlayer play];
        return;
    }
    
    _lastPlayerFile = [fileName copy];
    _lastPlayerTime = 0;
    [msg.fileData writeToFile:fullPath atomically:YES];
    
    NSString *wavPath = [VoiceConverter amrToWav:fullPath];
    NSError *error=nil;
    [audioPlayer stop];
    [audioPlayer release];

    [self initPlayer];
    audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:wavPath] error:&error];
    
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:wavPath];
    if (error) {
        error=nil;
    }
    [audioPlayer setVolume:1];
    [audioPlayer prepareToPlay];
    [audioPlayer setDelegate:self];
    [audioPlayer play];

    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO]; //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    
    if(_lastIndex>= _array.count)
        return;
    JXMessageObject *msg=[_array objectAtIndex:_lastIndex];
    [msg updateIsRead:YES];
    
    NSIndexPath* index=[NSIndexPath indexPathForRow:_lastIndex inSection:0];
    JXMsgCell* cell = (JXMsgCell*)[_table cellForRowAtIndexPath:index];
    [cell updateIsRead:YES];

    _lastIndex++;
    if(_lastIndex>= _array.count){
        _lastIndex--;
        return;
    }
    msg=[_array objectAtIndex:_lastIndex];
    if(![msg.isRead boolValue]){
        [self recordPlay:msg];
    }

    msg = nil;
    cell = nil;
    index = nil;
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    [self.tabBarController.tabBarItem setBadgeValue:@"1"];
    JXMessageObject *msg = [notifacation.userInfo objectForKey:@"newMsg"];

    if([msg.fromUserId isEqualToString:_chatPerson.userId] || [msg.toUserId isEqualToString:_chatPerson.userId] || [msg.toUserId isEqualToString:self.roomName] ){
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        [_array addObject:msg];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_array count]-1 inSection:0];
        [indexPaths addObject:indexPath];
        [_table beginUpdates];
        [_table insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        [_table endUpdates];
        [indexPaths release];
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_array.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    msg = nil;
}


#pragma mark sharemore按钮组协议

-(void)pickPhoto
{
    
    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imgPicker setDelegate:self];
    [imgPicker setAllowsEditing:NO];
    [self presentViewController:imgPicker animated:YES completion:^{
    }];
    
}


#pragma mark ----------图片选择完成-------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  * chosedImage=[[info objectForKey:@"UIImagePickerControllerOriginalImage"]retain];
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        //
        
        [self sendImage:chosedImage];
        
        
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


#pragma mark - 录制语音
- (IBAction)recordStart:(UIButton *)sender {
    if(recording)
        return;
    
    [audioPlayer pause];
    recording=YES;
    
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:8000],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"rec_%@_%@.wav",MY_USER_ID,[dateFormater stringFromDate:now]];
    NSString *fullPath = [[[ChatCacheFileUtil sharedInstance] userDocPath] stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL fileURLWithPath:fullPath];
    pathURL = url;
    
    NSError *error;
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:pathURL settings:settings error:&error];
    audioRecorder.delegate = self;
    
    peakTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updatePeak:) userInfo:nil repeats:YES];
    [peakTimer fire];
    
    [audioRecorder prepareToRecord];
    [audioRecorder setMeteringEnabled:YES];
    [audioRecorder peakPowerForChannel:0];
    [audioRecorder record];
    
    [dateFormater release];
}

- (void)updatePeak:(NSTimer*)timer
{
    _timeLen = audioRecorder.currentTime;
    if(_timeLen>=60)
        [self recordStop:nil];

/*    [audioRecorder updateMeters];
    const double alpha=0.5;
    double peakPowerForChannel=pow(10, (0.05)*[audioRecorder peakPowerForChannel:0]);
    lowPassResults=alpha*peakPowerForChannel+(1.0-alpha)*lowPassResults;
    
    for (int i=1; i<8; i++) {
        if (lowPassResults>1.0/7.0*i){
            [[talkView viewWithTag:i] setHidden:NO];
        }else{
            [[talkView viewWithTag:i] setHidden:YES];
        }
    }*/
}

- (IBAction)recordStop:(UIButton *)sender {
    if(!recording)
        return;
    [peakTimer invalidate];
    peakTimer = nil;
    
//    [self offRecordBtns];
    
    _timeLen = audioRecorder.currentTime;
    [audioRecorder stop];
    NSString *amrPath = [VoiceConverter wavToAmr:pathURL.path];
    NSData *recordData = [NSData dataWithContentsOfFile:amrPath];
    
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:pathURL.path];
    [[ChatCacheFileUtil sharedInstance] deleteWithContentPath:amrPath];
    _lastRecordFile = [[amrPath lastPathComponent] copy];
    
    NSLog(@"音频文件路径:%@\n%@",pathURL.path,amrPath);
//    if (_timeLen<1) {
//        [g_App showAlert:@"录的时间过短"];
//        return;
//    }
    [self sendVoice:recordData];
    [audioRecorder release];
    recording = NO;
}

- (IBAction)recordCancel:(UIButton *)sender
{
    if(!recording)
        return;
    [audioRecorder stop];
    [audioRecorder release];
    [peakTimer invalidate];
    peakTimer = nil;
    recording = NO;
}

-(void)sendVoice:(NSData *)data{
    if(![JXXMPP sharedInstance].isLogined){
        JXLoginViewController* vc = [[JXLoginViewController alloc]init];
        [g_App.window addSubview:vc.view];
        return;
    }
    
    //生成消息对象
    JXMessageObject *msg=[[JXMessageObject alloc]init];
    msg.timeSend     = [NSDate date];
    msg.fromUserId   = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    if([self.roomName length]>0)
        msg.toUserId = self.roomName;
    else
        msg.toUserId     = _chatPerson.userId;
    msg.fileData     = data;
    msg.fileName     = _lastRecordFile;
    msg.type         = [NSNumber numberWithInt:kWCMessageTypeVoice];
    msg.isSend       = [NSNumber numberWithBool:NO];
    msg.isRead       = [NSNumber numberWithBool:YES];
    msg.fileSize     = [NSNumber numberWithInt:[msg.fileData length]];
    msg.timeLen      = [NSNumber numberWithInt:_timeLen];
#ifdef IS_TEST_VERSION
    msg.isRead       = [NSNumber numberWithBool:NO];
#endif
    
    [[JXXMPP sharedInstance] sendMessage:msg roomName:roomName];//发送消息
    [msg release];
}

- (IBAction)sendGif:(id)sender {
    if(![JXXMPP sharedInstance].isLogined){
        JXLoginViewController* vc = [[JXLoginViewController alloc]init];
        [g_App.window addSubview:vc.view];
        return;
    }
    
    NSString *message = messageText.text;
    if (message.length > 0) {
        JXMessageObject *msg=[[JXMessageObject alloc]init];
        msg.timeSend     = [NSDate date];
        msg.fromUserId   = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
        if([self.roomName length]>0)
            msg.toUserId = self.roomName;
        else
            msg.toUserId     = _chatPerson.userId;
        msg.fileData     = nil;
        msg.fileName     = message;
        msg.content      = message;
        msg.type         = [NSNumber numberWithInt:kWCMessageTypeGif];
        msg.isSend       = [NSNumber numberWithBool:NO];
        msg.isRead       = [NSNumber numberWithBool:YES];
        msg.fileSize     = [NSNumber numberWithInt:[msg.fileData length]];
        msg.timeLen      = [NSNumber numberWithInt:0];
        
        [[JXXMPP sharedInstance] sendMessage:msg roomName:roomName];//发送消息
        [msg release];
    }
    [messageText setText:nil];
}


#pragma 表情

-(void)doBeginEdit{
    //	inputBar.frame = CGRectMake(0, JX_SCREEN_HEIGHT-480+156, 320, 44);
    //	_table.frame = CGRectMake(0, 0, 320, JX_SCREEN_HEIGHT-480+145+44);
	self.tableFooter.frame = CGRectMake(0, JX_SCREEN_HEIGHT-460+200, 320, 44);
	_table.frame = CGRectMake(0, 20, 320, JX_SCREEN_HEIGHT-460+200);
}

-(void)doEndEdit{
    //	inputBar.frame = CGRectMake(0, JX_SCREEN_HEIGHT-49-44-15, 320, 44);
    //	_table.frame = CGRectMake(0, 0, 320, height_table);
	self.tableFooter.frame = CGRectMake(0, JX_SCREEN_HEIGHT-self.heightFooter, 320, self.heightFooter);
    _table.frame =CGRectMake(0,self.heightHeader,self.view.frame.size.width,JX_SCREEN_HEIGHT-self.heightHeader-self.heightFooter);
    _faceView.hidden = YES;
    [_faceView removeFromSuperview];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
	[self doBeginEdit];
    _btnFace.selected = NO;
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	[self doEndEdit];
	return YES;
}

- (BOOL) hideKeyboard {
    [self doEndEdit];
    [messageText resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self hideKeyboard];
    if(textField.tag == kWCMessageTypeGif)
        [self sendGif:textField];
    else
        [self sendIt:textField];
	return YES;
}

-(void)actionFace:(UIButton*)sender{
//    [self.view _effectiveStatusBarStyleViewController];
    [self offRecordBtns];
    if(sender.selected){
        [messageText becomeFirstResponder];
        [_faceView removeFromSuperview];
        _faceView.hidden = YES;
        sender.selected = NO;
    }else{
        if(_faceView==nil){
            _faceView = g_App.faceView;
            _faceView.delegate = messageText;
        }
        [messageText resignFirstResponder];
        [self.view addSubview:_faceView];
        _faceView.hidden = NO;
        sender.selected = YES;
    }
	[self doBeginEdit];
}

-(void)recordSwitch:(UIButton*)sender{
    sender.selected = !sender.selected;
    _recordBtn.hidden = !sender.selected;
    messageText.hidden = !_recordBtn.hidden;
}

-(void)onSelect:(UIView*)sender{
    [self hideKeyboard];

    int n = sender.tag;
    JXMessageObject *msg=[_array objectAtIndex:n];
    
    switch ([msg.type intValue]) {
        case kWCMessageTypeImage:{
            JXImageView* iv = [[JXImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            iv.image    = [UIImage imageWithData:msg.fileData];
            iv.delegate = self;
            iv.didTouch = @selector(onSelectImage:);
            iv.userInteractionEnabled = YES;
            [g_App.window addSubview:iv];
            iv.hidden   = NO;
            break;
        }
        case kWCMessageTypeVoice:{
            _lastIndex = n;
            [self recordPlay:msg];
            break;
        }
        default:
            break;
    }
    msg = nil;
}

-(void)onSelectImage:(JXImageView*)sender{
    sender.hidden = YES;
    [sender release];
}

-(void)offRecordBtns{
    _recordBtnLeft.selected = NO;
    _recordBtn.hidden = YES;
    messageText.hidden = NO;
}


-(void)scrollToPageUp{
    if(_isLoading)
        return;
    _page ++;
    [self getServerData];
}

-(void)scrollToPageDown{
    if(_isLoading)
        return;
    _page=0;
    [self getServerData];
}

-(void)getServerData{
    _isLoading = YES;
    [self refresh:nil];
    [self stopLoading];
    _isLoading = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [self refresh:nil];
}

@end