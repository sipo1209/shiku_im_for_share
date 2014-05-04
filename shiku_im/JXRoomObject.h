//
//  JXRoomObject.h
//  shiku_im
//
//  Created by flyeagleTang on 14-4-21.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPRoomCoreDataStorage;

@interface JXRoomObject : NSObject{
    XMPPRoom *_xmppRoom;
    BOOL _isNew;
}

@property(nonatomic, retain) NSString *roomName;                    //房间名称
@property(nonatomic, retain) NSString *roomTitle;                   //房间主题
@property(nonatomic, retain) NSString *nickName;                   //房间主题
@property(nonatomic, retain) NSString *roomJid;
@property(nonatomic, assign) XMPPRoomCoreDataStorage* storage;

-(void)joinRoom;
-(void)createRoom;
@end
