//
//  RightViewController.m
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 22/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import "RightViewController.h"
#import "ExtendedMatchingQuestion.h"
#import "EMQParser.h"
#import "pmAppDelegate.h"

@interface RightViewController ()

@end

@implementation RightViewController
@synthesize rightViewTable, emq, leftView, popover;

-(void)initialiseDataArray
{
    //Initialize the dataArray
    dataArray = [[NSMutableArray alloc] init];
    
    // Zeroth section data - holds generic text
    NSArray *zerothItemsArray = [[NSArray alloc] initWithObjects:@"Each question is worth 1 mark.", nil];
    NSDictionary *zerothItemsArrayDict = [NSDictionary dictionaryWithObject:zerothItemsArray forKey:@"data"];
    [dataArray addObject:zerothItemsArrayDict];
    
    //First section data - holds options
    NSArray *firstItemsArray = [[NSArray alloc] initWithArray:emq.options];
    NSDictionary *firstItemsArrayDict = [NSDictionary dictionaryWithObject:firstItemsArray forKey:@"data"];
    [dataArray addObject:firstItemsArrayDict];
    
    //Second section data - holds generic question
    NSArray *secondItemsArray = [[NSArray alloc] initWithObjects:emq.GenericQuestion, nil];
    NSDictionary *secondItemsArrayDict = [NSDictionary dictionaryWithObject:secondItemsArray forKey:@"data"];
    [dataArray addObject:secondItemsArrayDict];
    
    //Third section data - holds qapairs
    NSArray *thirdItemsArray = [[NSArray alloc] initWithArray:emq.questions];
    /*    NSRange theRange;
     theRange.location=0;
     theRange.length=1;
     NSArray *firstElementArray = [thirdItemsArray subarrayWithRange:theRange];*/
    NSDictionary *thirdItemsArrayDict = [NSDictionary dictionaryWithObject:thirdItemsArray forKey:@"data"];
    [dataArray addObject:thirdItemsArrayDict];
    
    currentQuestion = 0; // current question is a counter that determines which question in this section is highlighted
    
    for (qaPair *question in thirdItemsArray) {
        
   /*     id object = question.answeredText[0];
        if (object == (id)[NSNull null]) {
            break;                  // if an unanswered question is found, leave loop as we have found our index, highlighting the question
        }*/
        
        if (question.answeredText.count==0) {
            break;
        }
        
        if (currentQuestion<thirdItemsArray.count - 1) {
            currentQuestion++;
        }
        else
        {
            currentQuestion = 0; // if we've checked all questions in the section and all have been answered, the first question is highlighted
        }
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.emq = [EMQParser loadEMQ];
    }
    
    [self initialiseDataArray];
  
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pmAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate]; // how to implement delegate explained in http://stackoverflow.com/questions/18950670/calling-uiviewcontroller-method-from-app-delegate
    appDelegate.myViewController = self;
    
    [rightViewTable setDataSource:self];
    [rightViewTable setDelegate:self];
    
    //Add a left swipe gesture recognizer
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeLeft:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.rightViewTable addGestureRecognizer:recognizer];
    
    //Add a right swipe gesture recognizer
    UISwipeGestureRecognizer *rightrecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleSwipeRight:)];
    [rightrecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.rightViewTable addGestureRecognizer:rightrecognizer];
    
    // Next line is half of getting rid of borders between cells; this part from http://stackoverflow.com/questions/8561774/hide-separator-line-on-one-uitableviewcell in the comment section of the correct answer
    self.rightViewTable.separatorColor = [UIColor clearColor];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //Get location of the swipe
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    //Get the corresponding index path within the table view
    NSIndexPath *indexPath = [self.rightViewTable indexPathForRowAtPoint:location];
    
    //Check if index path is valid
    if(indexPath)
    {
        if(indexPath.section==3)
        {
            currentQuestion = (int)indexPath.row;
            //Get the cell out of the table view
            //  UITableViewCell *cell = [self.rightViewTable cellForRowAtIndexPath:indexPath];
            
            //Update the cell or model
            //     cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            // GET qaPair WITH TEXT OF ANSWER FOR HIGHLIGHTED QUESTION
            NSDictionary *questionDictionary = [dataArray objectAtIndex:3];
            NSArray *questionArray = [questionDictionary objectForKey:@"data"];
            qaPair *questionToMatch = questionArray[currentQuestion];
            
            NSArray *emptyArray = [[NSArray alloc] init];
            questionToMatch.answeredText = emptyArray;
            [self.rightViewTable reloadData];
        }
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //Get location of the swipe
    CGPoint location = [gestureRecognizer locationInView:self.tableView];
    
    //Get the corresponding index path within the table view
    NSIndexPath *indexPath = [self.rightViewTable indexPathForRowAtPoint:location];
    
    //Check if index path is valid
    if(indexPath)
    {
        if(indexPath.section==3)
        {
            currentQuestion = (int)indexPath.row;
            //Get the cell out of the table view
            //  UITableViewCell *cell = [self.rightViewTable cellForRowAtIndexPath:indexPath];
            
            //Update the cell or model
            //     cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            // GET qaPair WITH TEXT OF ANSWER FOR HIGHLIGHTED QUESTION
            NSDictionary *questionDictionary = [dataArray objectAtIndex:3];
            NSArray *questionArray = [questionDictionary objectForKey:@"data"];
            qaPair *questionToMatch = questionArray[currentQuestion];
            
            UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Explanation" message:questionToMatch.explanationText delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [messageAlert show];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Number of rows it should expect should be based on the section
    NSDictionary *dictionary = [dataArray objectAtIndex:section];
    NSArray *array = [dictionary objectForKey:@"data"];
    return [array count];
}
/*
- (NSString *)cellText:(UITableView *)tableView cfrIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    NSString *cellValue;
    if (indexPath.section == 2) {
        qaPair *qapair = [[qaPair alloc] init];
        qapair = [array objectAtIndex:indexPath.row];
        if (!(qapair.answeredText[0]==(id)[NSNull null])) {
            NSString *accumulatedAnsweredStrings = [[qapair.answeredText valueForKey:@"description"] componentsJoinedByString:@"; "];
            cellValue = [NSString stringWithFormat:@"%@\r\rCURRENT ANSWER(S): %@", qapair.questionText, accumulatedAnsweredStrings];
        }
        else
        {
            cellValue = qapair.questionText;
        }
    }
    else
    {
        if (indexPath.section==0) {
            qaPair *currentQuestionPair = emq.questions[currentQuestion];
            if ([currentQuestionPair.answeredText containsObject:[array objectAtIndex:indexPath.row]]) {
                cell.textLabel.enabled = YES;
            }
            else
            {
                if (!(currentQuestionPair.answeredText[0] == (id)[NSNull null])) {
                    cell.textLabel.enabled = NO;
                }
            }
        }
        cellValue = [array objectAtIndex:indexPath.row];
    }
    return cellValue;
}*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // If first section then enter generic text
    if (indexPath.section == 0) {
        NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
        NSArray *array = [dictionary objectForKey:@"data"];
    //    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [array objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else // eg if section 1 (option list) section 2 (generic question text) or section 3 (question stems)
    {
        NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
        NSArray *array = [dictionary objectForKey:@"data"];
        NSString *cellValue;
        if (indexPath.section == 3) { // eg if question stems
            qaPair *qapair = [[qaPair alloc] init];
            qapair = [array objectAtIndex:indexPath.row];
            if (qapair.answeredText.count>0) { // && qapair.answeredText[0]!=(id)[NSNull null]) {
                NSString *accumulatedAnsweredStrings = [[qapair.answeredText valueForKey:@"description"] componentsJoinedByString:@"; "];
                cellValue = [NSString stringWithFormat:@"Question %d\r\r%@\r\rCURRENT ANSWER(S): %@", qapair.questionNumber, qapair.questionText, accumulatedAnsweredStrings];
            }
            else
            {
                cellValue = [NSString stringWithFormat:@"Question %d\r\r%@", qapair.questionNumber, qapair.questionText];
            }
        }
        else if (indexPath.section==1) {
            /*     qaPair *currentQuestionPair = emq.questions[currentQuestion];
             if ([currentQuestionPair.answeredText containsObject:[array objectAtIndex:indexPath.row]]) {
             cell.textLabel.enabled = YES;
             }
             else
             {
             cell.textLabel.enabled = NO;
             }*/
            NSArray *letters = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
            cellValue = [NSString stringWithFormat: @"%@%@\t%@", letters[indexPath.row], @".", [array objectAtIndex:indexPath.row]];
        }
        else
        {
            cellValue = [array objectAtIndex:indexPath.row];
        }
        if (indexPath.section == 0) {
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
        }
        else if (indexPath.section == 1)
        {
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:11.0];
        }
        else if (indexPath.section == 2)
        {
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0];
        }
        else
        {
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:11.0];
        }
        // cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = cellValue;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.section==3 && indexPath.row!=currentQuestion) {
            cell.textLabel.enabled = NO;
        }
        else
        {
            cell.textLabel.enabled = YES;
        }
    }
    
    // Next two lines are half of answer for removing borders between cells; this section from http://stackoverflow.com/questions/17506533/ios-grouped-tableview-transparent-cells
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    
    return cell;
}

