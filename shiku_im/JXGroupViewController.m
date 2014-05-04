//
//  JXGroupViewController.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "JXGroupViewController.h"
//#import "Statics.h"
//#import "KKMessageCell.h"
#import "XMPPStream.h"
#import "JXMessageObject.h"
#import "JXXMPP.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "JXCell.h"
#import "JXRoomPool.h"
#import "JXLoginViewController.h"

#define padding 20

@implementation JXGroupViewController

#pragma mark - life circle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _array = [[NSMutableArray alloc] init];
        _page=0;
        _isLoading=0;
        [self find];

        self.view.frame = CGRectMake(0, 0, 320, JX_SCREEN_HEIGHT-49-44);
//        [self buildButtons];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc {
    [_array release];
    [super dealloc];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated{
}

#pragma mark - private
- (void)actionNewRoom {
    if(![JXXMPP sharedInstance].isLogined){
        JXLoginViewController* vc = [[JXLoginViewController alloc]init];
        [g_App.window addSubview:vc.view];
        return;
    }
    [g_App showAlert:@"本版本不支持新建房间和永久保存成员，如需此功能、服务端源码、安卓端源码请联系微信公众号：视酷即时通讯，手机18665366227"];
    return;
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"didFetchMembersList");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
    NSLog(@"didFetchModeratorsList");
}


-(void)find
{
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"room/query")];
    
    [request setPostValue:@"" forKey:@"roomName"];
    [request setPostValue:[NSNumber numberWithInt:_page] forKey:@"pageIndex"];
    [request setPostValue:[NSNumber numberWithInt:10] forKey:@"pageSize"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestSuccess:)];
    [request setDidFailSelector:@selector(requestError:)];
    [request startAsynchronous];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	JXCell *cell=nil;
    NSString* s = [NSString stringWithFormat:@"msg_%d_%d",_refreshCount,indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:s];
    if(cell==nil){
        NSDictionary *dict=_array[indexPath.row];
        cell = [JXCell alloc];

        NSTimeInterval t = [[dict objectForKey:@"creationDate"] floatValue];
        t = t/1000;
        NSDate* d = [NSDate dateWithTimeIntervalSince1970:t];
        
        cell.title = [dict objectForKey:@"roomSubject"];
        cell.subtitle = [dict objectForKey:@"roomJID"];
        cell.bottomTitle = [g_App formatdate:d format:@"MM-dd HH:mm"];
        cell.headImage   = [JXUserObject getHeadImage:[dict objectForKey:@"roomName"]];
        [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s];
        dict = nil;
        
        if(indexPath.row == _recordCount-1 && _recordCount>=10*(_page+1))//建上拉翻页控件
            [self createScrollFooter:0];
    }
    return cell;
}

#pragma mark   -------网络请求回调---------
-(void)requestSuccess:(ASIFormDataRequest*)request
{
    [self stopLoading];
    [self deleteScrollFooter];

    NSLog(@"response:%@",request.responseString);
    SBJsonParser *paser=[[[SBJsonParser alloc]init] autorelease];
    NSDictionary *rootDic=[paser objectWithString:request.responseString];
    int resultCode=[[rootDic objectForKey:@"resultCode"]intValue];
    if (resultCode==1) {
        NSLog(@"查找成功");

        if(_page == 0)
            [_array removeAllObjects];
        
        //保存账号信息
        NSArray *userArr=[[rootDic objectForKey:@"data"] objectForKey:@"pageData"];
        
        for (NSDictionary *dic in userArr) {
            [_array addObject:dic];
        }
        [_table reloadData];
    }else
    {
        NSLog(@"查找房间失败,原因:%@",[rootDic objectForKey:@"msg"]);
    }
    
}

-(void)requestError:(ASIFormDataRequest *)request
{
    NSLog(@"请求失败");
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![JXXMPP sharedInstance].isLogined){
        JXLoginViewController* vc = [[JXLoginViewController alloc]init];
        [g_App.window addSubview:vc.view];
        return;
    }
    [_inputText resignFirstResponder];
    NSDictionary *dict=_array[indexPath.row];

    NSString* s = [dict objectForKey:@"roomName"];
    NSLog(@"加入房间：%@",s);

    [[JXXMPP sharedInstance].roomPool joinRoom:s title:[dict objectForKey:@"roomSubject"]];

    JXChatViewController *sendView=[JXChatViewController alloc];
    sendView.title = [dict objectForKey:@"roomSubject"];
    [sendView init];
    sendView.roomName = s;
    [g_App.window addSubview:sendView.view];

    JXUserObject* user = [[JXUserObject alloc]init];
    user.userNickname = [dict objectForKey:@"roomSubject"];
    user.userId = s;
    user.userDescription = [dict objectForKey:@"roomDesc"];
    user.userHead = [dict objectForKey:@"userHead"];
    if (![JXUserObject haveSaveUserById:user.userId])
        [JXUserObject saveNewRoom:user];
    [user release];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)scrollToPageUp{
    if(_isLoading)
        return;
    _page = 0;
    [self getServerData];
}

-(void)scrollToPageDown{
    if(_isLoading)
        return;
    _page++;
    [self getServerData];
}

-(void)getServerData{
    _refreshCount++;
    _isLoading = YES;
    [self find];
    _isLoading = NO;
}

-(void)buildButtons{
    //int height=60;
    int height1=26;
    int height=0;
    
    _inputText  = [[UITextField alloc]initWithFrame:CGRectMake(5, 44+2, 310, height1)];
    _inputText.textColor = [UIColor blackColor];
    _inputText.userInteractionEnabled = YES;
    _inputText.delegate = self;
    _inputText.placeholder = @"请输入新房间名称";
	_inputText.borderStyle = UITextBorderStyleRoundedRect;
    _inputText.font = [UIFont systemFontOfSize:14];
    _inputText.text = @"天上人间包房";
	_inputText.autocorrectionType = UITextAutocorrectionTypeNo;
	_inputText.returnKeyType = UIReturnKeyDone;
	_inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
    _table.tableHeaderView = _inputText;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end