//
//  JSONUtil.m
//  Focus
//
//  Created by Tijs Rademakers on 06/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "JSONUtil.h"

@implementation JsonUtil

+ (id) parseJSONString:(NSString *) jsonString
{
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data
                                           options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                             error:nil];
}

+ (NSString *) writeToJSONString:(id) jsonObject
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSData *) writeToJSONData:(id) jsonObject
{
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
}

@end
