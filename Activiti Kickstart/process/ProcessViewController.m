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

#define CELL_HEIGHT 60.0

@interface ProcessViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *workflows;
@property (nonatomic, strong) UILabel *workflowTableHeader;
@property (nonatomic, strong) UITableView *workflowTable;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIView *previewBackground;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) MBProgressHUD *hud;


@end

@implementation ProcessViewController

- (void)loadView
{
    [super loadView];

    // General
    self.title = @"Workflows";
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

    // Workflow table header
    self.workflowTableHeader = [[UILabel alloc] init];
    self.workflowTableHeader.backgroundColor = [UIColor clearColor];
    self.workflowTableHeader.font = [UIFont boldSystemFontOfSize:16];
    self.workflowTableHeader.textColor = [UIColor whiteColor];
    self.workflowTableHeader.numberOfLines = 2;
    self.workflowTableHeader.text = @"Following workflows are deployed to Alfresco:";
    [self.view addSubview:self.workflowTableHeader];

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

    self.previewImageView = [[UIImageView alloc] init];
    self.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.previewImageView];

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    hud.labelText = @"Retrieving workflows";

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
        NSLog(@"Could not retrieve workflows: %@", error.localizedDescription);
    }];
}

- (void)calculateFrames
{
    // Workflow table
    CGFloat workflowTableHeight = MIN(550.0, CELL_HEIGHT * self.workflows.count);
    CGRect workflowTableFrame = CGRectMake(20.0, (self.view.frame.size.height - workflowTableHeight) / 2, 400.0, workflowTableHeight - 1); // -1 or you see white border
    self.workflowTable.frame = workflowTableFrame;

    // Workflow table header
    CGRect workflowTableHeaderFrame = CGRectMake(40.0, workflowTableFrame.origin.y - 65.0, workflowTableFrame.size.width, 50.0);
    self.workflowTableHeader.frame = workflowTableHeaderFrame;

    // Preview image
    CGRect previewImageFrame = CGRectMake(workflowTableFrame.origin.x + workflowTableFrame.size.width + 60.0, 137, 500.0, 375);
    self.previewImageView.frame = previewImageFrame;

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
}

#pragma mark UITableView delegate/datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.workflows.count;
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

    NSDictionary *workflow = [self.workflows objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
    cell.textLabel.text = [workflow valueForKey:@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    if (self.selectedIndexPath != nil && self.selectedIndexPath.row == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedIndexPath == nil || (self.selectedIndexPath != nil & self.selectedIndexPath.row != indexPath.row))
    {
        NSIndexPath *previousSelected = self.selectedIndexPath;
        self.selectedIndexPath = indexPath;

        [self.workflowTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, previousSelected, nil] withRowAnimation:UITableViewRowAnimationNone];
        [self.workflowTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];

        // Fetch image
        if (self.hud)
        {
            [self.hud hide:NO];
        }
        self.hud = [MBProgressHUD showHUDAddedTo:self.previewImageView animated:YES];

        NSDictionary *workflow = [self.workflows objectAtIndex:indexPath.row];

        self.nameLabel.text = [workflow valueForKey:@"name"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd MMMM yyyy HH:mm"];
        NSNumber *creationTime = [workflow valueForKey:@"createTime"];
        self.dateLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(creationTime.longValue / 1000)]];

        KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
        [kickstartRestService retrieveWorkflowImage:[workflow valueForKey:@"id"]
            withCompletionBlock:^ (NSData *data)
            {
                UIImage *image = [[UIImage alloc] initWithData:data];
                self.previewImageView.image = image;
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

@end