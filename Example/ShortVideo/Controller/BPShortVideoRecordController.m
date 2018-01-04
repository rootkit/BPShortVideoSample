//
//  BPShortVideoRecordController.m
//  Zhudou
//
//  Created by zhudou on 2017/8/1.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPShortVideoRecordController.h"
#import "libksygpufilter.h"
#import "GPUImage.h"
#import "YFGIFImageView.h"
#import "BPStory.h"
#import "XMGLrcView.h"
//录音
#import "AERecorder.h"
#import "BPRecordTool.h"
#import "TheAmazingAudioEngine.h"
#import <Accelerate/Accelerate.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import "DGActivityIndicatorView.h"
#import <Masonry/Masonry.h>
#import "UIButton+BPImagePosition.h"
#import <UIImageView+WebCache.h>

#import "BPPowerMVPublishController.h"
#import <SSZipArchive/SSZipArchive.h>
#import <UIButton+WebCache.h>
#import "BPSceneSelectController.h"
#import "BPPowerMVTool.h"
#import "BPMVSticker.h"
#import "BPMVFaceSticker.h"

#import <iflyMSC/IFlyFaceSDK.h>
#import "IFlyFaceImage.h"
#import "IFlyFaceResultKeys.h"
#import "CalculatorTools.h"
#import "UIView+GXDevelop.h"
#import "CanvasView.h"

#import "UIButton+BPImagePosition.h"

#define videoRecordRealWidth 480
#define videoRecordRealHeight 640
#define sceneRecordWidth RYB_SCREEN_WIDTH
#define sceneRecordHeight RYB_SCREEN_WIDTH / 3 * 4
#define bottomHeight MAX((RYB_SCREEN_HEIGHT - RYB_SCREEN_WIDTH / 3 * 4), 141)

#define DownloadPathForMV [NSString stringWithFormat:@"%@/Documents/download/mv", NSHomeDirectory()]
#define CachePathForMV [NSString stringWithFormat:@"%@/Library/Caches/ZhudouMVCache", NSHomeDirectory()]
#define CacheRecordPathForMV [NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()]
#define OriginalSongPath @"export_original_song.m4a"
#define AccompanySongPath @"export_accompany_song.m4a"

@interface BPShortVideoRecordController () <GPUImageVideoCameraDelegate, UIScrollViewDelegate> {
    AEChannelGroupRef _group;
    GPUImageStillCamera* _videoCamera;
    GPUImageUIElement* _element;
    GPUImageView* _filterView;
    KSYBeautifyFaceFilter* _beatuifyFilter;
    GPUImageAlphaBlendFilter* _blendFilter;
    GPUImageCropFilter* _cropFilter;
    GPUImageMovieWriter* _movieWriter;
}
@property (weak, nonatomic) UIButton* reverseCameraButton;
@property (weak, nonatomic) UIButton* delayRecordButton;
@property (weak, nonatomic) UIView* recordCameraView;
@property (weak, nonatomic) UIButton* recordButton;
@property (weak, nonatomic) UIButton* stopRecordButton;
@property (weak, nonatomic) UIButton* takePhotoButton;
@property (weak, nonatomic) UIButton* modeSwitchButton;
@property (weak, nonatomic) UIButton* tipButton;
@property (nonatomic, weak) UIProgressView* progressView;
@property (nonatomic, strong) UIView* elementView;
@property (nonatomic, strong) UIView* elementFixedContainerView;

@property (nonatomic, strong) YFGIFImageView* headImageView;
@property (nonatomic, strong) YFGIFImageView* eyeImageView;
@property (nonatomic, strong) YFGIFImageView* noseImageView;
@property (nonatomic, strong) YFGIFImageView* mouthImageView;
@property (nonatomic, strong) BPMVFaceSticker* mouth_sticker;

@property (nonatomic, strong) DGActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) CIFaceFeature* faceFeature;
@property (nonatomic, retain) IFlyFaceDetector* ifly_faceDetector;
@property (nonatomic, strong) NSArray* faceInfos; // 人脸信息集 每个人脸的 rect 和特征点 信息
@property (nonatomic, strong) NSMutableArray<NSString*>* videoFilePathArray;
@property (nonatomic, strong) NSString* originFilePath;
@property (nonatomic, strong) NSString* currentFilePath;
@property (nonatomic, weak) XMGLrcView* lrcView;
@property (nonatomic, strong) CADisplayLink* lrcTimer;

//录音
@property (strong, nonatomic) AERecorder* aeRecorder;
@property (nonatomic, strong) AEAudioController* audioController;
@property (nonatomic, strong) AEAudioFilePlayer* audioBgMusicPlayer;
@property (nonatomic, strong) NSString* currentBgMusicFilePath;
@property (assign, nonatomic) NSTimeInterval currentBgMusicPlayTime;
@property (strong, nonatomic) NSTimer* timer;
@property (strong, nonatomic) NSTimer* progressTimer;
@property (assign, nonatomic) NSInteger left_count;
@property (weak, nonatomic) UILabel* left_count_lab;
@property (nonatomic, assign) BOOL isVideoRecording;

@property (nonatomic, strong) BPSceneSelectController* scene_select;
@property (nonatomic, weak) UIView* bottomBarView;

@end

@implementation BPShortVideoRecordController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;

    UIImageView* bgImageView = [[UIImageView alloc] init];

    [bgImageView sd_setImageWithURL:[NSURL URLWithString:self.mv_material.title_pic]];

    [self.view addSubview:bgImageView];

    bgImageView.frame = self.view.bounds;

    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [bgImageView addSubview:effectView];
    effectView.frame = self.view.bounds;

    UIView* recordCameraView = [[UIView alloc] init];
    recordCameraView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:recordCameraView];
    _recordCameraView = recordCameraView;
    recordCameraView.frame = self.view.bounds;

    [self configSubViews];
    [self chooseBgMusicAction:nil];
    [self loadLrc];
    [self showLoadingView];

    _ifly_faceDetector = [IFlyFaceDetector sharedInstance];
    [_ifly_faceDetector setParameter:@"1" forKey:@"detect"];
    [_ifly_faceDetector setParameter:@"1" forKey:@"align"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveAction) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveAction) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)showLoadingView
{
    WeakSelf;
    DGActivityIndicatorView* activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate tintColor:[UIColor whiteColor] size:40.0f];

    _activityIndicatorView = activityIndicatorView;

    [weakSelf.view addSubview:activityIndicatorView];
    _activityIndicatorView.backgroundColor = RYBRGBA(0, 0, 0, 0.7);
    _activityIndicatorView.frame = self.view.bounds;

    [activityIndicatorView startAnimating];
}

