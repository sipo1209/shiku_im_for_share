#import "gifViewController.h"
#import "SCGIFImageView.h"

#define BEGIN_FLAG @"["
#define END_FLAG @"]"

@implementation gifViewController
@synthesize delegate=_delegate,faceArray,imageArray;


#define WIDTH_PAGE 320

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor darkGrayColor];
    
    
	imageArray = [[NSMutableArray alloc] init];
    faceArray  = [[NSMutableArray alloc] init];

    [self getGifFiles];
    [self create];
    
    return self;
}

-(void)getGifFiles{
    
    NSString* dir=[self imageFilePath];
    NSString* Path;
    NSString* ext;
    
    NSArray *contentOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:NULL];
    for (NSString *aPath in contentOfFolder) {
        Path = [dir stringByAppendingPathComponent:aPath];
        ext  = [aPath pathExtension];

        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:Path isDirectory:&isDir] && !isDir)
        {
            if( [ext isEqualToString:@"gif"] ){
                SCGIFImageView* iv = [[SCGIFImageView alloc] initWithGIFFile:Path];
                [imageArray addObject:[iv getFrameAsImageAtIndex:0]];
                [faceArray addObject:[Path lastPathComponent]];
                [iv release];
            }
        }
    }

    int n = fmod([faceArray count], 8);
    maxPage = [faceArray count]/8;
    if(n != 0)
        maxPage++;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (NSString *)imageFilePath {
    NSString *s=[[NSBundle mainBundle] bundlePath];
    s = [s stringByAppendingString:@"/"];
    //NSLog(@"%@",s);
    return s;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [faceArray release];
    [imageArray release];
    [_gifIv release];
    [super dealloc];
}

-(void)create{
    _sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20)];
    _sv.contentSize = CGSizeMake(WIDTH_PAGE*maxPage, self.frame.size.height-20);
    _sv.pagingEnabled = YES;
    _sv.scrollEnabled = YES;
    _sv.delegate = self;
    _sv.showsVerticalScrollIndicator = NO;
    _sv.showsHorizontalScrollIndicator = NO;
    _sv.userInteractionEnabled = YES;
    _sv.minimumZoomScale = 1;
    _sv.maximumZoomScale = 1;
    _sv.decelerationRate = 0.01f;
    _sv.backgroundColor = [UIColor clearColor];
    [self addSubview:_sv];
    [_sv release];
    

    int n = 0;

    for(int i=0;i<maxPage;i++){
        int x=WIDTH_PAGE*i,y=0;
        for(int j=0;j<8;j++){
            if(n>=[faceArray count])
                break;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(x, y+10, 60, 60);
            button.tag = n;
            [button setBackgroundImage:[imageArray objectAtIndex:n] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(actionSelect:)forControlEvents:UIControlEventTouchUpInside];
            [_sv addSubview:button];
            
            
            if(fmod(i*8+j+1, 4)==0.0f && j>=3){
                x = WIDTH_PAGE*i;
                y += 70;
            }else
                x += 80;

            n++;
        }
    }
    
    _pc = [[UIPageControl alloc]initWithFrame:CGRectMake(100, self.frame.size.height-30, 120, 30)];
    _pc.numberOfPages  = maxPage;
    [_pc addTarget:self action:@selector(actionPage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pc];
    [_pc release];
}


-(void)actionSelect:(UIView*)sender
{
    NSString* s = [faceArray objectAtIndex:sender.tag];
    if( [_delegate isKindOfClass:[UITextField class]] ){
        UITextField* p = _delegate;
        p.tag = kWCMessageTypeGif;
        p.text = [s lastPathComponent];
        if(p.delegate)
            [p.delegate textFieldShouldReturn:p];
        p = nil;
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x/320;
    int mod   = fmod(scrollView.contentOffset.x,320);
    if( mod >= 160)
        index++;
    _pc.currentPage = index;
    //    [self setPage];
}

- (void) setPage
{
	_sv.contentOffset = CGPointMake(WIDTH_PAGE*_pc.currentPage, 0.0f);
    NSLog(@"setPage:%d,%f",_sv.contentOffset,_pc.currentPage);
    [_pc setNeedsDisplay];
}

-(void)actionPage{
    [self setPage];
}

@end