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
#import "UserView.h"
#import "UserSelectionViewController.h"
#import "LaunchWorkflowViewController.h"
#import "MBProgressHUD.h"


@interface CreateWorkflowViewController ()

@property (nonatomic) BOOL isEditingExistingWorkflow;

// Model
@property(nonatomic, strong) Workflow *workflow;

// Workflow steps table
@property(nonatomic, strong) UITableView *workflowStepsTable;
@property(nonatomic, strong) WorkflowStepsTableDelegate *workflowStepsTableDelegate;

// Task detail
@property NSInteger currentlySelectedIndex;
@property WorkflowTask *currentlySelectedTask;
@property(nonatomic, strong) UIView *taskDetailsView;
@property (nonatomic, strong) UIImageView *paperclipImageView;
@property (nonatomic, strong) UserView *userView;
@property(nonatomic, strong) UITextField *nameTextField;
@property(nonatomic, strong) WorkflowStepNameTextFieldHandler *nameTextFieldDelegate;
@property(nonatomic, strong) UITextView *descriptionTextView;
@property(nonatomic, strong) UIButton *createFormEntryButton;
@property(nonatomic, strong) FormController *formController;
@property(nonatomic, strong) UIPopoverController *currentPopoverController;
@property(nonatomic, strong) UITableView *formTable;
@property(nonatomic, strong) FormTableDelegate *formTableDelegate;

@end

@implementation CreateWorkflowViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.workflow = [[Workflow alloc] init];
        self.isEditingExistingWorkflow = NO;
    }
    return self;
}

- (void)editWorkflow:(Workflow *)workflow
{
    self.isEditingExistingWorkflow = YES;

    // Update workflow for table
    self.workflow = workflow;
    self.workflowStepsTableDelegate.workflow = workflow;
    [self.workflowStepsTable reloadData];

    // Remove right side detail panel
   [self clearRightSide];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!self.isEditingExistingWorkflow)
    {
         // Update workflow for table
        self.workflow = [[Workflow alloc] init];
        self.workflowStepsTableDelegate.workflow = self.workflow;
        [self.workflowStepsTable reloadData];
    }

    // Remove right side detail panel
    [self clearRightSide];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isEditingExistingWorkflow = NO;
}


- (void)clearRightSide
{
    [self.taskDetailsView removeFromSuperview];
    self.taskDetailsView = nil;
    [self.paperclipImageView removeFromSuperview]; // It is silly I have to do this. But it was thwe quickest solution.
}

- (void)loadView
{
    [super loadView];

    self.title = @"Create Workflow";
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];

    UIBarButtonItem *launchButton = [[UIBarButtonItem alloc] initWithTitle:@"Launch"
            style:UIBarButtonItemStyleBordered target:self action:@selector(launchWorkflow)];
    launchButton.tintColor = [UIColor colorWithRed:0.44 green:0.66 blue:0.99 alpha:0.18];
    self.navigationItem.rightBarButtonItem = launchButton;

    [self createViews];
}