- (void)applicationWillResignActiveAction
{
    [_videoCamera pauseCameraCapture];
    if (self.isVideoRecording && _recordButton.selected) {
        [self recordAction:_recordButton];
    }
}
- (void)applicationDidBecomeActiveAction
{
    [_videoCamera resumeCameraCapture];
}
- (void)configSubViews
{

    _videoFilePathArray = [NSMutableArray array];
    //GPUImageView
    _videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    _videoCamera.delegate = self;
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;

    //filters
    _beatuifyFilter = [[KSYBeautifyFaceFilter alloc] init];
    [_beatuifyFilter setGrindRatio:1];
    [_beatuifyFilter setWhitenRatio:1];
    [_beatuifyFilter setRuddyRatio:1];
    [_beatuifyFilter forceProcessingAtSize:CGSizeMake(sceneRecordWidth, sceneRecordHeight)];
    [_videoCamera addTarget:_beatuifyFilter];

    _element = [[GPUImageUIElement alloc] initWithView:self.elementView];
    _blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    _blendFilter.mix = 1.0;
    [_blendFilter forceProcessingAtSize:CGSizeMake(sceneRecordWidth, sceneRecordHeight)];
    [_beatuifyFilter addTarget:_blendFilter];

    [_element forceProcessingAtSize:CGSizeMake(sceneRecordWidth, sceneRecordHeight)];
    [_element addTarget:_blendFilter];
    _filterView = [[GPUImageView alloc] init];
    _filterView.fillMode = kGPUImageFillModeStretch;
    [_recordCameraView addSubview:_filterView];

    [_filterView setFrame:CGRectMake(0, 0, RYB_SCREEN_WIDTH, RYB_SCREEN_WIDTH / 3 * 4)];
    __weak typeof(self) weakSelf = self;
    [_beatuifyFilter setFrameProcessingCompletionBlock:^(GPUImageOutput* output, CMTime time) {
        __strong typeof(self) strongSelf = weakSelf;
        //[output useNextFrameForImageCapture];
        [strongSelf needsUpdate];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_blendFilter addTarget:_filterView];
        [_videoCamera startCameraCapture];
        [_activityIndicatorView removeFromSuperview];
    });

    //topToolBar
    UIView* topBarView = [[UIView alloc] init];
    [self.recordCameraView addSubview:topBarView];
    [topBarView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(self.recordCameraView);
        make.left.equalTo(self.recordCameraView);
        make.right.equalTo(self.recordCameraView);
        make.height.equalTo([SDVersion deviceSize] == Screen5Dot8inch ? @114 : @80);
    }];

    UIImageView* fadeTopImageView = [[UIImageView alloc] initWithImage:[UIImage bp_imageNamed:@"fade_top"]];
    [topBarView addSubview:fadeTopImageView];
    fadeTopImageView.alpha = 0.7;
    [fadeTopImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(topBarView);
    }];

    UIView* topBarButtonsContainerView = [[UIView alloc] init];
    [topBarView addSubview:topBarButtonsContainerView];
    [topBarButtonsContainerView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(topBarView).insets(UIEdgeInsetsMake(30, 80, 10, 20));
    }];

    //退出按钮
    UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage bp_imageNamed:@"backImage"] forState:UIControlStateNormal];
    [closeButton addBlockForControlEvents:UIControlEventTouchUpInside
                                    block:^(id _Nonnull sender) {
                                        [[RYBTool shareTool]
                                            showAlertWithType:RYBAlertTypeAlert
                                                        title:@"确定放弃吗"
                                                          msg:@""
                                                      options:@[ @"取消", @"确定" ]
                                                     redIndex:-1
                                                      handler:^(int index) {
                                                          if (index == 1) {
                                                              [weakSelf removeLrcTimer];
                                                              if (weakSelf.aeRecorder) {
                                                                  [weakSelf pauseRecord];
                                                              }
                                                              [_progressTimer invalidate];
                                                              _progressTimer = nil;
                                                              [weakSelf.navigationController popViewControllerAnimated:YES];
                                                          }
                                                      }];
                                    }];
    [topBarView addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(topBarView).offset([SDVersion deviceSize] == Screen5Dot8inch ? 68 : 34);
        make.left.equalTo(topBarView);
        make.width.equalTo(@40);
    }];
    CALayer* line_layer = [CALayer layer];
    [line_layer setBackgroundColor:RYBRGBA(255, 255, 255, 0.3).CGColor];
    line_layer.frame = CGRectMake(0, [SDVersion deviceSize] == Screen5Dot8inch ? 114 : 80, RYB_SCREEN_WIDTH, 1 / [UIScreen mainScreen].scale);
    [topBarView.layer addSublayer:line_layer];

    //延迟拍摄
    UIButton* delayRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _delayRecordButton = delayRecordButton;
    [delayRecordButton setTitle:@"延迟拍摄" forState:UIControlStateNormal];
    [delayRecordButton setTitleColor:RYBHEXCOLOR(0xffffff) forState:UIControlStateNormal];
    delayRecordButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    [delayRecordButton setImage:[UIImage bp_imageNamed:@"happysing_recordmv_icon_time"] forState:UIControlStateNormal];
    [delayRecordButton setImagePosition:BPImagePositionTop spacing:5];
    [delayRecordButton addBlockForControlEvents:UIControlEventTouchUpInside
                                          block:^(id _Nonnull sender) {
                                              [weakSelf delayRecordAction:sender];
                                          }];
    [topBarButtonsContainerView addSubview:delayRecordButton];
    [delayRecordButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(closeButton);
        make.left.equalTo(topBarButtonsContainerView);
        make.width.equalTo(topBarButtonsContainerView).multipliedBy(0.33);
        make.bottom.equalTo(closeButton);
    }];

    //拍照按钮
    UIButton* takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _takePhotoButton = takePhotoButton;
    [takePhotoButton setTitle:@"拍照" forState:UIControlStateNormal];
    [takePhotoButton setImage:[UIImage bp_imageNamed:@"happysing_recordmv_icon_takephoto"] forState:UIControlStateNormal];
    [takePhotoButton setTitleColor:RYBHEXCOLOR(0xffffff) forState:UIControlStateNormal];
    takePhotoButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    [takePhotoButton setImagePosition:BPImagePositionTop spacing:5];
    [takePhotoButton addBlockForControlEvents:UIControlEventTouchUpInside
                                        block:^(id _Nonnull sender) {
                                            [weakSelf takePhotoAction:sender];
                                        }];
    [topBarButtonsContainerView addSubview:takePhotoButton];
    [takePhotoButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerY.equalTo(delayRecordButton);
        make.left.equalTo(delayRecordButton.mas_right);
        make.width.equalTo(delayRecordButton);
    }];

    //翻转
    UIButton* reverseCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _reverseCameraButton = reverseCameraButton;
    [reverseCameraButton setTitle:@"翻转" forState:UIControlStateNormal];
    [reverseCameraButton setTitleColor:RYBHEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [reverseCameraButton setImage:[UIImage bp_imageNamed:@"happysing_recordmv_icon_turn"] forState:UIControlStateNormal];
    reverseCameraButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    [reverseCameraButton setImagePosition:BPImagePositionTop spacing:5];
    [reverseCameraButton addBlockForControlEvents:UIControlEventTouchUpInside
                                            block:^(id _Nonnull sender) {
                                                [weakSelf reverseCameraAction:sender];
                                            }];
    [topBarButtonsContainerView addSubview:reverseCameraButton];
    [reverseCameraButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(delayRecordButton);
        make.left.equalTo(takePhotoButton.mas_right);
        make.width.equalTo(delayRecordButton);
        make.bottom.equalTo(delayRecordButton);
    }];

    UIImageView* fadeBottomImageView = [[UIImageView alloc] initWithImage:[UIImage bp_imageNamed:@"fade_top"]];
    [self.recordCameraView addSubview:fadeBottomImageView];
    fadeBottomImageView.alpha = 0.7;

    //4 inch 最小高度141
    if (RYB_SCREEN_HEIGHT - RYB_SCREEN_WIDTH / 3 * 4 < 140) {
        [fadeBottomImageView mas_makeConstraints:^(MASConstraintMaker* make) {
            make.left.equalTo(self.recordCameraView);
            make.right.equalTo(self.recordCameraView);
            make.bottom.equalTo(self.recordCameraView);
            make.height.equalTo(@(141));
        }];
    } else {
        [fadeBottomImageView mas_makeConstraints:^(MASConstraintMaker* make) {
            make.left.equalTo(self.recordCameraView);
            make.top.equalTo(_filterView.mas_bottom);
            make.right.equalTo(self.recordCameraView);
            make.bottom.equalTo(self.recordCameraView);
        }];
    }

    UIView* bottomBarView = [[UIView alloc] init];
    _bottomBarView = bottomBarView;
    bottomBarView.backgroundColor = [UIColor clearColor];
    [self.recordCameraView addSubview:bottomBarView];
    [bottomBarView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(fadeBottomImageView);
    }];

    UIProgressView* progressView = [[UIProgressView alloc] init];
    _progressView = progressView;
    [self.recordCameraView addSubview:progressView];
    progressView.progress = 0;
    progressView.hidden = YES;
    [progressView setTrackTintColor:RYBRGBA(0, 0, 0, 0.2)];
    [progressView setProgressTintColor:RYBBASECOLORA(0.7)];
    [progressView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.bottom.equalTo(bottomBarView.mas_top).offset(5);
        make.left.equalTo(topBarView);
        make.right.equalTo(topBarView);
        make.height.equalTo(@5);
    }];

    //recordButton
    UIButton* recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordButton = recordButton;
    [recordButton setImage:[UIImage bp_imageNamed:@"happysing_recondmv_icon_shot"] forState:UIControlStateNormal];
    [recordButton setImage:[UIImage bp_imageNamed:@"happysing_recondmv_icon_stopshot"] forState:UIControlStateSelected];
    [bottomBarView addSubview:recordButton];
    [recordButton addBlockForControlEvents:UIControlEventTouchUpInside
                                     block:^(id _Nonnull sender) {
                                         [weakSelf recordAction:sender];
                                     }];
    [recordButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.center.equalTo(bottomBarView);
    }];

    //模式切换按钮
    UIButton* modeSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _modeSwitchButton = modeSwitchButton;
    [modeSwitchButton setTitle:@"原唱" forState:UIControlStateNormal];
    [modeSwitchButton setTitle:@"伴唱" forState:UIControlStateSelected];
    [modeSwitchButton setImage:[UIImage bp_imageNamed:@"coolidit_icon_accompany"] forState:UIControlStateNormal];
    [modeSwitchButton setTitleColor:RYBHEXCOLOR(0xffffff) forState:UIControlStateNormal];
    modeSwitchButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    [modeSwitchButton setImagePosition:BPImagePositionTop spacing:5];
    [modeSwitchButton addBlockForControlEvents:UIControlEventTouchUpInside
                                         block:^(id _Nonnull sender) {
                                             [weakSelf modeSwitchAction:sender];
                                         }];
    [bottomBarView addSubview:modeSwitchButton];
    [modeSwitchButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerY.equalTo(recordButton);
        make.right.equalTo(recordButton.mas_left).offset(-50);
    }];

    //完成录制按钮
    UIButton* stopRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _stopRecordButton = stopRecordButton;
    [stopRecordButton setTitle:@"场景" forState:UIControlStateNormal];
    [stopRecordButton setTitleColor:RYBHEXCOLOR(0xffffff) forState:UIControlStateNormal];
    [stopRecordButton setImage:[UIImage bp_imageNamed:@"happysing_recordmv_icon_scence"] forState:UIControlStateNormal];
    stopRecordButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    [stopRecordButton setImagePosition:BPImagePositionTop spacing:5];
    [stopRecordButton addBlockForControlEvents:UIControlEventTouchUpInside
                                         block:^(id _Nonnull sender) {
                                             [weakSelf showSceneSelectView];
                                         }];
    [bottomBarView addSubview:stopRecordButton];
    [stopRecordButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.centerY.equalTo(recordButton);
        make.left.equalTo(recordButton.mas_right).offset(50);
    }];

    //self.stopRecordButton.enabled = NO;

    //lrcView
    XMGLrcView* lrcView = [[XMGLrcView alloc] init];
    _lrcView = lrcView;
    _lrcView.contentSize = CGSizeMake(RYB_SCREEN_WIDTH * 2, 0);
    _lrcView.showsVerticalScrollIndicator = NO;
    _lrcView.showsHorizontalScrollIndicator = NO;
    _lrcView.contentOffset = CGPointMake(RYB_SCREEN_WIDTH, 0);
    _lrcView.scrollEnabled = YES;
    _lrcView.userInteractionEnabled = YES;
    _lrcView.pagingEnabled = YES;
    self.lrcView.rowHeight = 38;
    self.lrcView.normalFontSize = 18;
    self.lrcView.selectedFontSize = 22;
    self.lrcView.delegate = self;
    [self.recordCameraView addSubview:lrcView];

    [lrcView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.top.equalTo(topBarView.mas_bottom);
        make.left.right.equalTo(_recordCameraView);
        make.bottom.equalTo(bottomBarView.mas_top);
    }];

    UIButton* tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tipButton setImage:[UIImage bp_imageNamed:@"happysing_recordmv_icon_more"] forState:UIControlStateNormal];
    [tipButton setTitle:@"右滑隐藏歌词" forState:UIControlStateNormal];
    [tipButton.titleLabel setFont:[UIFont systemFontOfSize:12 weight:UIFontWeightLight]];
    [tipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tipButton.frame = CGRectMake(RYB_SCREEN_WIDTH - 105, 140, 235 / 2.0, 50 / 2.0);
    tipButton.backgroundColor = RYBRGBA(0, 0, 0, 0.4);
    tipButton.layer.cornerRadius = 12.5;
    tipButton.clipsToBounds = YES;
    [tipButton setImagePosition:BPImagePositionRight spacing:2];
    [self.recordCameraView addSubview:tipButton];
    self.tipButton = tipButton;

    self.automaticallyAdjustsScrollViewInsets = NO;

    if (@available(iOS 11, *)) {
        self.lrcView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    WeakSelf;
    if (scrollView == weakSelf.lrcView) {
        CGPoint offset = scrollView.contentOffset;
        CGFloat offsetRatio = offset.x / scrollView.bounds.size.width;
        weakSelf.tipButton.alpha = offsetRatio;
    }
}

- (void)loadLrc
{
    WeakSelf;
    if (!weakSelf.mv_material) {
        return;
    }
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", DownloadPathForMV, weakSelf.mv_material.lrc_path.lastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        weakSelf.lrcView.lrcname = filePath;
        [weakSelf addLrcTimer];
    } else {
        if (!weakSelf.mv_material.lrc_path || weakSelf.mv_material.lrc_path.length == 0) {
            weakSelf.lrcView.lrcname = @"null";
            return;
        }
    }
}
- (void)addLrcTimer
{
    WeakSelf;
    [weakSelf.lrcTimer removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [weakSelf.lrcTimer invalidate];
    weakSelf.lrcTimer = [CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(updateLrc)];
    [weakSelf.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)updateLrc
{
    self.lrcView.currentTime = _audioBgMusicPlayer.currentTime;
}

- (void)removeLrcTimer
{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}

- (void)needsUpdate
{
    [_element update];
}

- (CGFloat)rotateFromFaceFeature:(CIFaceFeature*)faceFeature
{
    CGPoint left_eye_position = faceFeature.leftEyePosition;
    CGPoint right_eye_position = faceFeature.rightEyePosition;
    CGFloat rotate = 0;
    if (_videoCamera.inputCamera.position == AVCaptureDevicePositionFront) {
        rotate = atan2(left_eye_position.y - right_eye_position.y, left_eye_position.x - right_eye_position.x);
    } else {
        rotate = atan2(right_eye_position.y - left_eye_position.y, right_eye_position.x - left_eye_position.x);
    }
    return rotate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //科大讯飞人脸识别
    IFlyFaceImage* faceImage = [self faceImageFromSampleBuffer:sampleBuffer];
    [self onOutputFaceImage:faceImage];
    faceImage = nil;
}

- (IFlyFaceImage*)faceImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{

    //获取灰度图像数据
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);

    uint8_t* lumaBuffer = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);

    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);

    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();

    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, 0);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    IFlyFaceDirectionType faceOrientation = [self faceImageOrientation];

    IFlyFaceImage* faceImage = [[IFlyFaceImage alloc] init];
    if (!faceImage) {
        return nil;
    }

    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);

    faceImage.data = (__bridge_transfer NSData*)CGDataProviderCopyData(provider);
    faceImage.width = width;
    faceImage.height = height;
    faceImage.direction = faceOrientation;

    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);

    return faceImage;
}
- (IFlyFaceDirectionType)faceImageOrientation
{

    IFlyFaceDirectionType faceOrientation = IFlyFaceDirectionTypeLeft;
    BOOL isFrontCamera = (_videoCamera.inputCamera.position == AVCaptureDevicePositionFront);
    switch (self.interfaceOrientation) {
    case UIDeviceOrientationPortrait: { //
        faceOrientation = IFlyFaceDirectionTypeLeft;
    } break;
    case UIDeviceOrientationPortraitUpsideDown: {
        faceOrientation = IFlyFaceDirectionTypeRight;
    } break;
    case UIDeviceOrientationLandscapeRight: {
        faceOrientation = isFrontCamera ? IFlyFaceDirectionTypeUp : IFlyFaceDirectionTypeDown;
    } break;
    default: { //
        faceOrientation = isFrontCamera ? IFlyFaceDirectionTypeDown : IFlyFaceDirectionTypeUp;
    }

    break;
    }

    return faceOrientation;
}
- (void)onOutputFaceImage:(IFlyFaceImage*)faceImg
{

    NSString* strResult = [self.ifly_faceDetector trackFrame:faceImg.data withWidth:faceImg.width height:faceImg.height direction:(int)faceImg.direction];
    //NSLog(@"result:%@",strResult);

    //此处清理图片数据，以防止因为不必要的图片数据的反复传递造成的内存卷积占用。
    faceImg.data = nil;

    NSMethodSignature* sig = [self methodSignatureForSelector:@selector(praseTrackResult:OrignImage:)];
    if (!sig)
        return;
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self];
    [invocation setSelector:@selector(praseTrackResult:OrignImage:)];
    [invocation setArgument:&strResult atIndex:2];
    [invocation setArgument:&faceImg atIndex:3];
    [invocation retainArguments];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
    faceImg = nil;
}

