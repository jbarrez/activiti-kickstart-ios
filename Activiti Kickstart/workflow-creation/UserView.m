//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "UserView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>


@implementation UserView

@synthesize userPicture = _userPicture;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Can't do shadow and rounding at the same time, so we wrap it in a separate view beneath the image
        UIView *userImageShadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        userImageShadowView.backgroundColor = [UIColor whiteColor];
        CGFloat borderWidth = 1.0;
        userImageShadowView.layer.borderWidth = borderWidth;
        userImageShadowView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
        userImageShadowView.layer.cornerRadius = 10.f;
        [self addSubview:userImageShadowView];

        // User image contains the image
        self.userPicture = [[UIImageView alloc] initWithFrame:CGRectMake(userImageShadowView.frame.origin.x + borderWidth,
                userImageShadowView.frame.origin.y + borderWidth,
                userImageShadowView.frame.size.width - 2*borderWidth,
                userImageShadowView.frame.size.height - 2*borderWidth)];
        [self.userPicture setContentMode:UIViewContentModeScaleToFill];
        [self.userPicture.layer setMasksToBounds:YES];
        [self.userPicture.layer setCornerRadius:10];
        [self addSubview:self.userPicture];
    }
    return self;
}


@end