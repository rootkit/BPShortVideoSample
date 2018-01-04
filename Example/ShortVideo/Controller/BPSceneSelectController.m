//
//  BPSceneSelectController.m
//  Zhudou
//
//  Created by zhudou on 2017/11/10.
//  Copyright © 2017年 红黄蓝教育. All rights reserved.
//

#import "BPSceneSelectController.h"
#import "DGActivityIndicatorView.h"
#import "Masonry.h"
#import "ASIHTTPRequest.h"
#import "SSZipArchive.h"

#define CachePathForMV [NSString stringWithFormat:@"%@/Library/Caches/ZhudouMVCache", NSHomeDirectory()]

#define sceneHeight MAX((RYB_SCREEN_HEIGHT - RYB_SCREEN_WIDTH / 3 * 4), 141)
@interface BPSceneSelectController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout* layout;
@property (nonatomic, weak) UIView* loadingView;
@property (nonatomic, strong) NSMutableDictionary* req_dict;

@end

@implementation BPSceneSelectController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configCollectionView];
    [self requestData];
}

- (void)configCollectionView
{
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    self.layout = layout;
    float lineSpacing = 17;
    float itemSpacing = 17;
    float collectionViewPadding = 17;
    layout.minimumLineSpacing = lineSpacing;
    layout.minimumInteritemSpacing = itemSpacing;
    int count = RYB_IS_PAD ? 12 : 6;
    float itemW = floor((RYB_SCREEN_WIDTH - itemSpacing * (count - 1) - 2 * collectionViewPadding) / count);
    float itemH = itemW;
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    CGFloat scene_height = sceneHeight;
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, RYB_SCREEN_WIDTH, scene_height) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView = collectionView;
    collectionView.contentInset = UIEdgeInsetsMake(collectionViewPadding, collectionViewPadding, collectionViewPadding, collectionViewPadding);
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerClass:[BPSceneSelectCell class] forCellWithReuseIdentifier:NSStringFromClass([BPSceneSelectCell class])];

    collectionView.dataSource = self;

    collectionView.delegate = self;

    [self.view addSubview:collectionView];

    if (self.dataSource) {
        [self refreshCollectionView];
    }

    self.dataSource = [NSMutableArray array];
    self.req_dict = [NSMutableDictionary dictionary];

    if (@available(iOS 11, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }

    NSString* cache_key = [[RYBTool shareTool] getCacheKeyNameWith:self property:@selector(dataSource)];

    NSMutableArray* dataSource = (NSMutableArray*)[[RYBTool shareTool].cache objectForKey:cache_key];

    if (dataSource) {

        self.dataSource = dataSource;

        [self refreshCollectionView];
    }
}

- (void)requestData
{
    WeakSelf;
    [weakSelf showLoadingView];
    BPUser* user = [BPUser user];

    [IKHttpTool
        postWithURL:@"api/v3/games/mvResources"
        params:@{ @"token" : user.token }
        success:^(id json) {
            if (json[@"code"] && [json[@"code"] intValue] == 1) {
                [weakSelf.dataSource removeAllObjects];
                if (!json[@"content"][@"scene"]) {
                    return;
                }

                for (NSDictionary* dict in json[@"content"][@"scene"]) {
                    BPMVScene* scene = [BPMVScene bp_modelWithDict:dict];
                    [weakSelf.dataSource addObject:scene];
                }
                //local
                BPMVScene* mv_scene = [[BPMVScene alloc] init];
                NSString* zip_path = [[NSBundle mainBundle] pathForResource:@"mv_scene/forest_music.zip" ofType:nil];
                mv_scene.zip_path_ios = zip_path;
                [weakSelf.dataSource addObject:mv_scene];
                
                BPMVScene* mv_scene2 = [[BPMVScene alloc] init];
                NSString* zip_path2 = [[NSBundle mainBundle] pathForResource:@"mv_scene/garden.zip" ofType:nil];
                mv_scene2.zip_path_ios = zip_path2;
                [weakSelf.dataSource addObject:mv_scene2];
                
                [weakSelf hideLoadingOrButtonView];
                [weakSelf refreshCollectionView];
                NSString* cache_key = [[RYBTool shareTool] getCacheKeyNameWith:self property:@selector(dataSource)];
                [[RYBTool shareTool].cache setObject:weakSelf.dataSource forKey:cache_key];
            } else {
                [weakSelf showButtonView];
            }
        }
        failure:^(NSError* error) {
            [weakSelf showButtonView];
        }];
}

- (void)refreshCollectionView
{
    [self.collectionView reloadData];
}

