//
//  RightViewController.h
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 22/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftSelectionDelegate.h"
#import "LeftViewController.h"

@interface RightViewController : UITableViewController <LeftSelectionDelegate>
{
    NSMutableArray *dataArray; // Contains text strings for each row
    int currentQuestion; // Index for currently active question (in section 2 (0-2 index))
    NSString *currentCluster; // CID of currently active cluster
}

- (void)initialiseDataArray;
//- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
- (void)goToSleep;
//- (NSString *)cellText:(UITableView *)tableView cfrIndexPath:(NSIndexPath *)indexPath;

@property (strong, nonatomic) IBOutlet UITableView *rightViewTable;
@property (strong, nonatomic) LeftViewController *leftView;
@property (strong, nonatomic) ExtendedMatchingQuestion *emq;
@property (nonatomic, strong) UIPopoverController *popover;

@end
