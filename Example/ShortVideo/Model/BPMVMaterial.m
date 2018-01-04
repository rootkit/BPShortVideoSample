//
//  BPMVMaterial.m
//  Zhudou
//
//  Created by zhudou on 2017/10/24.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPMVMaterial.h"

@implementation BPMVMaterial

+ (NSDictionary<NSString*, id>*)modelCustomPropertyMapper
{
    return @{@"filePath":@"video_path",@"material_id":@"id"};
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.title_pic forKey:NSStringFromSelector(@selector(title_pic))];
    [aCoder encodeObject:self.material_id forKey:NSStringFromSelector(@selector(material_id))];
    [aCoder encodeObject:self.lrc_path forKey:NSStringFromSelector(@selector(lrc_path))];
    [aCoder encodeObject:self.filePath forKey:NSStringFromSelector(@selector(filePath))];
    [aCoder encodeInteger:self.mv_count forKey:NSStringFromSelector(@selector(mv_count))];
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {

        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        self.title_pic = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title_pic))];
        self.material_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(material_id))];
        self.lrc_path = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(lrc_path))];
        self.filePath = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(filePath))];
        self.mv_count = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(mv_count))];
    }
    return self;
}

@end
