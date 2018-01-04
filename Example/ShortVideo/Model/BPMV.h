//
//  BPMV.h
//  Zhudou
//
//  Created by zhudou on 2017/10/24.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPModel.h"

typedef NS_ENUM(NSInteger, MVType) {
    MVTypeTop = 1,
    MVTypeHot = 2,
    MVTypeMine = 3,
    MVTypeDraft = 4
};

typedef NS_ENUM(NSInteger, MVPassStatus) {
    MVPassStatusRejected = -1,
    MVPassStatusReview = 0,
    MVPassStatusPassed = 1
};

@interface BPMV : BPModel <NSCoding>
@property (nonatomic, copy) NSString* mv_id;
//@property (nonatomic, copy) NSString* material_id;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* title_pic;
@property (nonatomic, copy) NSString* head_photo;
@property (nonatomic, copy) NSString* video_path;
@property (nonatomic, copy) NSString* nice_name;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, copy) NSString* user_id;
@property (nonatomic, copy) NSString* create_time;
@property (nonatomic, assign) NSInteger play_count;
@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) BOOL is_liked;
@property (nonatomic, assign) BOOL is_my;
@property (nonatomic, assign) MVPassStatus is_pass;
@end
