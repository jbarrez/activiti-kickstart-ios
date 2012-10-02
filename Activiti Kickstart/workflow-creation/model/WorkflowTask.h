//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Workflow.h"

@class FormEntry;


@interface WorkflowTask : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *description;
@property BOOL isConcurrent;
@property ConcurrencyType concurrencyType;
@property (nonatomic, strong) NSString *assignee;
@property NSMutableArray *formEntries;

- (id)initWithJson:(NSDictionary *)json;

- (void)addFormEntry:(FormEntry *)formEntry;
- (FormEntry *)formEntryAt:(NSInteger)index;

- (NSDictionary *)toJson;

@end