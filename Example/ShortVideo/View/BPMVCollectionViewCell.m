//
//  BPMVCollectionViewCell.m
//  Zhudou
//
//  Created by zhudou on 2017/11/2.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPMVCollectionViewCell.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import "BPPowerMVTool.h"

@interface BPMVCollectionViewCell ()
@property (nonatomic, weak) UIImageView* fadeBottomImageView;
@property (nonatomic, weak) UILabel* mvTitleLabel;
@property (nonatomic, weak) UIButton* deleteButton;
@property (nonatomic, weak) UIButton* publishButton;
@property (nonatomic, weak) UIButton* shareButton;
@property (nonatomic, weak) UILabel* passStatusLabel;
@property (nonatomic, weak) UILabel* playCountLabel;
@property (nonatomic, weak) UIImageView* playCountIconImageView;
@end

@implementation BPMVCollectionViewCell

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
    UIImageView* mvTitleImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:mvTitleImageView];
    mvTitleImageView.contentMode = UIViewContentModeScaleAspectFill;
    [mvTitleImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(self.contentView);
    }];
    self.mvTitleImageView = mvTitleImageView;

    UIImageView* fadeBottomImageView = [[UIImageView alloc] initWithImage:[UIImage bp_imageNamed:@"fade_bottom"]];
    fadeBottomImageView.alpha = 0.7;
    [self.mvTitleImageView addSubview:fadeBottomImageView];
    self.fadeBottomImageView = fadeBottomImageView;
    [fadeBottomImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.bottom.equalTo(mvTitleImageView);
        make.left.equalTo(mvTitleImageView);
        make.right.equalTo(mvTitleImageView);
        make.height.equalTo(@65);
    }];

    //self.mvTitleImageView.layer.cornerRadius = 5.0f;
    //self.mvTitleImageView.clipsToBounds = YES;

    UILabel* mvTitleLabel = [[UILabel alloc] init];
    mvTitleLabel.textColor = RYBHEXCOLOR(0xffffff);
    mvTitleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:mvTitleLabel];
    [mvTitleLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(mvTitleImageView).offset(10);
        make.right.equalTo(mvTitleImageView);
        make.bottom.equalTo(mvTitleImageView).offset(-32);
    }];
    self.mvTitleLabel = mvTitleLabel;

    UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:[UIImage bp_imageNamed:@"happysing_my_icon_delete"] forState:UIControlStateNormal];
    [self.contentView addSubview:deleteButton];
    [deleteButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.right.equalTo(mvTitleImageView).offset(-10);
        make.bottom.equalTo(mvTitleImageView).offset(-10);
    }];
    self.deleteButton = deleteButton;
    [deleteButton addBlockForControlEvents:UIControlEventTouchUpInside
                                     block:^(id _Nonnull sender) {
                                         [weakSelf deleteStory];
                                     }];

    UIButton* publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [publishButton setImage:[UIImage bp_imageNamed:@"happysing_my_icon_upload"] forState:UIControlStateNormal];
    [self.contentView addSubview:publishButton];
    [publishButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.right.equalTo(deleteButton).offset(-30);
        make.centerY.equalTo(deleteButton);
    }];
    self.publishButton = publishButton;
    [publishButton addBlockForControlEvents:UIControlEventTouchUpInside
                                      block:^(id _Nonnull sender) {
                                          NSString* filePath = [NSString stringWithFormat:@"%@/Documents/anchor/mv/%@", NSHomeDirectory(), weakSelf.story.media_path];
                                          NSArray* arr = [[BPPowerMVTool shareTool] thumbnailImageRequestWithVideoPath:filePath count:5];
                                          [[BPPowerMVTool shareTool] showPreviewPickerView:arr
                                                                               selectBlock:^(UIImage* img) {
                                                                                   [weakSelf didSelectImage:img];
                                                                               }];
                                      }];

    UIButton* shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage bp_imageNamed:@"happy_sing_share"] forState:UIControlStateNormal];
    [self.contentView addSubview:shareButton];
    [shareButton mas_makeConstraints:^(MASConstraintMaker* make) {
        make.center.equalTo(deleteButton);
    }];
    self.shareButton = shareButton;
    [shareButton addBlockForControlEvents:UIControlEventTouchUpInside
                                    block:^(id _Nonnull sender) {
                                        if (weakSelf.block) {
                                            weakSelf.block(2);
                                        }
                                    }];

    UILabel* passStatusLabel = [[UILabel alloc] init];
    self.passStatusLabel = passStatusLabel;
    self.passStatusLabel.text = @"审核中";
    passStatusLabel.textColor = RYBHEXCOLOR(0x60d774);
    passStatusLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightLight];
    [self.contentView addSubview:passStatusLabel];
    [passStatusLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(mvTitleLabel);
        make.centerY.equalTo(deleteButton);
        make.right.equalTo(self.contentView).offset(-75);
    }];

    UIImageView* playCountIconImageView = [[UIImageView alloc] initWithImage:[UIImage bp_imageNamed:@"happysing_my_icon_eye"]];
    self.playCountIconImageView = playCountIconImageView;
    [self.contentView addSubview:playCountIconImageView];
    [playCountIconImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(mvTitleLabel);
        make.centerY.equalTo(deleteButton);
    }];

    UILabel* playCountLabel = [[UILabel alloc] init];
    self.playCountLabel = playCountLabel;
    self.playCountLabel.text = [NSString stringWithFormat:@"%zd", self.mv.play_count];
    self.playCountLabel.textColor = [UIColor whiteColor];
    self.playCountLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightLight];
    [self.contentView addSubview:playCountLabel];
    [playCountLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        make.left.equalTo(playCountIconImageView.mas_right).offset(5);
        make.centerY.equalTo(deleteButton);
    }];

    self.contentView.highlightOnTouch = YES;
    self.contentView.clipsToBounds = YES;
}

