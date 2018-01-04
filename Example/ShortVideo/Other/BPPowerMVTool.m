//
//  BPPowerMVTool.m
//  Zhudou
//
//  Created by zhudou on 2017/11/13.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPPowerMVTool.h"
#import <AVFoundation/AVFoundation.h>
#include "ffmpeg.h"
#import "BPRecordTool.h"
#import "BPStory.h"

int ffmpegmain(int argc, char** argv);

#define CachePathForUploadImage [NSString stringWithFormat:@"%@/Library/Caches/ZhudouCache", NSHomeDirectory()]

typedef void (^optimize_completion)();
@interface BPPowerMVTool ()
@property (nonatomic, copy) NSString* optimize_path;
@property (nonatomic, copy) NSString* command_str;
@property (nonatomic, strong) optimize_completion completion;
@property (nonatomic, copy) NSString* title_pic;
@property (nonatomic, copy) NSString* mv_path;
@property (nonatomic, assign) BOOL currentUploadCancel;
@end

@implementation BPPowerMVTool

static BPPowerMVTool* _instance;

+ (instancetype)shareTool
{
    return [[self alloc] init];
}
+ (instancetype)allocWithZone:(struct _NSZone*)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
- (nonnull id)copyWithZone:(nullable NSZone*)zone
{
    return _instance;
}
- (nonnull id)mutableCopyWithZone:(nullable NSZone*)zone
{
    return _instance;
}

- (NSArray<UIImage*>*)thumbnailImageRequestWithVideoPath:(NSString*)path count:(int)count
{
    NSURL* url = [NSURL fileURLWithPath:path];
    //根据url创建AVURLAsset
    AVURLAsset* urlAsset = [AVURLAsset assetWithURL:url];
    //根据AVURLAsset创建AVAssetImageGenerator
    AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    /*截图
     * requestTime:缩略图创建时间
     * actualTime:缩略图实际生成的时间
     */
    NSError* error = nil;

    NSMutableArray* tempArr = [NSMutableArray arrayWithCapacity:count];

    for (int i = 0; i < count; i++) {

        long long timeBySecond = urlAsset.duration.value / urlAsset.duration.timescale;

        if (count == 1) {
            timeBySecond = 0;
        }

        CMTime time = CMTimeMakeWithSeconds(arc4random() % timeBySecond, 10); //CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
        CMTime actualTime;
        CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if (error) {
            RYBLog(@"截取视频缩略图时发生错误，错误信息：%@", error.localizedDescription);
            return nil;
        }
        CMTimeShow(actualTime);
        UIImage* image = [UIImage imageWithCGImage:cgImage]; //转化为UIImage
        CGImageRelease(cgImage);
        [tempArr addObject:image];
    }
    return tempArr;
}

