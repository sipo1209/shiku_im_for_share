//
//  JXImageView.h
//  textScr
//
//  Created by JK PENG on 11-8-17.
//  Copyright 2011年 Devdiv. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JXImageView : UIImageView {
    NSObject	*_delegate;
	SEL			_didTouch;
    int         _oldAlpha;
    BOOL        changeAlpha;
}
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		didTouch;
@property (nonatomic, assign) BOOL      changeAlpha;

@end
