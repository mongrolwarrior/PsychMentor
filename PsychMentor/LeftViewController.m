//
//  LeftViewController.m
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 22/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import "LeftViewController.h"
#import "ExtendedMatchingQuestion.h"
#import "EMQParser.h"
#import "GDataXMLNode.h"
#import "Examination.h"

@interface LeftViewController ()

@end

NSMutableArray *items;

@implementation LeftViewController

@synthesize examinations;
@synthesize listDisplay;

- (void)changeListDisplay
{
    NSArray *adminData = [EMQParser loadAdministrativeData];
    
    self.examinations = [EMQParser loadExaminations];
    NSMutableArray *maListDisplay = [[NSMutableArray alloc] init];
    for (Examination *indexExamination in self.examinations) {
        if ([indexExamination.currentExamination  isEqual: @"1"] && [adminData[3] isEqualToString:@"1"]) {
            [maListDisplay addObject:[NSString stringWithFormat:@"%@ - %@", indexExamination.Source, indexExamination.Title]];
            NSArray *clusterIndex = indexExamination.Clusters;
            int countClusters = 0;
            for (ExtendedMatchingQuestion *EMQIndex in clusterIndex) {
                countClusters++;
                [maListDisplay addObject:[NSString stringWithFormat:@"%d--%@", countClusters, EMQIndex.KnowledgeDomain]];
            }
        }
        else
        {
            [maListDisplay addObject:[NSString stringWithFormat:@"%@ - %@", indexExamination.Source, indexExamination.Title]];
        }
    }
    [maListDisplay addObject:@"Display performance"];
    listDisplay = maListDisplay;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.examinations = [EMQParser loadExaminations];
    }
    
    [self changeListDisplay];
    
 /*   Examination *tempExamination = self.examinations[0];
    currentQuestion =[tempExamination.currentQuestion intValue];
    currentCluster = [tempExamination.currentCluster intValue];
    currentExamination = [tempExamination.currentExamination intValue];*/
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listDisplay count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
  /*  if (indexPath.row < [self.examinations count]) {
        Examination *indexExamination = self.examinations[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", indexExamination.Source, indexExamination.Title];
    }
    else
    {
        cell.textLabel.text = @"Show results for current examination";
    }*/
    
    cell.textLabel.text = listDisplay[indexPath.row];
