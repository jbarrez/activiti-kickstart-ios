//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "KickstartRestService.h"
#import "JsonUtil.h"
#import "Workflow.h"

@implementation KickstartRestService

- (void)deployWorkflow:(Workflow *)workflow
   withCompletionBlock:(HttpCompletionBlock)completionBlock
      withFailureBlock:(HttpFailureBlock)failureBlock
{
    NSDictionary *workflowDictionary = [workflow toJson];

    if (workflow.isExistingWorkflow)
    {
        [HttpUtil executePUT:[self createRestCallFor:@"/workflow"]
                   withBody:workflowDictionary
                   withCompletionBlock:completionBlock
                   withFailureBlock:failureBlock];
    }
    else
    {
        [HttpUtil executePOST:[self createRestCallFor:@"/workflow"]
            withBody:workflowDictionary
            withCompletionBlock:completionBlock
            withFailureBlock:failureBlock];
    }
}

- (void)retrieveWorkflowsWithCompletionBlock:(HttpCompletionBlock)completionBlock
                            withFailureBlock:(HttpFailureBlock)failureBlock
{
    [HttpUtil executeGET:[self createRestCallFor:@"/workflows"] withCompletionBlock:completionBlock withFailureBlock:failureBlock];
}

- (void)retrieveWorkflowInfo:(NSString *)workflowId completionBlock:(HttpCompletionBlock)completionBlock withFailureBlock:(HttpFailureBlock)failureBlock
{
    [HttpUtil executeGET:[self createRestCallFor:[NSString stringWithFormat:@"/workflow/%@", workflowId]] withCompletionBlock:completionBlock withFailureBlock:failureBlock];
}

- (void)deleteWorkflow:(NSString *)workflowId completionBlock:(HttpCompletionBlock)completionBlock withFailureBlock:(HttpFailureBlock)failureBlock
{
    [HttpUtil executeDELETE:[self createRestCallFor:[NSString stringWithFormat:@"/workflow/%@", workflowId]] withCompletionBlock:completionBlock withFailureBlock:failureBlock];
}

- (void)uploadWorkflowImage:(NSString *)workflowId
                      image:(NSData *)imageData
        withCompletionBlock:(HttpCompletionBlock)completionBlock
           withFailureBlock:(HttpFailureBlock)failureBlock;
{

    [HttpUtil uploadImageDataWithPostTo:[self createRestCallFor:[NSString stringWithFormat:@"/workflow/%@/image", workflowId]]
                           withBodyData:imageData withCompletionBlock:completionBlock withFailureBlock:failureBlock];
}

- (void)retrieveWorkflowImage:(NSString *)workflowId withCompletionBlock:(HttpCompletionBlock)completionBlock withFailureBlock:(HttpFailureBlock)failureBlock
{
    [HttpUtil executeGETAndReturnRawData:[self createRestCallFor:[NSString stringWithFormat:@"/workflow/%@/image", workflowId]]
                     withCompletionBlock:completionBlock withFailureBlock:failureBlock cacheResult:YES];
}

- (void)retrieveWorkflowJson:(NSString *)workflowId withCompletionBlock:(HttpCompletionBlock)completionBlock withFailureBlock:(HttpFailureBlock)failureBlock
{
    [HttpUtil executeGET:[self createRestCallFor:[NSString stringWithFormat:@"/workflow/%@/metadata/json-source", workflowId]]
                     withCompletionBlock:completionBlock withFailureBlock:failureBlock];
}

- (void)retrieveUsersWithCompletionBlock:(HttpCompletionBlock)completionBlock withFailureBlock:(HttpFailureBlock)failureBlock
{
    [HttpUtil executeGET:[self createRestCallFor:@"/users"] withCompletionBlock:completionBlock withFailureBlock:failureBlock];
}

- (void)retrieveGroupsWithCompletionBlock:(HttpCompletionBlock)completionBlock withFailureBlock:(HttpFailureBlock)failureBlock
{
    [HttpUtil executeGET:[self createRestCallFor:@"/groups"] withCompletionBlock:completionBlock withFailureBlock:failureBlock];
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