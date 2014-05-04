#import <UIKit/UIKit.h>

@class SCGIFImageView;

@interface gifViewController : UIView{
	NSMutableArray            *_phraseArray;
    UIScrollView              *_sv;
    UIPageControl* _pc;
    SCGIFImageView* _gifIv;
    BOOL pageControlIsChanging;
    int maxPage;
}

@property (nonatomic, assign) NSObject       *delegate;
@property (nonatomic, retain) NSArray        *faceArray;
@property (nonatomic, retain) NSMutableArray *imageArray;

@end
