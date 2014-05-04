//
//  JXXMPP.m
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//
// Log levels: off, error, warn, info, verbose

#import "JXXMPP.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilities.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPRoster.h"
#import "XMPPMessage.h"
#import "TURNSocket.h"
#import "SBJsonWriter.h"
#import "AppDelegate.h"
#import "FMDatabase.h"
#import "emojiViewController.h"
#import "JXRoomPool.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif




#define DOCUMENT_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define CACHES_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]

@implementation JXXMPP
@synthesize stream=xmppStream,isLogined,roomPool;




static JXXMPP *sharedManager;

+(JXXMPP*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[JXXMPP alloc]init];
        sharedManager.isLogined = NO;
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [sharedManager setupStream];
    });
    
    return sharedManager;
}

-(void)login{
    if(isLogined)
        return;
    if (![self connect]) {
        [g_App showAlert:@"服务器连接失败,本demo服务器非24小时开启，若急需请手机18665366227"];
    };
}

-(void)logout{
    if(!isLogined)
        return;
    self.isLogined = NO;
    [self disconnect];
    [roomPool deleteAll];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginNotifaction object:[NSNumber numberWithBool:isLogined]];
}


- (void)dealloc
{
    [_db close];
    [_db release];
	[self teardownStream];
    [roomPool release];
    [super dealloc];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma  mark ------收发消息-------
- (void)sendMessage:(JXMessageObject*)msg roomName:(NSString*)roomName
{
	//采用SBjson将params转化为json格式的字符串
	SBJsonWriter * OderJsonwriter = [SBJsonWriter new];
	NSString * jsonString = [OderJsonwriter stringWithObject:[msg toDictionary]];
	[OderJsonwriter release];
    
    if(roomName == nil)
        [msg save];
    else
        msg.isGroup = YES;
//        [msg saveRoomMsg:roomName];
    
    XMPPMessage *aMessage;
    if(roomName == nil)
        aMessage=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",msg.toUserId,kXMPP_Domain]]];
    else{
        NSString* roomJid = [NSString stringWithFormat:@"%@@conference.%@",roomName,kXMPP_Domain];
        aMessage=[XMPPMessage messageWithType:@"groupchat" to:[XMPPJID jidWithString:roomJid]];
    }
    
    [aMessage addChild:[DDXMLNode elementWithName:@"body" stringValue:jsonString]];
    [xmppStream sendElement:aMessage];
}



#pragma mark --------配置XML流---------
- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
        xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
	[xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	[xmppStream setHostName:kXMPPHost];
	[xmppStream setHostPort:5222];
	
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
    
    self.isLogined = NO;
    
    self.roomPool = [[JXRoomPool alloc] init];
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	
	[xmppReconnect         deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// http://code.google.com/p/xmppframework/wiki/WorkingWithElements

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[xmppStream sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[xmppStream sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
	if (![xmppStream isDisconnected]) {
		return YES;
	}
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kMY_USER_ID];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kMY_USER_PASSWORD];
    
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
    [xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",myJID,kXMPP_Domain]]];
    password=myPassword;
    
	NSError *error = nil;
	if (![xmppStream connect:&error])
	{
        [g_App showAlert:[NSString stringWithFormat:@"服务器连接失败,本demo服务器非24小时开启，若急需请手机18665366227:%@",error.localizedDescription]];
		DDLogError(@"Error connecting: %@", error);
		return NO;
	}
    
	return YES;
}

- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store
	// enough application state information to restore your application to its current state in case
	// it is terminated later.
	//
	// If your application supports background execution,
	// called instead of applicationWillTerminate: when the user quits.
	
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}
// Returns the URL to the application's Documents directory.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![xmppStream authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
    [xmppRoster fetchRoster];
    self.isLogined = YES;
    [self.roomPool createAll];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginNotifaction object:[NSNumber numberWithBool:isLogined]];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq elementID]);
	
    NSLog(@"收到iq:%@",iq);
    
    
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    //    <message xmlns="jabber:client" id="JyebH-103" to="62275004d76f4e64affe38f48ebe30cb@www.talk.com/26a9fe46" type="groupchat" from="room2@conference.www.talk.com/tjx"><body>gg</body><x xmlns="jabber:x:event"><offline/><delivered/><displayed/><composing/></x></message>
    //    <message id="JyebH-110" to="luorc@www.talk.com" from="tjx@www.talk.com/Spark 2.6.3" type="chat"><body>dddd</body><thread>FtWwwk</thread><x xmlns="jabber:x:event"><offline/><composing/></x></message>
    
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSString *delay = [[message elementForName:@"delay"] stringValue];
    if(delay != nil)
        return;
    
    NSString *body = [[message elementForName:@"body"] stringValue];
    NSString *displayName = [[message from]bare];
    NSArray *strs=[displayName componentsSeparatedByString:@"@"];
    
    NSString* type = [[message attributeForName:@"type"] stringValue];
    
    SBJsonParser * resultParser = [[SBJsonParser alloc] init] ;
    NSDictionary* resultObject = [resultParser objectWithString:body];
    [resultParser release];
    
    JXMessageObject *msg=[[JXMessageObject alloc] init];
    if([type isEqualToString:@"chat"] || [type isEqualToString:@"groupchat"]){
        //创建message对象
        [msg fromDictionary:resultObject];
        
        if (![JXUserObject haveSaveUserById:strs[0]]) {
            [self fetchUser:strs[0]];
        }
        
        if(msg.type != nil ){
            if([type isEqualToString:@"chat"]){
                [msg save];
            }else{
                msg.isGroup = YES;
                NSString* room = [[message attributeForName:@"from"] stringValue];
                NSRange range = [room rangeOfString:@"@"];
                if(range.location != NSNotFound)
                    room = [room substringToIndex:range.location];
                [msg saveRoomMsg:room];
            }
        }
    }
    
    if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Ok";
        localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",@"新消息:",@"123"];
        //        localNotification.userInfo  = [NSDictionary dictionaryWithObject:msg forKey:@"newMsg"];
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
	
    [msg release];
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
    XMPPJID *jid=[XMPPJID jidWithString:[presence stringValue]];
    [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
}

