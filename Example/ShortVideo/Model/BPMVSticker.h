//
//  BPMVSticker.h
//  Zhudou
//
//  Created by zhudou on 2017/11/13.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPModel.h"

@interface BPMVSticker : BPModel
@property (nonatomic,copy) NSString *sticker_directory;
@property (nonatomic,copy) NSString *filename_format;
@property (nonatomic,assign) int frame_count;
@property (nonatomic,assign) float positionX;
@property (nonatomic,assign) float positionY;
@property (nonatomic,assign) float anchorpointX;
@property (nonatomic,assign) float anchorpointY;
@property (nonatomic,assign) float width;
@property (nonatomic,assign) float height;
@property (nonatomic,assign) float display_width;
@property (nonatomic,assign) float display_height;
@property (nonatomic,assign) float animation_duration;
@end