- (void)showLoadingView
{
    [self hideLoadingOrButtonView];
    DGActivityIndicatorView* activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeBallClipRotate tintColor:[UIColor flatBlackColor] size:20.0f];
    [self.view addSubview:activityIndicatorView];
    self.loadingView = activityIndicatorView;
    activityIndicatorView.frame = self.collectionView.bounds;
    [activityIndicatorView startAnimating];
}

- (void)showButtonView
{
    [self hideLoadingOrButtonView];
    UIButton* retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
    retryButton.highlightOnTouch = YES;
    [retryButton setTitle:@"重 试" forState:UIControlStateNormal];
    retryButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightLight];
    retryButton.layer.cornerRadius = 5;
    [retryButton setTitleColor:RYBHEXCOLOR(0x333333) forState:UIControlStateNormal];
    retryButton.layer.borderColor = RYBHEXCOLOR(0x333333).CGColor;
    retryButton.layer.borderWidth = 1;
    [self.view addSubview:retryButton];
    self.loadingView = retryButton;
    [self.loadingView mas_remakeConstraints:^(MASConstraintMaker* make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@(150));
        make.height.equalTo(@(45));
    }];
    [retryButton addTarget:self action:@selector(requestData) forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideLoadingOrButtonView
{
    [self.loadingView removeFromSuperview];
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count + 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    BPSceneSelectCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BPSceneSelectCell class]) forIndexPath:indexPath];
    if (!cell) {
    }
    BPMVScene* scene = nil;
    if (indexPath.row == 0) {
        scene = [[BPMVScene alloc] init];
        scene.is_empty = YES;
    } else {
        scene = [self.dataSource objectAtIndex:indexPath.row - 1];
    }
    scene.is_downloading = [_req_dict containsObjectForKey:scene.zip_path_ios.lastPathComponent];
    cell.scene = scene;
    return cell;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath
{
    BPMVScene* scene = nil;
    if (indexPath.row == 0) {
        scene = [[BPMVScene alloc] init];
        scene.is_empty = YES;
        if (self.selectBlock) {
            self.selectBlock(scene);
        }
        return;
    } else {
        scene = [self.dataSource objectAtIndex:indexPath.row - 1];
    }
    NSString* scene_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene.zip_path_ios.lastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:scene_path]) {
        if (self.selectBlock) {
            self.selectBlock(scene);
        }
    } else {
        if ([DownloadTool shareTool].currentNetworkType == NetworkTypeMobileNet) {
            [[RYBTool shareTool] showAlertWithType:RYBAlertTypeAlert
                                             title:@"当前为移动网络，是否继续下载"
                                               msg:@""
                                           options:@[ @"取消", @"继续" ]
                                          redIndex:1
                                           handler:^(int index) {
                                               if (index == 1) {
                                                   [self downloadSceneZip:scene];
                                               }
                                           }];
        } else {
            [self downloadSceneZip:scene];
        }
    }
}

- (void)downloadSceneZip:(BPMVScene*)scene
{
    WeakSelf;
    NSString* scene_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene.zip_path_ios.lastPathComponent];
    if ([scene.zip_path_ios hasPrefix:@"/var"]) {
        [[NSFileManager defaultManager] copyItemAtPath:scene.zip_path_ios toPath:scene_path error:nil];
        return;
    }
    ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:scene.zip_path_ios]];
    [req setNumberOfTimesToRetryOnTimeout:3];
    [req setDownloadDestinationPath:scene_path];
    [req setCompletionBlock:^{
        scene.is_downloading = NO;
        [_req_dict removeObjectForKey:scene.zip_path_ios.lastPathComponent];
        [weakSelf refreshCollectionView];
        [weakSelf unzipScene:scene];
    }];
    [req setFailedBlock:^{
        [_req_dict removeObjectForKey:scene.zip_path_ios.lastPathComponent];
        [weakSelf refreshCollectionView];
    }];
    [req setStartedBlock:^{
        [weakSelf refreshCollectionView];
    }];
    [_req_dict setObject:req forKey:scene.zip_path_ios.lastPathComponent];
    [req startAsynchronous];
}

- (void)unzipScene:(BPMVScene*)scene
{
    NSString* scene_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene.zip_path_ios.lastPathComponent];
    NSString* dest_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene_path.lastPathComponent.stringByDeletingPathExtension];
    NSString* info_path = [NSString stringWithFormat:@"%@/info.json", dest_path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:info_path]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [SSZipArchive unzipFileAtPath:scene_path
            toDestination:dest_path
            progressHandler:^(NSString* _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
            }
            completionHandler:^(NSString* _Nonnull path, BOOL succeeded, NSError* _Nullable error) {
                if (succeeded) {
                } else {
                    [[NSFileManager defaultManager] removeItemAtPath:dest_path error:nil];
                }
            }];
    });
}


@end
