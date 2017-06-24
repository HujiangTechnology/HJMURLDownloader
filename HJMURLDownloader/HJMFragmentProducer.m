//
//  HJMFragmentProducer.m
//  Pods
//
//  Created by lchen on 21/06/2017.
//
//

#import "HJMFragmentDBManager.h"
#import "HJMFragmentProducer.h"
#import "HJMFragmentsDownloadManager.h"

@interface HJMFragmentProducer ()

@property (nonatomic, strong) NSMutableArray <M3U8SegmentInfoList *> *pendingFragmentListArray;
@property (nonatomic, assign) NSInteger currentFragmentArrayCount;
@property (nonatomic, strong) HJMFragmentDBManager *dbManager;

@end

@implementation HJMFragmentProducer

- (instancetype)init {
    if (self = [super init]) {
        self.pendingFragmentListArray = [NSMutableArray array];
        self.dbManager = [HJMFragmentDBManager sharedManager];
    }
    return self;
}

- (BOOL)isTableExistInDatabaseWith:(NSString *)identifier {
    return [self.dbManager isTableExist:identifier];
}

- (M3U8SegmentInfoList *)nextFragmentList {
    M3U8SegmentInfoList *list = [self.pendingFragmentListArray firstObject];
    if (list) {
        // 到这里说明要下载下一个队列了，将队列写入数据库
        [self insertFragmentArrayToDatabase:list];
        self.currentFragmentArrayCount = list.segmentInfoList.count;
        // 已经入库，将它从pending array中移除
        [self.pendingFragmentListArray removeObject:list];
    } else {
        // 没有队列了
        if ([self.delegate respondsToSelector:@selector(allFragmentListsHaveRunOut)]) {
            [self.delegate allFragmentListsHaveRunOut];
        }
    }
    return list;
}

- (NSInteger)leftFragmentCountWithIdentifier:(NSString *)identifier {
    return [self.dbManager rowCountInTable:identifier];
}

- (NSInteger)totalCountForCurrentFragmentList {
    return self.currentFragmentArrayCount;
}

- (void)addFragmentsArray:(M3U8SegmentInfoList *)fragmentArray {
    [self.pendingFragmentListArray addObject:fragmentArray];
}

- (NSArray <M3U8SegmentInfo *> *)fragmentsWithIdentifier:(NSString *)identifier originalArray:(M3U8SegmentInfoList *)originalArray limitedCount:(NSInteger)limitedCount {
    // 到这里表示开始下载了 ，既然开始下载，就应该把整个队在数据库中做记录
    self.currentFragmentArrayCount = originalArray.segmentInfoList.count;

    [self insertFragmentArrayToDatabase:originalArray];
    
    // 从数据库中拿数据给返回给manager
    NSArray *fragmentsToDownload = [self.dbManager fragmentsModelWithCount:limitedCount tableName:identifier];
    if (fragmentsToDownload.count == 0) {
        [self.delegate fragmentListHasRunOutWithIdentifier:identifier];
    }
    return fragmentsToDownload;
}

- (M3U8SegmentInfo *)oneMoreFragmentWithIdentifier:(NSString *)identifier {
    if ([self.dbManager rowCountInTable:identifier]) {
        return [self.dbManager oneMoreFragmentModelInTable:identifier];
    } else {
        [self.delegate fragmentListHasRunOutWithIdentifier:identifier];
        return nil;
    }
}

- (void)removeFragmentOutofDatabaseWithFragmentIdentifier:(NSString *)fragmentIdentifer identifier:(NSString *)identifier {
    [self.dbManager removeFragmentModelWithIdentifier:fragmentIdentifer inTable:identifier];
}

- (void)insertFragmentArrayToDatabase:(M3U8SegmentInfoList *)fragmentList {
    if (![self.dbManager isTableExist:fragmentList.identifier]) {
        // 没有这个表，以identifier为表名，将所有的下载队列记录进表
        //        NSString *path = [[NSBundle mainBundle] pathForResource:@"localM3u8" ofType:@"txt"];
        //        NSString *m3u8String = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
        //        M3U8SegmentInfoList *m3u8InfoList = [M3U8Parser m3u8SegmentInfoListFromPlanString:m3u8String];
        //        m3u8InfoList.identifier = identifier;
        [self.dbManager createTableWithName:fragmentList.identifier];
        [self.dbManager insertFragmentModelArray:fragmentList.segmentInfoList toTable:fragmentList.identifier];
        // 已经将数组入库，将它从pending array中移除
        [self removePendingArrayWithIdentifier:fragmentList.identifier];
    }
}

- (void)removePendingArrayWithIdentifier:(NSString *)identifier {
    M3U8SegmentInfoList *itemShouldRemove = nil;
    for (M3U8SegmentInfoList *fragmentList in self.pendingFragmentListArray) {
        if ([fragmentList.identifier isEqualToString:identifier]) {
            itemShouldRemove = fragmentList;
            break;
        }
    }
    if (itemShouldRemove) {
        [self.pendingFragmentListArray removeObject:itemShouldRemove];
    }
}

@end
