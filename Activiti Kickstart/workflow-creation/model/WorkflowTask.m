//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "WorkflowTask.h"
#import "FormEntry.h"


@implementation WorkflowTask

@synthesize name = _name;
@synthesize description = _description;
@synthesize isConcurrent = isConcurrent;
@synthesize concurrencyType = _concurrencyType;
@synthesize formEntries = _formEntries;

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


@end