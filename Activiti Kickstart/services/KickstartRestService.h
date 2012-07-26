//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpUtil.h"

@interface KickstartRestService : NSObject

-(void)deployWorkflow:(NSDictionary *)workflowDictionary
  withCompletionBlock:(HttpCompletionBlock)completionBlock
       withFailureBlock:(HttpFailureBlock)failureBlock;

@end