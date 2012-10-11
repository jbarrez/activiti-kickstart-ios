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
// LaunchWorkflowViewController 
//
#import <QuartzCore/QuartzCore.h>
#import "LaunchWorkflowViewController.h"
#import "Workflow.h"
#import "MBProgressHUD.h"
#import "KickstartRestService.h"

#define COLOR_ENABLED [UIColor colorWithRed:0.16 green:0.43 blue:0.83 alpha:1.0]
#define COLOR_DISABLED [UIColor colorWithRed:0.63 green:0.63 blue:0.63 alpha:1.0]

@interface LaunchWorkflowViewController ()  <UITextFieldDelegate>

@property (nonatomic, strong) Workflow *workflow;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *launchButton;

@end


@implementation LaunchWorkflowViewController

- (id)initWithWorkflow:(Workflow *)workflow
{
    self = [super init];
    if (self)
    {
        self.workflow = workflow;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    UIImage *workflowImage = [UIImage imageNamed:@"createWorkflowBig.png"];
    UIImageView *workflowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 110, workflowImage.size.width, workflowImage.size.height)];
    workflowImageView.image = workflowImage;
    [self.view addSubview:workflowImageView];

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 50, 350, 30)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = @"How would you like to call this workflow?";
    [self.view addSubview:nameLabel];
    self.nameLabel = nameLabel;

    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
            nameLabel.frame.origin.y + nameLabel.frame.size.height, nameLabel.frame.size.width, 30)];
    self.nameTextField.delegate = self;
    self.nameTextField.font = [UIFont systemFontOfSize:16];
    self.nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.nameTextField.layer.masksToBounds = YES;
    self.nameTextField.layer.cornerRadius = 5;
    self.nameTextField.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    self.nameTextField.layer.borderWidth = 1.0;
    [self.view addSubview:self.nameTextField];

    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
            self.nameTextField.frame.origin.y + self.nameTextField.frame.size.height + 10.0, nameLabel.frame.size.width, nameLabel.frame.size.height)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.text = @"Description (optional)";
    [self.view addSubview:descriptionLabel];

    UITextView *descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(descriptionLabel.frame.origin.x,
            descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height, descriptionLabel.frame.size.width, 150)];
    descriptionTextView.font = [UIFont systemFontOfSize:16];
    descriptionTextView.layer.masksToBounds = YES;
    descriptionTextView.layer.cornerRadius = 5;
    descriptionTextView.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    descriptionTextView.layer.borderWidth = 1.0;
    [self.view addSubview:descriptionTextView];

    UIButton *launchButton = [[UIButton alloc] initWithFrame:CGRectMake(275, 330, 200, 50)];
    [launchButton addTarget:self action:@selector(launchButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [launchButton setTitle:@"Launch" forState:UIControlStateNormal];
    launchButton.layer.cornerRadius = 20;
    launchButton.layer.masksToBounds = YES;
    launchButton.layer.shadowRadius = 5;
    launchButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    launchButton.layer.borderWidth = 3.0;
    launchButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:launchButton];
    self.launchButton = launchButton;

    UIImage *closeImage = [UIImage imageNamed:@"close.png"];
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(600 - closeImage.size.width - 5, 5, closeImage.size.width, closeImage.size.height)];
    [closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];


    if (self.workflow.isExistingWorkflow)
    {
        self.nameTextField.text = self.workflow.name;
        self.nameTextField.enabled = NO;
        self.nameTextField.alpha = 0.41;
        self.nameTextField.backgroundColor = [UIColor lightGrayColor];

        launchButton.backgroundColor = COLOR_ENABLED;
    }
    else
    {
        launchButton.enabled = NO;
        launchButton.backgroundColor = COLOR_DISABLED;
    }
}

- (void)closeButtonTapped
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.launchButton.enabled = self.nameTextField.text && self.nameTextField.text.length > 0;
    self.launchButton.backgroundColor = self.launchButton.enabled ? COLOR_ENABLED : COLOR_DISABLED;
}

#pragma mark Launch button

- (void)launchButtonTapped
{
    // Set workflow name
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    self.workflow.name = self.nameTextField.text;
    hud.labelText = [NSString stringWithFormat:@"Deploying %@", self.workflow.name];

    // Kickstart service is async
    KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
    [kickstartRestService deployWorkflow:self.workflow
                     withCompletionBlock:^(NSDictionary *response)
                     {
                         NSString *workflowId = [response valueForKey:@"id"];
                         NSLog(@"Process deployment done (id = '%@'). Uploading process image", workflowId);

                         // Upload the screen shot if the deploy went ok
                         KickstartRestService *innerService = [[KickstartRestService alloc] init];
                         [innerService uploadWorkflowImage:workflowId image:self.screenshotData withCompletionBlock:^(id response)
                         {
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                             [self dismissModalViewControllerAnimated:NO];

                             [[NSNotificationCenter defaultCenter] postNotificationName:@"workflowLaunched" object:nil userInfo:[NSDictionary dictionaryWithObject:self.workflow.name forKey:@"workflowName"]];
                         }
                         withFailureBlock:^(NSError *error, NSInteger statusCode)
                         {
                            NSLog(@"Couldn't upload image: %@", error.localizedDescription);
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            [self dismissModalViewControllerAnimated:NO];
                         }];

                     }
                     withFailureBlock:^(NSError *error, NSInteger statusCode)
                     {
                         if (statusCode == 409)
                         {
                             self.nameLabel.text = @"A workflow with this name already exists....";
                             self.nameLabel.textColor = [UIColor redColor];
                         }

                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     }];
}


@end