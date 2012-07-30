//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "WorkflowStepsTableDelegate.h"
#import "WorkflowStepTableCell.h"
#import "WorkflowCreationDelegate.h"
#import "Workflow.h"
#import "WorkflowTask.h"


@implementation WorkflowStepsTableDelegate

@synthesize workflow = _workflow;
@synthesize workflowCreationDelegate = _workflowCreationDelegate;


#pragma mark UITableView delegate and datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.workflow.tasks.count + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    WorkflowStepTableCell *cell = (WorkflowStepTableCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[WorkflowStepTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if (indexPath.section < self.workflow.tasks.count)
    {
        cell.nameLabel.text = [self.workflow taskAtIndex:indexPath.section].name;
    } else if (indexPath.section == self.workflow.tasks.count) {
        cell.nameLabel.text = @"Click to create new task";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Add a new workflow step
    if (indexPath.section == self.workflow.tasks.count) {
        WorkflowTask *workflowTask = [[WorkflowTask alloc] init];
        workflowTask.name = @"New workflow step";
        [self.workflow addTask:workflowTask];
        [tableView reloadData];

        [self.workflowCreationDelegate workflowStepCreated:indexPath.section];
    }
    else
    {
        [self.workflowCreationDelegate workflowStepSelected:indexPath.section];
    }
}

@end