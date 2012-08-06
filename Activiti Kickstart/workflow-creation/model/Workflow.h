//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    CONCURRENCY_TYPE_FIRST,
    CONCURRENCY_TYPE_NORMAL,
    CONCURRENCY_TYPE_LAST
} ConcurrencyType;

@class WorkflowTask;

@interface Workflow : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *tasks;

- (void)addTask:(WorkflowTask *)workflowTask;

- (WorkflowTask *)taskAtIndex:(NSUInteger)index;

- (BOOL)isConcurrentTaskAtIndex:(NSUInteger)taskIndex;

- (ConcurrencyType)concurrencyTypeForTaskAtIndex:(NSUInteger)taskIndex;

- (void)verifyAndFixTaskConcurrency;

- (void)moveTaskFromIndex:(NSUInteger)srcIndex afterTaskAtIndex:(NSUInteger)dstIndex;

- (NSMutableDictionary *)generateJson;

@end