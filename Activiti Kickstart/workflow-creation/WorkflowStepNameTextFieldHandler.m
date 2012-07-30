//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "WorkflowStepNameTextFieldHandler.h"
#import "WorkflowCreationDelegate.h"

#define FONT_SIZE 18

@implementation WorkflowStepNameTextFieldHandler

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = [UIColor darkGrayColor];
    textField.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    [textField selectAll:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // If no text was added to the text field, reset to default
    if (textField.text == nil || textField.text.length == 0)
    {
        textField.text = @"New workflow step";
        textField.textColor = [UIColor lightGrayColor];
        textField.font = [UIFont italicSystemFontOfSize:FONT_SIZE];
    } else
    {
        textField.textColor = [UIColor darkGrayColor];
        textField.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    }
}

@end