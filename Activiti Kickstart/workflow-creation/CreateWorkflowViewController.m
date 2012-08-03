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
#import "WorkflowStepTableCell.h"
#import "FormController.h"
#import "FormEntry.h"
#import "FormTableDelegate.h"


@interface CreateWorkflowViewController ()

// Model
@property(nonatomic, strong) Workflow *workflow;

// Workflow steps table
@property(nonatomic, strong) UITableView *workflowStepsTable;
@property(nonatomic, strong) WorkflowStepsTableDelegate *workflowStepsTableDelegate;

@property(nonatomic, strong) UIButton *launchButton;

// Task detail
@property NSInteger currentlySelectedIndex;
@property WorkflowTask *currentlySelectedTask;
@property(nonatomic, strong) UIView *taskDetailsView;
@property(nonatomic, strong) UITextField *nameTextField;
@property(nonatomic, strong) WorkflowStepNameTextFieldHandler *nameTextFieldDelegate;
@property(nonatomic, strong) UITextView *descriptionTextView;
@property(nonatomic, strong) UIButton *createFormEntryButton;
@property(nonatomic, strong) FormController *formController;
@property(nonatomic, strong) UIPopoverController *formPopoverController;
@property(nonatomic, strong) UITableView *formTable;
@property(nonatomic, strong) FormTableDelegate *formTableDelegate;
@property(nonatomic, strong) UILabel *swipeHelpLabel;

@end

@implementation CreateWorkflowViewController


@synthesize workflow = _workflow;
@synthesize workflowStepsTable = _workflowStepsTable;
@synthesize workflowStepsTableDelegate = _workflowStepsTableDelegate;
@synthesize launchButton = _launchButton;
@synthesize taskDetailsView = _taskDetailsView;
@synthesize nameTextField = _nameTextField;
@synthesize nameTextFieldDelegate = _nameTextFieldDelegate;
@synthesize currentlySelectedIndex = _currentlySelectedIndex;
@synthesize currentlySelectedTask = _currentlySelectedTask;
@synthesize descriptionTextView = _descriptionTextView;
@synthesize createFormEntryButton = _createFormEntryButton;
@synthesize formPopoverController = _formPopoverController;
@synthesize formController = _formController;
@synthesize formTable = _formTable;
@synthesize formTableDelegate = _formTableDelegate;
@synthesize swipeHelpLabel = _swipeHelpLabel;


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
    self.workflowStepsTable.editing = YES; // Required to see reorder icons
    self.workflowStepsTable.allowsSelection = YES;
    self.workflowStepsTable.allowsSelectionDuringEditing = YES;
    [self.view addSubview:self.workflowStepsTable];

    // Workflow steps table delegate
    self.workflowStepsTableDelegate = [[WorkflowStepsTableDelegate alloc] init];
    self.workflowStepsTableDelegate.workflow = self.workflow;
    self.workflowStepsTable.dataSource = self.workflowStepsTableDelegate;
    self.workflowStepsTable.delegate = self.workflowStepsTableDelegate;

    // Swipe gesture recognizer
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleWorkflowStepsTableSwipeLeft:)];
    [leftSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.workflowStepsTable addGestureRecognizer:leftSwipeRecognizer];

    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleWorkflowStepsTableSwipeRight:)];
    [rightSwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.workflowStepsTable addGestureRecognizer:rightSwipeRecognizer];

    // Set controller as delegate of workflow events originating from table
    self.workflowStepsTableDelegate.workflowCreationDelegate = self;
}

- (void)handleWorkflowStepsTableSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    // Only possible starting from two steps
    if (self.workflow.tasks.count >= 2)
    {
         // Get location of the swipe
        CGPoint location = [gestureRecognizer locationInView:self.workflowStepsTable];

        // Get the corresponding index path within the table view
        NSIndexPath *indexPath = [self.workflowStepsTable indexPathForRowAtPoint:location];

        // Check if index path is valid
        if(indexPath != nil && indexPath.section < self.workflow.tasks.count)
        {
            // Update model
            [self makeTaskParallel:indexPath];

            if (indexPath.section != (self.workflow.tasks.count - 1))
            {
                // Make the next one concurrent, unless the previous one is concurrent already. Sounds complicated, I know.
                if (![self.workflow isConcurrentTaskAtIndex:(indexPath.section - 1)])
                {
                    [self makeTaskParallel:[NSIndexPath indexPathForRow:0 inSection:(indexPath.section + 1)]];
                }
            }
            else // If it's the last step, make the previous one parallel
            {
                [self makeTaskParallel:[NSIndexPath indexPathForRow:0 inSection:(indexPath.section - 1)]];
            }

            // Reload the table
            [self.workflow verifyAndFixTaskConcurrency];
            [self.workflowStepsTable reloadData];
        }
    }
}

- (void)makeTaskParallel:(NSIndexPath *)indexPath
{
    WorkflowTask *task = (WorkflowTask *) [self.workflow.tasks objectAtIndex:indexPath.section];
    task.isConcurrent = YES;
}

- (void)handleWorkflowStepsTableSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    // Get location of the swipe
    CGPoint location = [gestureRecognizer locationInView:self.workflowStepsTable];

    // Get the corresponding index path within the table view
    NSIndexPath *indexPath = [self.workflowStepsTable indexPathForRowAtPoint:location];

    // Check if index path is valid
    if (indexPath != nil && indexPath.section < self.workflow.tasks.count)
    {
        // Update model
        [self makeTaskNormal:indexPath];
        [self.workflow verifyAndFixTaskConcurrency];

        // Reload the table
        [self.workflowStepsTable reloadData];
    }
}

