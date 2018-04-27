//
//  MCDownloaderManager.h
//  MCDownLoader
//
//  Created by k12 on 2018/4/26.
//  Copyright © 2018年 k12. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCDownloadError.h"
@class MCDownloadItem,MCDownloadManager;
@protocol MCDownloadManagerDelegate <NSObject>

- (void) vodDownloadManager:(MCDownloadManager *) downloadManager didBeginDownloadVODDownloadItem:(MCDownloadItem *) vodDownloadItem;
- (void) vodDownloadManager:(MCDownloadManager *) downloadManager downloadingVODDownloadItem:(MCDownloadItem *) vodDownloadItem;
- (void) vodDownloadManager:(MCDownloadManager *) downloadManager didFinishDownloadVODDownloadItem:(MCDownloadItem *) vodDownloadItem;
- (void) vodDownloadManager:(MCDownloadManager *) downloadManager didFailDownloadVODDownloadItem:(MCDownloadItem *) vodDownloadItem withFailType:(MCDownloadErrorType) errorType;

@end
@interface MCDownloadManager : NSObject
+ (id) sharedManager;
@property (nonatomic, readonly) NSArray *vodItemsList;
@property (nonatomic,weak)id<MCDownloadManagerDelegate>delegate;

- (MCDownloadItem *) createVodDownLoadItemWithVideoId:(NSString *)videoId;

- (BOOL) isExistInDownLoadListWithVideoId:(NSString *)videoId;
- (NSArray *) vodDownloadItemsListWithVideoId:(NSString *) videoId;

- (void) startDownloadWithVODItem:(MCDownloadItem *) downloadItem;
- (void) pauseDownloadWithVODItem:(MCDownloadItem *) downloadItem;
- (void) cleanDownloadWithVODItem:(MCDownloadItem *) downloadItem;
- (void) startAllDownloads;
- (void) pauseAllDownloads;
- (void) cleanAllDownloads;
@end
