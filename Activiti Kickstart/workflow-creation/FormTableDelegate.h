//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Workflow;
@class WorkflowTask;


@interface FormTableDelegate : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) WorkflowTask *workflowTask;

@end