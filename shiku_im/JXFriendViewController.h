//
//  JXFriendViewController.h
//
//  Created by flyeagleTang on 14-4-3.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "PullRefreshTableViewController.h"
#import <UIKit/UIKit.h>

@interface JXFriendViewController: PullRefreshTableViewController{
    NSMutableArray* _array;
    int _refreshCount;
}

@end
