//
//  JXUserObject.h
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kUSER_ID @"userId"
#define kUSER_NICKNAME @"userNickname"
#define kUSER_DESCRIPTION @"userDescription"
#define kUSER_USERHEAD @"userHead"
#define kUSER_ROOM_FLAG @"roomFlag"
#define kUSER_NEW_MSGS @"newMsgs"
#define kUSER_TIME_CREATE @"timeCreate"


@interface JXUserObject : NSObject
@property (nonatomic,retain) NSString* userId;
@property (nonatomic,retain) NSString* userNickname;
@property (nonatomic,retain) NSString* userDescription;
@property (nonatomic,retain) NSString* userHead;
@property (nonatomic,retain) NSDate* timeCreate;
@property (nonatomic,retain) NSNumber* roomFlag;//0：朋友；1:永久房间；2:临时房间
@property (nonatomic,retain) NSNumber* newMsgs;//0：朋友；1:永久房间；2:临时房间


//数据库增删改查
+(BOOL)saveNewUser:(JXUserObject*)aUser;
+(BOOL)saveNewRoom:(JXUserObject*)aUser;

+(BOOL)deleteUserById:(NSString*)userId;
+(BOOL)updateUser:(JXUserObject*)newUser;
+(BOOL)haveSaveUserById:(NSString*)userId;
+(JXUserObject*)getUserById:(NSString*)userId;

+(NSMutableArray*)fetchAllFriendsFromLocal;
+(NSMutableArray*)fetchAllRoomsFromLocal;

//将对象转换为字典
-(NSDictionary*)toDictionary;
+(JXUserObject*)userFromDictionary:(NSDictionary*)aDic;
+(NSString*)getHeadImage:(NSString*)s;
@end