- (void)showPreviewPickerView:(NSArray<UIImage*>*)arr selectBlock:(void (^)(UIImage* img))block
{
    [LEEAlert actionsheet]
        .config
//        .LeeAddCustomView(^(LEECustomView *custom) {
//            UIView *containerView = [[UIView alloc] init];
//            UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
//            [refreshButton setTitle:@"再来一组" forState:UIControlStateNormal];
//            [refreshButton setTitleColor:RYBHEXCOLOR(0xffffff) forState:UIControlStateNormal];
//            refreshButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightLight];
//            refreshButton.layer.cornerRadius = 5;
//            refreshButton.layer.borderColor = RYBHEXCOLOR(0xffffff).CGColor;
//            refreshButton.layer.borderWidth = 1/[UIScreen mainScreen].scale;
//
//            UILabel *titleLabel = [[UILabel alloc] init];
//            titleLabel.text = @"选择一张预览图";
//            titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
//            titleLabel.textAlignment = NSTextAlignmentCenter;
//            [titleLabel setTextColor:RYBHEXCOLOR(0xffffff)];
//            [containerView addSubview:titleLabel];
//            [containerView addSubview:refreshButton];
//            refreshButton.frame = CGRectMake(RYB_SCREEN_WIDTH-75, 8.5, 60, 22);
//            titleLabel.frame = CGRectMake(0, 0, RYB_SCREEN_WIDTH-10, 35);
//            containerView.frame = CGRectMake(0, 0, RYB_SCREEN_WIDTH-10, 35);
//            custom.view = containerView;
//
//        })
        .LeeAddTitle(^(UILabel *label) {
            label.text = @"选择一张预览图";
            label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
            label.textColor = RYBHEXCOLOR(0xffffff);
        })
        .LeeItemInsets(UIEdgeInsetsMake(5, 5, 5, 5))
        .LeeAddCustomView(^(LEECustomView* custom) {
            float margin = 10;
            float buttonW = (RYB_SCREEN_WIDTH - margin * 3) / 2.5;
            float buttonH = buttonW / 3 * 4;
            UIScrollView* scrollView = [[UIScrollView alloc] init];
            scrollView.frame = CGRectMake(0, 0, RYB_SCREEN_WIDTH, buttonH);
            scrollView.contentSize = CGSizeMake(buttonW * arr.count + margin * (arr.count + 1), buttonH);
            scrollView.showsHorizontalScrollIndicator = NO;
            for (int i = 0; i < arr.count; i++) {
                float x = margin * (i + 1) + buttonW * i;
                UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setImage:[arr objectAtIndex:i] forState:UIControlStateNormal];
                button.frame = CGRectMake(x, 0, buttonW, buttonH);
                [scrollView addSubview:button];
                [button addBlockForControlEvents:UIControlEventTouchUpInside
                                           block:^(id _Nonnull sender) {
                                               if (block) {
                                                   block(arr[i]);
                                               }
                                           }];
            }
            custom.view = scrollView;
        })
        .LeeItemInsets(UIEdgeInsetsMake(10, 0, 0, 0))
        .LeeActionSheetBottomMargin(0.0f) // 设置底部距离屏幕的边距为0
        .LeeCornerRadius(0.0f) // 设置圆角曲率为0
        .LeeConfigMaxWidth(^CGFloat(LEEScreenOrientationType type) {
            // 这是最大宽度为屏幕宽度 (横屏和竖屏)
            return CGRectGetWidth([[UIScreen mainScreen] bounds]);
        })
        .LeeShadowOpacity(.1f)
        .LeeHeaderColor(RYBRGBA(0, 0, 0, 0.3))
        .LeeHeaderInsets(UIEdgeInsetsMake(12, 12, 12, 12))
        .LeeShow();
}

- (void)excuteFFMpegCommandStr:(NSString*)commandStr completion:(void (^)())completion
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadWillExit) name:NSThreadWillExitNotification object:nil];
    self.command_str = commandStr;
    self.completion = completion;
    [NSThread detachNewThreadSelector:@selector(performFFMpegCommandStr) toTarget:self withObject:nil];
}

- (void)performFFMpegCommandStr
{
    NSString* command_str = self.command_str;
    RYBLog(@"ffmpeg start:%@", command_str);
    NSArray* argv_array = [command_str componentsSeparatedByString:(@" ")];
    int argc = (int)argv_array.count;
    char** argv = (char**)malloc(sizeof(char*) * argc);
    for (int i = 0; i < argc; i++) {
        argv[i] = (char*)malloc(sizeof(char) * 1024);
        strcpy(argv[i], [[argv_array objectAtIndex:i] UTF8String]);
    }

    ffmpegmain(argc, argv);

    for (int i = 0; i < argc; i++)
        free(argv[i]);
    free(argv);
}

- (void)optimizeMV:(NSString*)path completion:(void (^)())completion
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadWillExit) name:NSThreadWillExitNotification object:nil];
    self.optimize_path = path;
    self.completion = completion;
    [NSThread detachNewThreadSelector:@selector(performOptimizeMV) toTarget:self withObject:nil];
}

