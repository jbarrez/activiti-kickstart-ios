//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    FORM_ENTRY_TYPE_STRING,
    FORM_ENTRY_TYPE_INTEGER,
    FORM_ENTRY_TYPE_DATE
} FormEntryType;

@interface FormEntry : NSObject

@property (nonatomic, strong) NSString *name;
@property FormEntryType type;
@property BOOL isRequired;

- (id)initWithJson:(NSDictionary *)json;
- (NSDictionary *)toJson;

@end