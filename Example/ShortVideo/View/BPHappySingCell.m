//
//  BPHappySingCell.m
//  Zhudou
//
//  Created by zhudou on 2017/11/2.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPHappySingCell.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface BPHappySingCell ()
@property (nonatomic, weak) UILabel* singTitleLabel;
@property (nonatomic, weak) UIImageView* singTitleImageView;
@property (nonatomic, weak) UILabel* singTimeLabel;
@property (nonatomic, weak) UIButton* deleteButton;
@property (weak, nonatomic) UIButton* quickPlayButton;
@end

@implementation BPHappySingCell

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
    WeakSelf;
    UIImageView* singTitleImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:singTitleImageView];
    singTitleImageView.contentMode = UIViewContentModeScaleAspectFill;
    [singTitleImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(self.contentView).offset(20);
        make.top.equalTo(self.contentView).offset(10);
        make.width.equalTo(@(60));
        make.height.equalTo(@(60));
    }];
    self.singTitleImageView = singTitleImageView;
    self.singTitleImageView.layer.cornerRadius = 30.0f;
    self.singTitleImageView.clipsToBounds = YES;
    self.singTitleImageView.userInteractionEnabled = YES;

    UIButton* quickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [quickButton setImage:[UIImage bp_imageNamed:@"listen_icon_goon"] forState:UIControlStateNormal];
    [quickButton setImage:[UIImage bp_imageNamed:@"listen_icon_stop"] forState:UIControlStateSelected];
    [self.singTitleImageView addSubview:quickButton];
    self.quickPlayButton = quickButton;
    [quickButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.center.equalTo(singTitleImageView);
    }];
    [quickButton addBlockForControlEvents:UIControlEventTouchUpInside
                                    block:^(UIButton* sender) {
                                        if (sender.selected) {
                                            [BPMusicTool pause];
                                        } else {
                                            if (self.quickPlay) {
                                                self.quickPlay();
                                            }
                                        }
                                    }];

    UILabel* singTitleLabel = [[UILabel alloc] init];
    singTitleLabel.textColor = RYBHEXCOLOR(0x272727);
    singTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    [self.contentView addSubview:singTitleLabel];
    [singTitleLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(singTitleImageView.mas_right).offset(20);
        make.top.equalTo(self.contentView).offset(22);
    }];

    UILabel* singTimeLabel = [[UILabel alloc] init];
    singTimeLabel.textColor = RYBHEXCOLOR(0xa5a4a4);
    singTimeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    [self.contentView addSubview:singTimeLabel];
    self.singTimeLabel = singTimeLabel;
    [singTimeLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(singTitleImageView.mas_right).offset(20);
        make.bottom.equalTo(self.contentView).offset(-17.5);
    }];

    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage bp_imageNamed:@"happysing_my_sing_icon_delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:button];
    self.deleteButton = button;
    [button mas_makeConstraints:^(MASConstraintMaker* make) {
        make.right.equalTo(self.contentView).offset(-20);
        make.centerY.equalTo(self.contentView);
    }];
    [button
        addBlockForControlEvents:UIControlEventTouchUpInside
                           block:^(id _Nonnull sender) {
                               if (weakSelf.block) {
                                   weakSelf.block();
                               }
                           }];

    self.singTitleLabel = singTitleLabel;
    self.contentView.highlightOnTouch = YES;
    self.contentView.clipsToBounds = YES;

    CALayer* layer = [CALayer layer];
    layer.backgroundColor = RYBPAGELINECOLOR.CGColor;
    layer.frame = CGRectMake(0, 79, RYB_SCREEN_WIDTH, 1 / [UIScreen mainScreen].scale);
    [self.contentView.layer addSublayer:layer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayState:) name:APP_NOTIFICATION_MUSIC_PLAYSTATE_CHANGED object:nil];
}

- (void)musicPlayState:(NSNotification*)notification
{
    RYBList* list = [RYBList listWithStory:_story andAnchor:nil];
    if (list && [BPMusicTool playingMusic] && [list.material_id isEqualToString:[BPMusicTool playingMusic].material_id]) {
        if (notification) {
            PlayState state = [[notification object] integerValue];
            [self processPlayState:state];
        }

    } else {
        self.quickPlayButton.selected = NO;
    }
}

- (void)processPlayState:(PlayState)state
{
    switch (state) {
    case PlayStateStoped: {
        self.quickPlayButton.selected = NO;
    } break;
    case PlayStateReady: {
        self.quickPlayButton.selected = NO;
    } break;
    case PlayStatePlaying: {
        self.quickPlayButton.selected = YES;
    } break;
    case PlayStatePaused: {
        self.quickPlayButton.selected = NO;
    } break;
    case PlayStateBuffering: {
        self.quickPlayButton.selected = NO;
    } break;
    case PlayStateError: {
    } break;
    case PlayStateSwitch: {
    } break;
    }
}

- (void)setStory:(BPStory*)story
{
    _story = story;
    self.singTitleLabel.text = story.title;
    self.singTimeLabel.text = story.create_time;
    [self.singTitleImageView sd_setImageWithURL:[NSURL URLWithString:story.media_pic]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