- (void)praseTrackResult:(NSString*)result OrignImage:(IFlyFaceImage*)faceImg
{

    if (!result) {
        return;
    }

    @try {
        NSError* error;
        NSData* resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* faceDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        resultData = nil;
        if (!faceDic) {
            return;
        }

        NSString* faceRet = [faceDic objectForKey:KCIFlyFaceResultRet];
        NSArray* faceArray = [faceDic objectForKey:KCIFlyFaceResultFace];
        faceDic = nil;

        int ret = 0;
        if (faceRet) {
            ret = [faceRet intValue];
        }
        //没有检测到人脸或发生错误
        if (ret || !faceArray || [faceArray count] < 1) {
            if (!self.faceInfos) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(hideFace) withObject:nil afterDelay:0.1];

            });
            return;
        }

        //检测到人脸

        NSMutableArray* arrPersons = [NSMutableArray array];

        for (id faceInArr in faceArray) {

            if (faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]) {

                NSDictionary* positionDic = [faceInArr objectForKey:KCIFlyFaceResultPosition];
                NSString* rectString = [self praseDetect:positionDic OrignImage:faceImg];
                positionDic = nil;

                NSDictionary* landmarkDic = [faceInArr objectForKey:KCIFlyFaceResultLandmark];
                NSMutableDictionary* strPoints = [self praseAlign:landmarkDic OrignImage:faceImg];
                landmarkDic = nil;

                NSMutableDictionary* dicPerson = [NSMutableDictionary dictionary];
                if (rectString) {
                    [dicPerson setObject:rectString forKey:RECT_KEY];
                }
                if (strPoints) {
                    [dicPerson setObject:strPoints forKey:POINTS_KEY];
                }

                strPoints = nil;

                [dicPerson setObject:@"0" forKey:RECT_ORI];
                [arrPersons addObject:dicPerson];

                dicPerson = nil;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFace) object:nil];
            //            [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
            self.faceInfos = arrPersons;

            [self reSetFaceUI];
            //            [self needUpdateFace];
        });

        faceArray = nil;
    }
    @catch (NSException* exception) {
        NSLog(@"prase exception:%@", exception.name);
    }
    @finally {
    }
}
- (void)reSetFaceUI
{
    if (self.faceInfos.count < 1) {
        //self.eyeImageView.hidden = YES;
        self.eyeImageView.transform = CGAffineTransformIdentity;
        [self.eyeImageView stopGIF];
        self.eyeImageView.hidden = YES;
        self.headImageView.transform = CGAffineTransformIdentity;
        [self.headImageView stopGIF];
        self.headImageView.hidden = YES;
        self.noseImageView.transform = CGAffineTransformIdentity;
        [self.noseImageView stopGIF];
        self.noseImageView.hidden = YES;
        self.mouthImageView.transform = CGAffineTransformIdentity;
        [self.mouthImageView stopGIF];
        self.mouthImageView.hidden = YES;
        return;
    }
    //    self.eyeImageView.gxBwidth = width *3;
    //    self.eyeImageView.gxBheight = height*5;
    //    self.eyeImageView.center = mouth_middle;

    //鼻子 绿
    NSDictionary* facedict = self.faceInfos[0];
    //                NSString *faceRectStr = [facedict objectForKey:RECT_KEY];
    NSDictionary* facePointDict = [facedict objectForKey:POINTS_KEY];

    CGFloat rotate = [self rotateFromDict:facePointDict];

    //                CGRect faceRect = CGRectFromString(faceRectStr);
    //    CGPoint nose_middle = CGPointFromString(facePointDict[@"nose_top"]);
    //    CGPoint nose_left_corner = CGPointFromString(facePointDict[@"nose_left"]);
    //    CGPoint nose_right_corner = CGPointFromString(facePointDict[@"nose_right"]);
    //    CGPoint nose_upper_lip_top = CGPointFromString(facePointDict[@"nose_top"]);
    //    CGPoint nose_lower_lip_bottom = CGPointFromString(facePointDict[@"nose_bottom"]);
    //    CGFloat nose_width = sqrt(pow((nose_left_corner.x - nose_right_corner.x), 2) + pow((nose_left_corner.y - nose_right_corner.y), 2));
    //    ;
    //    CGFloat nose_height = sqrt(pow((nose_upper_lip_top.x - nose_lower_lip_bottom.x), 2) + pow((nose_upper_lip_top.y - nose_lower_lip_bottom.y), 2));
    //    ;
    //
    //    CGRect nose_rect = CGRectMake(nose_middle.x - nose_width * 3.0 / 2, nose_middle.y - nose_height * 5.0 / 2, nose_width * 3, nose_height * 5);

    //头部 红
    CGPoint eyebow_left_point = CGPointFromString(facePointDict[@"left_eyebrow_left_corner"]);
    CGPoint eyebow_right_point = CGPointFromString(facePointDict[@"right_eyebrow_right_corner"]);
    CGFloat eyebow_width = sqrt(pow((eyebow_left_point.x - eyebow_right_point.x), 2) + pow((eyebow_left_point.y - eyebow_right_point.y), 2));
    eyebow_width = eyebow_width * 2;
    CGFloat eyebow_middle_y = (eyebow_left_point.y + eyebow_right_point.y) / 2;
    CGFloat eyebow_middle_x = (eyebow_left_point.x + eyebow_right_point.x) / 2;
    CGFloat head_height = eyebow_width * 0.7;

    CGRect head_rect = CGRectMake(eyebow_middle_x - eyebow_width / 2, eyebow_middle_y - head_height, eyebow_width, head_height);
    self.headImageView.frame = head_rect;
    [self.headImageView startGIF];
    self.headImageView.hidden = NO;
    self.headImageView.transform = CGAffineTransformMakeRotation(rotate);

    CGPoint nose_left = CGPointFromString(facePointDict[@"nose_left"]);
    CGPoint nose_right = CGPointFromString(facePointDict[@"nose_right"]);
    CGPoint nose_top = CGPointFromString(facePointDict[@"nose_top"]);
    CGPoint nose_bottom = CGPointFromString(facePointDict[@"nose_bottom"]);
    CGFloat nose_width = sqrt(pow((nose_left.x - nose_right.x), 2) + pow((nose_left.y - nose_right.y), 2));
    CGFloat nose_height = sqrt(pow((nose_top.x - nose_bottom.x), 2) + pow((nose_top.y - nose_bottom.y), 2));
    CGFloat nose_middle_x = (nose_left.x + nose_right.x) / 2;
    CGFloat nose_middle_y = (nose_top.y + nose_bottom.y) / 2;
    CGRect nose_rect = CGRectMake(nose_middle_x - eyebow_width / 2, nose_middle_y - nose_height * 0.5, eyebow_width, nose_height);
    [self.noseImageView setFrame:nose_rect];
    self.noseImageView.transform = CGAffineTransformMakeRotation(rotate);
    //                imageView.frame = [(NSValue *)weakSelf.faceBoundArr[idx] CGRectValue] ;
    self.noseImageView.hidden = NO;
    [self.noseImageView startGIF];

    //眼睛 蓝
    CGPoint eye_left_point = CGPointFromString(facePointDict[@"left_eye_left_corner"]);
    CGPoint eye_right_point = CGPointFromString(facePointDict[@"right_eye_right_corner"]);
    CGFloat eye_width = sqrt(pow((eye_left_point.x - eye_right_point.x), 2) + pow((eye_left_point.y - eye_right_point.y), 2));
    eye_width = eye_width * 1.5;
    CGFloat eye_middle_y = (eye_left_point.y + eye_right_point.y) / 2;
    CGFloat eye_middle_x = (eye_left_point.x + eye_right_point.x) / 2;
    CGFloat eye_height = 100;
    CGRect eye_rect = CGRectMake(eye_middle_x - eye_width / 2, eye_middle_y - eye_height / 2, eye_width, eye_height);
    self.eyeImageView.frame = eye_rect;
    [self.eyeImageView startGIF];
    self.eyeImageView.hidden = NO;
    self.eyeImageView.transform = CGAffineTransformMakeRotation(rotate);

    //嘴巴

    CGPoint mouth_left_corner = CGPointFromString(facePointDict[@"mouth_left_corner"]);
    CGPoint mouth_right_corner = CGPointFromString(facePointDict[@"mouth_right_corner"]);
    CGPoint mouth_middle = CGPointFromString(facePointDict[@"mouth_lower_lip_bottom"]);
    CGFloat mouth_width = sqrt(pow((mouth_left_corner.x - mouth_right_corner.x), 2) + pow((mouth_left_corner.y - mouth_right_corner.y), 2));
    mouth_width = mouth_width * 2;
    CGFloat mouth_height = mouth_width / self.mouth_sticker.width * self.mouth_sticker.height;
    [self.mouthImageView startGIF];
    self.mouthImageView.hidden = NO;
    CGRect mouth_rect = CGRectMake(mouth_middle.x - self.mouth_sticker.anchorpointX * mouth_width, mouth_middle.y - self.mouth_sticker.anchorpointY * mouth_height, mouth_width, mouth_height);
    self.mouthImageView.frame = mouth_rect;
    self.mouthImageView.transform = CGAffineTransformMakeRotation(rotate);
}

