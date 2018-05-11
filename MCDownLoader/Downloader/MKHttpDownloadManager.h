//
//  MKHttpDownloadManager.h
//  imooc
//
//  Created by k12 on 2018/5/3.
//  Copyright © 2018年 imooc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKHttpDownloadConst.h"
@interface MKHttpDownloadManager : NSObject
/**
 *  只限制 item 下载状态改变时是否需要通知  YES: 发送通知, NO: 不发送通知
 *  在添加下载任务时全部更新MKCacheCourseViewController中的状态, 不需要发送通知.
 *  通知结果: 更新 MKCacheCourseViewController界面状态
 */
@property (nonatomic,assign)BOOL needsNotification;
+ (id) sharedDownloadManager;
- (BOOL) downloadItem:(MKHttpDownloadItem *) downloadItem
     withStartHandler:(void(^)(void)) startHandler
withDownloadingHandler:(void(^)(long long downloadBytes,long long totalBytes)) downloadingHandler
    withFinishHandler:(void(^)(NSURLSessionDownloadTask*downloadTask,NSURL*location)) finishHandler
      withFailHandler:(void(^)(NSError*error,NSURLSessionTask*downloadTask)) failHandler;
- (void) stopDownloadTaskCompleted:(void(^)(void))completed;

//销毁session
- (void)cancelsAllOutstandingTasks;
@end
