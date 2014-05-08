//
//  AppDelegate.m
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "AppDelegate.h"

#import "JXMainViewController.h"
#import "emojiViewController.h"
#import "JXEmptyViewController.h"

@implementation AppDelegate
@synthesize window,faceView,mainVc,groupVC;

- (void)dealloc
{
    [faceView release];
    [window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSThread sleepForTimeInterval:0.5];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    JXEmptyViewController* temp = [[[JXEmptyViewController alloc]init] autorelease];
    self.window.rootViewController = temp;
    [self.window addSubview:temp.view];
    
    mainVc=[[JXMainViewController alloc]init];
    [self.window addSubview:mainVc.view];
    
    faceView = [[emojiViewController alloc]initWithFrame:CGRectMake(0, JX_SCREEN_HEIGHT-218, 320, 218)];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) showAlert: (NSString *) message
{
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [av show];
    [av release];
    //[self showMsg:message];
}

- (NSString *)docFilePath {
    NSString* s = [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()];
    //NSLog(@"%@",s);
    return s;
}

- (NSString *)dataFilePath {
    NSString* s = [NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()];
    //NSLog(@"%@",s);
    return s;
}

- (NSString *)tempFilePath {
    NSString* s = [NSString stringWithFormat:@"%@/tmp/",NSHomeDirectory()];
    //NSLog(@"%@",s);
    return s;
}

- (NSString *)imageFilePath {
    NSString *s=[[NSBundle mainBundle] bundlePath];
    s = [s stringByAppendingString:@"/"];
    //NSLog(@"%@",s);
    return s;
}

-(UIButton*)createFooterButton:(NSString*)s action:(SEL)action target:(id)target{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame   = CGRectMake((320-76)/2, (49-36)/2, 152/2, 72/2);
    
    //    UIImage* jpg = [[UIImage alloc]initWithContentsOfFile:[[self imageFilePath] stringByAppendingPathComponent:@"button@2x.png"]];
    UIImage* jpg = [UIImage imageWithContentsOfFile:[[self imageFilePath] stringByAppendingPathComponent:@"tabbar_button_normal@2x.png"]];
    jpg = [jpg stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    [btn setBackgroundImage:jpg forState:UIControlStateNormal];
    
    jpg = [UIImage imageWithContentsOfFile:[[self imageFilePath] stringByAppendingPathComponent:@"tabbar_button_normal@2x.png"]];
    jpg = [jpg stretchableImageWithLeftCapWidth:21 topCapHeight:14];
    [btn setBackgroundImage:jpg forState:UIControlStateHighlighted];
    
    btn.showsTouchWhenHighlighted = YES;
    [btn setTitle:s forState:UIControlStateNormal];
    btn.font = [UIFont systemFontOfSize:13];
    //btn.titleLabel.textColor = [UIColor yellowColor];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(NSString*)formatdateFromStr:(NSString*)s format:(NSString*)str{
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* d = [f dateFromString:s];
    
    f.dateFormat = str;
    NSString* s1 = [f stringFromDate:d];
    [f release];
    return  s1;
}

-(NSString*)formatdate:(NSDate*)d format:(NSString*)str{
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    f.dateFormat = str;
    NSString* s = [f stringFromDate:d];
    [f release];
    return  s;
}


@end
