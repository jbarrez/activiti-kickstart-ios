//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WorkflowStepsTableDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

    @property (nonatomic, strong) NSMutableArray *workflowSteps;

@end