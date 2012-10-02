//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "FormEntry.h"

#define NAME @"name"
#define IS_REQUIRED @"isRequired"
#define TYPE @"type"
#define TYPE_TEXT @"text"
#define TYPE_NUMBER @"number"
#define TYPE_DATE @"date"

@implementation FormEntry

@synthesize name = _name;
@synthesize type = _type;
@synthesize isRequired = _isRequired;

- (id)initWithJson:(NSDictionary *)json
{
    self = [super init];
    if (self)
    {
        self.name = [json valueForKey:NAME];
        self.isRequired = [[json valueForKey:IS_REQUIRED] isEqualToString:@"true"];

        NSString *type = [json valueForKey:TYPE];
        if ([type isEqualToString:TYPE_TEXT])
        {
            self.type = FORM_ENTRY_TYPE_STRING;
        }
        else if ([type isEqualToString:TYPE_NUMBER])
        {
            self.type = FORM_ENTRY_TYPE_INTEGER;
        }
        else if ([type isEqualToString:TYPE_DATE])
        {
            self.type = FORM_ENTRY_TYPE_DATE;
        }
    }
    return self;
}

- (NSDictionary *)toJson
{
    NSMutableDictionary *formEntryDict = [NSMutableDictionary dictionary];

    [formEntryDict setObject:self.name forKey:NAME];
    [formEntryDict setObject:(self.isRequired ? @"true" : @"false") forKey:IS_REQUIRED];

    NSString *type = nil;
    switch (self.type)
    {
        case FORM_ENTRY_TYPE_STRING:
            type = TYPE_TEXT;
            break;
        case FORM_ENTRY_TYPE_INTEGER:
            type = TYPE_NUMBER;
            break;
        case FORM_ENTRY_TYPE_DATE:
            type = TYPE_DATE;
            break;
    }

    [formEntryDict setObject:type forKey:TYPE];

    return formEntryDict;
}


@end