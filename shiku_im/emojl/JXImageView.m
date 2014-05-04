//
//  JXImageView.m
//  textScr
//
//  Created by JK PENG on 11-8-17.
//  Copyright 2011年 Devdiv. All rights reserved.
//

#import "JXImageView.h"


@implementation JXImageView
@synthesize delegate = _delegate;
@synthesize didTouch = _didTouch;
@synthesize changeAlpha;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        changeAlpha = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
    //[super touchesBegan: touches withEvent: event];
    if(changeAlpha)
        self.alpha = 0.5;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesMoved");
    [super touchesMoved: touches withEvent: event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    //[super touchesEnded: touches withEvent: event];
    if(changeAlpha)
        self.alpha = 1;
    BOOL inside = YES;
    for(int i=0;i<[touches count];i++){
        CGPoint p = [[[touches allObjects] objectAtIndex:i] locationInView:self];
        NSLog(@"%d=%f,%f",i,p.x,p.y);        
        if(p.x<0 || p.y <0){
            inside = NO;
            break;
        }
        if(p.x>self.frame.size.width || p.y>self.frame.size.height){
            inside = NO;
            break;
        }
    }
    if(!inside)
        return;
	if(self.delegate != nil && [self.delegate respondsToSelector:self.didTouch])
		[self.delegate performSelectorOnMainThread:self.didTouch withObject:self waitUntilDone:NO];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //[super touchesCancelled: touches withEvent: event];
    NSLog(@"touchesCancelled");
    if(changeAlpha)
        self.alpha = 1;
    for(int i=0;i<[touches count];i++){
        CGPoint p = [[[touches allObjects] objectAtIndex:i] locationInView:self];
        NSLog(@"%d=%f,%f",i,p.x,p.y);
    }
}

- (void)dealloc
{
    _delegate = nil;
    _didTouch = nil;
    //[_delegate release];
    [super dealloc];
}

@end
