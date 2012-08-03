//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "FormEntryCell.h"


@implementation FormEntryCell

@synthesize nameLabel = _nameLabel;
@synthesize subscriptLabel = _subscriptLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.nameLabel = [[UILabel alloc] init];
        self.subscriptLabel = [[UILabel alloc] init];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];

    // Name label
    self.nameLabel.frame = CGRectMake(5, 5, self.contentView.frame.size.width, 20);
    self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
    self.nameLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.7];
    [self.contentView addSubview:self.nameLabel];

    // Subscript label
    self.subscriptLabel.frame = CGRectMake(5, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height,
            self.nameLabel.frame.size.width, 20);
    self.subscriptLabel.font = [UIFont italicSystemFontOfSize:14];
    self.subscriptLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.contentView addSubview:self.subscriptLabel];
}

@end