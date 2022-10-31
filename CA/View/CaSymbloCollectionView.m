//
//  CaSymbloCollectionView.m
//  CA
//
//  Created by Davien Sin on 2022/10/31.
//

#import "CaSymbloCollectionView.h"

@implementation CaSymbloCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// 初始化collectionView
-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if(self){
        self.backgroundColor = [UIColor orangeColor];
        self.scrollEnabled = NO;
    }
    return self;
}


@end
