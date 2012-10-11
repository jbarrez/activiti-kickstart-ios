//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "Workflow.h"
#import "WorkflowTask.h"
#import "FormEntry.h"

#define WORKFLOW_NAME @"name"
#define WORKFLOW_TASKS @"tasks"

@implementation Workflow

@synthesize name = _name;
@synthesize tasks = _tasks;

- (void)addTask:(WorkflowTask *)workflowTask
{
    if (self.tasks == nil)
    {
        self.tasks = [[NSMutableArray alloc] init];
    }

    [self.tasks addObject:workflowTask];
}

- (WorkflowTask *)taskAtIndex:(NSUInteger)index
{
    return [self.tasks objectAtIndex:index];
}

- (BOOL)isConcurrentTaskAtIndex:(NSUInteger)taskIndex
{
    if (taskIndex < self.tasks.count)
    {
        WorkflowTask *task = [self.tasks objectAtIndex:taskIndex];
        return task.isConcurrent;
    }
    return NO;
}

- (ConcurrencyType)concurrencyTypeForTaskAtIndex:(NSUInteger)taskIndex
{
    if ((taskIndex == 0 && [self isConcurrentTaskAtIndex:taskIndex]) || ![self isConcurrentTaskAtIndex:(taskIndex - 1)])
    {
        return CONCURRENCY_TYPE_FIRST;
    }
    else if (![self isConcurrentTaskAtIndex:(taskIndex + 1)])
    {
        return CONCURRENCY_TYPE_LAST;
    }
    else
    {
        return CONCURRENCY_TYPE_NORMAL;
    }
}

- (void)verifyAndFixTaskConcurrency
{
    for (uint i = 0; i < self.tasks.count; i++)
    {
        WorkflowTask *task = [self.tasks objectAtIndex:i];
        if (task.isConcurrent)
        {
            task.concurrencyType = [self concurrencyTypeForTaskAtIndex:i];

            WorkflowTask *previousTask = (i > 0) ? (WorkflowTask *) [self.tasks objectAtIndex:(i-1)] : nil;
            WorkflowTask *nextTask = (i < self.tasks.count - 1) ? (WorkflowTask *) [self.tasks objectAtIndex:(i+1)] : nil;

            if ( (previousTask == nil || !previousTask.isConcurrent) && (nextTask == nil || !nextTask.isConcurrent) )
            {
                task.isConcurrent = NO;
            }
            else
            {
                if (previousTask != nil && previousTask.isConcurrent) {
                    task.startWithPrevious = YES;
                }
            }

        }
    }
}

- (void)moveTaskFromIndex:(NSUInteger)srcIndex afterTaskAtIndex:(NSUInteger)dstIndex;
{
    if (srcIndex != dstIndex)
    {
        WorkflowTask *srcTask = [self.tasks objectAtIndex:srcIndex];

        if (srcIndex < dstIndex && (dstIndex != self.tasks.count) ) // Moving to the end of row
        {
            [self.tasks insertObject:srcTask atIndex:(dstIndex + 1)];
            [self.tasks removeObjectAtIndex:srcIndex];
        }
        else if (dstIndex != self.tasks.count)// Moving to the front of the row
        {
            [self.tasks insertObject:srcTask atIndex:dstIndex];
            [self.tasks removeObjectAtIndex:(srcIndex + 1)];
        }
    }
}

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    if (self)
    {
        self.isExistingWorkflow = YES;

        self.name = [json valueForKey:WORKFLOW_NAME];

        NSArray *jsonTasks = [json valueForKey:WORKFLOW_TASKS];
        self.tasks = [NSMutableArray array];
        if (jsonTasks != nil && jsonTasks.count > 0)
        {
            for (NSDictionary *jsonTask in jsonTasks)
            {
                [self.tasks addObject:[[WorkflowTask alloc] initWithJson:jsonTask]];
            }
        }

        // Fix task concurrency
        for (uint i=0; i<self.tasks.count; i++)
        {
            WorkflowTask *task = [self.tasks objectAtIndex:i];
            if (task.startWithPrevious)
            {
                task.isConcurrent = YES;

                WorkflowTask *previousTask = [self.tasks objectAtIndex:(i-1)];
                previousTask.isConcurrent = YES;
            }
        }
        [self verifyAndFixTaskConcurrency]; // Will set the concurrency type
    }
    return self;
}

- (NSMutableDictionary *)toJson
{
    NSMutableDictionary *workflowDict = [[NSMutableDictionary alloc] init];
    [workflowDict setObject:self.name forKey:WORKFLOW_NAME];

    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    [workflowDict setObject:tasks forKey:WORKFLOW_TASKS];
    for (uint i = 0; i < self.tasks.count; i++)
    {
        WorkflowTask *workflowTask = [self.tasks objectAtIndex:i];
        [tasks addObject:[workflowTask toJson]];
    }

    return workflowDict;
}

@end