/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Alfresco Mobile App.
 *
 * The Initial Developer of the Original Code is Zia Consulting, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2011-2012
 * the Initial Developer. All Rights Reserved.
 *
 *
 * ***** END LICENSE BLOCK ***** */

//
// ProcessViewController 
//
#import <QuartzCore/QuartzCore.h>
#import "ProcessViewController.h"
#import "KickstartRestService.h"
#import "MBProgressHUD.h"
#import "UIAlertView+BlockExtensions.h"
#import "Workflow.h"
#import "CreateWorkflowViewController.h"

#define CELL_HEIGHT 60.0

@interface ProcessViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *workflows;
@property (nonatomic, strong) UITableView *workflowTable;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIView *previewBackground;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *trashButton;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSDictionary *selectedWorkflow;


@end

@implementation ProcessViewController

- (void)loadView
{
    [super loadView];

    // General
    self.title = @"Workflows";
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

    // Workflow table
    self.workflowTable = [[UITableView alloc] init];
    self.workflowTable.delegate = self;
    self.workflowTable.dataSource = self;
    self.workflowTable.layer.cornerRadius = 20.0;
    [self.view addSubview:self.workflowTable];

    // Image
    self.previewBackground = [[UIView alloc] init];
    self.previewBackground.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    self.previewBackground.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.63].CGColor;
    self.previewBackground.layer.borderWidth = 2.0;
    self.previewBackground.layer.shadowColor = [UIColor blackColor].CGColor;
    self.previewBackground.layer.shadowRadius = 10.0;
    self.previewBackground.layer.cornerRadius = 10;
    [self.view addSubview:self.previewBackground];

    self.editButton = [[UIButton alloc] init];
    self.editButton.contentMode = UIViewContentModeScaleAspectFit;
    [self.editButton addTarget:self action:@selector(editButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editButton];

    // Name label
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:13];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.nameLabel];

    // Date label
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.textColor = [UIColor whiteColor];
    self.dateLabel.font = [UIFont systemFontOfSize:13];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.dateLabel];

    // Trash button
    self.trashButton = [[UIButton alloc] init];
    [self.trashButton setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
    self.trashButton.hidden = YES;
    [self.trashButton addTarget:self action:@selector(trashButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.trashButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self loadWorkflows];
}

- (void)loadWorkflows
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    hud.labelText = @"Retrieving workflows";

    // Reset state
    self.selectedIndexPath = nil;
    self.selectedWorkflow = nil;
    self.dateLabel.text = nil;
    self.nameLabel.text = nil;
    [self.editButton setImage:nil forState:UIControlStateNormal];
    self.trashButton.hidden = YES;

    // Fetch workflows
    KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
    [kickstartRestService retrieveWorkflowsWithCompletionBlock:^ (NSArray *workflows)
    {
        self.workflows = workflows;
        [self.workflowTable reloadData];
        [self calculateFrames];
        [hud hide:NO];
    } withFailureBlock:^(NSError *error)
    {
        [hud hide:NO];
        [self showAlert:[NSString stringWithFormat:@"Error while retrieving workflows: %@", error.localizedDescription]];
    }];
}

- (void)calculateFrames
{

    // Workflow table
    CGFloat workflowTableHeight = MIN(550.0, CELL_HEIGHT * (self.workflows.count > 0 ? self.workflows.count : 1));
    CGRect workflowTableFrame = CGRectMake(20.0, (self.view.frame.size.height - workflowTableHeight) / 2, 400, workflowTableHeight - 1); // -1 or you see white border
    self.workflowTable.frame = workflowTableFrame;

    // Preview image
    CGRect previewImageFrame = CGRectMake(workflowTableFrame.origin.x + workflowTableFrame.size.width + 60.0, 137, 500.0, 375);
    self.editButton.frame = previewImageFrame;

    // Preview background
    CGFloat previewMarginX = 30.0;
    CGFloat previewMarginY = 20.0;
    CGRect previewBackgroundFrame = CGRectMake(previewImageFrame.origin.x - previewMarginX, previewImageFrame.origin.y - previewMarginY,
            previewImageFrame.size.width + 2 * previewMarginX, previewImageFrame.size.height + 2 * previewMarginY);
    self.previewBackground.frame = previewBackgroundFrame;

    // Labels
    CGRect nameLabelFrame = CGRectMake(previewBackgroundFrame.origin.x,
            previewBackgroundFrame.origin.y + previewBackgroundFrame.size.height + 10.0,
            previewBackgroundFrame.size.width, 20.0);
    self.nameLabel.frame = nameLabelFrame;

    CGRect dateLabelFrame = CGRectMake(nameLabelFrame.origin.x, nameLabelFrame.origin.y + nameLabelFrame.size.height + 5.0,
            nameLabelFrame.size.width, nameLabelFrame.size.height);
    self.dateLabel.frame = dateLabelFrame;

    // Trash button
    CGSize trashImageSize = [self.trashButton imageForState:UIControlStateNormal].size;
    CGRect trashButtonFrame = CGRectMake(previewBackgroundFrame.origin.x + ((previewBackgroundFrame.size.width - trashImageSize.width) / 2),
            dateLabelFrame.origin.y + dateLabelFrame.size.height + 10.0, trashImageSize.width, trashImageSize.height);
    self.trashButton.frame = trashButtonFrame;
}

