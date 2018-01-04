//
//  BPSceneSelectController.h
//  Zhudou
//
//  Created by zhudou on 2017/11/10.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPSceneSelectCell.h"

typedef void (^didSelectScene)(BPMVScene* scene);

@interface BPSceneSelectController : UIViewController

@property (strong, nonatomic) NSMutableArray<BPMVScene *>* dataSource;

@property (strong, nonatomic) didSelectScene selectBlock;

@end