- (void)createViews
{
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
        // Background
        self.taskDetailsView = [[UIView alloc] initWithFrame:CGRectMake(450, 25, 540, 610)];
        self.taskDetailsView.backgroundColor = [UIColor whiteColor];
        self.taskDetailsView.layer.cornerRadius = 30.f;
        self.taskDetailsView.layer.masksToBounds = YES;
        [self.view addSubview:self.taskDetailsView];

        // Name Label
        CGFloat margin = 20;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin,
                self.taskDetailsView.frame.size.width - 2*margin, 20)];
        nameLabel.font = [UIFont systemFontOfSize:18];
        nameLabel.text = @"Name";
        [self.taskDetailsView addSubview:nameLabel];

        // Name text field

        UIView *nameTextFieldBg = [[UIView alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
                        nameLabel.frame.origin.y + nameLabel.frame.size.height + 4, nameLabel.frame.size.width - 100, 30)]; // See http://stackoverflow.com/questions/2694411/text-inset-for-uitextfield
        nameTextFieldBg.layer.cornerRadius = 5;
        nameTextFieldBg.layer.masksToBounds = YES;
        nameTextFieldBg.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        nameTextFieldBg.layer.borderWidth = 1.0;
        [self.taskDetailsView addSubview:nameTextFieldBg];

        self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(nameTextFieldBg.frame.origin.x + 10,
                nameTextFieldBg.frame.origin.y, nameTextFieldBg.frame.size.width - 20, nameTextFieldBg.frame.size.height)];
        self.nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.nameTextField.backgroundColor = [UIColor clearColor];

        self.nameTextFieldDelegate = [[WorkflowStepNameTextFieldHandler alloc] init];
        self.nameTextField.delegate = self.nameTextFieldDelegate;
        [self.nameTextField addTarget:self action:@selector(workflowStepNameChanged) forControlEvents:UIControlEventEditingChanged];

        [self.taskDetailsView addSubview:self.nameTextField];

        // User picture
        self.userView = [[UserView alloc] initWithFrame:CGRectMake(
                self.nameTextField.frame.origin.x + self.nameTextField.frame.size.width + 2*margin - 5,
                nameLabel.frame.origin.y - 8, 70, 70)];
        self.userView.transform = CGAffineTransformMakeRotation(10.0 / 180.0 * M_PI);
        [self.taskDetailsView addSubview:self.userView];

        UIGestureRecognizer *userTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped)];
        [self.userView addGestureRecognizer:userTapRecognizer];

        // Paperclip
        self.paperclipImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paperclip.png"]];
        self.paperclipImageView.frame = CGRectMake(900, 19, self.paperclipImageView.image.size.width, self.paperclipImageView.image.size.height);
        [self.view addSubview:self.paperclipImageView];

        // Description label
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
                self.nameTextField.frame.origin.y + self.nameTextField.frame.size.height + 10, self.nameTextField.frame.size.width, 20)];
        descriptionLabel.font = nameLabel.font;
        descriptionLabel.text = @"Description";
        [self.taskDetailsView addSubview:descriptionLabel];

        // Description text view
        self.descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x,
                descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 4, nameLabel.frame.size.width, 80)];
        self.descriptionTextView.font = [UIFont systemFontOfSize:14];
        self.descriptionTextView.layer.masksToBounds = YES;
        self.descriptionTextView.layer.cornerRadius = 5;
        self.descriptionTextView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
        self.descriptionTextView.layer.borderWidth = 1.0;
        self.descriptionTextView.delegate = self;
        [self.taskDetailsView addSubview:self.descriptionTextView];

        // Form label
        UILabel *formLabel = [[UILabel alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x,
                self.descriptionTextView.frame.origin.y + self.descriptionTextView.frame.size.height + 20, nameLabel.frame.size.width, 20)];
        formLabel.font = nameLabel.font;
        formLabel.text = @"Form";
        [self.taskDetailsView addSubview:formLabel];

        // Add icon
        UIImage *createFormEntryImage = [UIImage imageNamed:@"add.png"];
        self.createFormEntryButton = [[UIButton alloc] initWithFrame:CGRectMake(formLabel.frame.origin.x + 475,
                formLabel.frame.origin.y, createFormEntryImage.size.width, createFormEntryImage.size.height)];
        [self.createFormEntryButton setImage:createFormEntryImage forState:UIControlStateNormal];
        [self.createFormEntryButton addTarget:self action:@selector(createFormEntryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.taskDetailsView addSubview:self.createFormEntryButton];

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
        [self.taskDetailsView addSubview:self.formTable];

        self.formTableDelegate = [[FormTableDelegate alloc] init];
        self.formTable.dataSource = self.formTableDelegate;
        self.formTable.delegate = self.formTableDelegate;
    }

    // Change to details of selected task
    self.nameTextField.text = self.currentlySelectedTask.name;
    self.userView.userPicture.image = [UIImage imageNamed:self.currentlySelectedTask.assignee];
    self.descriptionTextView.text = self.currentlySelectedTask.description;
    self.formTableDelegate.workflowTask = self.currentlySelectedTask;
    [self.formTable reloadData];
}

// Handling of description input field
- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.currentlySelectedTask.description = textView.text;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self textViewDidEndEditing:textView];
}