-(void)selectedEMQ
{
    [self goToSleep];
    self.emq = [EMQParser loadEMQ];
    [self initialiseDataArray];
    [self.rightViewTable reloadData];
}

// FUNCTIONS TO WRAP TEXT
- (UIFont *)fontForCell
{
    return [UIFont boldSystemFontOfSize:14.0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
    NSArray *array = [dictionary objectForKey:@"data"];
    NSString *cellValue;
    /*
    if (indexPath.section == 2) {
        qaPair *qapair = [[qaPair alloc] init];
        qapair = [array objectAtIndex:indexPath.row];
        id object = qapair.answeredText;
        if (!(object == (id)[NSNull null])) {
            NSString *accumulatedAnsweredStrings = [[qapair.answeredText valueForKey:@"description"] componentsJoinedByString:@"; "];
            cellValue = [NSString stringWithFormat:@"%@\r\rCURRENT ANSWER(S): %@", qapair.questionText, accumulatedAnsweredStrings];
        }
        else
        {
            cellValue = qapair.questionText;
        }
    }
    else
    {
        cellValue = [array objectAtIndex:indexPath.row];
    }*/
    
    if (indexPath.section == 0) {
        cellValue = [array objectAtIndex:indexPath.row];
    }
    else
    {
        NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
        NSArray *array = [dictionary objectForKey:@"data"];
        if (indexPath.section == 3) {
            qaPair *qapair = [[qaPair alloc] init];
            qapair = [array objectAtIndex:indexPath.row];
            if (qapair.answeredText.count>0) { // && qapair.answeredText[0]!=(id)[NSNull null]) {
                NSString *accumulatedAnsweredStrings = [[qapair.answeredText valueForKey:@"description"] componentsJoinedByString:@"; "];
                cellValue = [NSString stringWithFormat:@"Question %d\r\r%@\r\rCURRENT ANSWER(S): %@", qapair.questionNumber, qapair.questionText, accumulatedAnsweredStrings];
            }
            else
            {
                cellValue = [NSString stringWithFormat:@"Question %d\r\r%@", qapair.questionNumber, qapair.questionText];
            }
        }
        else if (indexPath.section==1) {
            /*     qaPair *currentQuestionPair = emq.questions[currentQuestion];
             if ([currentQuestionPair.answeredText containsObject:[array objectAtIndex:indexPath.row]]) {
             cell.textLabel.enabled = YES;
             }
             else
             {
             cell.textLabel.enabled = NO;
             }*/
            NSArray *letters = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
            cellValue = [NSString stringWithFormat: @"%@%@\t%@", letters[indexPath.row], @".", [array objectAtIndex:indexPath.row]];
        }
        else
        {
            cellValue = [array objectAtIndex:indexPath.row];
        }
        
    }
//    CGSize labelSize = [model.name sizeWithFont:self.nameLabel.font
//                              constrainedToSize:_maxNameLabelSize
//                                  lineBreakMode:self.nameLabel.lineBreakMode];
    // new
//    CGSize labelSize = [model.name boundingRectWithSize:_maxNameLabelSize
//                                                options:NSStringDrawingUsesLineFragmentOrigin
//                                             attributes:@{NSFontAttributeName: self.nameLabel.font}
//                                                context:nil].size;
    
    
  //  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    CGSize constraintSize = CGSizeMake(tableView.contentSize.width - 20, MAXFLOAT);
    CGSize labelSize = [cellValue boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:24.0]} context:nil].size;
