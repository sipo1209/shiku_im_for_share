//
//  emojiViewController.h
//
//  Created by daxiong on 13-11-27.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
@class menuImageView;
@class FaceViewController;
@class gifViewController;

@interface emojiViewController : UIView{
    menuImageView* _tb;
    FaceViewController* _faceView;
    gifViewController* _gifView;
}

@property (nonatomic, assign) UITextField* delegate;
@end
