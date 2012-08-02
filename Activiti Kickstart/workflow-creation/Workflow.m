//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "Workflow.h"
#import "WorkflowTask.h"

@implementation Workflow

@synthesize name = _name;
@synthesize tasks = _tasks;

- (void)addTask:(WorkflowTask *)workflowTask
{
    if (self.tasks == nil)
    {
        self.tasks = [[NSMutableArray alloc] init];
    }

    [((NSMutableArray *)self.tasks) addObject:workflowTask];
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
            [((NSMutableArray *)self.tasks) insertObject:srcTask atIndex:(dstIndex + 1)];
            [((NSMutableArray *)self.tasks) removeObjectAtIndex:srcIndex];
        }
        else if (dstIndex != self.tasks.count)// Moving to the front of the row
        {
            [((NSMutableArray *)self.tasks) insertObject:srcTask atIndex:dstIndex];
            [((NSMutableArray *)self.tasks) removeObjectAtIndex:(srcIndex + 1)];
        }
    }
}

@end