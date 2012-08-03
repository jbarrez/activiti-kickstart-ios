//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "WorkflowStepsTableDelegate.h"
#import "WorkflowStepTableCell.h"
#import "WorkflowCreationDelegate.h"
#import "WorkflowTask.h"
#import "UserView.h"


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

    if ([self isWorkflowStep:indexPath]) // workflow step
    {
        WorkflowTask *task = [self.workflow taskAtIndex:indexPath.section];
        cell.nameLabel.text = task.name;
        cell.userView.userPicture.image = [UIImage imageNamed:@"joram.jpg"];

        cell.indentationLevel = 0;
        cell.indentationWidth = 40;

        if (task.isConcurrent)
        {
            cell.indentationLevel = 1;
            cell.concurrencyType = task.concurrencyType;
        }
    }
    else if ([self isLastCell:indexPath]) // Cell to create new step
    {
        cell.nameLabel.text = @"Tap to create new task";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self isWorkflowStep:indexPath]) {
        // Add a new workflow step
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self isWorkflowStep:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self isWorkflowStep:indexPath];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.workflow moveTaskFromIndex:sourceIndexPath.section afterTaskAtIndex:destinationIndexPath.section];
    [self.workflow verifyAndFixTaskConcurrency];
    [tableView reloadData];
}

#pragma mark Helper Methods


- (BOOL)isWorkflowStep:(NSIndexPath *)indexPath
{
    return ![self isLastCell:indexPath];
}

- (BOOL)isLastCell:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.workflow.tasks.count)
    {
          return YES;
    }
    return NO;
}


@end