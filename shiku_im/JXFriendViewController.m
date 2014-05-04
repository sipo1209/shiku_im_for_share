//
//  JXFriendViewController.h.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXFriendViewController.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "JXCell.h"
#import "JXGroupViewController.h"
#import "JXRoomPool.h"

@interface JXFriendViewController ()

@end

@implementation JXFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.view.frame = CGRectMake(0, 0, 320, JX_SCREEN_HEIGHT-49-44);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFriend:) name:kXMPPNewFriendNotifaction object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _array=[[NSMutableArray alloc]init];
    [self refresh];
    UIBarButtonItem *barBtn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    [self.navigationItem setRightBarButtonItem:barBtn];
    [barBtn release];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	JXCell *cell=nil;
    NSString* s = [NSString stringWithFormat:@"msg_%d_%d",_refreshCount,indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:s];
    if(cell==nil){
        JXUserObject *user=_array[indexPath.row];
        cell = [JXCell alloc];
        cell.title = user.userNickname;
        cell.subtitle = user.userId;
        cell.bottomTitle = [g_App formatdate:user.timeCreate format:@"MM-dd HH:mm"];
        cell.headImage   = user.userHead;
        [cell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:s];
        user = nil;
    }
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JXUserObject *user=_array[indexPath.row];
    JXChatViewController *sendView=[JXChatViewController alloc];
    if([user.roomFlag intValue] > 0){
        sendView.roomName = user.userId;
        [[JXXMPP sharedInstance].roomPool joinRoom:user.userId title:user.userNickname];
    }
    sendView.title = user.userNickname;
    [sendView init];
    [sendView setChatPerson:user];
    [g_App.window addSubview:sendView.view];
}

- (void)dealloc {
    [_table release];
    [_array release];
    [super dealloc];
}


-(void)refresh{
    [self stopLoading];
    _refreshCount++;
    [_array release];
    _array=[JXUserObject fetchAllFriendsFromLocal];
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)scrollToPageUp{
    [self refresh];
}

-(void)newFriend:(NSObject*)sender{
    [self refresh];
}

@end