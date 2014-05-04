//
//  JXMessageObject.m
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "JXMessageObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "NSData+XMPP.h"
#import "XMPPStream.h"

@implementation JXMessageObject
@synthesize content,timeSend,fromUserId,toUserId,type,messageNo, messageId,timeReceive,fileName,fileData,fileSize,location_x,location_y,timeLen,isSend,isRead,progress,dictionary,index,isGroup;

-(id)init{
    self = [super init];
    if(self){
        dictionary = [[NSMutableDictionary alloc] init];
        fileData   = nil;
        self.isSend     = [NSNumber numberWithBool:NO];
        self.isRead     = [NSNumber numberWithBool:NO];
        self.type       = [NSNumber numberWithInt:0];
        self.fileSize   = [NSNumber numberWithInt:0];
        self.location_x = [NSNumber numberWithInt:0];
        self.location_y = [NSNumber numberWithInt:0];
        self.timeLen    = [NSNumber numberWithInt:0];
        isGroup = NO;
    }
    return self;
}

-(void)dealloc{
    NSLog(@"JXMessageObject.dealloc");
    [dictionary removeAllObjects];
    [dictionary release];
    [fromUserId release];
    [toUserId release];
    [content release];
    [timeSend release];
    [timeReceive release];
    [type release];
    [messageNo release];
    [messageId release];
    [fileName release];
    [fileSize release];
    [fileData release];
    [location_x release];
    [location_y release];
    [isSend release];
    [isRead release];
    [timeLen release];
    [super dealloc];
}

-(void)fromDictionary:(NSMutableDictionary*)p
{
    if(p==nil)
        p = dictionary;
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.fromUserId = [p objectForKey:kMESSAGE_FROM];
    self.toUserId = [p objectForKey:kMESSAGE_TO];
    self.content = [p objectForKey:kMESSAGE_CONTENT];
    self.timeSend = [f dateFromString:[p objectForKey:kMESSAGE_TIMESEND]];
    self.timeReceive = [f dateFromString:[p objectForKey:kMESSAGE_TIMERECEIVE]];
    self.type = [p objectForKey:kMESSAGE_TYPE];
    self.messageId = [p objectForKey:kMESSAGE_ID];
    self.messageNo = [p objectForKey:kMESSAGE_No];
    self.fileName = [p objectForKey:kMESSAGE_FILENAME];
    self.fileData = [NSData dataWithBase64EncodedString:[p objectForKey:kMESSAGE_FILEDATA]];
    [fileData release];
    self.location_x = [p objectForKey:kMESSAGE_LOCATION_X];
    self.location_y = [p objectForKey:kMESSAGE_LOCATION_Y];
    self.isSend = [p objectForKey:kMESSAGE_ISSEND];
    self.isRead = [p objectForKey:kMESSAGE_ISREAD];
    self.timeLen = [p objectForKey:kMESSAGE_TIMELEN];
    self.fileSize = [p objectForKey:kMESSAGE_FILESIZE];
    //    self. = [p objectForKey:kMESSAGE_];
    
    [f release];
}


//将对象转换为字典
-(NSMutableDictionary*)toDictionary
{
    NSDateFormatter* f=[[NSDateFormatter alloc]init];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [dictionary setValue:fromUserId forKey:kMESSAGE_FROM];
    [dictionary setValue:toUserId forKey:kMESSAGE_TO];
    [dictionary setValue:content forKey:kMESSAGE_CONTENT];
    [dictionary setValue:[f stringFromDate:timeSend] forKey:kMESSAGE_TIMESEND];
//    [dictionary setValue:[f stringFromDate:timeReceive] forKey:kMESSAGE_TIMERECEIVE];
    [dictionary setValue:type forKey:kMESSAGE_TYPE];
    [dictionary setValue:[fileData base64Encoded] forKey:kMESSAGE_FILEDATA];
    [dictionary setValue:fileName forKey:kMESSAGE_FILENAME];
    [dictionary setValue:fileSize forKey:kMESSAGE_FILESIZE];
    [dictionary setValue:location_x forKey:kMESSAGE_LOCATION_X];
    [dictionary setValue:location_y forKey:kMESSAGE_LOCATION_Y];
    [dictionary setValue:timeLen forKey:kMESSAGE_TIMELEN];
//    [dictionary setValue:messageNo forKey:kMESSAGE_No];
//    [dictionary setValue:isRead forKey:kMESSAGE_ISSEND];
//    [dictionary setValue:isSend forKey:kMESSAGE_ISREAD];
    //    [dictionary setValue: forKey:kMESSAGE_];
    
    [f release];
    return dictionary;
}

