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
#import "MBProgressHud/MBProgressHUD.h"

#define kScreen [[UIScreen mainScreen] bounds].size
NSString * const cacheURL = @"http://115.159.64.236:8000/cal";


@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) CaResultView *resultView;
@property (nonatomic,strong) CaSymbloCollectionViewCell *caSymbloCollectionViewCell;
@property (nonatomic,strong) CaSymbloCollectionView *caSymbloCollectionView;

@property (nonatomic,strong)  NSMutableDictionary *dataSource; //操作数据源
@property (nonatomic,strong) NSMutableArray<NSString *> *dataSourceCopy;

@property (nonatomic) NSInteger listCount;
@property (nonatomic,strong) NSString *resultCahe;
@property (nonatomic,strong) NSString *symbloCache;
@property (nonatomic,strong) NSString *caCache;
@property (nonatomic) BOOL isResult;
@property (nonatomic) BOOL hasTriggerSymblo;//是否触发运算符号
@property (nonatomic) BOOL hasChangeValueAfterTriggerSymblo;//是否触发运算后输入数字
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
    
    //监听操作数变化动态改变AC<-->C按键
    [self.resultView.caLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    //监听触发运算后改变AC<-->C
    [self.resultView.symbloLable addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
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
    
    self.resultCahe = @"";
    self.symbloCache = @"";
    self.caCache = @"";
    self.hasTriggerSymblo = NO;
    self.hasChangeValueAfterTriggerSymblo = NO;
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
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *hasCache = [userDefault valueForKey:@"hasCache"];
    if([hasCache isEqualToString:@"no"]){
     //   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:cacheURL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *json = responseObject;
            [self initDataSource:json];
            // 初始化数字盘
            [self initCollectionView];
      //      [MBProgressHUD hideHUDForView:self.view animated:YES];
            [userDefault setValue:json forKey:@"cache"];
            [userDefault setValue:@"yes" forKey:@"hasCache"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error == %@",error);
        }];
    }else{
        NSDictionary *json = [userDefault valueForKey:@"cache"];
        [self initDataSource:json];
        [self initCollectionView];
        
        //请求获取最新数据并缓存
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:cacheURL parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *json = responseObject;
            [userDefault setValue:json forKey:@"cache"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error == %@",error);
        }];
        
    }
    
    
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
    NSString *caText = self.resultView.caLabel.text;
    NSString *number = @"^[0-9]";
    NSString *operation = @"^[/*+-]";
    NSPredicate *numberregular = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    NSPredicate *operationregular = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",operation];
    
    
    if([numberregular evaluateWithObject:self.dataSourceCopy[indexPath.row]]){//数字按钮
        if(![self.caCache isEqualToString:@""]){//触发运算逻辑
            if([input isEqualToString:@"0"] && [self.resultView.caLabel.text isEqualToString:@"0"]){//输入0，当前显示为0。
                NSLog(@"输入0，当前显示为0");
            }else if(![input isEqualToString:@"0"] && [self.resultView.caLabel.text isEqualToString:@"0"]){//输入不为0,当前显示为0。
                self.resultView.caLabel.text = input;
            }else{//输入
                if(self.hasTriggerSymblo){
                    self.resultView.caLabel.text = input;
                }else{
                    self.resultView.caLabel.text = [self.resultView.caLabel.text stringByAppendingString:input];
                }
            }
            self.hasTriggerSymblo = NO;
        }else{//没有触发运算逻辑
            if([input isEqualToString:@"0"] && [self.resultView.caLabel.text isEqualToString:@"0"]){//输入0，当前显示为0。
                NSLog(@"输入0，当前显示为0");
            }else if(![input isEqualToString:@"0"] && [self.resultView.caLabel.text isEqualToString:@"0"]){//输入不为0,当前显示为0。
                self.resultView.caLabel.text = input;
            }else{
                self.resultView.caLabel.text = [self.resultView.caLabel.text stringByAppendingString:input];
            }
        }
        
        
    }else if([operationregular evaluateWithObject:self.dataSourceCopy[indexPath.row]]){//运算按钮
        self.resultView.symbloLable.text = input;
        if([self.caCache isEqualToString:@""]){
            [self triggerCa];
            self.resultView.cabLabel.text = self.caCache;
            self.resultView.caLabel.text = @"0";
        }else{
            [self triggerCaResult:input];
        }
    }else if([input isEqualToString:@"AC"]){//清空按钮
        [self resetResult];
    }else if([input isEqualToString:@"."]){//小数点
        if([caText rangeOfString:@"."].location == NSNotFound){
            self.resultView.caLabel.text = [caText stringByAppendingString:input];
        }
    }else if([input isEqualToString:@"="]){//=按钮
       [self triggerCaResult:input];
    }else if([input isEqualToString:@"C"]){//C按钮
        NSMutableString *temp = [caText mutableCopy];
        if(temp.length > 1){
            [temp deleteCharactersInRange:NSMakeRange(temp.length - 1, 1)];
            self.resultView.caLabel.text = temp;
        }else{
            self.resultView.caLabel.text = @"0";
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
    self.resultView.caLabel.text = @"0";
    self.resultView.symbloLable.text = @"";
    self.caCache = @"";
    self.resultCahe = @"";
    self.hasTriggerSymblo = NO;
    self.resultCahe = @"";
}

//触发运算符
-(void)triggerCa{
    self.caCache = self.resultView.caLabel.text; //记录ca数
    self.symbloCache = self.resultView.symbloLable.text;// 记录此次操作的运算符
}

//触发=
-(void)triggerCaResult:(NSString *)symblo{
    NSString *result = @"";
    if([symblo isEqualToString:@"="]){//=计算
        if(![self.resultCahe isEqualToString:@""] && ![self.caCache isEqualToString:@""] && [self.resultView.symbloLable.text isEqualToString:@""]){//resultCache:1,cache:1,ca:0
            // ======运算操作
            self.resultView.caLabel.text = [self getResult:self.symbloCache caValue:self.resultCahe cabValue:self.caCache];
            self.resultCahe = self.resultView.caLabel.text;
        }else if(![self.resultView.cabLabel.text isEqualToString:@""]){//resultCache:0,cache:1,ca:1
            result = [self getResult:self.resultView.symbloLable.text caValue:self.resultView.cabLabel.text cabValue:self.resultView.caLabel.text];
            self.caCache = self.resultView.caLabel.text;
            self.symbloCache = self.resultView.symbloLable.text;
            self.resultCahe = result;
            self.resultView.caLabel.text = result;
            self.resultView.cabLabel.text = @"";
            self.resultView.symbloLable.text = @"";
        }else{
            NSLog(@"what???");
        }
        [self changeCToAcKey];
        [self.caSymbloCollectionView reloadData];
    }else{//非等号运算
        if([self.resultView.cabLabel.text isEqualToString:@""]){
            self.resultView.cabLabel.text = self.resultView.caLabel.text;
            self.resultView.caLabel.text = @"0";
            self.resultView.symbloLable.text = symblo;
            self.caCache = self.resultView.caLabel.text;
        }else{
            if([self.resultCahe isEqualToString:@""]){//没有结果缓存
                result = [self getResult:self.symbloCache caValue:self.caCache cabValue:self.resultView.caLabel.text];
                self.caCache = self.resultView.caLabel.text;
                self.resultView.cabLabel.text = result;
                self.resultView.caLabel.text = @"0";
                self.resultCahe = result;
                self.symbloCache = symblo;
           }else{//有结果缓存
                //执行非等号操作  1+2+3+4
                result = [self getResult:self.symbloCache caValue:self.resultCahe cabValue:self.resultView.caLabel.text];
                self.caCache = self.resultView.caLabel.text;
                self.resultView.caLabel.text = @"0";
                self.resultView.cabLabel.text = result;
                self.resultCahe = result;
                self.symbloCache = symblo;
            }
        }
    }
}


//1+2 --> caa:1  cab:2  计算结果
-(NSString *)getResult:(NSString *)symblo caValue:(NSString *)caa cabValue:(NSString *)cab{
    
    //使用精准计算浮点数的类
    NSDecimalNumber *temp;
    NSDecimalNumber *ca =[NSDecimalNumber decimalNumberWithString:caa];
    NSDecimalNumber *cb =[NSDecimalNumber decimalNumberWithString:cab];
    if([symblo isEqualToString:@"+"]){
        temp =  [ca decimalNumberByAdding:cb];
    }else if([symblo isEqualToString:@"-"]){
        temp =  [ca decimalNumberBySubtracting:cb];
    }else if([symblo isEqualToString:@"*"]){
        temp =  [ca decimalNumberByMultiplyingBy:cb];
    }else if([symblo isEqualToString:@"/"]){
        if([cab isEqualToString:@"0"]){
            return @"错误";
        }else{
            temp = [ca decimalNumberByDividingBy:cb];
        }
    }else{
        
    }
    //四舍五入，保留小数点后10位
    NSDecimalNumberHandler *numberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:10 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    temp = [temp decimalNumberByRoundingAccordingToBehavior:numberHandler];
    return temp.stringValue;
}

-(void)initDataSource:(NSDictionary *)sender{
    @try {
        if([[NSString stringWithFormat:@"%@",[sender valueForKey:@"code"]] isEqualToString:@"0"]){
            NSArray *tempList = [sender valueForKey:@"list"];
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
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSString *newValue = [change valueForKey:@"new"];
    NSString *operation = @"^[/*+-]";
    NSString *number = @"^[0-9]";
    NSPredicate *numberregular = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    NSPredicate *operationregular = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",operation];
    
    NSUInteger ACindex = [self getACIndex];
    if([operationregular evaluateWithObject:newValue]){//判断newValue是否运算符号
        [self changeCToAcKey];
    }else{
        if([numberregular evaluateWithObject:newValue] && ![newValue isEqualToString:@"0"]){ //做判断首次为0时输入数字也能改变AC->C
            [self changeAcToCKey];
        }else if([numberregular evaluateWithObject:newValue]){
            [self changeCToAcKey];
        }
        self.hasChangeValueAfterTriggerSymblo = YES;
    }
    [self.caSymbloCollectionView reloadData];
}

-(void)changeAcToCKey{
    NSUInteger ACindex = [self getACIndex];
    [self.dataSourceCopy replaceObjectAtIndex:ACindex withObject:@"C"];
}

-(void)changeCToAcKey{
    NSUInteger ACindex = [self getACIndex];
    [self.dataSourceCopy replaceObjectAtIndex:ACindex withObject:@"AC"];
}



-(NSInteger)getACIndex{
    int ACindex = 0;
    for (int i = 0;i < self.dataSourceCopy.count; i++) {
        if([self.dataSourceCopy[i] isEqualToString:@"AC"]){
            ACindex = i;
        }
    }
    return ACindex;
}



-(void)dealloc{
    [self.resultView.caLabel removeObserver:self forKeyPath:@"text"];
}



@end
