#import "FaceViewController.h"
#import "SCGIFImageView.h"
#import "JXMessageObject.h"

#define BEGIN_FLAG @"["
#define END_FLAG @"]"

@implementation FaceViewController
@synthesize delegate=_delegate,faceArray,imageArray;


#define WIDTH_PAGE 320

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor darkGrayColor];
    
    faceArray = [[NSArray alloc]initWithObjects:@"[微笑]",@"[撇嘴]",@"[色]",@"[发呆]",@"[得意]",@"[流泪]",@"[害羞]",@"[闭嘴]",@"[睡]",@"[大哭]",
                 @"[尴尬]",@"[发怒]",@"[调皮]",@"[龇牙]",@"[惊讶]",@"[难过]",@"[严肃]",@"[冷汗]",@"[抓狂]",@"[吐]",@"[偷笑]",@"[可爱]",@"[白眼]",@"[傲慢]",
                 @"[饥饿]",@"[困]",@"[惊恐]",@"[流汗]",@"[憨笑]",@"[大兵]",@"[奋斗]",@"[咒骂]",@"[疑问]",@"[嘘]",@"[晕]",@"[折磨]",@"[衰]",@"[骷髅]",
                 @"[敲打]",@"[再见]",@"[擦汗]",@"[抠鼻]",@"[鼓掌]",@"[糗大了]",@"[坏笑]",@"[左哼哼]",@"[右哼哼]",@"[哈欠]",@"[鄙视]",@"[委屈]",@"[快哭了]",
                 @"[阴险]",@"[亲嘴]",@"[吓]",@"[可怜]",@"[菜刀]",@"[西瓜]",@"[啤酒]",@"[篮球]",@"[乒乓]",@"[咖啡]",@"[饭]",@"[猪头]",@"[玫瑰]",@"[凋谢]",
                 @"[示爱]",@"[爱心]",@"[心碎]",@"[蛋糕]",@"[闪电]",@"[炸弹]",@"[刀]",@"[足球]",@"[瓢虫]",@"[便便]",@"[拥抱]",@"[月亮]",@"[太阳]",@"[礼物]",
                 @"[强]",@"[弱]",@"[握手]",@"[胜利]",@"[抱拳]",@"[勾引]",@"[拳头]",@"[差劲]",@"[爱你]",@"[NO]",@"[OK]",@"[苹果]",@"[可爱狗]",@"[小熊]",@"[彩虹]",@"[皇冠]",@"[钻石]",nil];
    
	imageArray = [[NSMutableArray alloc] init];
    for (int i = 0;i<[faceArray count];i++){
        NSString* s = [NSString stringWithFormat:@"%@f%.3d.png",[self imageFilePath],i];
        [imageArray addObject:s];
    }
    [self create];
    return self;
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
    [super dealloc];
}

-(void)create{
    _sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-20)];
    _sv.contentSize = CGSizeMake(WIDTH_PAGE*5, self.frame.size.height-20);
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
    UIImage *tempImage;
    NSString* s;
    for(int i=0;i<5;i++){
        int x=WIDTH_PAGE*i,y=0;
        for(int j=0;j<24;j++){
            if(n>=[faceArray count])
                break;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(x, y+10, 32.0f, 32.0f);
            button.tag = n;
            
            if(j==23){
                s = [[self imageFilePath] stringByAppendingPathComponent:@"playback_close@2x.png"];
                [button addTarget:self action:@selector(actionDelete:)forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                s = [imageArray objectAtIndex:n];
                [button addTarget:self action:@selector(actionSelect:)forControlEvents:UIControlEventTouchUpInside];
                n++;
                
                if(fmod(i*24+j+1, 8)==0.0f && j>=7){
                    x = WIDTH_PAGE*i;
                    y += 50;
                }else
                    x += 40;
            }
            [button setBackgroundImage:[UIImage imageWithContentsOfFile:s] forState:UIControlStateNormal];
            [_sv addSubview:button];
            
        }
    }
    
    _pc = [[UIPageControl alloc]initWithFrame:CGRectMake(100, self.frame.size.height-30, 120, 30)];
    _pc.numberOfPages  = 5;
    [_pc addTarget:self action:@selector(actionPage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pc];
    [_pc release];
}


-(void)actionSelect:(UIView*)sender
{
    NSString* s = [faceArray objectAtIndex:sender.tag];
    if( [_delegate isKindOfClass:[UITextField class]] ){
        UITextField* p = _delegate;
        p.tag = kWCMessageTypeText;
        NSString* t = @"";
        if([p.text length]<=0)
            p.text = t;
        p.text = [p.text stringByAppendingString:s];
        [p setNeedsDisplay];
        p = nil;
    }
}

-(IBAction)actionDelete:(UIView*)sender{
    if( [_delegate isKindOfClass:[UITextField class]] ){
        UITextField* p = _delegate;
        NSString* s = p.text;

        if([s length]<=0)
            return;
        int n=-1;
        if( [s characterAtIndex:[s length]-1] == ']'){
            for(int i=[s length]-1;i>=0;i--){
                if( [s characterAtIndex:i] == '[' ){
                    n = i;
                    break;
                }
            }
        }
        if(n>=0)
            p.text = [s substringWithRange:NSMakeRange(0,n)];
        else
            p.text = [s substringToIndex:[s length]-1];
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

/*
-(void)createRecognizer{
    UIPanGestureRecognizer *panGR =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectDidDragged:)];
    //限定操作的触点数
    [panGR setMaximumNumberOfTouches:1];
    [panGR setMinimumNumberOfTouches:1];
    //将手势添加到draggableObj里
    [self addGestureRecognizer:panGR];
}

- (void)objectDidDragged:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        CGPoint offset = [sender translationInView:g_App.window];
        if(offset.y>20 || offset.y<-20)
            return;
        if(offset.x>0)
            _pc.currentPage++;
        else
            _pc.currentPage--;
        [self setPage];
    }
}*/

@end