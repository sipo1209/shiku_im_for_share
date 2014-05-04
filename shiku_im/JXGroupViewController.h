//
//  JXGroupViewController
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"

@protocol XMPPRoomDelegate;

@interface JXGroupViewController : PullRefreshTableViewController<XMPPRoomDelegate>{
    NSMutableArray *_array;
    int _refreshCount;
    int _recordCount;

    NSString* _roomJid;
    XMPPRoom *_xmppRoom;
    UITextField* _inputText;
}
- (void)actionNewRoom;
@end
