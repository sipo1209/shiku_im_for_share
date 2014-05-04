//
//  PullRefreshTableViewController.m
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "PullRefreshTableViewController.h"
#import "AppDelegate.h"
//#import "leftViewController.h"
//#import "myNearViewController.h"
#import "JXLabel.h"

#define REFRESH_HEADER_HEIGHT 60
#define HEIGHT_STATUS_BAR 20


@implementation PullRefreshTableViewController

@synthesize textPull,textDown,textRelease, textLoading, headerView, headerLabel, headerArrow, headerSpinner,headColor,textColor,footerView,footerArrow,footerLabel,footerSpinner,textLoadingFooter,textReleaseFooter,heightFooter,heightHeader,leftBarButtonItem,rightBarButtonItem,tableHeader,tableFooter,isGotoBack,footerBtnLeft,footerBtnMid,footerBtnRight,headerTitle,isFreeOnClose;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self != nil) {
        [self setupStrings];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self setupStrings];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        [self setupStrings];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(_table == nil)
        _table       = self.tableView;
    [self addPullToRefreshHeader];
//    [self create];
}

- (void)setupStrings{
    _isLoading = NO;
    heightHeader=44;
    heightFooter=49;
    isFreeOnClose = YES;
    textPull = [[NSString alloc] initWithString:@"下拉刷新..."];
    textDown = [[NSString alloc] initWithString:@"上拉翻页..."];
    textRelease = [[NSString alloc] initWithString:@"松开刷新..."];
    textLoading = [[NSString alloc] initWithString:@"正在刷新..."];

    textReleaseFooter = [[NSString alloc] initWithString:@"松开翻页..."];
    textLoadingFooter = [[NSString alloc] initWithString:@"正在翻页..."];
    if(headColor==nil)
        headColor = [UIColor clearColor];
    if(textColor==nil)
        textColor = [UIColor grayColor];
    isHeaderScrolling = YES;
    if(_table == nil)
        _table       = self.tableView;

    /*
    //创建手势
    UIPanGestureRecognizer *panGR =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectDidDragged:)];
    //限定操作的触点数
    [panGR setMaximumNumberOfTouches:1];
    [panGR setMinimumNumberOfTouches:1]; 
    //将手势添加到draggableObj里
    [self.view addGestureRecognizer:panGR];
     */
}

- (void)objectDidDragged:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        CGPoint offset = [sender translationInView:g_App.window];
        if(offset.y>20 || offset.y<-20)
            return;
        if(isGotoBack)
            [self actionQuit];
        else
            [self onGotoHome];
    }
    /*
     if (sender.state == UIGestureRecognizerStateChanged ||
     sender.state == UIGestureRecognizerStateEnded) {
     //注意，这里取得的参照坐标系是该对象的上层View的坐标。
     CGPoint offset = [sender translationInView:g_App.window];
     //通过计算偏移量来设定draggableObj的新坐标
     [self.view setCenter:CGPointMake(self.view.center.x + offset.x, self.view.center.y + offset.y)];
     //初始化sender中的坐标位置。如果不初始化，移动坐标会一直积累起来。
     [sender setTranslation:CGPointMake(0, 0) inView:g_App.window];
     }
     */
}

