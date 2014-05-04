//
//  JXRoomPool.h
//  shiku_im
//
//  Created by flyeagleTang on 14-4-21.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JXRoomObject;
@class XMPPRoomCoreDataStorage;

@interface JXRoomPool : NSObject{
    NSMutableDictionary* _pool;
    XMPPRoomCoreDataStorage* _storage;
}

-(JXRoomObject*)createRoom:(NSString*)name title:(NSString*)title;
-(JXRoomObject*)joinRoom:(NSString*)name title:(NSString*)title;
-(void)deleteAll;
-(void)createAll;
-(void)connectAll;

@end