- (void)hideFace
{
    self.faceInfos = nil;
    //self.eyeImageView.hidden = YES;
    [self reSetFaceUI];
}
- (CGFloat)rotateFromDict:(NSDictionary*)facePointDict
{
    CGPoint left_eye_left_corner = CGPointFromString(facePointDict[@"left_eye_left_corner"]);
    CGPoint right_eye_right_corner = CGPointFromString(facePointDict[@"right_eye_right_corner"]);
    //    CGPoint nose_top = CGPointFromString(facePointDict[@"nose_top"]);
    //    CGPoint eyeCenter = CGPointMake((left_eye_left_corner.x + right_eye_right_corner.x) / 2., (left_eye_left_corner.y + right_eye_right_corner.y) / 2.);
    CGPoint point0 = left_eye_left_corner;
    CGPoint point1 = right_eye_right_corner;
    CGFloat rotate = 0;
    if (_videoCamera.inputCamera.position == AVCaptureDevicePositionFront) {
        rotate = atan2(point0.y - point1.y, point0.x - point1.x);

    } else {
        rotate = atan2(point1.y - point0.y, point1.x - point0.x);
    }
    return rotate;
}

- (NSString*)praseDetect:(NSDictionary*)positionDic OrignImage:(IFlyFaceImage*)faceImg
{

    if (!positionDic) {
        return nil;
    }

    // 判断摄像头方向
    BOOL isFrontCamera = (_videoCamera.inputCamera.position == AVCaptureDevicePositionFront);

    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat width = self.view.gxWidth;
    CGFloat widthScaleBy = width / faceImg.height;
    CGFloat heightScaleBy = width / 0.75 / faceImg.width;

    CGFloat bottom = [[positionDic objectForKey:KCIFlyFaceResultBottom] floatValue];
    CGFloat top = [[positionDic objectForKey:KCIFlyFaceResultTop] floatValue];
    CGFloat left = [[positionDic objectForKey:KCIFlyFaceResultLeft] floatValue];
    CGFloat right = [[positionDic objectForKey:KCIFlyFaceResultRight] floatValue];

    float cx = (left + right) / 2;
    float cy = (top + bottom) / 2;
    float w = right - left;
    float h = bottom - top;

    float ncx = cy;
    float ncy = cx;

    CGRect rectFace = CGRectMake(ncx - w / 2, ncy - w / 2, w, h);

    if (!isFrontCamera) {
        rectFace = rSwap(rectFace);
        rectFace = rRotate90(rectFace, faceImg.height, faceImg.width);
    }

    rectFace = rScale(rectFace, widthScaleBy, heightScaleBy);

    //    if (_scale == 1) {
    //        rectFace =
    //    }

    return NSStringFromCGRect(rectFace);
}