//    CGSize labelSize = [cellValue sizeWithFont:[UIFont fontWithName:@"Helvetica" size:24.0] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    if (indexPath.section == 0) {
        labelSize = [cellValue boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:24.0]} context:nil].size;
 //       labelSize = [cellValue sizeWithFont:[UIFont fontWithName:@"Helvetica" size:24.0] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    else if (indexPath.section == 1)
    {
        labelSize = [cellValue boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:11.0]} context:nil].size;
 //       labelSize = [cellValue sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    else if (indexPath.section == 2)
    {
        labelSize = [cellValue boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:11.0]} context:nil].size;
 //       labelSize = [cellValue sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    else
    {
        labelSize = [cellValue boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:11.0]} context:nil].size;
 //       labelSize = [cellValue sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0] constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    return labelSize.height + 20;
}

//  ROW SELECTION TELLS US IF WE'RE RIGHT AND HIGHLIGHTS NEW QUESTION; MOVES TO NEXT CLUSTER IF LAST ROW IN THIS CLUSTER SELECTED; MOVES TO FIRST UNANSWERED QUESTION IN EXAMINATION IF FINAL QUESTION OF FINAL CLUSTER OF EXAMINATION
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        // GET ARRAY WITH TEXT OF OPTION SELECTED
        NSDictionary *dictionary = [dataArray objectAtIndex:indexPath.section];
        NSArray *array = [dictionary objectForKey:@"data"];
        
        // GET qaPair WITH TEXT OF ANSWER FOR HIGHLIGHTED QUESTION
        NSDictionary *questionDictionary = [dataArray objectAtIndex:3];
        NSArray *questionArray = [questionDictionary objectForKey:@"data"];
        qaPair *questionToMatch = questionArray[currentQuestion];
        NSMutableArray *answeredStrings = [[NSMutableArray alloc] initWithArray:questionToMatch.answeredText];
        
        // COMPOSE FEEDBACK STRING FOR ALERT BOX
        NSString *feedback;
        
        if ([questionToMatch.answerText containsObject:[array objectAtIndex:indexPath.row]]) {   // if the selected answer is in the answerText array containing all the answers, the selection is correct
            feedback = [NSString stringWithFormat:@"You are correct, \"%@\" is a valid answer", [array objectAtIndex:indexPath.row]];
            
      /*      if (answeredStrings[0] == (id)[NSNull null]) {
                answeredStrings[0] = [NSString stringWithString:[array objectAtIndex:indexPath.row]];
            }
            else*/ if (![questionToMatch.answeredText containsObject:[array objectAtIndex:indexPath.row]]) // eg if this answer is not already in the answered list
            {
                [answeredStrings addObject:[array objectAtIndex:indexPath.row]];
            }
        }
        else
        {
            NSString *feedbackArrayString = [questionToMatch.answerText componentsJoinedByString:@","];
            if (questionToMatch.answerText.count>1) {
                feedback = [NSString stringWithFormat:@"The correct answers include %@", feedbackArrayString];
            }
            else
            {
                feedback = [NSString stringWithFormat:@"The correct answer is %@", feedbackArrayString];
            }
        /*    if (answeredStrings[0] == (id)[NSNull null]) {
                answeredStrings[0] = [NSString stringWithString:[array objectAtIndex:indexPath.row]];
            }
            else */if (![questionToMatch.answeredText containsObject:[array objectAtIndex:indexPath.row]]) // eg if this answer is not already in the answered list
            {
                [answeredStrings addObject:[array objectAtIndex:indexPath.row]];
            }
        }
        questionToMatch.answeredText = answeredStrings;
        [self.rightViewTable reloadData];
        
        // DISPLAY FEEDBACK
        UIAlertView *messageAlert = [[UIAlertView alloc] initWithTitle:@"Row Selected" message:feedback delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [messageAlert show];
    }
    if (indexPath.section == 3) {
        currentQuestion = indexPath.row;
        [self.rightViewTable reloadData];
    }
    if (indexPath.section == 2)
        [EMQParser loadRemoteExaminations];
}

