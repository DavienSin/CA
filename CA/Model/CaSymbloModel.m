//
//  CaSymbloModel.m
//  CA
//
//  Created by Davien Sin on 2022/10/31.
//

#import "CaSymbloModel.h"

@implementation CaSymbloModel

-(NSMutableDictionary *)dataSource{
    if(!_dataSource){
        _dataSource = [[NSMutableDictionary alloc] init];
    }
    return _dataSource;
}


@end
