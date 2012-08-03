//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "WorkflowStepTableCell.h"
#import "UserView.h"

@interface WorkflowStepTableCell()

@property (nonatomic, strong) UIView *whiteBackground;

@end

@implementation WorkflowStepTableCell

@synthesize nameLabel = _nameLabel;
@synthesize whiteBackground = _whiteBackground;
@synthesize concurrencyType = _concurrencyType;
@synthesize isLastStep = _isLastStep;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.editing = YES;
        self.showsReorderControl = YES;

        // User picture
        self.userView = [[UserView alloc] initWithFrame:CGRectMake(20, 10, 40, 40)];
        [self.contentView addSubview:self.userView];

        // Name
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.isLastStep)
    {
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        self.userView.hidden = YES;

        self.nameLabel.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
        self.nameLabel.textAlignment = UITextAlignmentCenter;
        self.nameLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
        self.userView.hidden = NO;

        self.nameLabel.frame = CGRectMake(80, 15, 220, 30);
        self.nameLabel.textAlignment = UITextAlignmentLeft;
        self.nameLabel.font = [UIFont boldSystemFontOfSize:20];
        self.nameLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

        if (self.indentationLevel > 0)
        {

            float indentPoints = self.indentationLevel * self.indentationWidth;

            self.contentView.frame = CGRectMake(
                    indentPoints,
                    self.contentView.frame.origin.y,
                    self.contentView.frame.size.width - indentPoints,
                    self.contentView.frame.size.height
            );

            self.backgroundView.frame = CGRectMake(
                    indentPoints,
                    self.backgroundView.frame.origin.y,
                    self.backgroundView.frame.size.width - indentPoints / 2,
                    self.backgroundView.frame.size.height
            );

            // A bit hacky we need to call this manually ... but it works
            [self setNeedsDisplay];
        }

    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    if (self.indentationLevel > 0)
    {
        float indentPoints = self.indentationLevel * self.indentationWidth;

        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);

        if (self.concurrencyType == CONCURRENCY_TYPE_NORMAL)
        {
            CGContextMoveToPoint(context, indentPoints/2, 0);
            CGContextAddLineToPoint(context, indentPoints/2, 60);
            CGContextStrokePath(context);
        }
        else if (self.concurrencyType == CONCURRENCY_TYPE_FIRST)
        {
            CGContextMoveToPoint(context, indentPoints/2, 30);
            CGContextAddLineToPoint(context, indentPoints/2, 60);
            CGContextStrokePath(context);

            CGContextMoveToPoint(context, indentPoints/2, 30);
            CGContextAddLineToPoint(context, indentPoints, 30);
            CGContextStrokePath(context);
        }
        else
        {
            CGContextMoveToPoint(context, indentPoints / 2, 0);
            CGContextAddLineToPoint(context, indentPoints / 2, 30);
            CGContextStrokePath(context);

            CGContextMoveToPoint(context, indentPoints / 2, 30);
            CGContextAddLineToPoint(context, indentPoints, 30);
            CGContextStrokePath(context);
        }
    }
}


@end