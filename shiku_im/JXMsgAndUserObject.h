//
//  JXMsgAndUserObject.h
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JXMsgAndUserObject : NSObject
@property (nonatomic,retain) JXMessageObject* message;
@property (nonatomic,retain) JXUserObject* user;

+(JXMsgAndUserObject *)unionWithMessage:(JXMessageObject *)aMessage andUser:(JXUserObject *)aUser;
@end
