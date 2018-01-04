//
//  BPSceneSelectCell.m
//  Zhudou
//
//  Created by zhudou on 2017/11/10.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPSceneSelectCell.h"
#import <UIButton+WebCache.h>
#import <Masonry.h>
#import "DGActivityIndicatorView.h"

#define CachePathForMV [NSString stringWithFormat:@"%@/Library/Caches/ZhudouMVCache", NSHomeDirectory()]
@interface BPSceneSelectCell ()
@property (nonatomic, weak) UIButton* sceneImageButton;
@property (nonatomic, weak) UIImageView* downloadStatusImageView;
@property (nonatomic,weak) DGActivityIndicatorView *progressView;
@end

@implementation BPSceneSelectCell

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIButton* sceneImageButton = [[UIButton alloc] init];
    [self.contentView addSubview:sceneImageButton];
    sceneImageButton.userInteractionEnabled = NO;
    [sceneImageButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(self.contentView);
    }];
    self.sceneImageButton = sceneImageButton;
    self.contentView.clipsToBounds = YES;
    self.sceneImageButton.clipsToBounds = YES;

    UIImageView* downloadStatusImageView = [[UIImageView alloc] initWithImage:[UIImage bp_imageNamed:@"scence_icon_download"]];
    [self.contentView addSubview:downloadStatusImageView];
    self.downloadStatusImageView = downloadStatusImageView;
    [downloadStatusImageView mas_makeConstraints:^(MASConstraintMaker* make){
        make.bottom.equalTo(sceneImageButton);
        make.right.equalTo(sceneImageButton);
    }];

    DGActivityIndicatorView *progressView  = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate tintColor:[UIColor flatBlackColor] size:20.0f];
    [sceneImageButton addSubview:progressView];

    [progressView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(sceneImageButton);
    }];

    self.progressView = progressView;
    
    self.contentView.highlightOnTouch = YES;
    self.contentView.clipsToBounds = YES;
}

- (void)setScene:(BPMVScene *)scene
{
    _scene = scene;
    self.progressView.hidden = !scene.is_downloading;

    NSString* scene_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene.zip_path_ios.lastPathComponent];
    self.downloadStatusImageView.hidden = [[NSFileManager defaultManager] fileExistsAtPath:scene_path];
    if (scene.is_downloading) {
        [self.progressView startAnimating];
    } else {
        [self.progressView stopAnimating];
    }
    if (scene.is_empty) {
        [self.sceneImageButton setImage:[UIImage bp_imageNamed:@"scence_icon_none"] forState:UIControlStateNormal];
        self.downloadStatusImageView.hidden = YES;
    }else{
        [self.sceneImageButton sd_setImageWithURL:[NSURL URLWithString:scene.title_pic] forState:UIControlStateNormal];
    }
}

@end
