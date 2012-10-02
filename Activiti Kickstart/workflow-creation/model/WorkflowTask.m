//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "WorkflowTask.h"
#import "FormEntry.h"

#define TASK_NAME @"name"
#define TASK_DESCRIPTION @"description"
#define TASK_START_WITH_PREVIOUS @"startWithPrevious"
#define TASK_FORM @"form"

@implementation WorkflowTask

@synthesize name = _name;
@synthesize description = _description;
@synthesize isConcurrent = isConcurrent;
@synthesize concurrencyType = _concurrencyType;
@synthesize formEntries = _formEntries;
@synthesize assignee = _assignee;


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
        self.name = [json valueForKey:TASK_NAME];

        if ([[json valueForKey:TASK_DESCRIPTION] class] != [NSNull class])
        {
            self.description = [json valueForKey:TASK_DESCRIPTION];
        }

        self.isConcurrent = [[json valueForKey:TASK_START_WITH_PREVIOUS] isEqualToString:@"true"];

        NSArray *jsonFormEntries = [json valueForKey:TASK_FORM];
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
    [taskDict setObject:self.name forKey:TASK_NAME];
    if (self.description != nil)
    {
        [taskDict setObject:self.description forKey:TASK_DESCRIPTION];
    }
    [taskDict setObject:(self.isConcurrent ? @"true" : @"false") forKey:TASK_START_WITH_PREVIOUS];

    NSMutableArray *form = [[NSMutableArray alloc] init];
    [taskDict setObject:form forKey:TASK_FORM];

    for (uint j = 0; j < self.formEntries.count; j++)
    {
        FormEntry *formEntry = [self.formEntries objectAtIndex:j];
        [form addObject:[formEntry toJson]];
    }

    return taskDict;
}

@end