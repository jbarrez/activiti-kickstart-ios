//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "LaunchWorkflowAlertViewDelegate.h"
#import "Workflow.h"
#import "KickstartRestService.h"

@interface LaunchWorkflowAlertViewDelegate ()

@property(nonatomic, strong) Workflow *workflow;

@end

@implementation LaunchWorkflowAlertViewDelegate
@synthesize workflow = _workflow;


- (id)initWithWorkflow:(Workflow *)workflow
{
    self = [super init];
    if (self)
    {
        self.workflow = workflow;
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Set workflow name
    UITextField *textField = [alertView textFieldAtIndex:0];
    self.workflow.name = textField.text;

    // Deploy workflow
    if (buttonIndex == 1) // There is only one button, besides the cancel button
    {
        KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
        [kickstartRestService deployWorkflow:[self.workflow generateJson]
                withCompletionBlock:^(NSDictionary *jsonResponse)
                {
                    NSLog(@"Deploy done");
                }
                   withFailureBlock:^(NSError *error)
                   {
                       UIAlertView *errorAlertView = [[UIAlertView alloc]
                               initWithTitle:@"Something went wrong..."
                               message:[NSString stringWithFormat:@"Error while deploying workflow: %@", error.localizedDescription]
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
                       [errorAlertView show];
                   }];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (textField.text != nil && textField.text.length > 0)
    {
        return YES;
    }
    return NO;
}


@end