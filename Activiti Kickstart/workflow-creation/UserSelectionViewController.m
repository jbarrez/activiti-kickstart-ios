//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "UserSelectionViewController.h"
#import "UserView.h"
#import "WorkflowTask.h"
#import "WorkflowCreationDelegate.h"
#import "MBProgressHUD.h"
#import "KickstartRestService.h"

typedef enum {
    STATE_TYPE_SELECTION,
    STATE_USER_SELECTION,
    STATE_GROUP_SELECTION
} STATE;

@interface UserSelectionViewController()  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) STATE state;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *users;
@property (nonatomic, strong) NSDictionary *groups;

@end

@implementation UserSelectionViewController
@synthesize workflowTask = _workflowTask;
@synthesize workflowTaskIndex = _workflowTaskIndex;


- (void)loadView
{
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];
    self.state = STATE_TYPE_SELECTION;

    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self calculateFrames];
}

- (void)calculateFrames
{
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark TableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.state)
    {
        case STATE_TYPE_SELECTION:
        {
            return 3;
        }
        case STATE_USER_SELECTION:
        {
            NSArray *usersArray = [self.users objectForKey:@"people"];
            return usersArray.count;
        }
        case STATE_GROUP_SELECTION:
        {
            NSArray *groupArray = [self.groups objectForKey:@"data"];
            return groupArray.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    // reset state
    cell.imageView.image = nil;
    cell.textLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    switch (self.state)
    {
        case STATE_TYPE_SELECTION:
        {
            [self cellForTypeSelection:indexPath cell:cell];
            break;
        }
        case STATE_USER_SELECTION:
        {
            NSArray *usersArray = [self.users objectForKey:@"people"];
            NSDictionary *user = [usersArray objectAtIndex:indexPath.row];
            NSString *firstName = [user objectForKey:@"firstName"];
            NSString *lastName = [user objectForKey:@"lastName"];

            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            cell.detailTextLabel.text = [user objectForKey:@"email"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            break;
        }
        case STATE_GROUP_SELECTION:
        {
            NSArray *groupArray = [self.groups objectForKey:@"data"];
            NSDictionary *group = [groupArray objectAtIndex:indexPath.row];

            cell.textLabel.text = [group objectForKey:@"displayName"];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.imageView.image = [UIImage imageNamed:@"group_black.png"];
            break;
        }
    }

    return cell;
}

- (void)cellForTypeSelection:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    switch (indexPath.row)
    {
        case 0:
        {
            cell.textLabel.text = @"Person who initiates the workflow";
            cell.imageView.image = [UIImage imageNamed:@"initiator.png"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 1:
        {
            cell.textLabel.text = @"Single person";
            cell.imageView.image = [UIImage imageNamed:@"user.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 2:
        {
            cell.textLabel.text = @"Group of persons";
            cell.imageView.image = [UIImage imageNamed:@"group.png"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
    }

    cell.textLabel.font = [UIFont systemFontOfSize:18];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.state != STATE_TYPE_SELECTION)
    {
        return 40.0;
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (self.state)
    {
        case STATE_USER_SELECTION:
        {
            return @"Select a user";
        }
        case STATE_GROUP_SELECTION:
        {
            return @"Select a group of users";
        }
        default:
        {
            return nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.state)
    {
        case STATE_TYPE_SELECTION:
        {
            [self didSelectTypeWithIndexPath:indexPath];
            break;
        }
        case STATE_USER_SELECTION:
        {
            NSArray *usersArray = [self.users objectForKey:@"people"];
            NSDictionary *user = [usersArray objectAtIndex:indexPath.row];

            self.workflowTask.assigneeType = ASSIGNEE_TYPE_USER;
            self.workflowTask.assignee = [user objectForKey:@"userName"];

            [self assigneeSelectionFinished];
            break;
        }
        case STATE_GROUP_SELECTION:
        {
            NSArray *groupArray = [self.groups objectForKey:@"data"];
            NSDictionary *group = [groupArray objectAtIndex:indexPath.row];

            self.workflowTask.assigneeType = ASSIGNEE_TYPE_GROUP;
            self.workflowTask.assignee = [group objectForKey:@"fullName"];

            [self assigneeSelectionFinished];
            break;
        }
    }
}

- (void)didSelectTypeWithIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            self.workflowTask.assigneeType = ASSIGNEE_TYPE_INITIATOR;
            [self assigneeSelectionFinished];
            break;
        }
        case 1:
        {
            [self showHUD];
            self.state = STATE_USER_SELECTION;

            KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
            [kickstartRestService retrieveUsersWithCompletionBlock:^(NSDictionary *json)
            {
                self.users = json;
                [self.tableView reloadData];
                [self hideHUD];
            }
            withFailureBlock:^(NSError *error, NSInteger statusCode)
            {
                NSLog(@"Error while retrieving users: %@", error.description);
                [self hideHUD];
            }];
            break;
        }
        case 2:
        {
            [self showHUD];
            self.state = STATE_GROUP_SELECTION;

            KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
            [kickstartRestService retrieveGroupsWithCompletionBlock:^(NSDictionary *json)
            {
                self.groups = json;
                [self.tableView reloadData];
                [self hideHUD];
            }
            withFailureBlock:^(NSError *error, NSInteger statusCode)
            {
                NSLog(@"Error while retrieving groups: %@", error.description);
                [self hideHUD];
            }];
            break;
        }
    }
}

- (void)assigneeSelectionFinished
{
    [self.workflowCreationDelegate workflowStepUpdated:self.workflowTaskIndex];
}

#pragma mark HUD helper methods

- (void)showHUD
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)hideHUD
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end