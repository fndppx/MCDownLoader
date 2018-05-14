//
//  ViewController.m
//  MCDownLoader
//
//  Created by k12 on 2018/4/26.
//  Copyright © 2018年 k12. All rights reserved.
//

#import "ViewController.h"
#import "MKHttpDownloadManager.h"
#import "MKHttpDownloadFileManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@",NSHomeDirectory());
     NSArray * array = @[@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.2.4.dmg",
                        @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                        @"http://baobab.wdjcdn.com/14525705791193.mp4",
                        @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                        @"http://baobab.wdjcdn.com/1455968234865481297704.mp4",
                        @"http://vhot.dnion.videocdn.qq.com/l00237gbcoc.mp4?vkey=1DA6D16B4A77947B875B2B55C3CE57AD2DDC0ECC01DBE185E39DA9424BA832DB659F017C7AD2FA639CE4D66244741BF6513BE33D0B3E751D46D93B8F64DCEE3C6BBBF7008D57749937C297A30EB07F6F74506140F72A2EEE8E877B33C2F4BEA433A9BABBC25D175FAA3374E0A42547A0"];

    MKHttpDownloadItem * item = [[MKHttpDownloadItem alloc]init];
    item.downloadURL = array[0];
    item.totalBytesWritten = 0;
    item.filePath = [[MKHttpDownloadItem fileStorageDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@".%@",item.downloadURL.pathExtension]];
    [[MKHttpDownloadManager sharedDownloadManager]downloadItem:item withStartHandler:^{
        
    } withDownloadingHandler:^(long long downloadBytes, long long totalBytes) {
        
    } withFinishHandler:^(NSURLSessionDownloadTask *downloadTask, NSURL *location) {
        
        [MKHttpDownloadFileManager moveDownloadedItemToFilePath:item atLocation:location];
    } withFailHandler:^(NSError *error, NSURLSessionTask *downloadTask) {
        
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
