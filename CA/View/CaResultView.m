//
//  CaResultView.m
//  CA
//
//  Created by Davien Sin on 2022/10/31.
//

#import "CaResultView.h"
#import "Masonry/Masonry.h"

@implementation CaResultView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor blackColor];

        //resultLabel
        self.resultLable = [[UILabel alloc] init];
        [self addSubview:self.resultLable];
        [self.resultLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(80);
            make.width.equalTo(self.mas_width).offset(-20);
            make.height.mas_equalTo(50);
        }];
        self.resultLable.textColor = [UIColor whiteColor];
        self.resultLable.numberOfLines = 1;
        self.resultLable.textAlignment = NSTextAlignmentRight;
        self.resultLable.font = [UIFont boldSystemFontOfSize:40];

        //symbloLable
        self.symbloLable = [[UILabel alloc] init];
        [self addSubview:self.symbloLable];
        [self.symbloLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-20);
            make.width.mas_equalTo(50);
            make.height.equalTo(self.resultLable);
            make.left.equalTo(self.mas_left).offset(20);
        }];
        self.symbloLable.textColor = [UIColor whiteColor];
        self.symbloLable.numberOfLines = 1;
        self.symbloLable.text = @"";
        self.symbloLable.textAlignment = NSTextAlignmentCenter;
        self.symbloLable.font = [UIFont boldSystemFontOfSize:40];
        
        //cabLabel
        self.cabLabel = [[UILabel alloc] init];
        [self addSubview:self.cabLabel];
        [self.cabLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.resultLable.mas_bottom).offset(80);
            make.width.equalTo(self.mas_width).offset(-20);
            make.height.equalTo(self.resultLable);
        }];
        self.cabLabel.textColor = [UIColor whiteColor];
        self.cabLabel.numberOfLines = 1;
        self.cabLabel.textAlignment = NSTextAlignmentRight;
        self.cabLabel.font = [UIFont boldSystemFontOfSize:40];

        //caLable
        self.caLabel = [[UILabel alloc] init];
        [self addSubview:self.caLabel];
        [self.caLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-20);
            make.left.equalTo(self.symbloLable.mas_right).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
            make.height.equalTo(self.resultLable);
        }];
        self.caLabel.textColor = [UIColor whiteColor];
        self.caLabel.numberOfLines = 1;
        self.caLabel.textAlignment = NSTextAlignmentRight;
        self.caLabel.text = @"0";
        self.caLabel.font = [UIFont boldSystemFontOfSize:40];
    }
    return self;
}



@end
