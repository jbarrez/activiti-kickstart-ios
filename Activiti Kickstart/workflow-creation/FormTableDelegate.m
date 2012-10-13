//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "FormTableDelegate.h"
#import "WorkflowTask.h"
#import "FormEntryCell.h"
#import "FormEntry.h"


@implementation FormTableDelegate

@synthesize workflowTask = _workflowTask;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.workflowTask.formEntries.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FormEntryCell *cell = (FormEntryCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[FormEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    FormEntry *formEntry = [self.workflowTask formEntryAt:indexPath.row];
    cell.nameLabel.text = formEntry.name;

    NSString *type = nil;
    switch (formEntry.type)
    {
        case FORM_ENTRY_TYPE_STRING:
            type = @"text";
            break;
        case FORM_ENTRY_TYPE_INTEGER:
            type = @"number";
            break;
        case FORM_ENTRY_TYPE_DATE:
            type = @"date";
            break;
        case FORM_ENTRY_TYPE_DOCUMENTS:
            type = @"documents";
            break;
    }
    cell.subscriptLabel.text = [NSString stringWithFormat:@"Type: '%@'  (%@)", type, formEntry.isRequired ? @"required" : @"optional"];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    int srcIndex = sourceIndexPath.row;
    int dstIndex = destinationIndexPath.row;

    if (srcIndex != dstIndex)
    {
        FormEntry *srcFormEntry = [self.workflowTask formEntryAt:srcIndex];

        if (srcIndex < dstIndex) // Moving to the end of row
        {
            [self.workflowTask.formEntries insertObject:srcFormEntry atIndex:(dstIndex + 1)];
            [self.workflowTask.formEntries removeObjectAtIndex:srcIndex];
        }
        else // Moving to the front of the row
        {
            [self.workflowTask.formEntries insertObject:srcFormEntry atIndex:dstIndex];
            [self.workflowTask.formEntries removeObjectAtIndex:(srcIndex + 1)];
        }
    }
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.workflowTask.formEntries removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }

}


@end