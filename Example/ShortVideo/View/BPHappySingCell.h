//
//  BPHappySingCell.h
//  Zhudou
//
//  Created by zhudou on 2017/11/2.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPStory.h"

typedef void (^operationBlock)();
typedef void (^quickPlayBlock)();

@interface BPHappySingCell : UICollectionViewCell

@property (nonatomic, strong) BPStory* story;

@property (nonatomic, strong) operationBlock block;

@property (nonatomic, strong) quickPlayBlock quickPlay;

@end
