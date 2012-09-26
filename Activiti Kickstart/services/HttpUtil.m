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

+ (void)uploadImageDataWithPostTo:(NSURL *)url withBodyData:(NSData *)bodyData
              withCompletionBlock:(HttpCompletionBlock)completionBlock withFailureBlock:(HttpFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60];

    NSString *boundary = @"----------V2ymHFg03ehbqgZCaKO6jy"; // See http://stackoverflow.com/questions/8564833/ios-upload-image-and-text-using-http-post
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];

    NSMutableData *body = [[NSMutableData alloc] init];
    if (bodyData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.png\"\r\n", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:bodyData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];

    BlockBasedURLConnectionDataDelegate *delegate = [[BlockBasedURLConnectionDataDelegate alloc] init];
    delegate.completionBlock = completionBlock;
    delegate.failureBlock = failureBlock;

    NSLog(@"Executing HTTP POST to %@", url);

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
}

+ (void)executeGET:(NSURL *)url withCompletionBlock:(HttpCompletionBlock)completionBlock withFailureBlock:(HttpFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60];
    [request setHTTPMethod:@"GET"];

    BlockBasedURLConnectionDataDelegate *delegate = [[BlockBasedURLConnectionDataDelegate alloc] init];
    delegate.completionBlock = completionBlock;
    delegate.failureBlock = failureBlock;

    NSLog(@"Executing HTTP GET to %@", url);

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
}

+ (void)executeGETAndReturnRawData:(NSURL *)url
                   withCompletionBlock:(HttpCompletionBlock)completionBlock
                      withFailureBlock:(HttpFailureBlock)failureBlock
                           cacheResult:(BOOL)cacheResult
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
//         cachePolicy:(cacheResult) ? NSURLRequestReturnCacheDataDontLoad : NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
        cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [request setHTTPMethod:@"GET"];

    BlockBasedURLConnectionDataDelegate *delegate = [[BlockBasedURLConnectionDataDelegate alloc] init];
    delegate.completionBlock = completionBlock;
    delegate.failureBlock = failureBlock;
    delegate.parseToJson = NO;

    NSLog(@"Executing HTTP GET to %@", url);

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

- (id)init
{
    self = [super init];
    if (self)
    {
        self.parseToJson = YES; // default
    }
    return self;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.receivedData = [[NSMutableData alloc] init];
    self.statusCode = ((NSHTTPURLResponse *)response).statusCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
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

    if (self.completionBlock != nil && self.parseToJson)
    {
        NSString *jsonString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
        self.completionBlock([JsonUtil parseJSONString:jsonString]);
    }
    else if (self.completionBlock != nil)
    {
        self.completionBlock(self.receivedData);
    }
}

@end