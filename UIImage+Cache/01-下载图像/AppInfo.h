//
//  AppInfo.h
//  01-下载图像
//
//  Created by Ai on 15/1/10.
//  Copyright (c) 2015年 joyios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppInfo : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *download;

+ (instancetype)appInfoWithDict:(NSDictionary *)dict;
@end