- (void)addSomeBody:(NSString *)userId
{
    [xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",userId,kXMPP_Domain]]];
}

-(void)fetchUser:(NSString*)userId
{
    /*
     ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"servlet/GetUserDetailServlet")];
     
     [request setPostValue:userId forKey:@"userId"];
     [request setDelegate:self];
     [request setDidFinishSelector:@selector(requestSuccess:)];
     [request setDidFailSelector:@selector(requestError:)];
     [request startAsynchronous];
     */
}

-(void)requestSuccess:(ASIFormDataRequest*)request
{
    NSLog(@"response:%@",request.responseString);
    SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
    NSDictionary *rootDic=[paser objectWithString:request.responseString];
    int resultCode=[[rootDic objectForKey:@"resultCode"]intValue];
    if (resultCode==1) {
        NSDictionary *dic=[rootDic objectForKey:@"data"];
        JXUserObject *user=[JXUserObject userFromDictionary:dic];
        [JXUserObject saveNewUser:user];
    }
}

-(void)requestError:(ASIFormDataRequest*)request
{
    
}


- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSString *body = [[message elementForName:@"body"] stringValue];
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, body);
}

- (FMDatabase*)openUserDb:(NSString*)userId{
    userId = [userId uppercaseString];
    if([_userIdOld isEqualToString:userId]){
        if(_db && [_db goodConnection])
            return _db;
    }
    _userIdOld = [userId copy];
    NSString* t =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString* s = [NSString stringWithFormat:@"%@/%@.db",t,userId];
    
    [_db close];
    [_db release];
    _db = [[FMDatabase alloc] initWithPath:s];
    if (![_db open]) {
        NSLog(@"数据库打开失败");
        return nil;
    };
    return _db;
}

@end
