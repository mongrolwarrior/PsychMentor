//
//  LeftViewController.h
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 22/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftSelectionDelegate.h"
#import "GDataXMLNode.h"

@interface LeftViewController : UITableViewController <UITableViewDataSource>

@property (nonatomic, assign) id<LeftSelectionDelegate> delegate;
@property (nonatomic, retain) NSArray *examinations;
@property (nonatomic, retain) NSArray *listDisplay;

@property (strong, nonatomic) IBOutlet UITableView *leftTableView;
@end
