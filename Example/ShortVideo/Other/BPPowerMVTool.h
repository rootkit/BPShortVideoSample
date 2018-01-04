//
//  BPPowerMVTool.h
//  Zhudou
//
//  Created by zhudou on 2017/11/13.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPPowerMVTool : NSObject

+ (instancetype)shareTool;

//截取视频缩略图
- (NSArray<UIImage*>*)thumbnailImageRequestWithVideoPath:(NSString*)path count:(int)count;

//预览图选择
- (void)showPreviewPickerView:(NSArray<UIImage*>*)arr selectBlock:(void (^)(UIImage* img))block;

//压缩视频
- (void)optimizeMV:(NSString*)path completion:(void (^)())completion;

-(void)excuteFFMpegCommandStr:(NSString *)commandStr completion:(void (^)())completion;

-(void)publishMV:(BPStory *)mv withImage:(UIImage *)img completion:(void (^)())completion;

@end