//增删改查

-(BOOL)save
{
    JXMessageObject* p = self;
    
    NSString* toUserId1;
    NSString* myUserId = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    if([p.toUserId isEqualToString:myUserId])
        toUserId1 = p.fromUserId;
    else
        toUserId1 = p.toUserId;
    
    return [self saveMsg:myUserId tableName:toUserId1];
}


-(BOOL)saveRoomMsg:(NSString*)room
{
    NSString* myUserId = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    return [self saveMsg:myUserId tableName:room];
}


-(BOOL)saveMsg:(NSString*)dbName tableName:(NSString*)tableName{
    if([dbName length]<=0)
        return NO;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:dbName];
    
    NSString *createStr=[NSString stringWithFormat:@"CREATE  TABLE IF NOT EXISTS 'msg_%@' ('messageNo' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL  UNIQUE , 'fromUserId' VARCHAR, 'toUserId' VARCHAR, 'content' VARCHAR, 'timeSend' DATETIME,'timeReceive' DATETIME,'type' INTEGER, 'messageId' VARCHAR, 'fileData' VARCHAR, 'fileName' VARCHAR,'fileSize' INTEGER,'location_x' INTEGER,'location_y' INTEGER,'timeLen' INTEGER,'isRead' INTEGER,'isSend' INTEGER )",tableName];
    
    BOOL worked = [db executeUpdate:createStr];
//    FMDBQuickCheck(worked);

    if([self.messageId length]>0)
        self.messageId = [XMPPStream generateUUID];
    
    NSString *insertStr=[NSString stringWithFormat:@"INSERT INTO msg_%@ (fromUserId,toUserId,content,type,messageId,timeSend,timeReceive,fileData,fileName,fileSize,location_x,location_y,timeLen,isRead,isSend) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",tableName];
    worked = [db executeUpdate:insertStr,self.fromUserId,self.toUserId,self.content,self.type,self.messageId,self.timeSend,self.timeReceive,[self.fileData base64Encoded],self.fileName,self.fileSize,self.location_x,self.location_y,self.timeLen,self.isRead,self.isSend];
//    FMDBQuickCheck(worked);
    
    NSString* s=[self getLastContent];
    
        worked=[db executeUpdate:[NSString stringWithFormat:@"update friend set content=?,type=?,timeSend=?,newMsgs=newMsgs+1 where userId=?"],s,self.type,self.timeSend,tableName];
//        FMDBQuickCheck(worked);
    
    //发送全局通知
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction object:nil userInfo:[NSDictionary dictionaryWithObject:self forKey:@"newMsg"]];
    
    db = nil;
    return worked;
}

-(NSString*)getLastContent{
    NSString* s;
    switch ([self.type intValue]) {
        case kWCMessageTypeImage:
            s = @"[图片]";
            break;
        case kWCMessageTypeGif:
            s = @"[表情]";
            break;
        case kWCMessageTypeVoice:
            s = @"[语音]";
            break;
        default:
            s = self.content;
            break;
    }
    return s;
}

-(BOOL)updateIsRead:(BOOL)b{
    JXMessageObject* p = self;
    p.isRead = [NSNumber numberWithBool:b];
    NSString* toUserId1;
    NSString* myUserId = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    if([p.toUserId isEqualToString:myUserId])
        toUserId1 = p.fromUserId;
    else
        toUserId1 = p.toUserId;
    
    NSString* sql= [NSString stringWithFormat:@"update msg_%@ set isRead=? where fileName=?",toUserId1];
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:toUserId1];
    BOOL worked=[db executeUpdate:sql,p.isRead,p.fileName];
//    FMDBQuickCheck(worked);
    p = nil;
    return worked;
}

