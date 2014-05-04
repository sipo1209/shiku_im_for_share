//
//  JXLoginViewController.m
//
//  Created by flyeagleTang on 14-4-4.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXLoginViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXRegisterViewController.h"
#import "JXMainViewController.h"

@interface JXLoginViewController ()

@end

@implementation JXLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.heightFooter = 49;
        self.heightHeader = 44;
        self.isGotoBack   = YES;
        self.title = @"登录";
        [self createHeadAndFoot];

        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _table.backgroundColor= [UIColor whiteColor];

        UIButton* _btn = [g_App createFooterButton:@"注册" action:@selector(onReg) target:self];
        _btn.frame = CGRectMake(320-53-5, (49-33)/2, 53, 66/2);
        [self.tableFooter addSubview:_btn];

        _btn = [g_App createFooterButton:@"登录" action:@selector(onClick) target:self];
        [self.tableFooter addSubview:_btn];

        
        JXLabel* lb;
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(10, 100, 60, 30)];
        lb.textColor = [UIColor blackColor];
        lb.backgroundColor = [UIColor clearColor];
        lb.text = @"名称：";
        [_table addSubview:lb];
        [lb release];
        
        lb = [[JXLabel alloc]initWithFrame:CGRectMake(10, 150, 60, 30)];
        lb.textColor = [UIColor blackColor];
        lb.backgroundColor = [UIColor clearColor];
        lb.text = @"密码：";
        [_table addSubview:lb];
        [lb release];

        lb = [[JXLabel alloc]initWithFrame:CGRectMake(10, 250, 300, 50)];
        lb.textColor = [UIColor grayColor];
        lb.backgroundColor = [UIColor clearColor];
        lb.font = [UIFont systemFontOfSize:13];
        lb.numberOfLines = 0;
        lb.text = @"本服务器非24小时开启，若急需请关注微信公众号：视酷即时通讯，手机18665366227";
        [_table addSubview:lb];
        [lb release];

        _user = [[UITextField alloc] initWithFrame:CGRectMake(80, 100, 200, 30)];
        _user.delegate = self;
        _user.autocorrectionType = UITextAutocorrectionTypeNo;
        _user.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _user.enablesReturnKeyAutomatically = YES;
        _user.borderStyle = UITextBorderStyleRoundedRect;
        _user.returnKeyType = UIReturnKeyNext;
        _user.clearButtonMode = UITextFieldViewModeWhileEditing;
        _user.placeholder = @"请输入用户名";
        [_table addSubview:_user];
        [_user release];

        _pwd = [[UITextField alloc] initWithFrame:CGRectMake(80, 150, 200, 30)];
        _pwd.delegate = self;
        _pwd.autocorrectionType = UITextAutocorrectionTypeNo;
        _pwd.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwd.enablesReturnKeyAutomatically = YES;
        _pwd.borderStyle = UITextBorderStyleRoundedRect;
        _pwd.returnKeyType = UIReturnKeyDone;
        _pwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _pwd.placeholder = @"请输入密码";
        [_table addSubview:_pwd];
        [_pwd release];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //#ifdef IS_TEST_VERSION
    //    _userLoginName.text = @"18665366227";
    //    _userPassword.text = @"1234";
    //#endif
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_LoginName]) {
        [_user setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_LoginName]];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_PASSWORD]) {
        [_pwd setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_PASSWORD]];
    }
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

-(void)onClick{
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"user/login")];
    [request setPostValue:_user.text forKey:@"userName"];
    [request setPostValue:_pwd.text forKey:@"userPassword"];
    [request setPostValue:[NSString stringWithFormat:@"WeChat-V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forKey:@"versionInfo"];
    [request setPostValue:[[[UIDevice currentDevice]systemName]stringByAppendingString:[[UIDevice currentDevice]systemVersion]] forKey:@"deviceInfo"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestSuccess:)];
    [request setDidFailSelector:@selector(requestError:)];
    [request startAsynchronous];
}

#pragma mark  -------网络请求回调----------
-(void)requestSuccess:(ASIFormDataRequest*)request
{
    NSLog(@"response:%@",request.responseString);
    SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
    NSDictionary *rootDic=[paser objectWithString:request.responseString];
    int resultCode=[[rootDic objectForKey:@"resultCode"]intValue];
    if (resultCode==1) {
        NSLog(@"登陆成功");

        NSDictionary *userDic=[rootDic objectForKey:@"data"];
        [[NSUserDefaults standardUserDefaults]setObject:_user.text forKey:kMY_USER_LoginName];
        [[NSUserDefaults standardUserDefaults]setObject:_pwd.text forKey:kMY_USER_PASSWORD];
        [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userId"] forKey:kMY_USER_ID];
        [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userNickname"] forKey:kMY_USER_NICKNAME];
        [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userHead"] forKey:kMY_USER_Head];
        //立刻保存信息
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [[JXXMPP sharedInstance] login];
        [g_App.mainVc onAfterLogin];
        [self actionQuit];
    }else
    {
        [g_App showAlert:[NSString stringWithFormat:@"服务器登录失败,错误原因：%@",[rootDic objectForKey:@"resultMsg"]]];
    }
}

#pragma mark  -------请求错误--------
- (void)requestError:(ASIFormDataRequest*)request
{
    [g_App showAlert:[NSString stringWithFormat:@"服务器登录失败,本demo服务器非24小时开启，若急需请手机18665366227，错误码：%@",request.error.localizedDescription]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _user){
        [_pwd becomeFirstResponder];
        return NO;
    }
    if([_user.text length]<=0 || [_pwd.text length]<=0){
        [g_App showAlert:@"用户名或密码不能为空"];
        return NO;
    }
    [textField resignFirstResponder];
    [self onClick];
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_user resignFirstResponder];
    [_pwd resignFirstResponder];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return JX_SCREEN_HEIGHT-49-44;
}

-(void)onReg{
    [self actionQuit];
    JXRegisterViewController* vc = [[JXRegisterViewController alloc]init];
    [g_App.window addSubview:vc.view];
}

@end