//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Workflow;


@interface LaunchWorkflowAlertViewDelegate : NSObject <UIAlertViewDelegate>

- (id)initWithWorkflow:(Workflow *)workflow;

@end