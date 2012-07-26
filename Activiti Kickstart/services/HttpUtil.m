//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "HttpUtil.h"
#import "JsonUtil.h"


@implementation HttpUtil

+ (void)executePOST:(NSURL *)url withBody:(NSDictionary *)bodyDictionary
    withCompletionBlock:(HttpCompletionBlock)completionBlock
       withFailureBlock:(HttpFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[JsonUtil writeToJSONData:bodyDictionary]];

    BlockBasedURLConnectionDataDelegate *delegate = [[BlockBasedURLConnectionDataDelegate alloc] init];
    delegate.completionBlock = completionBlock;
    delegate.failureBlock = failureBlock;

    NSLog(@"Executing HTTP POST to %@", url);

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
}

@end

#pragma mark Helper class to convert between blocks and delegate

@interface BlockBasedURLConnectionDataDelegate()

@property (nonatomic, strong) NSMutableData *receivedData;
@property NSInteger statusCode;

@end

@implementation BlockBasedURLConnectionDataDelegate

@synthesize completionBlock = _completionBlock;
@synthesize failureBlock = _failureBlock;
@synthesize receivedData = _receivedData;
@synthesize statusCode = _statusCode;


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receivedData = [[NSMutableData alloc] init];
    self.statusCode = ((NSHTTPURLResponse *)response).statusCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.failureBlock != nil)
    {
        self.failureBlock(error);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *resultString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: [%d] %@", self.statusCode, resultString);

    if (self.completionBlock != nil)
    {
        NSString *jsonString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
        self.completionBlock([JsonUtil parseJSONString:jsonString]);
    }
}

@end