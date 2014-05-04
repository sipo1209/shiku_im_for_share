//
//  JXRoomPool.m
//  shiku_im
//
//  Created by flyeagleTang on 14-4-21.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "JXRoomPool.h"
#import "JXRoomObject.h"
#import "JXUserObject.h"

@implementation JXRoomPool

-(id)init{
    self = [super init];
    _pool = [[NSMutableDictionary alloc] init];
    _storage = [[XMPPRoomCoreDataStorage alloc] init];
    return self;
}

-(void)dealloc{
    NSLog(@"JXRoomPool.dealloc");
    [self deleteAll];
    [_storage release];
    [_pool release];
    [super dealloc];
}

-(JXRoomObject*)createRoom:(NSString*)name title:(NSString*)title{
}

-(JXRoomObject*)joinRoom:(NSString*)name title:(NSString*)title{
    if([_pool objectForKey:name])
        return [_pool objectForKey:name];
    JXRoomObject* room = [[JXRoomObject alloc] init];
    room.roomName = name;
    room.roomTitle = title;
    room.storage   = _storage;
    room.nickName  = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_NICKNAME];
    [room joinRoom];
    [_pool setObject:room forKey:room.roomName];
    return room;
}

-(void)deleteAll{
    for(int i=[_pool count]-1;i>=0;i--)
        [[_pool.allValues objectAtIndex:i] release];
    [_pool removeAllObjects];
}

-(void)createAll{
    NSMutableArray* array = [JXUserObject fetchAllRoomsFromLocal];
    for(int i=0;i<[array count];i++){
        JXUserObject *room = [array objectAtIndex:i];
        [self joinRoom:room.userId title:room.userNickname];
    }
    [array release];
}

-(void)connectAll{
    
}

@end
