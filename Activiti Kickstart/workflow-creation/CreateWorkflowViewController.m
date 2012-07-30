//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "CreateWorkflowViewController.h"
#import "WorkflowStepsTableDelegate.h"
#import "KickstartRestService.h"
#import "WorkflowStepNameTextFieldHandler.h"
#import "Workflow.h"
#import "WorkflowTask.h"


@interface CreateWorkflowViewController ()

    // Model
    @property (nonatomic, strong) Workflow *workflow;

    // Workflow steps table
    @property (nonatomic, strong) UITableView *workflowStepsTable;
    @property (nonatomic, strong) WorkflowStepsTableDelegate *workflowStepsTableDelegate;

    @property (nonatomic, strong) UIButton *launchButton;

    // Task detail
    @property NSUInteger currentSelectedStepIndex;
    @property (nonatomic, strong) UIView *taskDetailsView;
    @property (nonatomic, strong) UITextField *nameTextField;
    @property (nonatomic, strong) WorkflowStepNameTextFieldHandler *nameTextFieldDelegate;

@end

@implementation CreateWorkflowViewController


@synthesize workflow = _workflow;
@synthesize workflowStepsTable = _workflowStepsTable;
@synthesize workflowStepsTableDelegate = _workflowStepsTableDelegate;
@synthesize launchButton = _launchButton;
@synthesize taskDetailsView = _taskDetailsView;
@synthesize nameTextField = _nameTextField;
@synthesize nameTextFieldDelegate = _nameTextFieldDelegate;
@synthesize currentSelectedStepIndex = _currentSelectedStepIndex;


- (id)init
{
    self = [super init];
    if (self)
    {
        self.workflow = [[Workflow alloc] init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];

    self.title = @"My Workflow";
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

    [self createWorkflowStepsTable];
//    [self createLaunchButton];
}

- (void)createWorkflowStepsTable
{
    // Workflow steps table view
    self.workflowStepsTable = [[UITableView alloc] initWithFrame:CGRectMake(25, 20, 400, 600) style:UITableViewStyleGrouped];
    self.workflowStepsTable.backgroundColor = [UIColor clearColor];
    self.workflowStepsTable.backgroundView = nil; // Otherwise always gray background on ipad
    self.workflowStepsTable.separatorColor = [UIColor clearColor];
    self.workflowStepsTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.workflowStepsTable.sectionHeaderHeight = 5.0;
    self.workflowStepsTable.sectionFooterHeight = 5.0;
    [self.view addSubview:self.workflowStepsTable];

    // Workflow steps table delegate
    self.workflowStepsTableDelegate = [[WorkflowStepsTableDelegate alloc] init];
    self.workflowStepsTableDelegate.workflow = self.workflow;
    self.workflowStepsTable.dataSource = self.workflowStepsTableDelegate;
    self.workflowStepsTable.delegate = self.workflowStepsTableDelegate;

    // Set controller as delegate of workflow events originating from table
    self.workflowStepsTableDelegate.workflowCreationDelegate = self;
}

- (void)showDetailsForWorkflowStep:(NSUInteger)stepIndex
{
    self.currentSelectedStepIndex = stepIndex;

    // Create view if not yet created
    if (self.taskDetailsView == nil)
    {
        CGFloat detailX = 450;
        CGFloat detailY = 25;

        // Background
        self.taskDetailsView = [[UIView alloc] initWithFrame:CGRectMake(detailX, detailY, 540, 610)];
        self.taskDetailsView.backgroundColor = [UIColor whiteColor];
        self.taskDetailsView.layer.cornerRadius = 30.f;
        self.taskDetailsView.layer.masksToBounds = YES;
        [self.view addSubview:self.taskDetailsView];

        // Name Label
        CGFloat margin = 20;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(detailX + margin, detailY + margin,
                self.taskDetailsView.frame.size.width - 2*margin, 20)];
        nameLabel.font = [UIFont systemFontOfSize:18];
        nameLabel.text = @"Name";
        [self.view addSubview:nameLabel];

        // Name text field
        self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
                nameLabel.frame.origin.y + nameLabel.frame.size.height + 4, nameLabel.frame.size.width - margin, 30)];
        self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;

        self.nameTextFieldDelegate = [[WorkflowStepNameTextFieldHandler alloc] init];
        self.nameTextField.delegate = self.nameTextFieldDelegate;
        [self.nameTextField addTarget:self action:@selector(workflowStepNameChanged) forControlEvents:UIControlEventEditingChanged];

        [self.view addSubview:self.nameTextField];
    }

    // Change to details of selected task
    self.nameTextField.text = [self.workflow taskAtIndex:stepIndex].name;
}

- (void)createLaunchButton
{
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
    for (uint i = 0; i < self.workflow.tasks.count; i++)
    {
        NSString *workflowStep = [self.workflow.tasks objectAtIndex:i];
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

#pragma mark WorkflowCreationDelegate

- (void)workflowStepCreated:(NSUInteger)stepIndex
{
    // Show task detail view for the selected step
    [self showDetailsForWorkflowStep:stepIndex];

    // Make the name textfield the first responder
    [self.nameTextField becomeFirstResponder];
    [self.nameTextField selectAll:self];
}

- (void)workflowStepSelected:(NSUInteger)stepIndex
{
    // Show task detail view for the selected step
    [self showDetailsForWorkflowStep:stepIndex];
}

- (void)workflowStepNameChanged
{
    // Update the model
    WorkflowTask *workflowTask = [self.workflow taskAtIndex:self.currentSelectedStepIndex];
    workflowTask.name = self.nameTextField.text;

    // Update the name of the workflow step in the steps table
    [self.workflowStepsTable reloadSections:[NSIndexSet indexSetWithIndex:self.currentSelectedStepIndex]
            withRowAnimation:UITableViewRowAnimationFade];
}

@end