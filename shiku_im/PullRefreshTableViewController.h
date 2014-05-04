//
//  PullRefreshTableViewController.h
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

#import <UIKit/UIKit.h>
@class JXLabel;

@interface PullRefreshTableViewController : UITableViewController {
    //UIView *headerView;
    //UILabel *headerLabel;
    //UIImageView *headerArrow;
    //UIActivityIndicatorView *headerSpinner;
    
    BOOL isDragging;
    BOOL isLoading;
    BOOL isHeaderScrolling;
    BOOL _isLoading;
    int  _page;
    
    NSString *textPull;
    NSString *textRelease;
    NSString *textLoading;
//    NSString *textLoadingFooter;
    UITableView* _table;
    
    int _tableHeight;    

}

@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) UILabel *footerLabel;
@property (nonatomic, retain) UIImageView *footerArrow;
@property (nonatomic, retain) UIActivityIndicatorView *footerSpinner;

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UILabel *headerLabel;
@property (nonatomic, retain) UIImageView *headerArrow;
@property (nonatomic, retain) UIActivityIndicatorView *headerSpinner;

@property (nonatomic, retain) UIColor* headColor;
@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textDown;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;
@property (nonatomic, copy) NSString *textLoadingFooter;
@property (nonatomic, copy) NSString *textReleaseFooter;

@property(nonatomic,retain,setter = setLeftBarButtonItem:)  UIBarButtonItem *leftBarButtonItem;
@property(nonatomic,retain,setter = setRightBarButtonItem:) UIBarButtonItem *rightBarButtonItem;
@property(nonatomic,assign) BOOL isGotoBack;
@property(nonatomic,assign) BOOL isFreeOnClose;
@property(nonatomic,retain) UIView *tableHeader;
@property(nonatomic,retain) UIView *tableFooter;
@property(nonatomic,assign) int heightHeader;
@property(nonatomic,assign) int heightFooter;
@property(nonatomic,retain) UIButton *footerBtnMid;
@property(nonatomic,retain) UIButton *footerBtnLeft;
@property(nonatomic,retain) UIButton *footerBtnRight;
@property(nonatomic,retain) JXLabel  *headerTitle;



- (void)setupStrings;
- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;
- (void)deleteScrollFooter;

- (void)createScrollFooter;
- (void)createHeadAndFoot;

- (void)scrollToPageUp;
- (void)scrollToPageDown;
- (void)getServerData;
    
- (void)showLoading;
-(void)actionQuit;
-(void)onGotoHome;

@end
