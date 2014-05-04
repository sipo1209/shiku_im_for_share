//
//  menuImageView.m
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import "menuImageView.h"

@implementation menuImageView
@synthesize type,delegate,items,offset,arrayBtns,itemWidth,selected;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        int width;
        if(itemWidth<=0)
            width = 57;
        else
            width = itemWidth;
        if([items count]>5)
            width = 53;
        int n = frame.origin.x+(frame.size.width-width*[items count])/2+offset;
        int t;
        self.userInteractionEnabled = YES;
        
        if (type==0){
            self.image = [UIImage imageNamed:@"new_top@2x.png"];
            t = (frame.size.height-30)/2;
        }
        if (type==1){
            self.image = [UIImage imageNamed:@"new_top@2x.png"];
            t = (frame.size.height-30)/2;
        }
        if (type==2){
            self.backgroundColor = [UIColor clearColor];
            n = 0;
            t = 0;
        }
        
        arrayBtns = [[NSMutableArray alloc]init];
        UIButton* btn;
        UIFont* font15b= [UIFont boldSystemFontOfSize:15];

        btn = [self createButtonWithRect:CGRectMake(n, t, width, 30)
                                        title:[items objectAtIndex:0]
                                    titleFont:font15b
                                   titleColor:nil
                                       normal:@"0_left_n@2x.png"
                                     selected:@"0_left_c@2x.png"
                                     selector:@selector(onClick:)
                                       target:self];
        btn.tag = 0;
        [self addSubview:btn];
        [arrayBtns addObject:btn];
        
        int i;
        for(i=1;i<[items count]-1;i++){
            btn = [self createButtonWithRect:CGRectMake(n+width*i, t, width, 30)
                                            title:[items objectAtIndex:i]
                                        titleFont:font15b
                                       titleColor:nil
                                           normal:@"0_mid_n@2x.png"
                                         selected:@"0_mid_c@2x.png"
                                         selector:@selector(onClick:)
                                           target:self];
            btn.tag = i;
            [self addSubview:btn];
            [arrayBtns addObject:btn];
        }
        
        i =[items count]-1;
        btn = [self createButtonWithRect:CGRectMake(n+width*i, t, width, 30)
                                        title:[items objectAtIndex:i]
                                    titleFont:font15b
                                   titleColor:nil
                                       normal:@"0_right_n@2x.png"
                                     selected:@"0_right_c@2x.png"
                                     selector:@selector(onClick:)
                                       target:self];
        btn.tag = i;
        [self addSubview:btn];
        [arrayBtns addObject:btn];
    }
    return self;
}

-(void)dealloc{
    [arrayBtns release];
    [items release];
    [super dealloc];
}

-(void)onClick:(UIButton*)sender{
    [self unSelectAll];
    sender.selected = YES;
    self.selected = sender.tag;
	if(self.delegate != nil && [self.delegate respondsToSelector:self.onClick])
		[self.delegate performSelectorOnMainThread:self.onClick withObject:sender waitUntilDone:NO];
}

-(void)unSelectAll{
    for(int i=0;i<[arrayBtns count];i++)
        ((UIButton*)[arrayBtns objectAtIndex:i]).selected = NO;
    selected = -1;
}

-(void)selectOne:(int)n{
    [self unSelectAll];
    if(n >= [self.arrayBtns count])
        return;
    ((UIButton*)[self.arrayBtns objectAtIndex:n]).selected=YES;
    selected = n;
}

-(void)setTitle:(int)n title:(NSString*)s{
    if(n >= [self.arrayBtns count])
        return;
    [[self.arrayBtns objectAtIndex:n] setTitle:s forState:UIControlStateNormal];
}

- (UIButton *)createButtonWithRect:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont *)font
                        titleColor:(UIColor *)titleColor
                            normal:(NSString *)normalImage
                          selected:(NSString *)clickIamge
                          selector:(SEL)selector
                            target:(id)target;
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    if (title != nil)
        [button setTitle:title forState:UIControlStateNormal];
    
    if (titleColor != nil)
        [button setTitleColor:titleColor forState:UIControlStateNormal];
    
    if (font != nil)
        [button.titleLabel setFont:font];
    
    if (normalImage != nil)
        [button setBackgroundImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    
    if (clickIamge != nil)
        [button setBackgroundImage:[UIImage imageNamed:clickIamge] forState:UIControlStateSelected];
    
    if ((selector != nil) && (target != nil))
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end