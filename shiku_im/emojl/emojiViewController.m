//
//  emojiViewController.m
//
//  Created by daxiong on 13-11-27.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "emojiViewController.h"
#import "menuImageView.h"
#import "FaceViewController.h"
#import "gifViewController.h"
#import "AppDelegate.h"

@implementation emojiViewController
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _faceView = [[FaceViewController alloc]initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height-44)];
        [self addSubview:_faceView];
        _faceView.hidden   = NO;
        
        _gifView = [[gifViewController alloc]initWithFrame:CGRectMake(0, 0, 320, self.frame.size.height-44)];
        [self addSubview:_gifView];
        _gifView.hidden   = YES;

        _tb = [menuImageView alloc];
        _tb.items = [NSArray arrayWithObjects:@"表情",@"动画",@"声音",@"其他",nil];
        _tb.type  = 0;
        _tb.delegate = self;
        _tb.offset   = 0;
        _tb.itemWidth = 75;
        _tb.onClick  = @selector(actionSegment:);
        [_tb initWithFrame:CGRectMake(0, self.frame.size.height-44, 320, 44)];
        [self addSubview:_tb];
        [_tb selectOne:0];
        
}
    return self;
}

-(void) dealloc{
    [delegate release];
    [_tb release];
    [_faceView release];
    [_gifView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)actionSegment:(UIButton*)sender{
    switch (sender.tag){
        case 0:
            _faceView.hidden   = NO;
            _gifView.hidden   = YES;
            break;
        case 1:
            _faceView.hidden   = YES;
            _gifView.hidden   = NO;
            break;
    }
}

-(void)setDelegate:(UITextField *)value{
    if(delegate != value){
        delegate = value;
        _faceView.delegate = delegate;
        _gifView.delegate = delegate;
    }
}

@end