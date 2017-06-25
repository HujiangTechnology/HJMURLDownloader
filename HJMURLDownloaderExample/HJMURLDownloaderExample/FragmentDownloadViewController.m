//
//  FragmentDownloadViewController.m
//  HJMURLDownloaderExample
//
//  Created by lchen on 24/06/2017.
//  Copyright © 2017 HJ. All rights reserved.
//

#import "FragmentDownloadViewController.h"
#import <HJMURLDownloader/HJMFragmentsDownloadManager.h>
#import <HJMURLDownloader/M3U8Parser.h>

@interface FragmentDownloadViewController () <HJMFragmentsDownloadManagerDelegate>

@property (nonatomic, strong) NSArray *identifierArray;

@end

@implementation FragmentDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.identifierArray = @[@"aaaaaaa", @"bbbbbb", @"ccccccc"];
    [HJMFragmentsDownloadManager defaultManager].delegate = self;
    [self setupUI];
}

- (void)setupUI {
    NSArray *titleArray = @[@"下载任务一", @"下载任务二", @"下载任务三", @"停止下载一", @"停止下载二", @"停止下载三", @"恢复下载"];
    for (int i = 0; i < titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.layer.borderWidth = 1.0f;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        CGRect rect = CGRectMake(20.0f, 80.0f + 50.0f * i, 150.0f, 30.0f);
        button.frame = rect;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)buttonClicked:(UIButton *)button {
    switch (button.tag) {
        case 0:
        case 1:
        case 2:
            // 下载带有不同标示的任务
            [self downloadTaskWithIndex:button.tag];
            break;
        case 3:
        case 4:
        case 5:
            [self stopTaskWithIndex:button.tag];
            break;
        case 6:
            // 恢复下载带有不同标示的任务
            [self resumeTaskWithIndex:button.tag];
            break;
        case 7:
            break;
        default:
            break;
    }
}

- (void)downloadTaskWithIndex:(NSInteger)index {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"localM3u8" ofType:@"txt"];
    NSString *m3u8String = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    M3U8SegmentInfoList *m3u8InfoList = [M3U8Parser m3u8SegmentInfoListFromPlanString:m3u8String];
    m3u8InfoList.segmentInfoList = [NSMutableArray arrayWithArray:[m3u8InfoList.segmentInfoList subarrayWithRange:NSMakeRange(0, 10)]];
    m3u8InfoList.identifier = self.identifierArray[index];
    [[HJMFragmentsDownloadManager defaultManager] downloadFragmentList:m3u8InfoList delegate:self];
}

- (void)stopTaskWithIndex:(NSInteger)index {
    NSString *identifier = self.identifierArray[index % 3];
    [[HJMFragmentsDownloadManager defaultManager] stopDownloadFragmentListWithIdentifier:identifier];
}

- (void)resumeTaskWithIndex:(NSInteger)index {

}

#pragma mark - HJMFragmentsDownloadManagerDelegate

- (void)downloadTaskAddedToQueueWithIdentifer:(NSString *)identifier {
    NSLog(@"add to queue");
}

- (void)downloadTaskBeginWithIdentifier:(NSString *)identifier {
    NSLog(@"task begin: identifier :%@", identifier);
}

- (void)downloadTaskReachProgress:(CGFloat)progress identifier:(NSString *)identifier {
    NSLog(@"download progress : %f  identifier :%@", progress, identifier);
}

- (void)downloadTaskCompleteWithDirectoryPath:(NSString *)directoryPath identifier:(NSString *)identifier {
    NSLog(@"download success with path : %@", directoryPath);
}

- (void)downloadTaskCompleteWithError:(NSError *)error identifier:(NSString *)identifier {
    NSLog(@"download failed with error : %@", error);
}

- (void)fragmentSaveToDiskFailed {
    NSLog(@"save failed");
}


@end