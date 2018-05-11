//
//  MKHttpDownloadFileMD5Tools.h
//  imooc
//
//  Created by k12 on 2018/5/3.
//  Copyright © 2018年 imooc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKHttpDownloadFileMD5Tools : NSObject

#pragma mark - md5 校验视频是否正确
+ (NSString*)fileMD5:(NSString*)path;
@end
