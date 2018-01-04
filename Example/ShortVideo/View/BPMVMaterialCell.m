//
//  BPMVMaterialCell.m
//  Zhudou
//
//  Created by zhudou on 2017/10/25.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPMVMaterialCell.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "UIView+highlightOnTouch.h"

@interface BPMVMaterialCell ()
@property (nonatomic, weak) UIImageView* mvTitleImageView;
@property (nonatomic, weak) UILabel* mvTitleLabel;
@end

@implementation BPMVMaterialCell

- (instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        [self setup];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIImageView* mvTitleImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:mvTitleImageView];
    [mvTitleImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 0, 25, 0));
    }];
    mvTitleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mvTitleImageView = mvTitleImageView;
    self.mvTitleImageView.layer.cornerRadius = 5.0f;
    self.mvTitleImageView.clipsToBounds = YES;
    self.mvTitleImageView.layer.shouldRasterize = YES;
    self.mvTitleImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;

    UILabel* mvTitleLabel = [[UILabel alloc] init];
    mvTitleLabel.textColor = RYBHEXCOLOR(0x272727);
    mvTitleLabel.textAlignment = NSTextAlignmentCenter;
    mvTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    [self.contentView addSubview:mvTitleLabel];
    [mvTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mvTitleImageView.mas_bottom).offset(10);
        make.left.equalTo(mvTitleImageView);
        make.right.equalTo(mvTitleImageView);
    }];
    self.mvTitleLabel = mvTitleLabel;
    self.contentView.highlightOnTouch = YES;
}

- (void)setMaterial:(BPMVMaterial*)material
{
    _material = material;
    [self.mvTitleImageView sd_setImageWithURL:[NSURL URLWithString:material.title_pic]];
    self.mvTitleLabel.text = material.title;
}

@end

