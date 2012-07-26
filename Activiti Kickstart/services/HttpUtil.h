//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HttpCompletionBlock)(NSDictionary *jsonResponse);
typedef void (^HttpFailureBlock)(NSError *error);

@interface HttpUtil : NSObject

+ (void)executePOST:(NSURL *)url withBody:(NSDictionary *)bodyDictionary
        withCompletionBlock:(HttpCompletionBlock)completionBlock
        withFailureBlock:(HttpFailureBlock)failureBlock;

@end

@interface BlockBasedURLConnectionDataDelegate : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, strong) HttpCompletionBlock completionBlock;
@property (nonatomic, strong) HttpFailureBlock failureBlock;

@end