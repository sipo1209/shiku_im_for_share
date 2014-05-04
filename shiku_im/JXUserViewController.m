//
//  JXUserViewController.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXUserViewController.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "AppDelegate.h"
#import "JXLoginViewController.h"
#import "JXCell.h"

@interface JXUserViewController ()

@end

@implementation JXUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.frame = CGRectMake(0, 0, 320, JX_SCREEN_HEIGHT-49-44);
        [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _array =[[NSMutableArray alloc] init];
    _page=0;
    _isLoading=0;
    [self find];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)find
{
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"user/query")];
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

        NSTimeInterval t = [[dict objectForKey:@"registerDate"] floatValue];
        t = t/1000;
        NSDate* d = [NSDate dateWithTimeIntervalSince1970:t];

        cell.title = [dict objectForKey:@"userNickname"];
        cell.subtitle = [dict objectForKey:@"userId"];
        cell.bottomTitle = [g_App formatdate:d format:@"MM-dd HH:mm"];
        cell.headImage   = [JXUserObject getHeadImage:[dict objectForKey:@"userId"]];
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
    _refreshCount++;
    
    NSLog(@"response:%@",request.responseString);
    SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
    NSDictionary *rootDic=[paser objectWithString:request.responseString];
    int resultCode=[[rootDic objectForKey:@"resultCode"]intValue];
    if (resultCode==1) {
        NSLog(@"查找成功");
        //保存账号信息

        if(_page == 0)
            [_array removeAllObjects];
        
        NSArray *userArr=[[rootDic objectForKey:@"data"] objectForKey:@"pageData"];
        for (NSDictionary *dic in userArr)
            [_array addObject:dic];
        [_table reloadData];
    }else
    {
        NSLog(@"查找好友失败,原因:%@",[rootDic objectForKey:@"msg"]);
    }
    
}


-(void)requestError:(ASIFormDataRequest *)request
{
    NSLog(@"请求失败");
}

-(void)dealloc
{
    [_table release];
    [super dealloc];
    [_array release];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(![JXXMPP sharedInstance].isLogined){
        JXLoginViewController* vc = [[JXLoginViewController alloc]init];
        [g_App.window addSubview:vc.view];
        return;
    }
    
    NSDictionary *dic=_array[indexPath.row];
    NSString* myUserId = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    
    JXUserObject *user=[JXUserObject userFromDictionary:dic];
    if ([myUserId isEqualToString:user.userId]){
        [g_App showAlert:@"不能加自己"];
        return;
    }
    if (![JXUserObject haveSaveUserById:user.userId]){
        [JXUserObject saveNewUser:user];
        [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewFriendNotifaction object:nil userInfo:nil];
        [g_App showAlert:@"已加为好友"];
    }else{
        [g_App showAlert:@"已经是好友，请到朋友中聊天"];
        
    }
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
    _isLoading = YES;
    [self find];
    _isLoading = NO;
}

@end