- (NSMutableDictionary*)praseAlign:(NSDictionary*)landmarkDic OrignImage:(IFlyFaceImage*)faceImg
{
    if (!landmarkDic) {
        return nil;
    }

    // 判断摄像头方向
    BOOL isFrontCamera = (_videoCamera.inputCamera.position == AVCaptureDevicePositionFront);

    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat width = self.view.gxWidth;
    CGFloat widthScaleBy = width / faceImg.height;
    CGFloat heightScaleBy = width / 0.75 / faceImg.width;

    NSMutableDictionary* arrStrPoints = [NSMutableDictionary dictionary];
    NSEnumerator* keys = [landmarkDic keyEnumerator];
    for (id key in keys) {
        id attr = [landmarkDic objectForKey:key];
        if (attr && [attr isKindOfClass:[NSDictionary class]]) {

            id attr = [landmarkDic objectForKey:key];
            CGFloat x = [[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
            CGFloat y = [[attr objectForKey:KCIFlyFaceResultPointY] floatValue];

            CGPoint p = CGPointMake(y, x);

            if (!isFrontCamera) {
                p = pSwap(p);
                p = pRotate90(p, faceImg.height, faceImg.width);
            }

            p = pScale(p, widthScaleBy, heightScaleBy);

            //            NSDictionary *dict = @{key : NSStringFromCGPoint(p)};
            //            [arrStrPoints addObject:dict];
            [arrStrPoints setObject:NSStringFromCGPoint(p) forKey:key];
            //            dict = nil;
        }
    }
    return arrStrPoints;
}

- (void)showSceneSelectView
{
    WeakSelf;
    CGFloat scene_height = bottomHeight;
    [LEEAlert actionsheet]
        .config
        .LeeAddCustomView(^(LEECustomView* custom) {
            BPSceneSelectController* scene_select = [[BPSceneSelectController alloc] init];
            _scene_select = scene_select;
            [_scene_select setSelectBlock:^(BPMVScene* scene) {
                [weakSelf unzipScene:scene];
            }];
            UIView* scene_view = scene_select.view;
            scene_view.frame = CGRectMake(0, 0, RYB_SCREEN_WIDTH, scene_height);
            [scene_view mas_remakeConstraints:^(MASConstraintMaker* make) {
                make.height.equalTo(@(scene_height));
                make.width.equalTo(@(RYB_SCREEN_WIDTH));
            }];
            custom.view = scene_view;
            custom.view.backgroundColor = [UIColor clearColor];
        })
        .LeeItemInsets(UIEdgeInsetsZero)
        .LeeCornerRadius(0.0f) // 设置圆角曲率为0
        .LeeConfigMaxWidth(^CGFloat(LEEScreenOrientationType type) {
            // 这是最大宽度为屏幕宽度 (横屏和竖屏)
            return CGRectGetWidth([[UIScreen mainScreen] bounds]);
        })
        .LeeShadowOpacity(.0f)
        .LeeClickBackgroundClose(YES)
        .LeeHeaderColor([UIColor clearColor])
        .LeeActionSheetBottomMargin(0)
        .LeeQueue(YES)
        .LeeContinueQueueDisplay(YES)
        .LeeCloseComplete(^{
            [_scene_select.view removeAllSubviews];
            [_scene_select.view removeFromSuperview];
            _scene_select = nil;
            _bottomBarView.hidden = NO;
        })
        .LeeHeaderInsets(UIEdgeInsetsZero)
        .LeeBackgroundStyleTranslucent(.0f)
        .LeeShow();
    _bottomBarView.hidden = YES;
}

- (void)unzipScene:(BPMVScene*)scene
{
    WeakSelf;
    if (scene.is_empty) {
        [_elementFixedContainerView removeAllSubviews];
        return;
    }
    [weakSelf showLoadingView];
    NSString* scene_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene.zip_path_ios.lastPathComponent];
    NSString* dest_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene_path.lastPathComponent.stringByDeletingPathExtension];
    NSString* info_path = [NSString stringWithFormat:@"%@/info.json", dest_path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:info_path]) {
        [weakSelf loadScene:scene];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SSZipArchive unzipFileAtPath:scene_path
            toDestination:dest_path
            progressHandler:^(NSString* _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
            }
            completionHandler:^(NSString* _Nonnull path, BOOL succeeded, NSError* _Nullable error) {
                if (succeeded) {
                    [[RYBTool shareTool] doInMainThread:^{
                        [weakSelf loadScene:scene];
                    }];
                } else {
                    [[RYBTool shareTool] doInMainThread:^{
                        [_activityIndicatorView removeFromSuperview];
                        [[RYBTool shareTool] showHUD:hudImageTypeFailed text:@"加载场景出错" detailText:nil inView:nil];
                    }];
                }
            }];
    });
}

