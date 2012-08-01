//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WorkflowTask : NSObject

    @property (nonatomic, strong) NSString *name;
    @property (nonatomic, strong) NSString *description;
    @property BOOL isConcurrent;

@end