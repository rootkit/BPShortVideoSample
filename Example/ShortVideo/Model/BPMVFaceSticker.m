//
//  BPMVFaceSticker.m
//  Zhudou
//
//  Created by zhudou on 2017/11/23.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPMVFaceSticker.h"

@implementation BPMVFaceSticker
+ (instancetype)bp_modelWithDict:(NSDictionary*)dict
{
    BPMVFaceSticker* sticker = [super bp_modelWithDict:dict];
    if ([sticker.face_type isEqualToString:@"head"]) {
        sticker.faceType = MVStickerFaceTypeHead;
    } else if ([sticker.face_type isEqualToString:@"eye"]) {
        sticker.faceType = MVStickerFaceTypeEye;
    } else if ([sticker.face_type isEqualToString:@"nose"]) {
        sticker.faceType = MVStickerFaceTypeNose;
    } else if ([sticker.face_type isEqualToString:@"mouth"]) {
        sticker.faceType = MVStickerFaceTypeMouth;
    }
    return sticker;
}
@end
