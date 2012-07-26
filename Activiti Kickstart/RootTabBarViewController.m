//
//  RootViewController.m
//  Activiti Kickstart
//
//  Created by Joram Barrez on 23/07/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "RootTabBarViewController.h"
#import "CreateWorkflowViewController.h"

@interface RootTabBarViewController ()

    @property (nonatomic, strong) UIViewController *homeViewController;
    @property (nonatomic, strong) UIViewController *tasksViewController;
    @property (nonatomic, strong) CreateWorkflowViewController *createWorkflowViewController;

@end

@implementation RootTabBarViewController

@synthesize homeViewController = _homeViewController;
@synthesize tasksViewController = _tasksViewController;
@synthesize createWorkflowViewController = _createWorkflowViewController;

- (void)loadView
{
    [super loadView];

    self.homeViewController = [[UIViewController alloc] init];
    self.homeViewController.title = @"Home";
    self.homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:0];

    self.tasksViewController = [[UIViewController alloc] init];
    self.tasksViewController.title = @"Tasks";
    self.tasksViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tasks" image:nil tag:1];
    self.tasksViewController.tabBarItem.badgeValue = @"4";

    self.createWorkflowViewController = [[CreateWorkflowViewController alloc] init];
    self.createWorkflowViewController.title = @"Create Workflow";
    self.createWorkflowViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Create workflow" image:nil tag:2];

    [self setViewControllers:[NSArray arrayWithObjects:self.homeViewController,
                    self.tasksViewController, self.createWorkflowViewController, nil] animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
