//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "UserView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@interface UserView ()

@property UIView *userImageShadowView;

@end

@implementation UserView

@synthesize userPicture = _userPicture;
@synthesize userImageShadowView = _userImageShadowView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Can't do shadow and rounding at the same time, so we wrap it in a separate view beneath the image
        self.userImageShadowView = [[UIView alloc] init];
        self.userImageShadowView.backgroundColor = [UIColor whiteColor];
        self.userImageShadowView.layer.borderWidth = 1.0;
        self.userImageShadowView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
        self.userImageShadowView.layer.cornerRadius = 10.f;
        [self addSubview:self.userImageShadowView];

        // User image contains the image
        self.userPicture = [[UIImageView alloc] init];
        [self.userPicture setContentMode:UIViewContentModeScaleToFill];
        [self.userPicture.layer setMasksToBounds:YES];
        [self.userPicture.layer setCornerRadius:10];
        [self addSubview:self.userPicture];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.userImageShadowView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);

    CGFloat borderWidth = 1.0;
    self.userPicture.frame = CGRectMake(
                    self.userImageShadowView.frame.origin.x + borderWidth,
                    self.userImageShadowView.frame.origin.y + borderWidth,
                    self.userImageShadowView.frame.size.width - 2*borderWidth,
                    self.userImageShadowView.frame.size.height - 2*borderWidth);
}


@end