- (void)performOptimizeMV
{
    NSString* inputPathString = self.optimize_path;
    NSString* outputPathStirng = [NSString stringWithFormat:@"%@/%@_compress.mp4", inputPathString.stringByDeletingLastPathComponent, inputPathString.lastPathComponent.stringByDeletingPathExtension];
    NSString* command_str = [NSString stringWithFormat:@"ffmpeg -i %@ -vcodec mpeg4 %@", inputPathString, outputPathStirng];
    RYBLog(@"ffmpeg start:%@", command_str);
    NSArray* argv_array = [command_str componentsSeparatedByString:(@" ")];
    int argc = (int)argv_array.count;
    char** argv = (char**)malloc(sizeof(char*) * argc);
    for (int i = 0; i < argc; i++) {
        argv[i] = (char*)malloc(sizeof(char) * 1024);
        strcpy(argv[i], [[argv_array objectAtIndex:i] UTF8String]);
    }

    ffmpegmain(argc, argv);

    for (int i = 0; i < argc; i++)
        free(argv[i]);
    free(argv);
}

- (void)threadWillExit
{
    if (self.completion) {
        self.completion();
    }
    RYBLogFunc();
}

- (void)publishMV:(BPStory*)mv withImage:(UIImage*)img completion:(void (^)())completion
{
    WeakSelf;
    if ([[DownloadTool shareTool] currentNetworkType] == NetworkTypeMobileNet) {
        [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert
                                         title:@"当前为移动网络，是否继续？"
                                           msg:@""
                                       options:@[ @"取消", @"继续" ]
                                      redIndex:-1
                                       handler:^(int index) {
                                           if (index == 1) {
                                               [weakSelf uploadMV:mv withImage:img completion:completion];
                                           }
                                       }];
    } else if ([[DownloadTool shareTool] currentNetworkType] == NetworkTypeNotReached) {
        [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert title:@"没有网络" msg:@"" options:@[ @"确定" ] redIndex:-1 handler:nil];
    } else {
        [weakSelf uploadMV:mv withImage:img completion:completion];
    }
}

