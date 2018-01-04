//
//  BPMVFaceSticker.h
//  Zhudou
//
//  Created by zhudou on 2017/11/23.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPModel.h"
typedef NS_ENUM(NSInteger, MVStickerFaceType) {
    MVStickerFaceTypeNone = 0,
    MVStickerFaceTypeHead,
    MVStickerFaceTypeEye,
    MVStickerFaceTypeNose,
    MVStickerFaceTypeMouth
};
@interface BPMVFaceSticker : BPModel
@property (nonatomic, copy) NSString* sticker_directory;
@property (nonatomic, copy) NSString* filename_format;
@property (nonatomic, assign) int frame_count;
@property (nonatomic, assign) float anchorpointX;
@property (nonatomic, assign) float anchorpointY;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float animation_duration;
@property (nonatomic, assign) MVStickerFaceType faceType;
@property (nonatomic, copy) NSString* face_type;
@end