- (void)makeTaskNormal:(NSIndexPath *)indexPath
{
    WorkflowTask *task = (WorkflowTask *) [self.workflow.tasks objectAtIndex:indexPath.section];
    task.isConcurrent = NO;
}

- (void)showDetailsForWorkflowStep:(NSUInteger)stepIndex
{
    self.currentlySelectedIndex = stepIndex;
    self.currentlySelectedTask = [self.workflow taskAtIndex:stepIndex];

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

        UIView *nameTextFieldBg = [[UIView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
                        nameLabel.frame.origin.y + nameLabel.frame.size.height + 4, nameLabel.frame.size.width - 100, 30)]; // See http://stackoverflow.com/questions/2694411/text-inset-for-uitextfield
        nameTextFieldBg.layer.cornerRadius = 5;
        nameTextFieldBg.layer.masksToBounds = YES;
        nameTextFieldBg.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        nameTextFieldBg.layer.borderWidth = 1.0;
        [self.view addSubview:nameTextFieldBg];

        self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(nameTextFieldBg.frame.origin.x + 10,
                nameTextFieldBg.frame.origin.y, nameTextFieldBg.frame.size.width - 20, nameTextFieldBg.frame.size.height)];
        self.nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.nameTextField.backgroundColor = [UIColor clearColor];

        self.nameTextFieldDelegate = [[WorkflowStepNameTextFieldHandler alloc] init];
        self.nameTextField.delegate = self.nameTextFieldDelegate;
        [self.nameTextField addTarget:self action:@selector(workflowStepNameChanged) forControlEvents:UIControlEventEditingChanged];

        [self.view addSubview:self.nameTextField];

        // Description label
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
                self.nameTextField.frame.origin.y + self.nameTextField.frame.size.height + 10, nameLabel.frame.size.width, 20)];
        descriptionLabel.font = nameLabel.font;
        descriptionLabel.text = @"Description";
        [self.view addSubview:descriptionLabel];

        // Description text view
        self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x,
                descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 4, nameLabel.frame.size.width, 80)];
        self.descriptionTextView.layer.masksToBounds = YES;
        self.descriptionTextView.layer.cornerRadius = 5;
        self.descriptionTextView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.descriptionTextView.layer.borderWidth = 1.0;
        self.descriptionTextView.delegate = self;
        [self.view addSubview:self.descriptionTextView];

        // Form label
        UILabel *formLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x,
                self.descriptionTextView.frame.origin.y + self.descriptionTextView.frame.size.height + 20, nameLabel.frame.size.width, 20)];
        formLabel.font = nameLabel.font;
        formLabel.text = @"Form";
        [self.view addSubview:formLabel];

        // Add icon
        UIImage *createFormEntryImage = [UIImage imageNamed:@"add.png"];
        self.createFormEntryButton = [[UIButton alloc] initWithFrame:CGRectMake(formLabel.frame.origin.x + 455,
                formLabel.frame.origin.y, createFormEntryImage.size.width, createFormEntryImage.size.height)];
        [self.createFormEntryButton setImage:createFormEntryImage forState:UIControlStateNormal];
        [self.createFormEntryButton addTarget:self action:@selector(createFormEntryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.createFormEntryButton];

        // Form table
        self.formTable = [[UITableView alloc] initWithFrame:CGRectMake(formLabel.frame.origin.x,
                formLabel.frame.origin.y + formLabel.frame.size.height + 10, nameLabel.frame.size.width, 330) style:UITableViewStylePlain];
        self.formTable.allowsSelection = NO;
        self.formTable.editing = YES;
        self.formTable.backgroundColor = [UIColor whiteColor];
        self.formTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.formTable.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
        self.formTable.layer.borderWidth = 1.0;
        self.formTable.layer.cornerRadius = 5.0;
        self.formTable.layer.masksToBounds = YES;
        [self.view addSubview:self.formTable];

        self.formTableDelegate = [[FormTableDelegate alloc] init];
        self.formTable.dataSource = self.formTableDelegate;
        self.formTable.delegate = self.formTableDelegate;
    }

    // Change to details of selected task
    self.nameTextField.text = [self.workflow taskAtIndex:stepIndex].name;
    self.descriptionTextView.text = [self.workflow taskAtIndex:stepIndex].description;
    self.formTableDelegate.workflowTask = self.currentlySelectedTask;
    [self.formTable reloadData];
}

// Handling of description input field
- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.currentlySelectedTask.description = textView.text;
}

- (void)createFormEntryButtonTapped
{
    self.formController = [[FormController alloc] init];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
         style:UIBarButtonItemStyleBordered target:self action:@selector(saveNewFormEntry)];
    saveButton.tintColor = [UIColor colorWithRed:0.44 green:0.66 blue:0.99 alpha:0.18];
    self.formController.navigationItem.rightBarButtonItem = saveButton;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.formController];

    self.formPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    [self.formPopoverController setPopoverContentSize:CGSizeMake(400, 180)];

    [self.formPopoverController presentPopoverFromRect:self.createFormEntryButton.frame
                          inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void)saveNewFormEntry
{
    [self.currentlySelectedTask addFormEntry:[self.formController generateFormEntry]];
    [self.formTable reloadData];
    [self.formPopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.formController = nil;
    self.formPopoverController = nil;
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
    self.currentlySelectedTask.name = self.nameTextField.text;

    // Update the name of the workflow step in the steps table
    [self.workflowStepsTable reloadSections:[NSIndexSet indexSetWithIndex:self.currentlySelectedIndex]
            withRowAnimation:UITableViewRowAnimationFade];
}

@end