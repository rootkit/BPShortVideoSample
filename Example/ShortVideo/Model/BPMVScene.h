//
//  BPMVScene.h
//  Zhudou
//
//  Created by zhudou on 2017/11/10.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPModel.h"

@interface BPMVScene : BPModel <NSCoding>
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* title_pic;
@property (nonatomic, copy) NSString* create_time;
@property (nonatomic, copy) NSString* scene_id;
@property (nonatomic, copy) NSString* zip_path_ios;
@property (nonatomic, assign) BOOL is_delete;
@property (nonatomic,assign) BOOL is_downloading;
@property (nonatomic, assign) BOOL is_empty;
@end
