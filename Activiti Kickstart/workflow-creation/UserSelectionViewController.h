//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WorkflowTask;
@protocol WorkflowCreationDelegate;


@interface UserSelectionViewController : UIViewController

@property NSInteger workflowTaskIndex;
@property (nonatomic, strong) WorkflowTask *workflowTask;
@property (nonatomic, strong) id<WorkflowCreationDelegate> workflowCreationDelegate;

@end