//
//  JXMsgViewController.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXMsgViewController.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "JXCell.h"
#import "JXGroupViewController.h"
#import "JXRoomPool.h"
#import "JXLoginViewController.h"

@interface JXMsgViewController ()

@end

@implementation JXMsgViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.heightHeader = 0;
        self.heightFooter = 0;
        [self createHeadAndFoot];
        self.view.frame = CGRectMake(0, 0, 320, JX_SCREEN_HEIGHT-49-44);
        
        [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        JXXMPP *manager= [JXXMPP sharedInstance];
        [manager goOnline];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];

        [self getServerData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	JXCell *cell=nil;
    NSString* s = [NSString stringWithFormat:@"msg_%d_%d",_refreshCount,indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:s];
    if(cell==nil){
        NSDateFormatter *formatter=[[[NSDateFormatter alloc]init]autorelease];
        [formatter setAMSymbol:@"上午"];
        [formatter setPMSymbol:@"下午"];
        [formatter setDateFormat:@"a HH:mm"];

        JXMsgAndUserObject * dict = (JXMsgAndUserObject*) [_array objectAtIndex:indexPath.row];
        cell = [JXCell alloc];
        cell.title = dict.user.userNickname;
        cell.subtitle = dict.message.content;
        cell.bottomTitle = [formatter stringFromDate:dict.message.timeSend];
        cell.headImage   = dict.user.userHead;
        cell.bage        = [NSString stringWithFormat:@"%d",[dict.user.newMsgs intValue]];
        [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s];
        dict = nil;

        if(indexPath.row == _recordCount-1 && _recordCount>=3*(_page+1))//建上拉翻页控件
            [self createScrollFooter:0];
    }
    return cell;
}


#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _recordCount = _array.count;
    return _array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)dealloc
{
    [_array release];
    [super dealloc];
}


#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    JXMessageObject *msg = [notifacation.userInfo objectForKey:@"newMsg"];
    NSString* myUserId = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    NSString* s;
    if(msg.isGroup)
        s = msg.toUserId;
    else{
        if([myUserId isEqualToString:msg.fromUserId])
            s = msg.toUserId;
        else
            s = msg.fromUserId;
    }
    
    JXMsgAndUserObject *unionObj=nil;
    for(int i=0;i<[_array count];i++){
        unionObj=[_array objectAtIndex:i];
        if([unionObj.user.userId isEqualToString:s]){
            unionObj.message.content = [msg getLastContent];
            unionObj.message.timeSend = msg.timeSend;
            if(![msg.fromUserId isEqualToString:myUserId])
                unionObj.user.newMsgs = [NSNumber numberWithInt:[unionObj.user.newMsgs intValue]+1];
            [_array removeObjectAtIndex:i];
            break;
        }
        unionObj = nil;
    }
    
    if(unionObj){
        [_array insertObject:unionObj atIndex:0];
        _refreshCount++;
        [_table reloadData];
        return;
    }
    
    JXMsgAndUserObject* obj = [[JXMsgAndUserObject alloc]init];
    obj.user = [JXUserObject getUserById:s];
    obj.message = msg;
    [_array insertObject:obj atIndex:0];
//    [obj release];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [indexPaths addObject:indexPath];
    [_table beginUpdates];
    [_table insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_table endUpdates];
    [indexPaths release];
    [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)getServerData
{
    [self stopLoading];
    if(_array==nil || _page == 0){
        [_array release];
        _array = [[NSMutableArray alloc]init];
        _refreshCount++;
    }
    NSMutableArray* p = [JXMessageObject fetchRecentChatByPage:_page];
    if (p.count>0 || _page == 0) {
        [_array addObjectsFromArray:p];
        [_table reloadData];
    }
    p = nil;
    [self deleteScrollFooter];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath.begin");

    JXCell* cell = (JXCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.bage = @"0";
    
    JXMsgAndUserObject *unionObj=[_array objectAtIndex:indexPath.row];
    unionObj.user.newMsgs = [NSNumber numberWithInt:0];
    
    JXChatViewController *sendView=[JXChatViewController alloc];
    sendView.title = unionObj.user.userNickname;
    if([unionObj.user.roomFlag intValue] > 0){
        if(![JXXMPP sharedInstance].isLogined){
            JXLoginViewController* vc = [[JXLoginViewController alloc]init];
            [g_App.window addSubview:vc.view];
            return;
        }
        sendView.roomName = unionObj.user.userId;
        [[JXXMPP sharedInstance].roomPool joinRoom:unionObj.user.userId title:unionObj.user.userNickname];
    }
    [JXMessageObject updateNewMsgsTo0:unionObj.user.userId];
    [sendView init];
    [sendView setChatPerson:unionObj.user];
    [g_App.window addSubview:sendView.view];
    sendView.view.hidden = NO;
}

@end