- (void)uploadMV:(BPStory*)mv withImage:(UIImage*)img completion:(void (^)())completion
{
    WeakSelf;
    BPUser* user = [BPUser user];
    __block UILabel* titleLabel = nil;
    __block UILabel* contentLabel = nil;
    __block UIProgressView* progressView = [[UIProgressView alloc] init];
    progressView.frame = CGRectMake(0, 0, 210, 1);
    self.currentUploadCancel = NO;
    LEEAlertConfigModel* alert =
        [LEEAlert alert]
            .config
            .LeeAddTitle(^(UILabel* label) {
                label.text = @"正在发布动感MV(1/3)";
                titleLabel = label;
                label.font = [UIFont systemFontOfSize:17];
                label.textColor = FlatBlackDark;
            })
            .LeeAddContent(^(UILabel* label) {
                label.text = @"正在上传图片…";
                contentLabel = label;
                label.font = [UIFont systemFontOfSize:15];
                label.textColor = RYBHEXCOLOR(0x777777);
            })
            .LeeAddCustomView(^(LEECustomView* customView) {
                customView.view = progressView;
                progressView.progress = 0;
            })
            .LeeItemInsets(UIEdgeInsetsZero)
            .LeeAddAction(^(LEEAction* action) {
                action.title = @"取消";
                action.type = LEEActionTypeCancel;
                action.clickBlock = ^{
                    self.currentUploadCancel = YES;
                    [[BPRecordTool shareTool] cancelCurrentUpload];
                };
            })
            .LeeShow();

    NSString* filePath = [weakSelf getImagePath:img];
    NSString* url = [NSString stringWithFormat:@"api/fs/upload?token=%@", user.token];

    [IKHttpTool uploadFile:filePath
        filePostName:@"file"
        url:url
        params:@{ @"token" : user.token }
        ulprogress:^(float progress) {
            [[RYBTool shareTool] doInMainThread:^{
                progressView.progress = progress;
            }];
        }
        success:^(id json) {
            if ([json[@"code"] integerValue] == 1) {
                weakSelf.title_pic = [json valueForKeyPath:@"content.file"];
                titleLabel.text = @"正在发布动感MV(2/3)";
                contentLabel.text = @"正在上传MV…";
                progressView.progress = 0;
                NSString* mv_localpath = [NSString stringWithFormat:@"%@/Documents/anchor/mv/%@", NSHomeDirectory(), mv.media_path];
                if (![[NSFileManager defaultManager] fileExistsAtPath:mv_localpath]) {
                    mv_localpath = [NSString stringWithFormat:@"%@/tmp/%@",NSHomeDirectory(),mv.media_path];
                }
                if (self.currentUploadCancel) {
                    return;
                }
                [[BPRecordTool shareTool]
                    uploadFileToQiniu:mv_localpath
                    savePath:[NSString stringWithFormat:@"app/mv/%@", mv.media_path]
                    userToken:user.token
                    withProgress:^(NSString* savePath, float percent) {
                        [[RYBTool shareTool] doInMainThread:^{
                            progressView.progress = percent;
                        }];
                    }
                    Success:^(NSString* key) {
                        weakSelf.mv_path = key;
                        titleLabel.text = @"正在发布动感MV(3/3)";
                        contentLabel.text = @"正在提交MV…";
                        progressView.hidden = YES;
                        if (self.currentUploadCancel) {
                            return;
                        }
                        [IKHttpTool
                            postWithURL:@"api/v3/games/updateMv"
                            params:@{
                                @"title" : mv.title,
                                @"titlePic" : weakSelf.title_pic,
                                @"video" : key,
                                @"resId" : mv.media_info,
                                @"token" : user.token
                            }
                            success:^(id json) {
                                if ([json[@"code"] integerValue] == 1) {
                                    [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert title:@"提交MV成功" msg:@"" options:@[ @"确定" ] redIndex:-1 handler:nil];
                                } else {
                                    [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert title:@"提交MV失败" msg:@"" options:@[ @"确定" ] redIndex:-1 handler:nil];
                                }
                                [[NSFileManager defaultManager] removeItemAtPath:mv_localpath error:nil];
                                [[RYBDBTool shareTool] removeStory:mv];
                                if (completion) {
                                    completion();
                                }
                            }
                            failure:^(NSError* error) {
                                [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert title:@"网络原因：提交MV失败" msg:@"" options:@[ @"确定" ] redIndex:-1 handler:nil];
                            }];
                    }
                    failure:^(NSError* error) {
                        alert.LeeCloseComplete(^{
                            [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert title:@"上传MV失败" msg:@"" options:@[ @"确定" ] redIndex:-1 handler:nil];
                        });
                    }];

            } else if ([json[@"code"] integerValue] == 4004) {
                alert.LeeCloseComplete(^{
                    [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert title:@"登录状态失效" msg:@"" options:@[ @"确定" ] redIndex:-1 handler:nil];
                });
            } else {
                alert.LeeCloseComplete(^{
                    [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert title:@"上传预览图失败" msg:@"" options:@[ @"确定" ] redIndex:-1 handler:nil];
                });
            }
        }
        failure:^(NSError* error) {
            alert.LeeCloseComplete(^{
                [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert title:@"网络不太好" msg:@"" options:@[ @"确定" ] redIndex:-1 handler:nil];
            });
        }];
}

//照片获取本地路径转换
- (NSString*)getImagePath:(UIImage*)Image
{
    NSString* filePath = nil;
    NSData* data = nil;
    if (UIImagePNGRepresentation(Image) == nil) {
        data = UIImageJPEGRepresentation(Image, 1.0);
    } else {
        data = UIImagePNGRepresentation(Image);
    }

    //文件管理器
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if ([fileManager fileExistsAtPath:CachePathForUploadImage isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:CachePathForUploadImage withIntermediateDirectories:YES attributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] error:nil];
    }
    NSString* ImagePath = [NSString stringWithFormat:@"%@/cacheImage.png",CachePathForUploadImage];
    
    [fileManager createFileAtPath:ImagePath contents:data attributes:nil];
    
    //得到选择后沙盒中图片的完整路径
    return ImagePath;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
