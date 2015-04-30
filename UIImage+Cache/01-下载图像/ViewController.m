//
//  ViewController.m
//  01-下载图像
//
//  Created by Ai on 15/1/10.
//  Copyright (c) 2015年 joyios. All rights reserved.
//

#import "ViewController.h"
#import "AppInfo.h"
@interface ViewController ()
/**
 *  全局操作队列
 */
@property (nonatomic, strong) NSOperationQueue *opQueue;
/**
 *  操作缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *operationsCache;
/**
 *  图像缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *imagesCache;
/**
 *  应用程序列表
 */
@property (nonatomic, strong) NSArray *appList;
@end

@implementation ViewController

- (NSDictionary *)operationsCache {
    if (_operationsCache == nil) {
        _operationsCache = [[NSMutableDictionary alloc] init];
    }
    return _operationsCache;
}

- (NSMutableDictionary *)imagesCache {
    if (_imagesCache == nil) {
        _imagesCache = [[NSMutableDictionary alloc] init];
    }
    return _imagesCache;
}

- (NSOperationQueue *)opQueue {
    if (_opQueue == nil) {
        _opQueue = [[NSOperationQueue alloc] init];
    }
    return _opQueue;
}

- (NSArray *)appList {
    if (_appList == nil) {
        NSArray *array = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"apps.plist" withExtension:nil]];
        
        NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [arrayM addObject:[AppInfo appInfoWithDict:obj]];
        }];
        _appList = [arrayM copy];
    }
    return _appList;
}

#pragma mark - 数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.appList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppCell"];
    
    // 设置 Cell...
    AppInfo *app = self.appList[indexPath.row];
    
    cell.textLabel.text = app.name;
    cell.detailTextLabel.text = app.download;
    
    if (self.imagesCache[app.icon]) {
        NSLog(@"没有下载");
        cell.imageView.image = self.imagesCache[app.icon];
    } else {
        // 检查沙盒
        NSString *filePath = [self cacheDirWithURLString:app.icon];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSLog(@"从沙盒加载图像");
            
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            [self.imagesCache setObject:image forKey:app.icon];
            cell.imageView.image = image;
        } else {
            cell.imageView.image = [UIImage imageNamed:@"user_default"];
            
            [self downloadImageWithIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (void)downloadImageWithIndexPath:(NSIndexPath *)indexPath {
    
    AppInfo *app = self.appList[indexPath.row];
    
    if (self.operationsCache[app.icon]) {
        NSLog(@"正在玩命下载中...");
        return;
    }
    
    // 设置图像
    NSOperation *downloadOp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"加载网络图片...");
                
        NSURL *url = [NSURL URLWithString:app.icon];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // 将图像保存到沙盒
        [data writeToFile:[self cacheDirWithURLString:app.icon] atomically:YES];
        
        UIImage *image = [UIImage imageWithData:data];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.imagesCache setObject:image forKey:app.icon];
            
            // 删除操作，能够避免出现循环引用！
            [self.operationsCache removeObjectForKey:app.icon];
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }];
    
    [self.opQueue addOperation:downloadOp];
    [self.operationsCache setObject:downloadOp forKey:app.icon];
}

- (NSString *)cacheDirWithURLString:(NSString *)urlString {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

    return [cacheDir stringByAppendingPathComponent:[urlString lastPathComponent]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", self.operationsCache);
}

- (void)dealloc {
    NSLog(@"我走了");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // 清理内存
    [self.imagesCache removeAllObjects];
    [self.operationsCache removeAllObjects];
    
    // 取消所有下载操作
    [self.opQueue cancelAllOperations];
}

@end
