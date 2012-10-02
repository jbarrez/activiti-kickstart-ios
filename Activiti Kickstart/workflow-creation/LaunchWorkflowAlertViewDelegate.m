//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LaunchWorkflowAlertViewDelegate.h"
#import "Workflow.h"
#import "KickstartRestService.h"
#import "MBProgressHUD.h"
#import "CreateWorkflowViewController.h"

@interface LaunchWorkflowAlertViewDelegate ()

@property(nonatomic, strong) Workflow *workflow;

@end

@implementation LaunchWorkflowAlertViewDelegate


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
    // Take screenshot
    NSData *screenshotData = [self takeScreenshot];

    // Deploy workflow
    if (buttonIndex == 1) // There is only one button, besides the cancel button
    {
        // Set workflow name
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.createWorkflowViewController.view animated:YES];

        UITextField *textField = [alertView textFieldAtIndex:0];
        self.workflow.name = textField.text;
        self.createWorkflowViewController.title = self.workflow.name;
        hud.labelText = [NSString stringWithFormat:@"Deploying %@", self.workflow.name];

        // Kickstart service is async
        KickstartRestService *kickstartRestService = [[KickstartRestService alloc] init];
        [kickstartRestService deployWorkflow:[self.workflow toJson]
            withCompletionBlock:^(NSDictionary *response)
            {
                NSString *workflowId = [response valueForKey:@"id"];
                NSLog(@"Process deployment done (id = '%@'). Uploading process image", workflowId);

                // Upload the screen shot if the deploy went ok
                KickstartRestService *innerService = [[KickstartRestService alloc] init];
                [innerService uploadWorkflowImage:workflowId image:screenshotData withCompletionBlock:^(id response)
                {
                    [MBProgressHUD hideHUDForView:self.createWorkflowViewController.view animated:YES];
                }
                withFailureBlock:^(NSError *error)
                {
                    NSLog(@"Couldn't upload image: %@", error.localizedDescription);
                    [MBProgressHUD hideHUDForView:self.createWorkflowViewController.view animated:YES];
                }];

            }
            withFailureBlock:^(NSError *error)
            {
                [MBProgressHUD hideHUDForView:self.createWorkflowViewController.view animated:YES];

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

- (NSData *)takeScreenshot
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(self.createWorkflowViewController.view.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(self.createWorkflowViewController.view.window.bounds.size);
    [self.createWorkflowViewController.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
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