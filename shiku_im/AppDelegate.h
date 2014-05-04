//
//  AppDelegate.h
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@class emojiViewController;
@class JXMainViewController;
@class JXGroupViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{

}
@property (strong, nonatomic) UIWindow *window;

- (void) showAlert: (NSString *) message;

- (NSString *)docFilePath;
- (NSString *)dataFilePath;
- (NSString *)tempFilePath;
- (NSString *)imageFilePath;
-(UIButton*)createFooterButton:(NSString*)s action:(SEL)action target:(id)target;

-(NSString*)formatdateFromStr:(NSString*)s format:(NSString*)str;
-(NSString*)formatdate:(NSDate*)d format:(NSString*)str;

@property (retain, nonatomic) emojiViewController* faceView;
@property (retain, nonatomic) JXGroupViewController* groupVC;
@property (retain, nonatomic) JXMainViewController *mainVc;
@end