+(void)fromRs:(JXMessageObject*)p rs:(FMResultSet*)rs{
    p.fromUserId = [rs stringForColumn:kMESSAGE_FROM];
    p.toUserId = [rs stringForColumn:kMESSAGE_TO];
    p.content = [rs stringForColumn:kMESSAGE_CONTENT];
    p.timeSend = [rs dateForColumn:kMESSAGE_TIMESEND];
    p.timeReceive = [rs dateForColumn:kMESSAGE_TIMERECEIVE];
    p.type = [rs objectForColumnName:kMESSAGE_TYPE];
    p.messageId = [rs stringForColumn:kMESSAGE_ID];
    p.messageNo = [rs objectForColumnName:kMESSAGE_No];
    p.fileName = [rs stringForColumn:kMESSAGE_FILENAME];
    if([rs objectForColumnName:kMESSAGE_FILEDATA] != [NSNull null]){
        p.fileData = [NSData dataWithBase64EncodedString:[rs objectForColumnName:kMESSAGE_FILEDATA]];
        [p.fileData release];
    }
    
    p.location_x = [rs objectForColumnName:kMESSAGE_LOCATION_X];
    p.location_y = [rs objectForColumnName:kMESSAGE_LOCATION_Y];
    p.isSend = [rs objectForColumnName:kMESSAGE_ISSEND];
    p.isRead = [rs objectForColumnName:kMESSAGE_ISREAD];
    p.timeLen = [rs objectForColumnName:kMESSAGE_TIMELEN];
    p.fileSize = [rs objectForColumnName:kMESSAGE_FILESIZE];
}

//获取某联系人聊天记录
+(NSMutableArray*)fetchMessageListWithUser:(NSString *)userId byPage:(int)pageIndex
{
    NSLog(@"fetchMessageListWithUser.begin");
    NSString* myUserId = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    if([myUserId length]<=0)
        return nil;
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:myUserId];
    
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    
    NSString *queryString=[NSString stringWithFormat:@"select * from msg_%@ where fromUserId=? or toUserId=? order by timeSend desc limit ?*20,20",userId];
    
    NSMutableArray* temp = [[NSMutableArray alloc]init];
    FMResultSet *rs=[db executeQuery:queryString,userId,userId,[NSNumber numberWithInt:pageIndex]];
    while ([rs next]) {
        JXMessageObject *p=[[JXMessageObject alloc]init];
        [JXMessageObject fromRs:p rs:rs];
        NSLog(@"聊天记录：%@",p.content);
        [temp addObject:p];
    }
    [rs close];
    db = nil;
    
    for(int i=[temp count]-1;i>=0;i--){
        [messageList addObject:[temp objectAtIndex:i]];
    }
    [temp release];
    
    NSLog(@"fetchMessageListWithUser.end");
    return  messageList;
}

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex
{
    NSString* userId = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:userId];
    
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    NSString *queryString=[NSString stringWithFormat:@"select * from friend where length(content)>0 order by timeSend desc limit ?*20,20"];
    FMResultSet *rs=[db executeQuery:queryString,[NSNumber numberWithInt:pageIndex]];
    while ([rs next]) {
        JXMessageObject *p=[[JXMessageObject alloc]init];
        p.content = [rs stringForColumn:kMESSAGE_CONTENT];
        p.type = [rs objectForColumnName:kMESSAGE_TYPE];
        p.timeSend = [rs dateForColumn:kMESSAGE_TIMESEND];
        p.fromUserId = [rs stringForColumn:kUSER_ID];
        p.toUserId = userId;
        
        JXUserObject *user=[[JXUserObject alloc]init];
        [user setUserId:[rs stringForColumn:kUSER_ID]];
        [user setUserNickname:[rs stringForColumn:kUSER_NICKNAME]];
        [user setUserHead:[rs stringForColumn:kUSER_USERHEAD]];
        [user setUserDescription:[rs stringForColumn:kUSER_DESCRIPTION]];
        [user setRoomFlag:[rs objectForColumnName:kUSER_ROOM_FLAG]];
        
        JXMsgAndUserObject *unionObject=[JXMsgAndUserObject unionWithMessage:p andUser:user ];
        [messageList addObject:unionObject];
    }
    db = nil;
    return  messageList;
}

-(CGPoint)getLocation{
    return CGPointMake([location_x floatValue],[location_y floatValue]);
}

+(BOOL)updateNewMsgsTo0:(NSString*)tableName{
    NSString* dbName = [[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID];
    FMDatabase* db = [[JXXMPP sharedInstance] openUserDb:dbName];
    BOOL worked=[db executeUpdate:[NSString stringWithFormat:@"update friend set newMsgs=0 where userId=?"],tableName];
    return worked;
}

@end