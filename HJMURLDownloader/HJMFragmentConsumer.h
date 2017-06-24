//
//  HJMFragmentConsumer.h
//  Pods
//
//  Created by lchen on 21/06/2017.
//
//

#import <Foundation/Foundation.h>
#import "M3U8SegmentInfo.h"

@protocol HJMFragmentConsumerDelegate <NSObject>

@required
- (M3U8SegmentInfo *)oneMoreFragmentWithIdentifier:(NSString *)identifier;

- (void)oneFragmentDownloadedWithFragmentIdentifier:(NSString *)fragmentIdentifier identifier:(NSString *)identifier;

- (void)downloadTaskDidCompleteWithError:(NSError *)error identifier:(NSString *)identifier;

- (NSString *)currentDownloadingIdentifier;

@end

@interface HJMFragmentConsumer : NSObject

@property (nonatomic, weak) id<HJMFragmentConsumerDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL isBusy;

- (instancetype)initWithLimitedConcurrentCount:(NSInteger)count isSupportBackground:(BOOL)isSupportBackground backgroundIdentifier:(NSString *)backgroundIdentifier;

- (void)handleEventsForBackgroundURLSession:(NSString *)aBackgroundURLSessionIdentifier completionHandler:(void (^)())aCompletionHandler;

- (void)startToDownloadFragmentArray:(NSArray <M3U8SegmentInfo *> *)fragmentArray arrayIdentifer:(NSString *)identifier;

@end
