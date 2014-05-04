#import <UIKit/UIKit.h>


@interface FaceViewController : UIView{
	NSMutableArray            *_phraseArray;
    UIScrollView              *_sv;
    UIPageControl* _pc;
    BOOL pageControlIsChanging;
}

@property (nonatomic, assign) NSObject       *delegate;
@property (nonatomic, retain) NSArray        *faceArray;
@property (nonatomic, retain) NSMutableArray *imageArray;

@end
