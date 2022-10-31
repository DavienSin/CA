//
//  CaSymbloCollectionViewCell.m
//  CA
//
//  Created by Davien Sin on 2022/10/29.
//
#import "Masonry/Masonry.h"
#import "CaSymbloCollectionViewCell.h"

@implementation CaSymbloCollectionViewCell

//初始化cell布局
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if(self){
        self.caSymbloLabel = [[UILabel alloc] init];
        [self addSubview:self.caSymbloLabel];
        self.caSymbloLabel.textColor = [UIColor whiteColor];
        self.caSymbloLabel.textAlignment = NSTextAlignmentCenter;
        self.caSymbloLabel.font = [UIFont boldSystemFontOfSize:30];
        
        [self.caSymbloLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self);
        }];
        
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

@end
