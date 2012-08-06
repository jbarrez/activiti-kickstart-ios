//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "UserSelectionViewController.h"
#import "UserView.h"
#import "WorkflowTask.h"
#import "WorkflowCreationDelegate.h"

@interface UserSelectionViewController()

@property (nonatomic, strong) NSArray *users;

@end

@implementation UserSelectionViewController
@synthesize workflowTask = _workflowTask;
@synthesize workflowTaskIndex = _workflowTaskIndex;


- (id)init
{
    self = [super init];
    if (self)
    {
        self.users = [NSArray arrayWithObjects:@"arthur.png", @"david.jpg", @"fred.jpg",
                        @"john_newton.jpg", @"paul.jpg", @"tijs.jpg", @"tom.jpg", nil];
    }
    return self;
}


- (void)loadView
{
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];

    for (int i = 0; i < self.users.count; i++)
    {
        int row = i/4;
        int column = i%4;

        UserView *userView = [[UserView alloc] initWithFrame:CGRectMake( 10 + (column * 100), 10 + (row * 80), 60, 60)];
        userView.tag = i;
        userView.userPicture.image = [UIImage imageNamed:[self.users objectAtIndex:i]];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped:)];
        [userView addGestureRecognizer:tapGestureRecognizer];

        [self.view addSubview:userView];
    }
}

- (void)userTapped:(UITapGestureRecognizer *)recognizer
{
    self.workflowTask.assignee = [self.users objectAtIndex:recognizer.view.tag];
    [self.workflowCreationDelegate workflowStepUpdated:self.workflowTaskIndex];
}


@end