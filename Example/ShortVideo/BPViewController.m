//
//  BPViewController.m
//  ShortVideo
//
//  Created by bubue on 01/04/2018.
//  Copyright (c) 2018 bubue. All rights reserved.
//

#import "BPViewController.h"
#import "BPShortVideoRecordController.h"

@interface BPViewController ()
- (IBAction)shortVideoRecordAction:(UIButton*)sender;

@end

@implementation BPViewController

- (IBAction)shortVideoRecordAction:(UIButton*)sender
{
    BPShortVideoRecordController* shortVideoRecord = [[BPShortVideoRecordController alloc] init];
    [self.navigationController pushViewController:shortVideoRecord animated:YES];
}
@end
