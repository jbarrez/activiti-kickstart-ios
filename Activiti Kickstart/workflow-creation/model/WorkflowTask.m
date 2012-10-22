//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "WorkflowTask.h"
#import "FormEntry.h"

#define TASK_KEY_NAME @"name"
#define TASK_KEY_DESCRIPTION @"description"
#define TASK_KEY_START_WITH_PREVIOUS @"startWithPrevious"
#define TASK_KEY_FORM @"form"
#define TASK_KEY_ASSIGNEE_TYPE @"assigneeType"
#define TASK_KEY_ASSIGNEE @"assignee"
#define TASK_KEY_CANDIDATE_GROUP @"candidateGroup"

@implementation WorkflowTask

- (id)init
{
    self = [super init];
    if (self)
    {
        self.formEntries = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)addFormEntry:(FormEntry *)formEntry
{
    [self.formEntries addObject:formEntry];
}

- (FormEntry *)formEntryAt:(NSInteger)index
{
    return [self.formEntries objectAtIndex:index];
}

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    if (self)
    {
        self.name = [json valueForKey:TASK_KEY_NAME];

        if ([[json valueForKey:TASK_KEY_DESCRIPTION] class] != [NSNull class])
        {
            self.description = [json valueForKey:TASK_KEY_DESCRIPTION];
        }

        self.startWithPrevious = [[json valueForKey:TASK_KEY_START_WITH_PREVIOUS] boolValue];

        NSString *assigneeType = [json valueForKey:TASK_KEY_ASSIGNEE_TYPE];
        if ([assigneeType isEqualToString:@"user"])
        {
            self.assigneeType = ASSIGNEE_TYPE_USER;
            self.assignee = [json valueForKey:TASK_KEY_ASSIGNEE];
        }
        else if ([assigneeType isEqualToString:@"group"])
        {
            self.assigneeType = ASSIGNEE_TYPE_GROUP;
            self.assignee = [json valueForKey:TASK_KEY_ASSIGNEE];
        }
        else if ([assigneeType isEqualToString:@"initiator"])
        {
            self.assigneeType = ASSIGNEE_TYPE_INITIATOR;
        }

        NSArray *jsonFormEntries = [json valueForKey:TASK_KEY_FORM];
        self.formEntries = [NSMutableArray array];
        if (jsonFormEntries && jsonFormEntries.count > 0)
        {
            for (NSDictionary *jsonFormEntry in jsonFormEntries)
            {
                [self.formEntries addObject:[[FormEntry alloc] initWithJson:jsonFormEntry]];
            }
        }
    }
    return self;
}


- (NSDictionary *)toJson
{
    NSMutableDictionary *taskDict = [NSMutableDictionary dictionary];
    [taskDict setObject:self.name forKey:TASK_KEY_NAME];
    if (self.description != nil)
    {
        [taskDict setObject:self.description forKey:TASK_KEY_DESCRIPTION];
    }
    [taskDict setObject:(self.startWithPrevious ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO]) forKey:TASK_KEY_START_WITH_PREVIOUS];

    if (self.assigneeType == ASSIGNEE_TYPE_USER)
    {
        [taskDict setObject:@"user" forKey:TASK_KEY_ASSIGNEE_TYPE];
        [taskDict setObject:self.assignee forKey:TASK_KEY_ASSIGNEE];
    }
    else if (self.assigneeType == ASSIGNEE_TYPE_GROUP)
    {
        [taskDict setObject:@"group" forKey:TASK_KEY_ASSIGNEE_TYPE];
        [taskDict setObject:self.assignee forKey:TASK_KEY_ASSIGNEE];
    }
    else if (self.assigneeType == ASSIGNEE_TYPE_INITIATOR)
    {
        [taskDict setObject:@"initiator" forKey:TASK_KEY_ASSIGNEE_TYPE];
    }

    NSMutableArray *form = [[NSMutableArray alloc] init];
    [taskDict setObject:form forKey:TASK_KEY_FORM];

    for (uint j = 0; j < self.formEntries.count; j++)
    {
        FormEntry *formEntry = [self.formEntries objectAtIndex:j];
        [form addObject:[formEntry toJson]];
    }

    return taskDict;
}

@end