//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "WorkflowStepsTableDelegate.h"
#import "WorkflowStepTableCell.h"
#import "WorkflowCreationDelegate.h"


@implementation WorkflowStepsTableDelegate

@synthesize workflowSteps = _workflowSteps;
@synthesize workflowCreationDelegate = _workflowCreationDelegate;


#pragma mark UITableView delegate and datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.workflowSteps.count + 1;
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

    if (indexPath.section < self.workflowSteps.count)
    {
        cell.nameLabel.text = [self.workflowSteps objectAtIndex:indexPath.section];
    } else if (indexPath.section == self.workflowSteps.count) {
        cell.nameLabel.text = @"Click to create new task";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Add a new workflow step
    if (indexPath.section == self.workflowSteps.count) {
        [self.workflowSteps addObject:@"New workflow step"];
        [tableView reloadData];

        [self.workflowCreationDelegate workflowStepCreated:indexPath.section];
    }
    else
    {
        [self.workflowCreationDelegate workflowStepSelected:indexPath.section];
    }
}

@end