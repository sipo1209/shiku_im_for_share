//
//  JXMsgAndUserObject.m
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXMsgAndUserObject.h"

@implementation JXMsgAndUserObject
@synthesize message,user;


+(JXMsgAndUserObject *)unionWithMessage:(JXMessageObject *)aMessage andUser:(JXUserObject *)aUser
{
    JXMsgAndUserObject *unionObject=[[JXMsgAndUserObject alloc]init];
    [unionObject setUser:aUser];
    [unionObject setMessage:aMessage];
    return unionObject;
}

-(void)dealloc{
    [user release];
    [message release];
    [super release];
}



@end
