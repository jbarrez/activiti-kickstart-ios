//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "FormController.h"
#import "FormEntry.h"

@interface FormController ()

@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UISegmentedControl *typeSelection;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, strong) UISwitch *requiredSwitch;

@end


@implementation FormController

@synthesize nameTextField = _nameTextField;
@synthesize typeSelection = _typeSelection;
@synthesize requiredSwitch = _requiredSwitch;
@synthesize types = _types;


- (id)init
{
    self = [super init];
    if (self)
    {
        self.title = @"Create Form Entry";
        self.types = [NSArray arrayWithObjects:@"Text", @"Number", @"Date", @"Docs", nil];
        self.allowDocuments = YES; // Default
    }
    return self;
}


- (void)loadView
{
    [super loadView];

    self.view.backgroundColor = [UIColor whiteColor];

    // Name label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    nameLabel.font = [UIFont systemFontOfSize:18];
    nameLabel.text = @"Name:";
    [self.view addSubview:nameLabel];

    // Name textfield
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 10, 300, 30)];
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.nameTextField];

    // Type label
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 100, 20)];
    typeLabel.font = [UIFont systemFontOfSize:18];
    typeLabel.text = @"Type:";
    [self.view addSubview:typeLabel];

    // Type choices
    self.typeSelection = [[UISegmentedControl alloc] initWithItems:self.types];
    self.typeSelection.frame = CGRectMake(70, 55, 380, 30);
    self.typeSelection.segmentedControlStyle = UISegmentedControlStyleBordered;
    self.typeSelection.selectedSegmentIndex = 0;
    [self.view addSubview:self.typeSelection];

    // Enabled/disable documents based on property
    [self.typeSelection setEnabled:self.allowDocuments forSegmentAtIndex:3];

    // Required label
    UILabel *requiredLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 100, 20)];
    requiredLabel.font = [UIFont systemFontOfSize:18];
    requiredLabel.text = @"Required";
    [self.view addSubview:requiredLabel];

    // Required checkbox
    self.requiredSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(100, 105, 50, 40)];

    [self.view addSubview:self.requiredSwitch];
}

- (FormEntry *)generateFormEntry
{
    FormEntry *formEntry = [[FormEntry alloc] init];
    formEntry.name = self.nameTextField.text;
    formEntry.isRequired = self.requiredSwitch.on;

    switch (self.typeSelection.selectedSegmentIndex)
    {
        case 0:
            formEntry.type = FORM_ENTRY_TYPE_STRING;
            break;
        case 1:
            formEntry.type = FORM_ENTRY_TYPE_INTEGER;
            break;
        case 2:
            formEntry.type = FORM_ENTRY_TYPE_DATE;
            break;
        case 3:
            formEntry.type = FORM_ENTRY_TYPE_DOCUMENTS;
            break;
    }

    return formEntry;
}


@end