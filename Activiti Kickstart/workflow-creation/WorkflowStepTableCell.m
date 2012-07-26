//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "WorkflowStepTableCell.h"

@implementation WorkflowStepTableCell

@synthesize nameTextField = _nameTextField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Workflow step name
        self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width, 20)];
    }
    return self;
}

- (void)layoutSubviews
{
    [self.contentView addSubview:self.nameTextField];
}


@end