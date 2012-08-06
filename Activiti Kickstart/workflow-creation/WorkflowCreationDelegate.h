//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

@protocol WorkflowCreationDelegate <NSObject>

- (void)workflowStepCreated:(NSUInteger)stepIndex;

- (void)workflowStepSelected:(NSUInteger)stepIndex;

- (void)workflowStepUpdated:(NSUInteger)stepIndex;

@end