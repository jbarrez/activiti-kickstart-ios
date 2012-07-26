//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "WorkflowStepsTableDelegate.h"
#import "WorkflowStepTableCell.h"


@implementation WorkflowStepsTableDelegate

@synthesize workflowSteps = _workflowSteps;

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

    // Adding a tag to the name text field such that the text field delegate can easily know which value changed
    cell.nameTextField.tag = indexPath.section;
    cell.nameTextField.delegate = self;

    if (indexPath.section < self.workflowSteps.count)
    {
        cell.nameTextField.text = [self.workflowSteps objectAtIndex:indexPath.section];
        cell.nameTextField.enabled = YES;
    } else if (indexPath.section == self.workflowSteps.count) {
        cell.nameTextField.text = @"Click to create new task";
        cell.nameTextField.enabled = NO;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Add a new workflow step
    if (indexPath.section == self.workflowSteps.count) {
        [self.workflowSteps addObject:@"New workflow step"];
        [tableView reloadData];
    }

    // Select the newly created step
    WorkflowStepTableCell *newCell = (WorkflowStepTableCell *) [tableView cellForRowAtIndexPath:indexPath];
    [newCell.nameTextField becomeFirstResponder];
    [newCell.nameTextField selectAll:self];
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.text == nil || [textField.text isEqualToString:@""])
    {
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.workflowSteps replaceObjectAtIndex:textField.tag withObject:textField.text];
}


@end