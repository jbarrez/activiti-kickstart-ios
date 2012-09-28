//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^HttpCompletionBlock)(id jsonResponse);
typedef void (^HttpFailureBlock)(NSError *error);

@interface HttpUtil : NSObject

+ (void)executePOST:(NSURL *)url withBody:(NSDictionary *)bodyDictionary
        withCompletionBlock:(HttpCompletionBlock)completionBlock
        withFailureBlock:(HttpFailureBlock)failureBlock;

+ (void)uploadImageDataWithPostTo:(NSURL *)url withBodyData:(NSData *)bodyData
              withCompletionBlock:(HttpCompletionBlock)completionBlock
                 withFailureBlock:(HttpFailureBlock)failureBlock;

+ (void)executeGET:(NSURL *)url withCompletionBlock:(HttpCompletionBlock)completionBlock
  withFailureBlock:(HttpFailureBlock)failureBlock;

+ (void)executeDELETE:(NSURL *)url withCompletionBlock:(HttpCompletionBlock)completionBlock
  withFailureBlock:(HttpFailureBlock)failureBlock;

+ (void)executeGETAndReturnRawData:(NSURL *)url
                   withCompletionBlock:(HttpCompletionBlock)completionBlock
                      withFailureBlock:(HttpFailureBlock)failureBlock
                           cacheResult:(BOOL)cacheResult;
@end

@interface BlockBasedURLConnectionDataDelegate : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, strong) HttpCompletionBlock completionBlock;
@property (nonatomic, strong) HttpFailureBlock failureBlock;
@property (nonatomic) BOOL parseToJson;

@end