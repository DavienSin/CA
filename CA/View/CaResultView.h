//
//  CaResultView.h
//  CA
//
//  Created by Davien Sin on 2022/10/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CaResultView : UIView

@property (nonatomic,strong) UILabel *resultLable; //结果
@property (nonatomic,strong) UILabel *symbloLable; //操作符号

//1+2 
@property (nonatomic,strong) UILabel *cabLabel; //被操作符号
@property (nonatomic,strong) UILabel *caLabel; //操作数

@end

NS_ASSUME_NONNULL_END
