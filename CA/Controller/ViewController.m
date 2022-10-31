//
//  ViewController.m
//  CA
//
//  Created by davien on 2022/10/24.
//

#import "ViewController.h"
#import "Masonry/Masonry.h"
#import "CaSymbloCollectionViewCell.h"
#import "CaSymbloModel.h"
#import "CaResultView.h"
#import "CaSymbloCollectionView.h"
#import "AFNetworking/AFNetworking.h"
#import "AFNetworking.h"

#define kScreen [[UIScreen mainScreen] bounds].size

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) CaResultView *resultView;
@property (nonatomic,strong) CaSymbloCollectionViewCell *caSymbloCollectionViewCell;
@property (nonatomic,strong) CaSymbloCollectionView *caSymbloCollectionView;

@property (nonatomic,strong)  NSMutableDictionary *dataSource; //操作数据源
@property (nonatomic,strong) NSMutableArray *dataSourceCopy;

@property (nonatomic) NSInteger listCount;

@end

@implementation ViewController

// 初始化View
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化头部显示View
    [self initHeadView];
    
    //获取远端数据
    [self getDataSource];
}


-(void)initHeadView{
    //headview
    self.resultView = [[CaResultView alloc] init];
    [self.view addSubview:self.resultView];
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(350);
    }];
}

-(void)initCollectionView{
    // 初始化必须设定collectionView layou布局
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 1;
    flowLayout.minimumInteritemSpacing = 0;
    
    self.caSymbloCollectionView = [[CaSymbloCollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
    self.caSymbloCollectionView.delegate = self;
    self.caSymbloCollectionView.dataSource = self;
    [self.view addSubview:self.caSymbloCollectionView];
    
    [self.caSymbloCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.resultView.mas_bottom);
    }];
    [self.caSymbloCollectionView registerClass:[CaSymbloCollectionViewCell class] forCellWithReuseIdentifier:@"ca"];
    
}

-(void)getDataSource{
  //  NSDictionary *json = @{@"code":@"0",@"list":@[@[@"AC"],@[@"1",@"2",@"3",@"/"],@[@"4",@"5",@"*",@"6",@"7"],@[@"8",@"9",@"+"],@[@"0"],@[@"-",@"="],@[@"."
//    ]]}
    self.dataSource = [[NSMutableDictionary alloc] init];
    self.dataSourceCopy = [[NSMutableArray alloc] init];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://115.159.64.236:8000/cal" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *json = responseObject;
        @try {
            if([[NSString stringWithFormat:@"%@",[json valueForKey:@"code"]] isEqualToString:@"0"]){
                NSArray *tempList = [json valueForKey:@"list"];
                self.listCount = 0;
                for (int i = 0; i < tempList.count; i++) {
                    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
                    for (NSString *temp in tempList[i]) {
                        self.listCount += 1;
                        [self.dataSourceCopy addObject:temp];
                        [tempArr addObject:temp];
                    }
                    [self.dataSource setValue:tempArr forKey:[NSString stringWithFormat:@"%i",i]];
                }
            }else{
                NSLog(@"");
            }
        } @catch (NSException *exception) {
            NSLog(@"异常->>%@",exception);
        } @finally {

        }
        
        // 初始化数字盘
        [self initCollectionView];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error == %@",error);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
     return self.listCount;
}



- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CaSymbloCollectionViewCell  *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"ca" forIndexPath:indexPath];
    cell.caSymbloLabel.text = self.dataSourceCopy[indexPath.row];
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

