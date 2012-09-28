//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Workflow;
@class CreateWorkflowViewController;


@interface LaunchWorkflowAlertViewDelegate : NSObject <UIAlertViewDelegate>

@property (nonatomic, weak) CreateWorkflowViewController *createWorkflowViewController;

- (id)initWithWorkflow:(Workflow *)workflow;

@end