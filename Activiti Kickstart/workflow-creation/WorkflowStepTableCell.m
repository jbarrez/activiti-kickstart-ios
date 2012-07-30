//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "WorkflowStepTableCell.h"

@implementation WorkflowStepTableCell

@synthesize nameLabel = _nameLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Workflow step name
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width, 20)];
    }
    return self;
}

- (void)layoutSubviews
{
    self.nameLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.nameLabel];
}


@end