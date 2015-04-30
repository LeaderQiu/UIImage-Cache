//
//  AppInfo.m
//  01-下载图像
//
//  Created by Ai on 15/1/10.
//  Copyright (c) 2015年 joyios. All rights reserved.
//

#import "AppInfo.h"

@implementation AppInfo
+ (instancetype)appInfoWithDict:(NSDictionary *)dict {
    id obj = [[self alloc] init];
    
    [obj setValuesForKeysWithDictionary:dict];
    
    return obj;
}
@end