-(void)goToSleep
{
//    NSArray *thirdItemsArray = [[NSArray alloc] initWithArray:emq.questions];
/*    NSDictionary *questionDictionary = [dataArray objectAtIndex:2];
    NSArray *questionArray = [questionDictionary objectForKey:@"data"];
    */
    [EMQParser saveAnswers:self.emq.questions];
    self.emq = [EMQParser loadEMQ];
    [self initialiseDataArray];
    [self.rightViewTable reloadData];
    return;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // called after alert view with feedback from last question leaves the screen
    NSDictionary *questionDictionary = [dataArray objectAtIndex:3];
    NSArray *questionArray = [questionDictionary objectForKey:@"data"];
    qaPair *questionToMatch = questionArray[currentQuestion];
    
    if (questionToMatch.answerText == questionToMatch.answeredText) { // eg if correct, move to next question else stay on present question
        NSIndexPath *greyCell = [NSIndexPath indexPathForRow:currentQuestion inSection:3];
        
        currentQuestion = 0;
        NSArray *thirdItemsArray = [[NSArray alloc] initWithArray:emq.questions];
        for (qaPair *question in thirdItemsArray) {
            if (question.answeredText.count==0) {
                break;
            }
            if (currentQuestion<thirdItemsArray.count - 1) { // if not at last question of array, increase index by one
                currentQuestion++;
            }
            else                                                // if are at last question of array, which has been answered, save answers and reload data
            {
                [EMQParser saveAnswers:thirdItemsArray];
                self.emq = [EMQParser loadEMQ];
                [self initialiseDataArray];
                [self.rightViewTable reloadData];
                return;
            }
        }
        
  /*    // replaced by goToSleep function
        currentQuestion = 0;
        
        NSArray *thirdItemsArray = [[NSArray alloc] initWithArray:emq.questions];
        for (qaPair *question in thirdItemsArray) {
            if (question.answeredText.length==0) {
                break;
            }
            if (currentQuestion<thirdItemsArray.count - 1) { // if not at last question of array, increase index by one
                currentQuestion++;
            }
            else                                                // if are at last question of array, which has been answered, save answers and reload data
            {
                [EMQParser saveAnswers:thirdItemsArray];
                self.emq = [EMQParser loadEMQ];
                [self initialiseDataArray];
                [self.rightViewTable reloadData];
                return;
            }
        }*/
        
        NSIndexPath *highlightCell = [NSIndexPath indexPathForRow:currentQuestion inSection:3];
        UITableViewCell *cell = [self.rightViewTable cellForRowAtIndexPath:greyCell];
        cell.textLabel.enabled = NO;
        cell = [self.rightViewTable cellForRowAtIndexPath:highlightCell];
        cell.textLabel.enabled = YES;
    }
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
