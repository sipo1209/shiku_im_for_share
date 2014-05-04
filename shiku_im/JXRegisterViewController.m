//
//  JXRegisterViewController.m
//
//  Created by flyeagleTang on 14-4-4.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXRegisterViewController.h"
#import "AppDelegate.h"
#import "JXLabel.h"
#import "JXLoginViewController.h"

@interface JXRegisterViewController ()

@end

@implementation JXRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.heightFooter = 49;
        self.heightHeader = 44;
        self.isGotoBack   = YES;
        self.title = @"注册";
        [self createHeadAndFoot];
        
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        //        _table.backgroundColor= [UIColor whiteColor];
        
        UIButton* _btn = [g_App createFooterButton:@"注册" action:@selector(onClick) target:self];
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
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_LoginName]) {
            [_user setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_LoginName]];
        }
        if ([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_PASSWORD]) {
            [_pwd setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_PASSWORD]];
        }
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

-(void)onClick{
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"user/register")];
    [request setPostValue:_user.text forKey:@"userName"];
    if([_pwd.text length]==0)
        _pwd.text = @"1234";
    [request setPostValue:_pwd.text forKey:@"userPassword"];
    [request setPostValue:_user.text forKey:@"userNickname"];
    [request setPostValue:_user.text forKey:@"userDescription"];
    [request setTimeOutSeconds:30];
    //    [request setData:UIImageJPEGRepresentation(userHead.imageView.image,0.01) withFileName:[_user.text stringByAppendingString:@"-head.jpg"] andContentType:@"image/jpeg" forKey:@"userHead"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestSuccess:)];
    [request setDidFailSelector:@selector(requestError:)];
    [request startAsynchronous];
}

#pragma mark  -------网络请求回调----------
-(void)requestSuccess:(ASIFormDataRequest*)request
{
    SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
    NSDictionary *rootDic=[paser objectWithString:request.responseString];
    int resultCode=[[rootDic objectForKey:@"resultCode"]intValue];
    if (resultCode==1) {
        NSLog(@"注册成功");
        
        [[NSUserDefaults standardUserDefaults]setObject:[rootDic objectForKey:@"gid"] forKey:kMY_USER_ID];
        [[NSUserDefaults standardUserDefaults]setObject:_user.text forKey:kMY_USER_LoginName];
        [[NSUserDefaults standardUserDefaults]setObject:_pwd.text forKey:kMY_USER_PASSWORD];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [g_App showAlert:@"注册成功，请登录"];
        [self onLogin];
    }else
    {
        [g_App showAlert:[NSString stringWithFormat:@"注册失败,原因:%@",[rootDic objectForKey:@"msg"]]];
    }
}

#pragma mark  -------请求错误--------
- (void)requestError:(ASIFormDataRequest*)request
{
    [g_App showAlert:[NSString stringWithFormat:@"服务器注册失败,错误码：%@",request.error.localizedDescription]];
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

-(void)onLogin{
    [self actionQuit];
    JXLoginViewController* vc = [[JXLoginViewController alloc]init];
    [g_App.window addSubview:vc.view];
}

@end
