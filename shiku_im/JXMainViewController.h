//
//  JXMainViewController.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class menuImageView;
@class JXMsgViewController;
@class JXUserViewController;
@class JXFriendViewController;
@class JXGroupViewController;

@interface JXMainViewController : UIViewController{
    menuImageView* _tb;
    UIView* _topView;
    UIView* _mainView;
    UIImageView* _bottomView;
    UIButton* _btn;
    
    JXMsgViewController* _msgVc;
    JXFriendViewController* _friendVc;
    JXUserViewController* _userVc;
    JXGroupViewController* _groupVc;
}
@property (retain, nonatomic) UIButton* btn;
-(void)onAfterLogin;

@end
