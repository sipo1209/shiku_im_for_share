//
//  JXMessageObject.h
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMESSAGE_TYPE @"type"
#define kMESSAGE_FROM @"fromUserId"
#define kMESSAGE_TO @"toUserId"
#define kMESSAGE_CONTENT @"content"
#define kMESSAGE_DATE @"timeSend"
#define kMESSAGE_ID @"messageId"
#define kMESSAGE_No @"messageNo"
#define kMESSAGE_TIMESEND @"timeSend"
#define kMESSAGE_TIMERECEIVE @"timeReceive"
#define kMESSAGE_FILEDATA @"fileData"
#define kMESSAGE_FILENAME @"fileName"
#define kMESSAGE_LOCATION_X @"location_x"
#define kMESSAGE_LOCATION_Y @"location_y"
#define kMESSAGE_TIMELEN @"timeLen"
#define kMESSAGE_ISSEND @"isSend"
#define kMESSAGE_ISREAD @"isRead"
#define kMESSAGE_FILESIZE @"fileSize"
//#define kMESSAGE_ @""
//#define kMESSAGE_ @""

enum kWCMessageType {
    kWCMessageTypeText = 1,
    kWCMessageTypeImage = 2,
    kWCMessageTypeVoice = 3,
    kWCMessageTypeLocation=4,
    kWCMessageTypeGif=5
};

@class FMResultSet;

@interface JXMessageObject : NSObject
@property (nonatomic,retain) NSNumber*  messageNo;//序列号，数值型
@property (nonatomic,retain) NSNumber*  type;//消息类型
@property (nonatomic,retain) NSString*  messageId;//消息标识号，字符串
@property (nonatomic,retain) NSString*  fromUserId;//源
@property (nonatomic,retain) NSString*  toUserId;//目标
@property (nonatomic,retain) NSString*  content;//内容
@property (nonatomic,retain) NSString*  fileName;//文件名
@property (nonatomic,retain) NSNumber*  fileSize;//文件尺寸
@property (nonatomic,retain) NSNumber*  timeLen;//录音时长
@property (nonatomic,retain) NSNumber*  isSend;//是否已送达
@property (nonatomic,retain) NSNumber*  isRead;//是否已读
@property (nonatomic,retain) NSNumber*  location_x;//位置经度
@property (nonatomic,retain) NSNumber*  location_y;//位置纬度
@property (nonatomic,retain) NSDate*    timeSend;//发送的时间
@property (nonatomic,retain) NSDate*    timeReceive;//收到的时间
@property (nonatomic,retain) NSData*    fileData;//文件内容
@property (nonatomic,assign) BOOL       isGroup;//是否群聊

@property (nonatomic,retain) NSMutableDictionary*  dictionary;
@property (nonatomic,assign) float      progress;
@property (nonatomic,assign) int        index;

-(CGPoint)getLocation;

+(JXMessageObject *)messageWithType:(int)aType;

//将对象转换为字典
-(NSDictionary*)toDictionary;
-(void)fromDictionary:(NSDictionary*)p;

//数据库增删改查
-(BOOL)save;
-(BOOL)saveRoomMsg:(NSString*)room;
+(BOOL)deleteMessageById:(NSNumber*)aMessageNo;
+(BOOL)merge:(JXMessageObject*)aMessage;
+(BOOL)updateNewMsgsTo0:(NSString*)tableName;

//获取某联系人聊天记录
+(NSMutableArray *)fetchMessageListWithUser:(NSString *)userId byPage:(int)pageIndex;

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex;

+(void)fromRs:(JXMessageObject*)p rs:(FMResultSet*)rs;

-(BOOL)updateIsRead:(BOOL)b;
-(NSString*)getLastContent;

@end