#pragma mark UITableView delegate/datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (self.workflows.count > 0) ? self.workflows.count : 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell * cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if (self.workflows.count > 0)
    {
        NSDictionary *workflow = [self.workflows objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.text = [workflow valueForKey:@"name"];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        if (self.selectedIndexPath != nil && self.selectedIndexPath.row == indexPath.row)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else
    {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.text = @"No workflows found";
        cell.textLabel.textColor = [UIColor grayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.workflows.count > 0)
    {
        if (self.selectedIndexPath == nil || (self.selectedIndexPath != nil & self.selectedIndexPath.row != indexPath.row))
        {
            // Show workflow as selected
            NSIndexPath *previousSelected = self.selectedIndexPath;
            self.selectedIndexPath = indexPath;

            [self.workflowTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, previousSelected, nil] withRowAnimation:UITableViewRowAnimationNone];
            [self.workflowTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

            // Show HUD when fetching image
            if (self.hud)
            {
                [self.hud hide:NO];
            }
            self.hud = [MBProgressHUD showHUDAddedTo:self.editButton animated:YES];

            // Switch details label
            self.selectedWorkflow = [self.workflows objectAtIndex:indexPath.row];
            self.nameLabel.text = [self.selectedWorkflow valueForKey:@"name"];
            self.trashButton.hidden = NO;

            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd MMMM yyyy HH:mm"];
            NSNumber *creationTime = [self.selectedWorkflow valueForKey:@"createTime"];
            self.dateLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(creationTime.longLongValue / 1000)]];

            // Fetch image
            KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
            [kickstartRestService retrieveWorkflowImage:[self.selectedWorkflow valueForKey:@"id"]
                withCompletionBlock:^ (NSData *data)
                {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    [self.editButton setImage:image forState:UIControlStateNormal];
                    [self.hud hide:YES];
                    self.hud = nil;
                }
                withFailureBlock:^ (NSError *error)
                {
                    NSLog(@"Could not retrieve workflow image: %@", error.localizedDescription);
                    [self.hud hide:YES];
                    self.hud = nil;
                }];
        }
    }
}

#pragma Workflow deletion

- (void)trashButtonTapped
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    // Fetch the number of runtime instances
    NSString *workflowId = [self.selectedWorkflow valueForKey:@"id"];
    KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
    [kickstartRestService retrieveWorkflowInfo:workflowId completionBlock:^(NSDictionary *jsonResponse)
    {
        // Get number of instances from response
        long numberOfRuntimeInstances = ((NSNumber *) [jsonResponse valueForKey:@"nrOfRuntimeInstances"]).longValue;

        // Remove HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        // Show warning
        [self showWorkflowDeletionAlertView:workflowId nrOfInstances:numberOfRuntimeInstances];
    }
    withFailureBlock:^(NSError *error)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self showAlert:[NSString stringWithFormat:@"Error while retrieving workflow: %@", error.localizedDescription]];
    }];
}

- (void)showWorkflowDeletionAlertView:(NSString *)workflowId nrOfInstances:(long)nrOfInstances
{
    NSString *warningMessage = [NSString stringWithFormat:@"Are you sure you want to delete workflow '%@'?%@",
                  [self.selectedWorkflow valueForKey:@"name"],
                  (nrOfInstances > 0) ? [NSString stringWithFormat:@" Note that this wel also delete %ld instance%@ of this workflow!", nrOfInstances, (nrOfInstances == 1) ? @"" : @"s"] : @""];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Delete workflow '%@'", [self.selectedWorkflow valueForKey:@"name"]]
            message:warningMessage
            completionBlock:^ (NSUInteger buttonIndex, UIAlertView *uiAlertView)
            {
                if (buttonIndex == 1)
                {
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hud.labelText = @"Removing workflow";

                    KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
                    [kickstartRestService deleteWorkflow:workflowId completionBlock:^ (id response)
                    {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self loadWorkflows];
                    }
                    withFailureBlock:^(NSError *error)
                    {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self showAlert:[NSString stringWithFormat:@"Error while removing workflow: %@", error.localizedDescription]];
                    }];
                }
            } cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, I'm sure", nil];
    [alertView show];
}

#pragma mark Button targets

- (void)editButtonTapped
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
    [kickstartRestService retrieveWorkflowJson:[self.selectedWorkflow valueForKey:@"id"]
        withCompletionBlock:^ (NSDictionary *json)
        {
            Workflow *workflow = [[Workflow alloc] initWithJson:json];
            [MBProgressHUD hideHUDForView:self.view animated:YES];

            // Show createWorkflowViewController with this workflow
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showWorkflowCreation" object:nil userInfo:[NSDictionary dictionaryWithObject:workflow forKey:@"workflow"]];
        }
        withFailureBlock:^ (NSError *error)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self showAlert:[NSString stringWithFormat:@"Error while retrieving workflow: %@", error.localizedDescription]];
        }];
}

#pragma mark Helpers

- (void)showAlert:(NSString *)alertMessage
{
    UIAlertView *errorAlertView = [[UIAlertView alloc]
                initWithTitle:nil message:alertMessage
                     delegate:nil cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [errorAlertView show];
}

@end