- (void)didSelectImage:(UIImage*)img
{
    WeakSelf;
    NSString* filePath = [NSString stringWithFormat:@"%@/Documents/anchor/mv/%@", NSHomeDirectory(), weakSelf.story.media_path];

    [[BPPowerMVTool shareTool]
         publishMV:weakSelf.story
         withImage:img
        completion:^{
        }];
}

- (void)deleteStory
{
    WeakSelf;
    [[RYBTool shareTool] showAlertWithType:RYBAlertTypeActionSheet
                                     title:@""
                                       msg:@"确认删除？"
                                   options:@[ @"确认" ]
                                  redIndex:0
                                   handler:^(int index) {
                                       if (index == 0) {
                                           if (weakSelf.type == MVTypeDraft) {
                                               NSString* filePath = [NSString stringWithFormat:@"%@/Documents/anchor/mv/%@", NSHomeDirectory(), weakSelf.story.media_path];
                                               [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                                               [[RYBDBTool shareTool] removeStory:weakSelf.story];
                                               [[FileTool shareTool] removeFilesWithStory:weakSelf.story];
                                               if (weakSelf.block) {
                                                   weakSelf.block(1);
                                               }
                                           } else if (weakSelf.type == MVTypeMine) {
                                               [IKHttpTool
                                                   postWithURL:@"api/v3/games/delMv"
                                                   params:@{
                                                       @"token" : [BPUser user].token,
                                                       @"id" : weakSelf.mv.mv_id
                                                   }
                                                   success:^(id json) {
                                                       if (json[@"code"] && [json[@"code"] integerValue] == 1) {
                                                           [[RYBTool shareTool] showHUD:hudImageTypeSuccess text:@"删除成功" detailText:@"" inView:nil];
                                                           if (weakSelf.block) {
                                                               weakSelf.block(1);
                                                           }
                                                       } else {
                                                           [[RYBTool shareTool] showHUD:hudImageTypeFailed text:@"删除失败" detailText:@"" inView:nil];
                                                       }
                                                   }
                                                   failure:^(NSError* error) {
                                                       [[RYBTool shareTool] showHUD:hudImageTypeFailed text:@"请求超时" detailText:@"" inView:nil];
                                                   }];
                                           }
                                       }
                                   }];
}

- (void)setMv:(BPMV*)mv
{
    _mv = mv;
    [self.mvTitleImageView sd_setImageWithURL:[NSURL URLWithString:mv.title_pic]];
    self.mvTitleLabel.text = mv.title;
    self.publishButton.hidden = YES;
    self.shareButton.hidden = NO;
    if (mv.is_pass == MVPassStatusPassed) {
        self.passStatusLabel.text = @"已通过";
        self.passStatusLabel.textColor = RYBHEXCOLOR(0x60d774);
    } else if (mv.is_pass == MVPassStatusReview) {
        self.passStatusLabel.text = @"审核中";
        self.passStatusLabel.textColor = FlatYellow;

    } else if (mv.is_pass == MVPassStatusRejected) {
        self.passStatusLabel.text = @"被拒绝";
        self.passStatusLabel.textColor = FlatRed;
    }
    if (self.type == MVTypeMine) {
        self.passStatusLabel.hidden = NO;
        self.deleteButton.hidden = NO;
        self.playCountLabel.hidden = YES;
        self.playCountIconImageView.hidden = YES;
        [self.shareButton mas_remakeConstraints:^(MASConstraintMaker* make) {
            make.center.equalTo(_publishButton);
        }];
    } else {
        self.passStatusLabel.hidden = YES;
        self.deleteButton.hidden = YES;
        self.playCountLabel.hidden = NO;
        self.playCountIconImageView.hidden = NO;
        [self.shareButton mas_remakeConstraints:^(MASConstraintMaker* make) {
            make.center.equalTo(_deleteButton);
        }];
    }
    if (!mv.is_pass) {
        self.shareButton.hidden = YES;
    }
}

- (void)setStory:(BPStory*)story
{
    _story = story;
    NSString* savePath = [NSString stringWithFormat:@"%@/Documents/anchor/mv/%@", NSHomeDirectory(), story.media_path];
    self.mvTitleImageView.image = [[BPPowerMVTool shareTool] thumbnailImageRequestWithVideoPath:savePath count:1].firstObject;
    self.mvTitleLabel.text = story.title;
    self.passStatusLabel.hidden = YES;
    self.publishButton.hidden = NO;
    self.deleteButton.hidden = NO;
    self.playCountLabel.hidden = YES;
    self.playCountIconImageView.hidden = YES;
    self.shareButton.hidden = YES;
}

@end

