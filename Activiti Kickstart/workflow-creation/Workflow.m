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