- (void)createFormEntryButtonTapped
{
    self.formController = [[FormController alloc] init];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
         style:UIBarButtonItemStyleBordered target:self action:@selector(saveNewFormEntry)];
    saveButton.tintColor = [UIColor colorWithRed:0.44 green:0.66 blue:0.99 alpha:0.18];
    self.formController.navigationItem.rightBarButtonItem = saveButton;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.formController];

    self.currentPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    [self.currentPopoverController setPopoverContentSize:CGSizeMake(400, 180)];

    [self.currentPopoverController presentPopoverFromRect:self.createFormEntryButton.frame
                          inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void)saveNewFormEntry
{
    [self.currentlySelectedTask addFormEntry:[self.formController generateFormEntry]];
    [self.formTable reloadData];
    [self.currentPopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.formController = nil;
    self.currentPopoverController = nil;
}

- (void)userTapped
{
    UserSelectionViewController *userSelectionViewController = [[UserSelectionViewController alloc] init];
    userSelectionViewController.workflowTaskIndex = self.currentlySelectedIndex;
    userSelectionViewController.workflowTask = self.currentlySelectedTask;
    userSelectionViewController.workflowCreationDelegate = self;

    self.currentPopoverController = [[UIPopoverController alloc] initWithContentViewController:userSelectionViewController];
    [self.currentPopoverController setPopoverContentSize:CGSizeMake(380, 160)];
    self.currentPopoverController.delegate = self;

    [self.currentPopoverController presentPopoverFromRect:self.userView.frame
                          inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)launchWorkflow
{
    // A screenshot will be taken. So we select the first step always for consistent screenshots
    if ([self.workflowStepsTable numberOfRowsInSection:0] > 0)
    {
        [self.workflowStepsTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                             animated:NO scrollPosition:UITableViewScrollPositionTop];
    }

    // Launch screen
    LaunchWorkflowViewController *launchWorkflowViewController = [[LaunchWorkflowViewController alloc] initWithWorkflow:self.workflow];
    launchWorkflowViewController.screenshotData = [self takeScreenshot];
    launchWorkflowViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    launchWorkflowViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:launchWorkflowViewController animated:YES];

    launchWorkflowViewController.view.superview.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;
    launchWorkflowViewController.view.superview.frame = CGRectMake(
            launchWorkflowViewController.view.superview.frame.origin.x,
            launchWorkflowViewController.view.superview.frame.origin.y,
            600, 400);
    launchWorkflowViewController.view.superview.center = self.view.center;
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

- (void)workflowStepUpdated:(NSUInteger)stepIndex
{
    // Close any popover currently showing
    [self.currentPopoverController dismissPopoverAnimated:YES];

    // Reload the changed workflow step
    [self.workflowStepsTable reloadRowsAtIndexPaths:
            [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:stepIndex]]
            withRowAnimation:UITableViewRowAnimationFade];

    // Reload the task details
    [self showDetailsForWorkflowStep:stepIndex];
}

#pragma mark Capturing screenshot

- (NSData *)takeScreenshot
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.view.window.bounds.size);
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *portraitImage = UIGraphicsGetImageFromCurrentImageContext();

    // Hack: screenshot is taken in portrait mode, but we assume we're always in landscape
    // Correct solution would be to use the image rotation property
    UIImage *image = [self image:portraitImage rotatedByDegrees:90.0];

    UIGraphicsEndImageContext();
    return UIImagePNGRepresentation(image);
}

- (UIImage *)image:(UIImage *)image rotatedByDegrees:(CGFloat)degrees
{
   // calculate the size of the rotated view's containing box for our drawing space
   UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width, image.size.height)];
   CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
   rotatedViewBox.transform = t;
   CGSize rotatedSize = rotatedViewBox.frame.size;

   // Create the bitmap context
   UIGraphicsBeginImageContext(rotatedSize);
   CGContextRef bitmap = UIGraphicsGetCurrentContext();

   // Move the origin to the middle of the image so we will rotate and scale around the center.
   CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);

   //   // Rotate the image context
   CGContextRotateCTM(bitmap, degrees * M_PI / 180);

   // Now, draw the rotated/scaled image into the context
   CGContextScaleCTM(bitmap, 1.0, -1.0);
   CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);

   UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   return newImage;

}


@end