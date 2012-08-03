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

    }
    cell.subscriptLabel.text = [NSString stringWithFormat:@"Type: '%@'  (%@)", type, formEntry.isRequired ? @"required" : @"optional"];

    return cell;
}


@end