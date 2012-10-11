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
    @property (nonatomic, strong) ProcessViewController *processesOverviewController;
    @property (nonatomic, strong) CreateWorkflowViewController *createWorkflowController;

    @property (nonatomic) NSInteger activeTabTag;

@end

@implementation RootTabBarViewController

@synthesize homeViewController = _homeViewController;
@synthesize processesOverviewController = _processesOverviewController;
@synthesize createWorkflowController = _createWorkflowController;

- (void)loadView
{
    [super loadView];

    self.delegate = self;

    // Home
    self.homeViewController = [[UIViewController alloc] init];
    self.homeViewController.title = @"Home";
    self.homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:[UIImage imageNamed:@"tabbar-home.png"] tag:TAG_HOME];

    // Tasks
    self.processesOverviewController = [[ProcessViewController alloc] init];
    self.processesOverviewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Workflows" image:[UIImage imageNamed:@"tabbar-tasks.png"] tag:TAG_PROCESSES];

    // Create workflow
    self.createWorkflowController = [[CreateWorkflowViewController alloc] init];
    self.createWorkflowController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Create workflow" image:[UIImage imageNamed:@"tabbar-add-process.png"] tag:TAG_CREATE_WORKFLOW];

    // Need to wrap the view controller in a navigation controller to show the buttons
    UINavigationController *createWorkflowNavigationController = [[UINavigationController alloc] initWithRootViewController:self.createWorkflowController];
    createWorkflowNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    // Configure Tab bar to contain all view controllers
    [self setViewControllers:[NSArray arrayWithObjects:self.homeViewController,
                                                       self.processesOverviewController, createWorkflowNavigationController, nil] animated:NO];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWorkflowLaunchNotification:) name:@"workflowLaunched" object:nil];
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
    [self.createWorkflowController editWorkflow:workflow];
}

- (void)handleWorkflowLaunchNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *workflowName = [userInfo valueForKey:@"workflowName"];
    self.processesOverviewController.nameOfWorkflowToSelect = workflowName;

    // Switch selected tab
    [self setSelectedIndex:TAG_PROCESSES];
}

@end