// 触发点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *input = self.dataSourceCopy[indexPath.row];
    
    NSString *number = @"^[0-9]";
    NSString *operation = @"^[/*+-]";
    NSPredicate *numberregular = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    NSPredicate *operationregular = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",operation];
    if([numberregular evaluateWithObject:self.dataSourceCopy[indexPath.row]]){//数字按钮
        if([input isEqualToString:@"0"] && [self.resultView.caLabel.text isEqualToString:@"0"]){//输入0，当前显示为0
            NSLog(@"d");
        }else if([input isEqualToString:@"0"] && ![self.resultView.caLabel.text isEqualToString:@"0"]){//输入0，当前显示不为0
           self.resultView.caLabel.text = [self.resultView.caLabel.text stringByAppendingString:input];
        }else if(![input isEqualToString:@"0"] && [self.resultView.caLabel.text isEqualToString:@"0"]){//输入不为0,当前显示为0
            self.resultView.caLabel.text = input;
        }else if (![input isEqualToString:@"0"] && ![self.resultView.caLabel.text isEqualToString:@"0"]){//输入不为0，当前显示不为0
            self.resultView.caLabel.text = [self.resultView.caLabel.text stringByAppendingString:input];
        }
    }else if([operationregular evaluateWithObject:self.dataSourceCopy[indexPath.row]]){//运算按钮
        self.resultView.symbloLable.text = input;
        self.resultView.cabLabel.text = self.resultView.caLabel.text;
        self.resultView.caLabel.text = @"0";
    }else if([input isEqualToString:@"AC"]){//清空按钮
        [self resetResult];
    }else if([input isEqualToString:@"."]){//小数点
        if([self.resultView.caLabel.text rangeOfString:@"."].location == NSNotFound){
            self.resultView.caLabel.text = [self.resultView.caLabel.text stringByAppendingString:input];
        }
    }else if([input isEqualToString:@"="]){//=按钮
        if(![self.resultView.symbloLable.text isEqualToString:@""]){
            self.resultView.resultLable.text =  [self getResult:self.resultView.symbloLable.text caValue:self.resultView.cabLabel.text cabValue:self.resultView.caLabel.text];
               self.resultView.caLabel.text = @"0";
               self.resultView.cabLabel.text = @"";
               self.resultView.symbloLable.text = @"";
        }
    }else{//预防未知
        NSLog(@"未知操作");
    }
}



// 点击高亮
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView cellForItemAtIndexPath:indexPath].backgroundColor = [UIColor greenColor];
}
// 手离开时取消高亮
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView cellForItemAtIndexPath:indexPath].backgroundColor = [UIColor orangeColor];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

   int intemIndex = 0;
    NSArray *temp;
    for (int i = 0; i < self.dataSource.count; i++) {
        temp = [self.dataSource valueForKey:[NSString stringWithFormat:@"%i",i]];
        for (NSString *_temp in temp) {
        if([_temp isEqualToString:self.dataSourceCopy[indexPath.row]]){
                intemIndex = i;
            }
        }
    }
    temp = [self.dataSource valueForKey:[NSString stringWithFormat:@"%i",intemIndex]];
    int itemWidth = kScreen.width / temp.count;
    CGFloat itemHeight = self.caSymbloCollectionView.bounds.size.height / self.dataSource.count;
    return CGSizeMake(itemWidth, itemHeight);
}


-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)resetResult{
    self.resultView.resultLable.text = @"";
    self.resultView.caLabel.text = @"0";
    self.resultView.cabLabel.text = @"";
    self.resultView.symbloLable.text = @"";
}

//1+2 --> caa:1  cab:2
-(NSString *)getResult:(NSString *)symblo caValue:(NSString *)caa cabValue:(NSString *)cab{
    CGFloat temp = 0.0;
    if([symblo isEqualToString:@"+"]){
        temp =  caa.floatValue + cab.floatValue;
    }else if([symblo isEqualToString:@"-"]){
        temp =  caa.floatValue - cab.floatValue;
    }else if([symblo isEqualToString:@"*"]){
        temp =  caa.floatValue * cab.floatValue;
    }else if([symblo isEqualToString:@"/"]){
        if([cab isEqualToString:@"0"]){
            return @"错误";
        }else{
            temp = caa.floatValue / cab.floatValue;
        }
    }else{
        
    }
    return [NSString stringWithFormat:@"%f",temp];
}



@end
