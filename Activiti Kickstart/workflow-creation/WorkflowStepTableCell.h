//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Workflow.h"

@class UserView;

@interface WorkflowStepTableCell : UITableViewCell

@property (nonatomic, strong) UserView *userView;
@property (nonatomic, strong) UILabel *nameLabel;
@property ConcurrencyType concurrencyType;

@end