- (void)addPullToRefreshHeader {
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    headerView.backgroundColor = headColor;
    
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12.0];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.textColor = textColor;
    
    headerArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayArrow@2x.png"]];
    headerArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 23) / 2),
                                   (floorf(REFRESH_HEADER_HEIGHT - 60) / 2),	
                                   23, 60);
    //27, 44);
    
    headerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    headerSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    headerSpinner.hidesWhenStopped = YES;
    
    [headerView addSubview:headerLabel];
    [headerLabel release];
    [headerView addSubview:headerArrow];
    [headerArrow release];
    [headerView addSubview:headerSpinner];
    [headerSpinner release];
    [_table addSubview:headerView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!headerView.hidden && headerView){
        if (isLoading) {
            // Update the content inset, good for section headers
            if (scrollView.contentOffset.y > 0)
                _table.contentInset = UIEdgeInsetsZero;
            else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
                _table.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (isDragging && scrollView.contentOffset.y < 0) {
            // Update the arrow direction and label
            [UIView beginAnimations:nil context:NULL];
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                headerLabel.text = self.textRelease;
                [headerArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else { // User is scrolling somewhere within the header
                headerLabel.text = self.textPull;
                [headerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
            [UIView commitAnimations];
        }
    }
    if(!footerView.hidden && footerView){
        if (isLoading) {
            // Update the content inset, good for section headers
            //NSLog(@"1=%f",scrollView.contentOffset.y);
            //if (scrollView.contentOffset.y+scrollView.frame.size.height >= scrollView.contentSize.height)
            _table.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_HEADER_HEIGHT*1.5, 0);
            return;
        } else if (isDragging && scrollView.contentOffset.y+scrollView.frame.size.height >= scrollView.contentSize.height) {
            // Update the arrow direction and label
            //NSLog(@"2=%f",scrollView.contentOffset.y);
            footerArrow.hidden = NO;
            [UIView beginAnimations:nil context:NULL];
            if (scrollView.contentOffset.y+scrollView.frame.size.height >= scrollView.contentSize.height + REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                footerLabel.text = self.textReleaseFooter;
                [footerArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else { // User is scrolling somewhere within the header
                footerLabel.text = self.textDown;
                [footerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
            [UIView commitAnimations];
            return;
        }        
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if(!headerView.hidden && headerView){
        if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
            // Released above the header
            isHeaderScrolling = YES;
            [self startLoading];
        }
    }
    if(!footerView.hidden && footerView){
        if (scrollView.contentOffset.y+scrollView.frame.size.height >= scrollView.contentSize.height+REFRESH_HEADER_HEIGHT) {
            // Released above the header
            isHeaderScrolling = NO;
            [self startLoading];
        }
    }
}

- (void)showLoading {
    // Show the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    if(isHeaderScrolling){
        _table.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);      
        headerLabel.text = self.textLoading;
        headerArrow.hidden = YES;
        [headerSpinner startAnimating];
    }else{
        _table.contentInset = UIEdgeInsetsMake(0, 0, REFRESH_HEADER_HEIGHT*1.5, 0);
        footerLabel.text = self.textLoadingFooter;
        footerArrow.hidden = YES;
        [footerSpinner startAnimating];        
    }
    [UIView commitAnimations];
}

- (void)startLoading {
    isLoading = YES;

    [self showLoading];
    
    if(isHeaderScrolling)
        [self scrollToPageUp];
    else
        [self scrollToPageDown];
}

- (void)stopLoading {
    isLoading = NO;
    
    // Hide the header
/*    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];*/
    [self doReset];
    if(isHeaderScrolling){
        _table.contentInset = UIEdgeInsetsZero;
        if(!headerView.hidden && headerView){
            [headerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
    }else{
        _table.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        if(!footerView.hidden && footerView){
            [footerArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        //[self deleteScrollFooter];
    }
    //[UIView commitAnimations];
    isHeaderScrolling = YES;
}

-(void) doReset{
    // Reset the header
    if(isHeaderScrolling){
        headerLabel.text = self.textPull;
        headerArrow.hidden = NO;
        [headerSpinner stopAnimating];
    }else{
        if(footerView){
            footerLabel.text = self.textPull;
            footerArrow.hidden = NO;
            [footerSpinner stopAnimating];
        }
    }
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self doReset];
}

- (void)dealloc {
    [headerView release];
    [footerView release];
    /* [headerLabel release];
     [headerArrow release];
     [headerSpinner release];
     
     [footerLabel release];
     [footerArrow release];
     [footerSpinner release];*/
    
    [textPull release];
    [textRelease release];
    [textLoading release];
    [textReleaseFooter release];
    [textLoadingFooter release];
    [super dealloc];
}


- (void)deleteScrollFooter{
    if(footerView==nil)
        return;
    [footerView removeFromSuperview];
    [footerView release];
    footerView   = nil;
    footerLabel  = nil;
    footerArrow  = nil;
    footerSpinner = nil;
}

- (void)createScrollFooter:(int)lastCellHeight {
    footerView.hidden = YES;
    [self deleteScrollFooter];
    NSLog(@"%f",_table.contentSize.height+lastCellHeight);
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, _table.contentSize.height+lastCellHeight, 320, REFRESH_HEADER_HEIGHT)];
    footerView.backgroundColor = headColor;
    
    footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.font = [UIFont boldSystemFontOfSize:12.0];
    footerLabel.textAlignment = UITextAlignmentCenter;
    footerLabel.textColor = textColor;
    
    footerArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grayArrow@2x.png"]];
    footerArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 23) / 2),
                                   (floorf(REFRESH_HEADER_HEIGHT - 60) / 2),
                                   23, 60);
    //27, 44);
    
    footerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    footerSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    footerSpinner.hidesWhenStopped = YES;
    
    [footerView addSubview:footerLabel];
    [footerLabel release];
    footerArrow.hidden = YES;
    [footerView addSubview:footerArrow];
    [footerArrow release];
    [footerView addSubview:footerSpinner];
    [footerSpinner release];
    [_table addSubview:footerView];
}

-(void)createHeaderView{
    tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, heightHeader)];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    iv.image = [UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"new_top@2x.png"]];
    iv.userInteractionEnabled = YES;
    [tableHeader addSubview:iv];
    [iv release];

    JXLabel* p = [[JXLabel alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    p.backgroundColor = [UIColor clearColor];
    p.textAlignment   = UITextAlignmentCenter;
    p.textColor       = [UIColor whiteColor];
    p.text = self.title;
    p.userInteractionEnabled = YES;
    p.didTouch = @selector(actionTitle:);
    p.delegate = self;
    [tableHeader addSubview:p];
    [p release];

    self.headerTitle = p;
}

-(void)createFooterView{
    tableFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, heightFooter)];
    UIImageView* iv = [[UIImageView alloc] initWithFrame:tableFooter.frame];
    iv.image = [UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"new_bottom@2x.png"]];
    iv.userInteractionEnabled = YES;
    [tableFooter addSubview:iv];
    [iv release];

    UIButton* btn;
    if(isGotoBack){
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(5, (49-33)/2, 53, 66/2);
        btn.showsTouchWhenHighlighted = YES;
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"back_button@2x.png"]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(actionQuit) forControlEvents:UIControlEventTouchUpInside];
        [tableFooter addSubview:btn];
    }else{
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(5, (49-33)/2, 53, 66/2);
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"navigation_button_normal@2x.png"]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"navigation_button_press@2x.png"]] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(onGotoHome) forControlEvents:UIControlEventTouchUpInside];
        [tableFooter addSubview:btn];
    }
    self.footerBtnLeft = btn;

    if(isGotoBack)
        return;

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((320-76)/2, (49-36)/2, 152/2, 72/2);
    [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"singing_button_normal@2x.png"]] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"singing_button_press@2x.png"]] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onSing) forControlEvents:UIControlEventTouchUpInside];
    [tableFooter addSubview:btn];
    self.footerBtnMid = btn;

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(320-53-5, (49-33)/2, 53, 66/2);
    [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"nearby_button_normal@2x.png"]] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"nearby_button_press@2x.png"]] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(onBtnRight) forControlEvents:UIControlEventTouchUpInside];
    [tableFooter addSubview:btn];
    self.footerBtnRight = btn;
    self.footerBtnRight.hidden = YES;
}