- (void)loadScene:(BPMVScene*)scene
{
    NSString* dest_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene.zip_path_ios.lastPathComponent.stringByDeletingPathExtension];

    NSString* jsonString = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/info.json", dest_path] encoding:NSUTF8StringEncoding error:nil];

    NSError* err;

    NSDictionary* json_dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&err];

    if (err) {
        return;
    }

    NSArray* stickers = [json_dict objectForKey:@"fixed_stickers"];

    [_elementFixedContainerView removeAllSubviews];

    NSArray* face_stickers = [json_dict objectForKey:@"face_stickers"];
    for (NSDictionary* dict in face_stickers) {
        BPMVFaceSticker* sticker = [BPMVFaceSticker bp_modelWithDict:dict];

        YFGIFImageView* faceView = [[YFGIFImageView alloc] initWithFrame:CGRectMake(0, 0, sticker.width, sticker.height)];
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:sticker.frame_count];
        NSString* img_path_format = [NSString stringWithFormat:@"%@/%@/%@.png", dest_path, sticker.sticker_directory, sticker.filename_format];
        for (NSInteger i = 1; i < sticker.frame_count + 1; i++) {
            NSString* img_path = [NSString stringWithFormat:img_path_format, i];
            [arr addObject:[[UIImage alloc] initWithContentsOfFile:img_path]];
        }
        faceView.gifImages = arr;
        faceView.gifImagesTime = sticker.animation_duration / sticker.frame_count;
        //faceView.backgroundColor = RYBRGBA(arc4random() % 250, arc4random() % 250, arc4random() % 250, 0.2);
        faceView.contentMode = UIViewContentModeScaleAspectFit;
        [_elementFixedContainerView addSubview:faceView];
        if (sticker.faceType == MVStickerFaceTypeEye) {
            self.eyeImageView = faceView;
        } else if (sticker.faceType == MVStickerFaceTypeHead) {
            self.headImageView = faceView;
        } else if (sticker.faceType == MVStickerFaceTypeNose) {
            self.noseImageView = faceView;
        } else if (sticker.faceType == MVStickerFaceTypeMouth) {
            self.mouthImageView = faceView;
            self.mouth_sticker = sticker;
        }
    }

    for (NSDictionary* dict in stickers) {

        BPMVSticker* sticker = [BPMVSticker bp_modelWithDict:dict];
        float scale = 480.0 / 540;
        float display_width = sticker.width * scale;
        float display_height = sticker.height * scale;
        if (sticker.display_width > 0 && sticker.display_height == 0) {
            display_width = sticker.display_width * sceneRecordWidth;
            display_height = sticker.height / sticker.width * display_width;
        }
        if (sticker.display_height > 0 && sticker.display_width == 0) {
            display_height = sticker.display_height * sceneRecordHeight;
            display_width = sticker.width / sticker.height * display_height;
        }
        if (sticker.display_height > 0 && sticker.display_width > 0) {
            display_height = sticker.display_height * sceneRecordHeight;
            display_width = sticker.display_width * sceneRecordWidth;
        }
        sticker.display_width = display_width;
        sticker.display_height = display_height;
        sticker.positionX = sceneRecordWidth * sticker.positionX - sticker.anchorpointX * sticker.display_width;
        sticker.positionY = sceneRecordHeight * sticker.positionY - sticker.anchorpointY * sticker.display_height;

        YFGIFImageView* gifView = [[YFGIFImageView alloc] initWithFrame:CGRectMake(sticker.positionX, sticker.positionY, sticker.display_width, sticker.display_height)];
        gifView.contentMode = UIViewContentModeScaleAspectFit;
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:sticker.frame_count];
        NSString* img_path_format = [NSString stringWithFormat:@"%@/%@/%@.png", dest_path, sticker.sticker_directory, sticker.filename_format];
        for (int i = 1; i < sticker.frame_count + 1; i++) {
            NSString* img_path = [NSString stringWithFormat:img_path_format, i];
            [arr addObject:[[UIImage alloc] initWithContentsOfFile:img_path]];
        }
        gifView.gifImages = arr;
        gifView.gifImagesTime = sticker.animation_duration / sticker.frame_count;
        [gifView startGIFWithRunLoopMode:NSRunLoopCommonModes
                         andImageDidLoad:^(CGSize imageSize){
                         }];
        [_elementFixedContainerView addSubview:gifView];
    }

    [_activityIndicatorView removeFromSuperview];
}

