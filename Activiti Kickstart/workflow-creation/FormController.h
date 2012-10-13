//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FormEntry;


@interface FormController : UIViewController

@property (nonatomic) BOOL allowDocuments;

- (FormEntry *)generateFormEntry;

@end