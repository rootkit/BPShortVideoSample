//
//  BPMVMaterial.h
//  Zhudou
//
//  Created by zhudou on 2017/10/24.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPModel.h"

@interface BPMVMaterial : BPModel <NSCoding>
@property (nonatomic, copy) NSString* material_id;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* title_pic;
@property (nonatomic, copy) NSString* lrc_path;
@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, copy) NSString* create_time;
@property (nonatomic, assign) BOOL is_delete;
@property (nonatomic, assign) NSInteger mv_count;
@end
