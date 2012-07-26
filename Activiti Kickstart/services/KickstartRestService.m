//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "KickstartRestService.h"
#import "JsonUtil.h"

@implementation KickstartRestService

- (void)deployWorkflow:(NSDictionary *)workflowDictionary
   withCompletionBlock:(HttpCompletionBlock)completionBlock
      withFailureBlock:(HttpFailureBlock)failureBlock
{
    [HttpUtil executePOST:[self createRestCallFor:@"/workflow"]
            withBody:workflowDictionary
            withCompletionBlock:completionBlock
            withFailureBlock:failureBlock];
}

#pragma mark Helper methods


- (NSURL *)createRestCallFor:(NSString *)resourceUrlPart
{
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"kickstart-server"];

    if (baseUrl == nil)
    {
        NSLog(@"Warning: user default were nil!");
        baseUrl = @"http://localhost:9000/activiti-kickstart";
    }

    NSString *urlString = [NSString stringWithFormat:@"%@%@", baseUrl, resourceUrlPart];
    return [NSURL URLWithString:urlString];
}

@end