- (UIView*)elementView
{
    if (!_elementView) {
        _elementView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RYB_SCREEN_WIDTH, RYB_SCREEN_WIDTH / 3 * 4)];

        _elementFixedContainerView = [[UIView alloc] initWithFrame:_elementView.bounds];

        [_elementView addSubview:_elementFixedContainerView];
    }
    return _elementView;
}

- (void)recordAction:(UIButton*)sender
{
    //self.stopRecordButton.enabled = YES;
    if (sender.selected) {
        [self pauseRecord];
        //self.stopRecordButton.selected = YES;
    } else {
        [self beginRecord];
        //self.stopRecordButton.selected = NO;
    }
    sender.selected = !sender.selected;
}

- (void)stopRecordAction:(UIButton*)sender
{
    if (sender.selected) {
        [self pushToMVPublish];
    } else {
        [self endRecord];
    }
    //self.stopRecordButton.enabled = NO;
    sender.selected = !sender.selected;
}

- (void)chooseBgMusicAction:(UIButton*)sender
{
    NSString* fileName = self.mv_material.filePath.lastPathComponent.stringByDeletingPathExtension;

    NSString* outputOriginalSongPath = [NSString stringWithFormat:@"%@/%@_%@", CachePathForMV, fileName, OriginalSongPath];
    _currentBgMusicFilePath = outputOriginalSongPath;
}

- (void)takePhotoAction:(UIButton*)sender
{
    if (self.isVideoRecording) {
        [self pauseRecord];
    }
    [_videoCamera capturePhotoAsImageProcessedUpToFilter:_blendFilter
                                   withCompletionHandler:^(UIImage* processedImage, NSError* error) {
                                       //剪裁图片
                                       if (error) {
                                       } else {
                                           UIImageWriteToSavedPhotosAlbum(processedImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
                                       }
                                       if (self.isVideoRecording) {
                                           [self beginRecord];
                                       }
                                   }];
}

- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(id)contextInfo
{
    if (error) {
        [[RYBTool shareTool] showHUD:hudImageTypeFailed text:@"照片保存失败" detailText:@"可能没有访问系统相册的权限" inView:nil];
    } else {
        [[RYBTool shareTool] showHUD:hudImageTypeSuccess text:@"已保存到相册" detailText:nil inView:nil];
    }
}

- (void)modeSwitchAction:(UIButton*)sender
{
    WeakSelf;
    if (!weakSelf.recordButton.selected) {
        sender.selected = !sender.selected;
        return;
    }
    sender.selected = !sender.selected;
    [weakSelf removeBgMusicChannel];
    [weakSelf addBgMusicChannel];
}

- (void)delayRecordAction:(UIButton*)sender
{
    if (self.isVideoRecording) {
        return;
    }
    [_timer invalidate];
    NSTimer* timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(runCountDownAnimate) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    _left_count = 5;
    [self runCountDownAnimate];
}

- (void)runCountDownAnimate
{
    if (_left_count_lab) {
        [_left_count_lab removeFromSuperview];
    }
    UILabel* lab = [[UILabel alloc] init];
    _left_count_lab = lab;
    [lab setText:[NSString stringWithFormat:@"%zd", _left_count]];
    if (_left_count == 0) {
        [lab setText:@""];
    }
    [lab setFont:[UIFont systemFontOfSize:70]];
    [lab setTextColor:RYBHEXCOLOR(0xeeeeee)];
    [lab setTextAlignment:NSTextAlignmentCenter];
    lab.layer.shadowColor = RYBHEXCOLOR(0x555555).CGColor;
    lab.layer.shadowOffset = CGSizeMake(1, 1);
    lab.layer.shadowRadius = 5;
    lab.layer.cornerRadius = 10;
    lab.layer.masksToBounds = YES;
    lab.backgroundColor = RYBRGBA(0, 0, 0, 0.5);

    [self.view addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker* make) {
        make.center.equalTo(_recordCameraView);
        make.width.equalTo(@100);
        make.height.equalTo(@100);
    }];

    if (_left_count == 0) {
        [_timer invalidate];
        [_left_count_lab removeFromSuperview];
        [self recordAction:_recordButton];
    }
    _left_count--;
}

- (void)reverseCameraAction:(UIButton*)sender
{
    [_videoCamera rotateCamera];
}

- (void)configAudioRecord
{
    _audioController = [BPRecordTool shareTool].recordController;
    _group = [_audioController createChannelGroup];

    _aeRecorder = [[AERecorder alloc] initWithAudioController:_audioController];
    NSError* err = nil;
    NSString* filePath = [_originFilePath stringByReplacingOccurrencesOfString:@".mp4" withString:@".wav"];
    if (![_aeRecorder beginRecordingToFileAtPath:filePath fileType:kAudioFileWAVEType error:&err]) {
        _aeRecorder = nil;
        return;
    }
    [_audioController start:NULL];
    [_audioController addOutputReceiver:_aeRecorder];
    [_audioController addInputReceiver:_aeRecorder];
}

- (void)addBgMusicChannel
{
    WeakSelf;
    NSString* fileName = self.mv_material.filePath.lastPathComponent.stringByDeletingPathExtension;
    NSString* outputOriginalSongPath = [NSString stringWithFormat:@"%@/%@_%@", CachePathForMV, fileName, OriginalSongPath];
    NSString* outputAccompanySongPath = [NSString stringWithFormat:@"%@/%@_%@", CachePathForMV, fileName, AccompanySongPath];
    _currentBgMusicFilePath = !_modeSwitchButton.selected ? outputAccompanySongPath : outputOriginalSongPath;
    NSURL* fileUrl = [NSURL fileURLWithPath:_currentBgMusicFilePath ? _currentBgMusicFilePath : [[NSBundle mainBundle] pathForResource:@"节奏" ofType:@"mp3"]];
    weakSelf.audioBgMusicPlayer = [AEAudioFilePlayer audioFilePlayerWithURL:fileUrl error:nil];
    weakSelf.audioBgMusicPlayer.loop = NO;
    weakSelf.audioBgMusicPlayer.volume = 1;
    weakSelf.audioBgMusicPlayer.channelIsMuted = NO;
    [weakSelf.audioController addChannels:[NSArray arrayWithObjects:weakSelf.audioBgMusicPlayer, nil] toChannelGroup:_group];
    [weakSelf.audioBgMusicPlayer setCurrentTime:weakSelf.currentBgMusicPlayTime];
    [weakSelf.audioBgMusicPlayer setCompletionBlock:^{
        [weakSelf stopRecordAction:_stopRecordButton];
    }];
}