//    cell.textLabel.lineBreakMode = [UILineBreakModeWordWrap];
    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSArray *adminData = [EMQParser loadAdministrativeData];
    if (indexPath.row<[self.listDisplay count]-1) { // as last row is option to see results
        int countRows = 0;
        int countExamination = 0;
        for (Examination *examinationIndex in self.examinations) {// count examinations so can set current row if switch to non-expanded
            if (countRows == indexPath.row) {                   // found selected and it is an examination row
                if ([adminData[2] isEqualToString:examinationIndex.eid]) {                    // eg if this is the current examination
                    if ([adminData[3] isEqualToString:@"1"]) {  // eg if cluster elements are expanded, switch to non-expanded
                        [EMQParser setAdministrativeData:[NSArray arrayWithObjects:adminData[0], adminData[1], examinationIndex.eid, @"0", @"2", nil]];
                    }
                    else                                        // eg if cluster elements are not expanded, switch to expanded
                    {
                        [EMQParser setAdministrativeData:[NSArray arrayWithObjects:adminData[0], adminData[1],examinationIndex.eid,  @"1", @"2", nil]];
                    }
                }
                else                                            // eg if selected not previously selected row, make non-expanded and set current eid
                {
                    [EMQParser setAdministrativeData:[NSArray arrayWithObjects:adminData[0], adminData[1], examinationIndex.eid, @"0", @"2", nil]];
                }
                
                if (_delegate) {                                // delegated method triggered in Right view controller
                    [_delegate selectedEMQ];
                }
                [self changeListDisplay];
                [self.leftTableView reloadData];
                return;
            }
            else                                                // eg selected row not already selected
            {
                countRows++;                                    // add to countRows for current examination
                if ([examinationIndex.currentExamination isEqualToString:@"1"] && [adminData[3] isEqualToString:@"1"]) {  // this examination is current and expanded
                    for (ExtendedMatchingQuestion *EMQIndex in examinationIndex.Clusters) {
                        if (countRows == indexPath.row) {
                            // found selected row and it is a cluster row
                            
                            [EMQParser setAdministrativeData:[NSArray arrayWithObjects:adminData[0], EMQIndex.CID, adminData[2], @"1", @"1", nil]];
                            // sets current examination, sets expanded to 0 (not expanded), sets index to 2 (base loadEMQ on eid)
                            
                            if (_delegate) {
                                [_delegate selectedEMQ];
                            }
                            [self changeListDisplay];
                            [self.leftTableView reloadData];
                            return;
                        }
                        countRows++;                // adds to counter for option
                    }
                }
            }
            countExamination++;
        }
    }
    else                    // eg last row selected; display results
    {
        NSArray *currentAdminData = [EMQParser loadAdministrativeData];
        NSMutableString *cumulativeResults = [[NSMutableString alloc] init];
        for (Examination *exam in self.examinations) {
            if ([exam.eid isEqualToString:currentAdminData[2]]) {
                [cumulativeResults appendString:[NSString stringWithFormat:@"Results for examination \'%@\' from \'%@\'\r\r", exam.Title, exam.Source]];
                NSArray *clusterArray = exam.Clusters;
                int countEMQ = 0;
                int totalCountQuestions = 0;
                int totalCountAnswered = 0;
                int totalMarksCorrect = 0;
                int totalMarksAnswered = 0;
                for (ExtendedMatchingQuestion *emqIndex in clusterArray) {
                    int countQuestions = 0;
                    int countAnswered = 0;
                    int marksCorrect = 0;
                    int marksAnswered = 0;
                    for (qaPair *questionIndex in emqIndex.questions) {
                        int questionMarksCorrect = 0;
                        int questionMarksAnswered = 0;
                        int questionCountAnswered = 0;
                        for (NSString *answeredList in questionIndex.answeredText) {
                            if (answeredList.length>0) {   // eg don't count if there is an empty string placeholder
                                questionCountAnswered=1;   // eg if there are any answered strings, the question has been answered
                                if ([questionIndex.answerText containsObject:answeredList]) {
                                    questionMarksCorrect++;
                                }
                                else
                                {
                                    questionMarksCorrect--;
                                }
                                if (questionMarksCorrect>[questionIndex.marks intValue]) {
                                    questionMarksCorrect=[questionIndex.marks intValue];
                                }
                                if (questionMarksCorrect<0) {
                                    questionMarksCorrect=0;
                                }
                                questionMarksAnswered+=[questionIndex.marks intValue];
                            }
                        }
                        countAnswered+=questionCountAnswered;
                        marksCorrect+=questionMarksCorrect;
                        marksAnswered+=questionMarksAnswered;
                        countQuestions++;
                    }
                    totalCountQuestions += countQuestions;
                    totalCountAnswered += countAnswered;
                    totalMarksCorrect += marksCorrect;
                    totalMarksAnswered += marksAnswered;
                    countEMQ++;
                    [cumulativeResults appendString:[NSString stringWithFormat:@"Section %d: Total questions: (%d) Correct/Answered: (%d/%d)\r", countEMQ, countQuestions, marksCorrect, marksAnswered]];
                }
                
                [cumulativeResults appendString:[NSString stringWithFormat:@"\rSections %d, Total questions: (%d) Correct/Answered: (%d/%d) Accuracy: %.01f%%", countEMQ, totalCountQuestions, totalMarksCorrect, totalMarksAnswered, 100.0*(float)(totalMarksCorrect)/(float)(totalMarksAnswered)]];
            }
        }

        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Row Selected" message:cumulativeResults delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
        [messageAlert show];
    }
    return;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
