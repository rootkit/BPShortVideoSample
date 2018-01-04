//
//  BPMVCollectionViewCell.h
//  Zhudou
//
//  Created by zhudou on 2017/11/2.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPMV.h"
#import "BPStory.h"

typedef void (^collectionViewBlock)(int type);

@interface BPMVCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) BPMV* mv;
@property (nonatomic, strong) BPStory* story;
@property (nonatomic, strong) collectionViewBlock block;
@property (nonatomic, assign) MVType type;

@property (nonatomic, weak) UIImageView* mvTitleImageView;

@end
