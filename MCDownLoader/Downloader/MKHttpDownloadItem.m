



//
//  MKHttpDownloadItem.m
//  imooc
//
//  Created by k12 on 2018/5/3.
//  Copyright © 2018年 imooc. All rights reserved.
//

#import "MKHttpDownloadItem.h"

@implementation MKHttpDownloadItem

- (BOOL)isTs{
    NSString * url = self.downloadURL;
    
    NSURL *tmp = [NSURL URLWithString:url];
    
    BOOL isTs = NO;
    if (tmp.query) {
        if ([tmp.path.pathExtension isEqualToString:@"ts"]) {
            isTs = YES;
        }
    }else{
        if ([url.pathExtension isEqualToString:@"ts"]) {
            isTs = YES;
        }
    }
    return isTs;
}
@end
