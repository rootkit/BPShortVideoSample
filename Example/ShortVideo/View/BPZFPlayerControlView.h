
#import <UIKit/UIKit.h>
#import "ASValueTrackingSlider.h"
#import "ZFPlayer.h"
#import "BPPlayerConfig.h"

typedef NS_ENUM(NSInteger, PlayOperationType) {
    PlayOperationTypeBackAction = 1,
    PlayOperationTypePlayFinished = 2,
    PlayOperationTypeLikeAction = 3
};

typedef void (^PlayProgressBlock)(NSInteger currentTime, NSInteger totalTime, CGFloat progress);

typedef void (^OperationBlock)(PlayOperationType type);

@interface BPZFPlayerControlView : UIView

@property (nonatomic, strong) OperationBlock block;

@property (nonatomic, strong) PlayProgressBlock progress_block;

- (instancetype)initWithConfig:(BPPlayerConfig*)config;

@end
