//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Workflow.h"

typedef enum
{
    ASSIGNEE_TYPE_NONE,
    ASSIGNEE_TYPE_INITIATOR,
    ASSIGNEE_TYPE_USER,
    ASSIGNEE_TYPE_GROUP
} WORKFLOW_TASK_ASSIGNEE_TYPE;

@class FormEntry;


@interface WorkflowTask : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic) BOOL startWithPrevious;
@property (nonatomic) BOOL isConcurrent; // Indicates that this task is part of a concurrent group of tasks
@property (nonatomic) ConcurrencyType concurrencyType;
@property (nonatomic) WORKFLOW_TASK_ASSIGNEE_TYPE assigneeType;
@property (nonatomic, strong) NSString *assignee;
@property (nonatomic, strong) NSMutableArray *formEntries;

- (id)initWithJson:(NSDictionary *)json;

- (void)addFormEntry:(FormEntry *)formEntry;
- (FormEntry *)formEntryAt:(NSInteger)index;

- (NSDictionary *)toJson;

@end