
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (Extensions)

#pragma mark - compress
- (UIImage *)compressedImage;
- (CGFloat)compressionQuality;
- (NSData *)compressedData;
- (NSData *)compressedData:(CGFloat)compressionQuality;

#pragma mark - fixOrientation
- (UIImage *)fixOrientation;

#pragma mark - rotate & resize
- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)horizontalFlip;
- (UIImage *)verticalFlip;
@end
