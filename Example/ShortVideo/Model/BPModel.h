//
//  BPModel.h
//  Zhudou
//
//  Created by 红黄蓝.马龙彪 on 16/9/7.
//  Copyright © 2016年 红黄蓝教育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

@interface BPModel : NSObject <YYModel>

+ (instancetype)bp_modelWithDict:(NSDictionary*)dict;

@end
