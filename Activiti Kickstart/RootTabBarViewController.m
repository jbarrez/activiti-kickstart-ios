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
#import "ProcessViewController.h"
#import "Workflow.h"

#define TAG_HOME 0
#define TAG_PROCESSES 1
#define TAG_CREATE_WORKFLOW 2

@interface RootTabBarViewController ()

    @property (nonatomic, strong) UIViewController *homeViewController;
    @property (nonatomic, strong) UINavigationController *tasksViewController;
    @property (nonatomic, strong) UINavigationController *createWorkflowNavigationController;

    @property (nonatomic) NSInteger activeTabTag;

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
    self.homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"tabbar-home.png"] tag:TAG_HOME];

    // Tasks
    self.tasksViewController = [[UINavigationController alloc] init];
    self.tasksViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Workflows" image:[UIImage imageNamed:@"tabbar-tasks.png"] tag:TAG_PROCESSES];
    self.tasksViewController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    // Create workflow
    self.createWorkflowNavigationController = [[UINavigationController alloc] init];
    self.createWorkflowNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Create workflow" image:[UIImage imageNamed:@"tabbar-add-process.png"] tag:TAG_CREATE_WORKFLOW];
    self.createWorkflowNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    // Configure Tab bar to contain all view controllers
    [self setViewControllers:[NSArray arrayWithObjects:self.homeViewController,
                    self.tasksViewController, self.createWorkflowNavigationController, nil] animated:NO];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSInteger tag = viewController.tabBarItem.tag;
    if (self.activeTabTag != tag)
    {
        if (tag == TAG_CREATE_WORKFLOW)
        {
            CreateWorkflowViewController *createWorkflowViewController = [[CreateWorkflowViewController alloc] init];
            [self.createWorkflowNavigationController popViewControllerAnimated:NO];
            [self.createWorkflowNavigationController pushViewController:createWorkflowViewController animated:NO];
        }
        else if (tag == TAG_PROCESSES)
        {
            ProcessViewController *processViewController = [[ProcessViewController alloc] init];
            [self.tasksViewController popViewControllerAnimated:NO];
            [self.tasksViewController pushViewController:processViewController animated:NO];
        }

    }
    self.activeTabTag = tag;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark NSNotification handling

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWorkflowCreationNotification:) name:@"showWorkflowCreation" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleWorkflowCreationNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    Workflow *workflow = [userInfo valueForKey:@"workflow"];

    // Switch selected tab
    [self setSelectedIndex:TAG_CREATE_WORKFLOW];

    // Push new view controller
    CreateWorkflowViewController *createWorkflowViewController = [[CreateWorkflowViewController alloc] initWithWorkflow:workflow];
    [self.createWorkflowNavigationController popViewControllerAnimated:NO];
    [self.createWorkflowNavigationController pushViewController:createWorkflowViewController animated:NO];
}

@end
