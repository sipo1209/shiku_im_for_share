//
//  menuImageView.h
//  sjvodios
//
//  Created by daxiong on 13-4-17.
//
//

#import <UIKit/UIKit.h>

@interface menuImageView : UIImageView{
    NSMutableArray*    _arrayBtns;

}
@property (nonatomic,retain)  NSMutableArray* arrayBtns;
@property (nonatomic,retain)  NSMutableArray* items;
@property (nonatomic, assign) NSObject* delegate;
@property (nonatomic, assign) SEL		onClick;
@property (nonatomic, assign) int		type;
@property (nonatomic, assign) int       offset;
@property (nonatomic, assign) int		itemWidth;
@property (nonatomic, assign) int       selected;

-(void)unSelectAll;
-(void)selectOne:(int)n;
-(void)setTitle:(int)n title:(NSString*)s;
@end