-(void)createHeadAndFoot{
    if(heightHeader==0 && heightFooter==0)
        return;
    _table = self.tableView;
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.frame = CGRectMake(0, 20, 320, JX_SCREEN_HEIGHT);
    NSLog(@"");
    UIView* myview = [[UIView alloc] initWithFrame:self.view.frame];
    [myview addSubview:_table];

    if(heightFooter>0 && heightHeader>0){
        _table.frame =CGRectMake(0,heightHeader,self.view.frame.size.width,JX_SCREEN_HEIGHT-heightHeader-heightFooter);
        NSLog(@"%f,%f",_table.frame.size.height,_table.frame.origin.y);
        [self createHeaderView];
        [self createFooterView];
        [myview addSubview:tableHeader];
        [tableHeader release];
        tableFooter.frame = CGRectMake(0,JX_SCREEN_HEIGHT-heightFooter,self.view.frame.size.width,heightFooter);
        [myview addSubview:tableFooter];
        [tableFooter release];

        /*
        UIImageView* v = [[UIImageView alloc]initWithFrame:CGRectMake(0, heightHeader, 320, 5)];
        v.image = [[UIImage alloc]initWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"2_head@2x.png"]];
        [myview addSubview:v];
        [v release];
        [v.image release];

        v = [[UIImageView alloc]initWithFrame:CGRectMake(0, tableFooter.frame.origin.y-7, 320, 7)];
        v.image = [[UIImage alloc]initWithContentsOfFile:[[g_App imageFilePath] stringByAppendingPathComponent:@"2_footer@2x.png"]];
        [myview addSubview:v];
        [v release];
        [v.image release];*/
    }
    else{
        if(heightHeader>0){
            _table.frame =CGRectMake(0,heightHeader,self.view.frame.size.width,JX_SCREEN_HEIGHT-heightHeader);
            [self createHeaderView];
            [myview addSubview:tableHeader];
            [tableHeader release];
        }else{
            _table.frame =CGRectMake(0,0,self.view.frame.size.width,JX_SCREEN_HEIGHT-heightFooter);
            [self createFooterView];
            [myview addSubview:tableFooter];
            [tableFooter release];
            tableFooter.frame = CGRectMake(0,JX_SCREEN_HEIGHT-heightFooter,self.view.frame.size.width,heightFooter);
        }
        
    }

    self.view = myview;
    [myview release];
}

-(void) onGotoHome{
    if(self.view.frame.origin.x == 260){
//        [g_App.leftView onClick];
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    
    self.view.frame = CGRectMake (260, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
//    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(aviFinished:) userInfo:nil repeats:NO];
}

-(void)actionQuit{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(aviFinished:)];
    
    self.view.frame = CGRectMake (JX_SCREEN_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

-(void)aviFinished:(NSTimer*)timer{
    [self.view removeFromSuperview];
    if(isFreeOnClose)
        [self release];
}

-(void) setLeftBarButtonItem:(UIBarButtonItem*)button{
    leftBarButtonItem = button;
    button.customView.frame = CGRectMake(7, 7, 65, 30);
    [tableHeader addSubview:button.customView];
}

-(void) setRightBarButtonItem:(UIBarButtonItem*)button{
    rightBarButtonItem = button;
    button.customView.frame = CGRectMake(320-7-65, 7, 65, 30);
    [tableHeader addSubview:button.customView];
}

-(void)onSing{
//    [g_App.leftView onSing];
}

-(void)onBtnRight{
//    [g_App.leftView onNear];
}

-(void)actionTitle:(JXLabel*)sender{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)scrollToPageUp{
    if(_isLoading)
        return;
    _page = 0;
    [self getServerData];
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

-(void)scrollToPageDown{
    if(_isLoading)
        return;
    _page++;
    [self getServerData];
}


@end