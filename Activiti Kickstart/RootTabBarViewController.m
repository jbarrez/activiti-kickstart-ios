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

#define TAG_HOME 0
#define TAG_TASKS 1
#define TAG_CREATE_WORKFLOW 2

@interface RootTabBarViewController ()

    @property (nonatomic, strong) UIViewController *homeViewController;
    @property (nonatomic, strong) UIViewController *tasksViewController;
    @property (nonatomic, strong) UINavigationController *createWorkflowNavigationController;

@end

@implementation RootTabBarViewController

@synthesize homeViewController = _homeViewController;
@synthesize tasksViewController = _tasksViewController;
@synthesize createWorkflowNavigationController = _createWorkflowNavigationController;

- (void)loadView
{
    [super loadView];

    self.delegate = self;

    // Home
    self.homeViewController = [[UIViewController alloc] init];
    self.homeViewController.title = @"Home";
    self.homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:nil tag:TAG_HOME];

    // Tasks
    self.tasksViewController = [[UIViewController alloc] init];
    self.tasksViewController.title = @"Tasks";
    self.tasksViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tasks" image:nil tag:TAG_TASKS];
    self.tasksViewController.tabBarItem.badgeValue = @"4";

    // Create workflow
    self.createWorkflowNavigationController = [[UINavigationController alloc] init];
    self.createWorkflowNavigationController.title = @"Create Workflow";
    self.createWorkflowNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Create workflow" image:nil tag:TAG_CREATE_WORKFLOW];
    self.createWorkflowNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    // Configure Tab bar to contain all view controllers
    [self setViewControllers:[NSArray arrayWithObjects:self.homeViewController,
                    self.tasksViewController, self.createWorkflowNavigationController, nil] animated:NO];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController.tabBarItem.tag == TAG_CREATE_WORKFLOW)
    {
        CreateWorkflowViewController *createWorkflowViewController = [[CreateWorkflowViewController alloc] init];
        [self.createWorkflowNavigationController pushViewController:createWorkflowViewController animated:NO];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
