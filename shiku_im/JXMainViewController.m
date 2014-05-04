//
//  JXMainViewController.m
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXMainViewController.h"
#import "menuImageView.h"
#import "JXMsgViewController.h"
#import "JXFriendViewController.h"
#import "JXUserViewController.h"
#import "JXGroupViewController.h"
#import "AppDelegate.h"
#import "JXLoginViewController.h"
#import "JXRegisterViewController.h"


@interface JXMainViewController ()

@end

@implementation JXMainViewController
@synthesize btn=_btn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.frame = CGRectMake(0, 20, 320, JX_SCREEN_HEIGHT);
        self.view.backgroundColor = [UIColor clearColor];
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [self.view addSubview:_topView];
        [_topView release];
        
        _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 320, JX_SCREEN_HEIGHT-44-49)];
        [self.view addSubview:_mainView];
        [_mainView release];
        
        _bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-49, 320, 49)];
        _bottomView.userInteractionEnabled = YES;
        _bottomView.image = [UIImage imageNamed:@"new_bottom@2x.png"];
        [self.view addSubview:_bottomView];
        [_bottomView release];
        
        [self buildTop];
        
        _friendVc = [[JXFriendViewController alloc]init];
        [_mainView addSubview:_friendVc.view];
        [_friendVc.view release];

        _userVc = [[JXUserViewController alloc]init];
        [_mainView addSubview:_userVc.view];
        [_userVc.view release];
        
        _groupVc = [[JXGroupViewController alloc]init];
        [_mainView addSubview:_groupVc.view];
        [_groupVc.view release];
        
        _msgVc = [[JXMsgViewController alloc]init];
        [_mainView addSubview:_msgVc.view];
        [_msgVc.view release];
        
        _btn = [g_App createFooterButton:@"登录" action:@selector(onClick:) target:self];
        [_bottomView addSubview:_btn];
//        [_btn retain];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onLoginChanged:) name:kLoginNotifaction object:nil];
        
        g_App.groupVC = _groupVc;
    }
    return self;
}

-(void)dealloc{
//    [_btn release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginNotifaction object:nil];
    [super dealloc];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)buildTop{
    _tb = [menuImageView alloc];
    _tb.items = [NSArray arrayWithObjects:@"消息",@"朋友",@"发现",@"群聊",nil];
    _tb.type  = 0;
    _tb.delegate = self;
    _tb.offset   = 0;
    _tb.itemWidth = 75;
    _tb.onClick  = @selector(actionSegment:);
    [_tb initWithFrame:CGRectMake(0, 0, 320, 44)];
    [_topView addSubview:_tb];
    [_tb selectOne:0];
}

-(void)actionSegment:(UIButton*)sender{
    switch (sender.tag){
        case 0:
            [_btn setTitle:@"登录" forState:UIControlStateNormal];
            _btn.hidden = [JXXMPP sharedInstance].isLogined;
            [_mainView bringSubviewToFront:_msgVc.view];
            break;
        case 1:
            [_btn setTitle:@"注销" forState:UIControlStateNormal];
            _btn.hidden = ![JXXMPP sharedInstance].isLogined;
            [_mainView bringSubviewToFront:_friendVc.view];
            break;
        case 2:
            [_btn setTitle:@"注册" forState:UIControlStateNormal];
            _btn.hidden = NO;
            [_mainView bringSubviewToFront:_userVc.view];
            break;
        case 3:
            [_btn setTitle:@"新建房间" forState:UIControlStateNormal];
            _btn.hidden = ![JXXMPP sharedInstance].isLogined;
            [_mainView bringSubviewToFront:_groupVc.view];
            break;
    }
}

-(void)onClick:(UIButton*)sender{
    switch (_tb.selected){
        case 0:{
            JXLoginViewController* vc = [[JXLoginViewController alloc]init];
            [g_App.window addSubview:vc.view];
            break;
        }
        case 1:{
            [[JXXMPP sharedInstance] logout];
            JXLoginViewController* vc = [[JXLoginViewController alloc]init];
            [g_App.window addSubview:vc.view];
            break;
        }
        case 2:{
            JXRegisterViewController* vc = [[JXRegisterViewController alloc]init];
            [g_App.window addSubview:vc.view];
            break;
        }
        case 3:
            [_groupVc actionNewRoom];
            break;
    }
}

-(void)onLoginChanged:(NSNumber*)isLogin{
    switch (_tb.selected){
        case 0:
            _btn.hidden = [JXXMPP sharedInstance].isLogined;
            break;
        case 1:
            _btn.hidden = ![JXXMPP sharedInstance].isLogined;
            break;
        case 2:
            _btn.hidden = NO;
            break;
        case 3:
            _btn.hidden = ![JXXMPP sharedInstance].isLogined;
            break;
    }
}

-(void)onAfterLogin{
    [_msgVc scrollToPageUp];
    [_friendVc scrollToPageUp];
}

@end