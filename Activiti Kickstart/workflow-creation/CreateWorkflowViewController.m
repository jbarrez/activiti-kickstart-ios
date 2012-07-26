//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "CreateWorkflowViewController.h"
#import "WorkflowStepsTableDelegate.h"
#import "KickstartRestService.h"


@interface CreateWorkflowViewController ()

    // Model
    @property (nonatomic, strong) NSMutableArray *workflowSteps;

    // Views
    @property (nonatomic, strong) UITableView *workflowStepsTable;
    @property (nonatomic, strong) WorkflowStepsTableDelegate *workflowStepsTableDelegate;

    @property (nonatomic, strong) UIButton *launchButton;

@end

@implementation CreateWorkflowViewController

@synthesize workflowSteps = _workflowSteps;
@synthesize workflowStepsTable = _workflowStepsTable;
@synthesize workflowStepsTableDelegate = _workflowStepsTableDelegate;
@synthesize launchButton = _launchButton;


- (id)init
{
    self = [super init];
    if (self)
    {
        self.workflowSteps = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    // Temporary, to check if all is set correctly
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

    // Workflow steps table view
    self.workflowStepsTable = [[UITableView alloc] initWithFrame:CGRectMake(25, 50, 400, 600) style:UITableViewStyleGrouped];
    self.workflowStepsTable.backgroundColor = [UIColor clearColor];
    self.workflowStepsTable.backgroundView = nil; // Otherwise always gray background on ipad
    self.workflowStepsTable.separatorColor = [UIColor clearColor];
    self.workflowStepsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.workflowStepsTable.sectionHeaderHeight = 5.0;
    self.workflowStepsTable.sectionFooterHeight = 5.0;
    [self.view addSubview:self.workflowStepsTable];

    // Workflow steps table delegate
    self.workflowStepsTableDelegate = [[WorkflowStepsTableDelegate alloc] init];
    self.workflowStepsTableDelegate.workflowSteps = self.workflowSteps;
    self.workflowStepsTable.dataSource = self.workflowStepsTableDelegate;
    self.workflowStepsTable.delegate = self.workflowStepsTableDelegate;

    // Launch button
    self.launchButton = [[UIButton alloc] initWithFrame:CGRectMake(450, 300, 100, 100)];
    [self.launchButton setTitle:@"Launch" forState:UIControlStateNormal];
    [self.launchButton addTarget:self action:@selector(launchWorkflow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.launchButton];
}

- (void)launchWorkflow
{
    // Temporary
    [self.launchButton setTitle:@"Deploying..." forState:UIControlStateNormal];

    // Create json representation of workflow
    NSMutableDictionary *workflowDict = [[NSMutableDictionary alloc] init];
    [workflowDict setObject:@"Test Process from iPad" forKey:@"name"];
    [workflowDict setObject:@"Test description" forKey:@"description"];

    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    [workflowDict setObject:tasks forKey:@"tasks"];
    for (uint i = 0; i < self.workflowSteps.count; i++)
    {
        NSString *workflowStep = [self.workflowSteps objectAtIndex:i];
        NSMutableDictionary *task = [[NSMutableDictionary alloc] init];
        [task setObject:workflowStep forKey:@"name"];
        [task setObject:@"Test description" forKey:@"description"];
        [task setObject:@"false" forKey:@"startWithPrevious"];

        [tasks addObject:task];
    }

    // Call Rest service
    KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
    __weak CreateWorkflowViewController *weakSelf = self;
    [kickstartRestService deployWorkflow:workflowDict
        withCompletionBlock:^(NSDictionary *jsonResponse)
        {
            NSLog(@"Deploy done");
            [weakSelf.launchButton setTitle:@"Launch" forState:UIControlStateNormal];
        }
        withFailureBlock:^(NSError *error)
        {
            // TODO: nice error handling
            NSLog(@"Error while deploying workflow: %@", error.localizedDescription);
        }];
}

@end