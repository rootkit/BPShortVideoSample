//
//  BPMV.m
//  Zhudou
//
//  Created by zhudou on 2017/10/24.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPMV.h"

@implementation BPMV
+ (NSDictionary<NSString*, id>*)modelCustomPropertyMapper
{
    return @{ @"mv_id" : @"id" };
}
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.title_pic forKey:NSStringFromSelector(@selector(title_pic))];
    [aCoder encodeObject:self.head_photo forKey:NSStringFromSelector(@selector(head_photo))];
    [aCoder encodeObject:self.video_path forKey:NSStringFromSelector(@selector(video_path))];
    [aCoder encodeObject:self.nice_name forKey:NSStringFromSelector(@selector(nice_name))];
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
    [aCoder encodeObject:self.user_id forKey:NSStringFromSelector(@selector(user_id))];
    [aCoder encodeObject:self.create_time forKey:NSStringFromSelector(@selector(create_time))];
    [aCoder encodeInteger:self.play_count forKey:NSStringFromSelector(@selector(play_count))];
    [aCoder encodeInteger:self.like_count forKey:NSStringFromSelector(@selector(like_count))];
    [aCoder encodeBool:self.is_liked forKey:NSStringFromSelector(@selector(isLiked))];
    [aCoder encodeBool:self.is_my forKey:NSStringFromSelector(@selector(is_my))];
    [aCoder encodeInteger:self.is_pass forKey:NSStringFromSelector(@selector(is_pass))];
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {

        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        self.title_pic = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title_pic))];
        self.head_photo = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(head_photo))];
        self.video_path = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(video_path))];
        self.nice_name = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(nice_name))];
        self.url = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(url))];
        self.user_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(user_id))];
        self.create_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(create_time))];
        self.play_count = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(play_count))];
        self.like_count = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(like_count))];
        self.is_liked = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(is_liked))];
        self.is_pass = [aDecoder decodeIntegerForKey:NSStringFromSelector(@selector(is_pass))];
        self.is_my = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(is_my))];
    }
    return self;
}
@end

