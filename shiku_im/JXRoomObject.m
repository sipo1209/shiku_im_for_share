//
//  JXRoomObject.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "JXRoomObject.h"
//#import "Statics.h"
//#import "KKMessageCell.h"
#import "XMPPStream.h"
#import "XMPPRoom.h"
#import "XMPPRoomCoreDataStorage.h"
#import "JXMessageObject.h"
#import "JXXMPP.h"
#import "JXChatViewController.h"
#import "AppDelegate.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilities.h"
#import "XMPPRoster.h"
#import "XMPPMessage.h"
#import "JXLabel.h"
#import "JXImageView.h"
#import "JXCell.h"
#import "JXLoginViewController.h"

#define padding 20

@implementation JXRoomObject

@synthesize roomName,roomTitle,storage,nickName,roomJid;
#pragma mark - life circle

-(id)init{
    self = [super init];
    _isNew = NO;
    return self;
}

- (void)dealloc {
    NSLog(@"JXRoomObject.dealloc");
    [_xmppRoom deactivate];
    [_xmppRoom release];
    [super dealloc];
}


//初始化聊天室
-(void)joinRoom{
    _isNew = NO;
    self.roomJid = [NSString stringWithFormat:@"%@@conference.%@",self.roomName,kXMPP_Domain];
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:storage jid:[XMPPJID jidWithString:self.roomJid] dispatchQueue:dispatch_get_main_queue()];
    [_xmppRoom activate:[JXXMPP sharedInstance].stream];
    [_xmppRoom joinRoomUsingNickname:nickName history:nil];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self noSendHistory];
}

//可以创建一个聊天室:room2

-(void)createRoom{
    _isNew = YES;
    self.roomJid = [NSString stringWithFormat:@"%@@conference.%@",self.roomName,kXMPP_Domain];
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:storage jid:[XMPPJID jidWithString:self.roomJid] dispatchQueue:dispatch_get_main_queue()];
    [_xmppRoom activate:[JXXMPP sharedInstance].stream];
    [_xmppRoom joinRoomUsingNickname:nickName history:nil];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(DDXMLElement *)configForm
{
    NSLog(@"config : %@", configForm);
    NSXMLElement *newConfig = [configForm copy];
    NSArray* fields = [newConfig elementsForName:@"field"];
    for (NSXMLElement *field in fields) {
        NSString *var = [field attributeStringValueForName:@"var"];
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    [sender configureRoomUsingOptions:newConfig];
}

#pragma mark - XMPPRoom delegate
//创建结果
-(void)xmppRoomDidCreate:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidCreate");
    [_xmppRoom changeRoomSubject:self.roomTitle];
//    [_xmppRoom fetchMembersList1:self.roomName];
    
    JXUserObject* user = [[JXUserObject alloc]init];
    user.userNickname = self.roomTitle;
    user.userId = self.roomName;
    user.userDescription = self.roomTitle;
    if (![JXUserObject haveSaveUserById:user.userId])
        [JXUserObject saveNewRoom:user];
    [user release];
}

//是否已经加入房间
-(void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidJoin");
    //    [_xmppRoom chageNickname:@"fuck"];
    //    [_xmppRoom changeRoomSubject:@"聊天室主题名"];
    //    [_xmppRoom changeToMember:self.roomName nickName:@"tjx"];

    if(_isNew){
        [self configNewRoom];
    }
    else{
        [self noSendHistory];
        [_xmppRoom configureRoomUsingOptions:nil];
        [_xmppRoom fetchConfigurationForm];
    }
}

//是否已经离开
-(void)xmppRoomDidLeave:(XMPPRoom *)sender{
    NSLog(@"xmppRoomDidLeave");
}

//收到群聊消息
-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    return;
}

//房间人员加入
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSLog(@"occupantDidJoin");
    NSString *jid = occupantJID.user;
    NSString *domain = occupantJID.domain;
    NSString *resource = occupantJID.resource;
    NSString *presenceType = [presence type];
    NSString *userId = [sender myRoomJID].user;
    NSString *presenceFromUser = [[presence from] user];
    
    NSLog(@"occupantDidJoin----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
    
    if (![presenceFromUser isEqualToString:userId]) {
        //对收到的用户的在线状态的判断在线状态
        
        //在线用户
        if ([presenceType isEqualToString:@"available"]) {
            NSString *buddy = [[NSString stringWithFormat:@"%@@%@", presenceFromUser, kXMPP_Domain] retain];
            //            [chatDelegate newBuddyOnline:buddy];//用户列表委托
        }
        
        //用户下线
        else if ([presenceType isEqualToString:@"unavailable"]) {
            //            [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName]];//用户列表委托
        }
    }
}

//房间人员离开
-(void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSString *jid = occupantJID.user;
    NSString *domain = occupantJID.domain;
    NSString *resource = occupantJID.resource;
    NSString *presenceType = [presence type];
    NSString *userId = [sender myRoomJID].user;
    NSString *presenceFromUser = [[presence from] user];
    NSLog(@"occupantDidLeave----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
}

//房间人员加入
-(void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence{
    NSString *jid = occupantJID.user;
    NSString *domain = occupantJID.domain;
    NSString *resource = occupantJID.resource;
    NSString *presenceType = [presence type];
    NSString *userId = [sender myRoomJID].user;
    NSString *presenceFromUser = [[presence from] user];
    NSLog(@"occupantDidUpdate----jid=%@,domain=%@,resource=%@,当前用户:%@ ,出席用户:%@,presenceType:%@",jid,domain,resource,userId,presenceFromUser,presenceType);
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    NSLog(@"didFetchMembersList");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
    NSLog(@"didFetchModeratorsList");
}

-(void)saveRoom:(JXUserObject *)user{
    if (![JXUserObject haveSaveUserById:user.userId]){
        [JXUserObject saveNewRoom:user];
    }
}

- (void)noSendHistory
{
    XMPPPresence* y = [[XMPPPresence alloc] initWithType:@"" to:[XMPPJID jidWithString:self.roomJid]];
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kMY_USER_ID];
    [y addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@@%@",myJID,kXMPP_Domain]];
    [y removeAttributeForName:@"type"];
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
    NSXMLElement *p = [NSXMLElement elementWithName:@"history"];
    [p addAttributeWithName:@"maxchars" stringValue:@"0"];
    [x addChild:p];
    [y addChild:x];
    [[JXXMPP sharedInstance].stream sendElement:y];
    [y release];
}

-(void)configNewRoom{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    NSXMLElement *p;
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];//永久房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1000"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];//公共房间
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    /*
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];//房间名称
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:self.roomTitle]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_enablelogging"];//允许登录对话
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
    [x addChild:p];
    */
    
    [_xmppRoom configureRoomUsingOptions:x];
}


@end