//
//  HJMFragmentDBManager.h
//  Pods
//
//  Created by lchen on 21/06/2017.
//
//

#import <Foundation/Foundation.h>
#import "M3U8SegmentInfo.h"

@interface HJMFragmentDBManager : NSObject

+ (instancetype)sharedManager;

- (void)createTableWithName:(NSString *)tableName;

- (NSArray <M3U8SegmentInfo *> *)fragmentsModelWithCount:(NSInteger)count tableName:(NSString *)tableName;

- (M3U8SegmentInfo *)oneMoreFragmentModelInTable:(NSString *)tableName;

- (void)insertFragmentModelArray:(NSMutableArray <M3U8SegmentInfo *> *)fragmentModels toTable:(NSString *)tableName;

- (void)markFragmentModelDoneWithIdentifier:(NSString *)fragmentIdentifier inTable:(NSString *)tableName;

- (NSInteger)leftRowCountInTable:(NSString *)tableName;

- (BOOL)allFragmentsHaveDownloadedWithIdentifier:(NSString *)identifier;

- (BOOL)isTableExist:(NSString *)tableName;

- (void)dropTable:(NSString *)tableName;

@end
