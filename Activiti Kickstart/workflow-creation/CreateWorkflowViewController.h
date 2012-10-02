//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorkflowCreationDelegate.h"

@class Workflow;

@interface CreateWorkflowViewController : UIViewController <WorkflowCreationDelegate, UITextViewDelegate, UIPopoverControllerDelegate>

- (id)initWithWorkflow:(Workflow *)workflow;

@end