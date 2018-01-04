//
//  BPModel.m
//  Zhudou
//
//  Created by 红黄蓝.马龙彪 on 16/9/7.
//  Copyright © 2016年 红黄蓝教育. All rights reserved.
//

#import "BPModel.h"

@implementation BPModel

- (instancetype)initWithDict:(NSDictionary*)dict
{
    if (self = [super init]) {
        self = [object_getClass(self) yy_modelWithDictionary:dict];
    }
    return self;
}

+ (instancetype)bp_modelWithDict:(NSDictionary*)dict
{
    return [[self alloc] initWithDict:dict];
}
@end