- (void)removeBgMusicChannel
{
    WeakSelf;
    weakSelf.currentBgMusicPlayTime = weakSelf.audioBgMusicPlayer.currentTime;
    [weakSelf.audioController removeChannels:[NSArray arrayWithObjects:weakSelf.audioBgMusicPlayer, nil] fromChannelGroup:_group];
    _audioBgMusicPlayer = nil;
}

- (void)prepareRecord
{
    NSString* savePath = [NSString stringWithFormat:@"%@/Documents/anchor/mv", NSHomeDirectory()];
    if (![[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        NSError* err;
        [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] error:&err];
        [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] ofItemAtPath:savePath error:&err];
        //设置不被iCloud备份
        NSURL* URL = [NSURL fileURLWithPath:savePath];
        NSError* error = nil;
        BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                      forKey:NSURLIsExcludedFromBackupKey
                                       error:&error];
        [[NSFileManager defaultManager] setAttributes:@{ NSFileProtectionKey : NSFileProtectionNone } ofItemAtPath:[URL path] error:NULL];
        if (!success) {
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
    }

    NSArray* arr = @[ @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9" ];
    NSString* timeString = [NSString stringWithFormat:@"mv_%0.f", [[NSDate date] timeIntervalSince1970]];
    NSMutableString* randomStr = [NSMutableString stringWithString:timeString];
    for (int i = 0; i < 3; i++) {
        [randomStr appendString:arr[arc4random() % 10]];
    }
    NSString* originFilePath = [NSString stringWithFormat:@"%@/%@.mp4", CacheRecordPathForMV, randomStr];
    _originFilePath = originFilePath;

    [self configAudioRecord];
}

- (void)beginRecord
{
    WeakSelf;
    if (!_originFilePath) {
        [self prepareRecord];
    }
    _progressView.hidden = NO;
    NSString* filePath = [_originFilePath stringByReplacingOccurrencesOfString:@".mp4" withString:[NSString stringWithFormat:@"_%zd.mp4", _videoFilePathArray.count]];
    _currentFilePath = filePath;
    NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
    CGSize outputSize = [UIScreen mainScreen].bounds.size;
    outputSize.width = [UIScreen mainScreen].scale * ceil(videoRecordRealWidth / 16) * 16;
    outputSize.height = [UIScreen mainScreen].scale * ceil(videoRecordRealHeight / 16) * 16;
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:fileUrl size:outputSize];

    CGFloat widthScale = outputSize.width / videoRecordRealWidth;
    CGFloat cropHeightScale = (1 - outputSize.height / widthScale / videoRecordRealHeight) / 2;
    CGFloat heightScale = outputSize.height / videoRecordRealHeight;
    CGFloat cropWidthScale = (1 - outputSize.width / heightScale / videoRecordRealWidth) / 2;
    if (cropHeightScale < 0) {
        _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(cropWidthScale, 0, 1 - 2 * cropWidthScale, 1)];
    } else {
        _cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, cropHeightScale, 1, 1 - 2 * cropHeightScale)];
    }
    [_blendFilter addTarget:_cropFilter];
    [_cropFilter addTarget:_movieWriter];
    _movieWriter.encodingLiveVideo = YES;
    //_videoCamera.audioEncodingTarget = _movieWriter;
    [self addBgMusicChannel];
    AERecorderStartRecording(weakSelf.aeRecorder);
    [_movieWriter startRecording];
    self.isVideoRecording = YES;
    _progressTimer = [NSTimer timerWithTimeInterval:0.2
                                              block:^(NSTimer* _Nonnull timer) {
                                                  float progress = 1.0 * weakSelf.audioBgMusicPlayer.currentTime / weakSelf.audioBgMusicPlayer.duration;
                                                  _progressView.progress = progress;
                                              }
                                            repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_progressTimer forMode:NSRunLoopCommonModes];
}

- (void)pauseRecord
{
    _videoCamera.audioEncodingTarget = nil;
    AERecorderStopRecording(_aeRecorder);
    [self removeBgMusicChannel];
    [_movieWriter finishRecordingWithCompletionHandler:^{
        [_videoFilePathArray addObject:_currentFilePath];
    }];
    self.isVideoRecording = NO;
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (void)endRecord
{
    WeakSelf;
    _videoCamera.audioEncodingTarget = nil;
    [weakSelf.aeRecorder finishRecording];
    [self removeBgMusicChannel];
    [weakSelf.audioController removeInputReceiver:weakSelf.aeRecorder];
    [weakSelf.audioController removeOutputReceiver:weakSelf.aeRecorder];
    weakSelf.aeRecorder = nil;
    [_audioController stop];
    [_movieWriter finishRecordingWithCompletionHandler:^{
        [_videoFilePathArray addObject:_currentFilePath];
        [weakSelf pushToMVPublish];
    }];
    self.isVideoRecording = NO;
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    RYBLog(@"finish:%@", videoPath);
    if (error) {
        return;
    }
    [[RYBTool shareTool] showHUD:hudImageTypeSuccess text:@"保存成功" detailText:@"已保存到系统相册" inView:nil];
}

- (void)pushToMVPublish
{
    WeakSelf;
    BPStory* story = [[BPStory alloc] init];
    story.story_id = _originFilePath.lastPathComponent.stringByDeletingPathExtension;
    story.media_path = _originFilePath.lastPathComponent;
    story.story_status = BPStoryStatusUnsubmited;
    story.type = BPStoryTypePowerMV;
    story.title = weakSelf.mv_material.title;
    BPPowerMVPublishController* publish = [[BPPowerMVPublishController alloc] init];
    publish.mv = story;
    publish.videoFilePathArray = _videoFilePathArray;
    publish.originFilePath = _originFilePath;
    publish.tempBackgroundImage = [[BPPowerMVTool shareTool] thumbnailImageRequestWithVideoPath:_currentFilePath count:1].firstObject;
    [[RYBTool shareTool] doInMainThread:^{
        [DCURLNavgation pushViewController:publish animated:YES andRemoveCount:1];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_videoCamera stopCameraCapture];
    if ([[RYBTool shareTool] canDeallocWithVC:self]) {
        if (_recordButton.selected && self.aeRecorder) {
            [self pauseRecord];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self removeLrcTimer];
        [_videoCamera stopCameraCapture];
        _videoCamera.delegate = nil;
        _videoCamera = nil;
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:CacheRecordPathForMV error:nil];
        NSEnumerator* e = [contents objectEnumerator];
        NSString* filename;
        while (filename = [e nextObject]) {
            NSString* currentPath = [NSString stringWithFormat:@"%@/%@", CacheRecordPathForMV, filename];
            [[NSFileManager defaultManager]removeItemAtPath:currentPath error:nil];
        }
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end

