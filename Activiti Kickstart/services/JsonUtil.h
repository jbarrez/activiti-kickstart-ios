//
//  JSONUtil.h
//  Focus
//
//  Created by Tijs Rademakers on 06/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonUtil : NSObject

+ (id) parseJSONString:(NSString *) jsonString;
+ (NSString *) writeToJSONString:(id) jsonObject;
+ (NSData *) writeToJSONData:(id) jsonObject;

@end
