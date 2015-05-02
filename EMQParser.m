	//
//  EMQParser.m
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 23/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import "EMQParser.h"
#import "ExtendedMatchingQuestion.h"
#import "GDataXMLNode.h"
#import "qaPair.h"
#import "Examination.h"

@implementation EMQParser

-(NSString*)DocumentDirectoryPath
{
    NSArray *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [documentPath objectAtIndex:0];
    
    return documentFolder;
}

+(void)saveAnswers:(NSArray *)questions
{
    NSString *filePath = [self dataFilePath:FALSE nameOfFile:@"EMQ"];
    NSData *xmlData = [[NSData alloc]initWithContentsOfFile:filePath];
    
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    
    for (qaPair *question in questions) {
        NSArray *answeredStringArray = [xmlDocument nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination/Clusters/Cluster/Questions/Question[QID=\"%@\"]/Answered", question.qid] error:Nil];
        NSArray *questionArray = [xmlDocument nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination/Clusters/Cluster/Questions/Question[QID=\"%@\"]", question.qid] error:Nil];
        
        GDataXMLElement *questionElement = questionArray[0];
        
        for (GDataXMLElement *answeredStringElement in answeredStringArray) {   // remove old Answered elements so we can add new elements to be saved
            [questionElement removeChild:answeredStringElement];
        }
        
        for (NSString *answeredInstance in question.answeredText) {             // add new child element for each answered string sent to method
            GDataXMLElement *answeredStringElement = [GDataXMLNode elementWithName:@"Answered"];
            answeredStringElement.stringValue = answeredInstance;
            [questionElement addChild:answeredStringElement];
        }
    }
    
    //you supply in the details of the new xml data that you want to write to the NSData variable
    xmlData = xmlDocument.XMLData;
    
    filePath = [self dataFilePath:TRUE nameOfFile:@"EMQ"];
    
    //finally write the data to the file in the doc directory
    [xmlData writeToFile:filePath atomically:YES];
}

+ (NSString *)dataFilePath:(BOOL)forSave nameOfFile:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentsPath = [documentsDirectory
                               stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xml", fileName]];
    if (forSave || [[NSFileManager defaultManager] fileExistsAtPath:documentsPath]) {
        return documentsPath;
        
    } else {
        return [[NSBundle mainBundle] pathForResource:fileName ofType:@"xml"];
    }
}

+ (NSArray *)loadAdministrativeData
{
    NSString *filePath = [self dataFilePath:FALSE nameOfFile:@"Administrative"];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    
    NSArray *currentQuestionStringArray = [doc nodesForXPath:@"//AdministrativeData/CurrentQuestion" error:Nil];
    GDataXMLElement *currentQuestionStringElement = currentQuestionStringArray[0];
    NSArray *currentClusterStringArray = [doc nodesForXPath:@"//AdministrativeData/CurrentCluster" error:Nil];
    GDataXMLElement *currentClusterStringElement = currentClusterStringArray[0];
    NSArray *currentExaminationStringArray = [doc nodesForXPath:@"//AdministrativeData/CurrentExamination" error:Nil];
    GDataXMLElement *currentExaminationStringElement = currentExaminationStringArray[0];
    NSArray *expandedExaminationArray = [doc nodesForXPath:@"//AdministrativeData/ExaminationExpanded" error:Nil];
    GDataXMLElement *expandedExaminationElement = expandedExaminationArray[0];
    NSArray *currentIndexArray = [doc nodesForXPath:@"//AdministrativeData/Index" error:Nil];
    GDataXMLElement *currentIndexElement = currentIndexArray[0];
    
    return [NSArray arrayWithObjects:currentQuestionStringElement.stringValue, currentClusterStringElement.stringValue, currentExaminationStringElement.stringValue, expandedExaminationElement.stringValue, currentIndexElement.stringValue, nil];
}

+ (ExtendedMatchingQuestion *)loadEMQ {
    
    NSString *filePath = [self dataFilePath:FALSE nameOfFile:@"EMQ"];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    
    NSArray *administrativeData = [EMQParser loadAdministrativeData];
    
    /*
    // /Examinations/Examination/Examination[EID=\"%@\"]/Clusters/Cluster/ *[descendant::
    // Returns the first cluster element with at least one empty Answered element indicating unanswered; if none exist returns first cluster of examination
    NSArray *clusterArray = [doc nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination[EID=\"%@\"]/Clusters/Cluster[Questions/Question[string-length(Answered)<1]][1]", administrativeData[2]] error:nil]; //XPath finds the first Cluster element of the currently active Examination with an unanswered question; [1] specifies one element from the [string-length...] set
    
    if (clusterArray.count==0) {
        clusterArray = [doc nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination[EID=\"%@\"]/Clusters/Cluster[1]", administrativeData[2]] error:nil];
        if  (clusterArray.count==0)
            return nil;
    }*/
    
    // FIND OUT WHICH CLUSTER IS CURRENT
    NSArray *clusterArray;
    if ([administrativeData[4] isEqualToString:@"1"]) {
        clusterArray = [doc nodesForXPath:[NSString stringWithFormat:@"/Examinations/Examination/Clusters/Cluster[CID=\"%@\"]", administrativeData[1]] error:nil];
    }
    else if ([administrativeData[4] isEqualToString:@"2"])
    {
        clusterArray = [doc nodesForXPath:[NSString stringWithFormat:@"/Examinations/Examination[EID=\"%@\"]/Clusters/Cluster[1]", administrativeData[2]] error:nil];
    }
    else
    {
        clusterArray = [doc nodesForXPath:[NSString stringWithFormat:@"/Examinations/Examination/Clusters/Cluster[Questions/Question[QID=\"%@\"]]", administrativeData[0]] error:nil];
    }
    
    // FIND OUT WHICH EXAMINATION CONTAINS CURRENT CLUSTER
    GDataXMLElement *clusterElement = clusterArray[0];
    GDataXMLElement *cidElement = [[clusterElement elementsForName:@"CID"] objectAtIndex:0];
    NSString *cidString = [NSString stringWithString:cidElement.stringValue];
    
    NSArray *examinationArray = [doc nodesForXPath:[NSString stringWithFormat:@"/Examinations/Examination[Clusters/Cluster[CID=\"%@\"]]", cidString]  error:nil];
    GDataXMLElement *examinationElement = examinationArray[0];
    GDataXMLElement *eidElement = [[examinationElement elementsForName:@"EID"] objectAtIndex:0];
    NSString *eidString = [NSString stringWithString:eidElement.stringValue];
    
    // COUNT QUESTIONS IN THIS EXAMINATION PRIOR TO CURRENT CLUSTER (TO ALLOW NUMBERING OF QUESTIONS)
    NSArray *countQuestions = [doc nodesForXPath:[NSString stringWithFormat:@"/Examinations/Examination[EID=\"%@\"]/Clusters/Cluster[CID<\"%@\"]/Questions/Question", eidString, cidString] error:nil];
    
    NSMutableArray *optionsToParse = [[NSMutableArray alloc] init];
    NSString *genericQuestion;
    NSMutableArray *questionsToParse = [[NSMutableArray alloc] init];
    int sequentialQuestionNumber = [countQuestions count];
    for (GDataXMLElement *emqMember in clusterArray) {
        
        // Let's fill these in!
        NSArray *optionsNode = [emqMember elementsForName:@"Options"];
        NSArray *questionsNode = [emqMember elementsForName:@"Questions"];
        NSArray *options = [optionsNode[0] elementsForName:@"Option"];
        NSArray *questions = [questionsNode[0] elementsForName:@"Question"];
        
        // Options
        for (GDataXMLElement *option in options)
        {
            [optionsToParse addObject:[NSString stringWithString:option.stringValue]];
        }
        
        // Generic question
        GDataXMLElement *genericQuestionElement = [[emqMember elementsForName:@"GenericQuestion"] objectAtIndex:0];
        genericQuestion = [NSString stringWithString:genericQuestionElement.stringValue];
        
        // Questions
        for (GDataXMLElement *question in questions) {
            sequentialQuestionNumber++;
            NSArray *qidArray = [question elementsForName:@"QID"];
            NSArray *text = [question elementsForName:@"Text"];
            NSArray *answer = [question elementsForName:@"Answer"];
            NSArray *answered = [question elementsForName:@"Answered"];
            NSArray *explanation = [question elementsForName:@"Explanation"];
            GDataXMLElement *qidElement = qidArray[0];
            GDataXMLElement *tempTextElement = text[0];
            NSMutableArray *answerElementArray = [[NSMutableArray alloc] init];
            for (GDataXMLElement *answerElement in answer) {
                if (answerElement.stringValue.length>0) {
                    [answerElementArray addObject:answerElement.stringValue];
                }
            }
      /*      if (answerElementArray.count==0) {
                [answerElementArray addObject:@""];
            }*/
            NSMutableArray *answeredElementArray = [[NSMutableArray alloc] init];
            for (GDataXMLElement *answeredElement in answered) {
                if (answeredElement.stringValue.length>0) {
                    [answeredElementArray addObject:answeredElement.stringValue];
                }                
            }
       /*     if (answeredElementArray.count==0) {
                [answeredElementArray addObject:@""];
            } */
            qaPair *qapair = [[qaPair alloc] init];
            qapair.qid = qidElement.stringValue;
            qapair.questionNumber = sequentialQuestionNumber;
            qapair.questionText = [NSString stringWithString:tempTextElement.stringValue];
            if ([explanation count])
            {
                GDataXMLElement *explanationTextElement = explanation[0];
                qapair.explanationText = [NSString stringWithString:explanationTextElement.stringValue];
            }
            else
            {
                qapair.explanationText = @"No explanation yet";
            }
            NSArray *answerTextArray = [[NSArray alloc] init];
            answerTextArray = answerElementArray;
            qapair.answerText = answerTextArray;
            if (answeredElementArray.count>0) {
                qapair.answeredText = [NSArray arrayWithArray:answeredElementArray];
            }
     /*       else
            {
                qapair.answeredText = [NSArray arrayWithObject:(id)[NSNull null]];
            }*/
            
            [questionsToParse addObject:qapair];
        }
    }
    
    return [ExtendedMatchingQuestion newEMQWithOptionsToAdd:optionsToParse questionInstruction:genericQuestion questionsToAdd:questionsToParse];
}

+ (NSArray *)loadExaminations
{
    NSArray *administrativeData = [self loadAdministrativeData];
    
    NSString *filePath = [self dataFilePath:FALSE nameOfFile:@"EMQ"];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    
    NSMutableArray *examinationsArray = [[NSMutableArray alloc] init];
    /*   NSArray *currentQuestionArray = [doc.rootElement elementsForName:@"CurrentQuestion"];
     //   GDataXMLElement *currentQuestionElement = currentQuestionArray[0];
     NSArray *currentClusterArray = [doc.rootElement elementsForName:@"CurrentCluster"];
     //   GDataXMLElement *currentClusterElement = currentClusterArray[0];
     NSArray *currentExaminationArray = [doc.rootElement elementsForName:@"CurrentExamination"];
     //   GDataXMLElement *currentExaminationElement = currentExaminationArray[0];*/
    
    NSArray *examinations = [doc nodesForXPath:@"//Examinations/Examination" error:nil];
    for (GDataXMLElement *examElement in examinations) {
        
        // Single element items
        NSArray *eidArray = [examElement elementsForName:@"EID"];
        GDataXMLElement *eidElement = eidArray[0];
        NSArray *sourceArray = [examElement elementsForName:@"Source"];
        GDataXMLElement *sourceElement = sourceArray[0];
        NSArray *titleArray = [examElement elementsForName:@"Title"];
        GDataXMLElement *titleElement = titleArray[0];
        
        NSArray *clustersArray = [doc nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination[EID=\"%@\"]/Clusters/Cluster", eidElement.stringValue] error:Nil];
        NSMutableArray *clustersStoreArray = [[NSMutableArray alloc] init];
        for (GDataXMLElement *clusterElement in clustersArray) {
            // Single element items
            NSArray *cidArray = [clusterElement elementsForName:@"CID"];
            GDataXMLElement *cidElement = cidArray[0];
            NSArray *genericQuestionArray = [clusterElement elementsForName:@"GenericQuestion"];
            GDataXMLElement *genericQuestionElement = genericQuestionArray[0];
            NSArray *knowledgeDomainArray = [clusterElement elementsForName:@"KnowledgeDomain"];
            GDataXMLElement *knowledgeDomainElement = knowledgeDomainArray[0];
            NSArray *knowledgeSubDomainArray = [clusterElement elementsForName:@"KnowledgeSubDomain"];
            GDataXMLElement *knowledgeSubDomainElement = knowledgeSubDomainArray[0];
            
            // Multiple element items - options and questions
            
            NSArray *optionsArray = [doc nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination/Clusters/Cluster[CID=\"%@\"]/Options/Option", cidElement.stringValue] error:nil];
            NSArray *questionsArray = [doc nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination/Clusters/Cluster[CID=\"%@\"]/Questions/Question", cidElement.stringValue] error:nil];
            
            NSMutableArray *optionsStoreArray = [[NSMutableArray alloc] init];
            for (GDataXMLElement *option in optionsArray) {
                [optionsStoreArray addObject:option.stringValue];
            }
            
            NSMutableArray *questionsStoreArray = [[NSMutableArray alloc] init];
            for (GDataXMLElement *questionElement in questionsArray) {
                // Single element items
                NSArray *qidArray = [questionElement elementsForName:@"QID"];
                GDataXMLElement *qidElement = qidArray[0];
                NSArray *marksArray = [questionElement elementsForName:@"Marks"];
                GDataXMLElement *marksElement;
                if (marksArray.count>0) {
                    marksElement = marksArray[0];
                }
                NSArray *textArray = [questionElement elementsForName:@"Text"];
                GDataXMLElement *textElement = textArray[0];
                NSArray *answerArray = [questionElement elementsForName:@"Answer"];
                //           GDataXMLElement *answerElement = answerArray[0];
                NSArray *answeredArray = [questionElement elementsForName:@"Answered"];
                //           GDataXMLElement *answeredElement = answeredArray[0];
                qaPair *question = [[qaPair alloc] init];
                question.qid = qidElement.stringValue;
                if (marksArray.count>0) {
                    question.marks = marksElement.stringValue;
                }
                else
                {
                    question.marks = @"1";
                }
                question.questionText = textElement.stringValue;
                NSMutableArray *answerStringArray = [[NSMutableArray alloc] init];
                for (GDataXMLElement *answerElement in answerArray) {
                    [answerStringArray addObject:answerElement.stringValue];
                }
                NSMutableArray *answeredStringArray = [[NSMutableArray alloc] init];
                for (GDataXMLElement *answeredElement in answeredArray) {
                    [answeredStringArray addObject:answeredElement.stringValue];
                }
                question.answerText = answerStringArray;
                question.answeredText = answeredStringArray;
                [questionsStoreArray addObject:question];
            }
            ExtendedMatchingQuestion *EMQtoAdd = [[ExtendedMatchingQuestion alloc] init];
            EMQtoAdd.CID = cidElement.stringValue;
            EMQtoAdd.GenericQuestion = genericQuestionElement.stringValue;
            EMQtoAdd.KnowledgeDomain = knowledgeDomainElement.stringValue;
            EMQtoAdd.KnowledgeSubDomain = knowledgeSubDomainElement.stringValue;
            EMQtoAdd.options = optionsStoreArray;
            EMQtoAdd.questions = questionsStoreArray;
            [clustersStoreArray addObject: EMQtoAdd];
        }
        
        Examination *examinationToAdd = [[Examination alloc] init];
        examinationToAdd.eid = eidElement.stringValue;
        if ([examinationToAdd.eid isEqualToString:administrativeData[2]]) {
            examinationToAdd.currentExamination = @"1";
        }
        else
        {
            examinationToAdd.currentExamination = @"0";
        }
        examinationToAdd.Source = sourceElement.stringValue;
        examinationToAdd.Title = titleElement.stringValue;
        examinationToAdd.Clusters = clustersStoreArray;
        /*    if ([examinationToAdd.eid isEqualToString:@"1"]) {
         examinationToAdd.currentQuestion = [NSNumber numberWithInteger:[currentQuestionElement.stringValue integerValue]];
         examinationToAdd.currentCluster = [NSNumber numberWithInteger:[currentClusterElement.stringValue integerValue]];
         examinationToAdd.currentExamination = [NSNumber numberWithInteger:[currentExaminationElement.stringValue integerValue]];
         }*/
        
        [examinationsArray addObject:examinationToAdd];
    }
    
    return examinationsArray;
}

+ (void)loadRemoteExaminations
{
  //  NSArray *administrativeData = [self loadAdministrativeData];
    
    NSString *filePath = [self dataFilePath:FALSE nameOfFile:@"EMQ"];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    
    NSData *xmlDataRemote = [[NSMutableData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://australianpsychiatryreview.com/EMQ%20copy%202.xml"]];
    NSError *errorRemote;
    GDataXMLDocument *docRemote = [[GDataXMLDocument alloc] initWithData:xmlDataRemote options:0 error:&errorRemote];
    
    NSArray *examinations = [docRemote nodesForXPath:@"//Examinations/Examination" error:nil];
    for (GDataXMLElement *examElement in examinations) {
        
        // Single element items
        NSArray *eidArray = [examElement elementsForName:@"EID"];
        GDataXMLElement *eidElement = eidArray[0];
        
        NSArray *localExaminations = [doc nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination[EID=\"%@\"]", eidElement.stringValue] error:nil];
        if(localExaminations.count == 0) // if new examination copy element for whole examination
        {
            NSArray *localExaminationsRoot = [doc nodesForXPath:[NSString stringWithFormat:@"//Examinations"] error:nil];
            GDataXMLElement *rootElement = localExaminationsRoot[0];
            [rootElement addChild:examElement];
        }
    }
    
    NSArray *clusters = [docRemote nodesForXPath:@"//Examinations/Examination/Clusters/Cluster" error:nil];
    for (GDataXMLElement *clusterElement in clusters)
    {
        NSArray *cidArray = [clusterElement elementsForName:@"CID"];
        GDataXMLElement *cidElement = cidArray[0];
        
        NSArray *localClusters = [doc nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination/Clusters/Cluster[CID=\"%@\"]", cidElement.stringValue] error:nil];
        if(localClusters.count == 0)
        {
            NSArray *remoteExaminationArray = [docRemote nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination[Clusters/Cluster[CID=\"%@\"]]/EID",cidElement.stringValue] error:nil]; // Gives us the examination which the new cluster is part of from which we take the EID to find the examination in the local document
            GDataXMLElement *remoteExaminationRoot = remoteExaminationArray[0];
            NSArray *localClusterArray = [doc nodesForXPath:[NSString stringWithFormat:@"//Examinations/Examination[EID=\"%@\"]/Clusters", remoteExaminationRoot.stringValue] error:nil];
            GDataXMLElement *localClusterElement = localClusterArray[0];
            [localClusterElement addChild:clusterElement];
        }
    }
    
    xmlData = doc.XMLData;
    
    filePath = [self dataFilePath:TRUE nameOfFile:@"EMQ"];
    
    [xmlData writeToFile:filePath atomically:YES];
}

+ (NSArray *)clusterProperties:(NSString *)cid
{
    
    NSString *filePath = [self dataFilePath:FALSE nameOfFile:@"EMQ"];
    NSData *xmlData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    NSError *error;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                           options:0 error:&error];
    
    NSArray *clusterArray = [doc nodesForXPath:[NSString stringWithFormat:@"//Examination/Cluster[CID=\"%@\"]", cid] error:nil];
    GDataXMLElement *clusterToReport = [clusterArray objectAtIndex:0];
    NSArray *knowledgeDomainArray = [clusterToReport elementsForName:@"KnowledgeDomain"];
    GDataXMLElement *knowledgeDomain = (GDataXMLElement *)[knowledgeDomainArray objectAtIndex:0];
    NSArray *knowledgeSubDomainArray = [clusterToReport elementsForName:@"KnowledgeSubDomain"];
    GDataXMLElement *knowledgeSubDomain = (GDataXMLElement *)[knowledgeSubDomainArray objectAtIndex:0];
    NSArray *questionNodesArray = [clusterToReport elementsForName:@"Questions"];
    GDataXMLElement *questionNodes = (GDataXMLElement *)[questionNodesArray objectAtIndex:0];
    NSArray *questionsArray = [questionNodes elementsForName:@"QID"];
    
    return [NSArray arrayWithObjects:cid, [NSString stringWithString:knowledgeDomain.stringValue], [NSString stringWithString:knowledgeSubDomain.stringValue], [questionsArray count], nil];
}

+ (void)setAdministrativeData:(NSArray *)adminData
{
    /* Takes array with NSStrings - [0] indicates CurrentQuestion; [1] indicates CurrentExamination; [2] indicates CurrentCluster; [3] indicates examination expanded, which is whether the clusters of the currently selected examination are displayed in the left tableview; [4] indicates index, in which 0 indicates loadEMQ is guided by current question, 1 indicates current examination, 2 indicates current cluster
     */
    NSString *filePath = [self dataFilePath:TRUE nameOfFile:@"Administrative"];
    NSData *xmlData = [[NSData alloc]initWithContentsOfFile:[self dataFilePath:FALSE nameOfFile:@"Administrative"]];
    
    GDataXMLDocument *xmlDocument = [[GDataXMLDocument alloc]initWithData:xmlData options:0 error:nil];
    
    NSArray *currentQuestionArray = [xmlDocument nodesForXPath:[NSString stringWithFormat:@"//AdministrativeData/CurrentQuestion"] error:nil];
    GDataXMLElement *currentQuestionElement = currentQuestionArray[0];
    currentQuestionElement.stringValue = adminData[0];
    NSArray *currentClusterArray = [xmlDocument nodesForXPath:[NSString stringWithFormat:@"//AdministrativeData/CurrentCluster"] error:Nil];
    GDataXMLElement *currentClusterElement = currentClusterArray[0];
    currentClusterElement.stringValue = adminData[1];
    NSArray *currentExaminationArray = [xmlDocument nodesForXPath:[NSString stringWithFormat:@"//AdministrativeData/CurrentExamination"] error:Nil];
    GDataXMLElement *currentExaminationElement = currentExaminationArray[0];
    currentExaminationElement.stringValue = adminData[2];
    NSArray *currentExpandedArray = [xmlDocument nodesForXPath:[NSString stringWithFormat:@"//AdministrativeData/ExaminationExpanded"] error:Nil];
    GDataXMLElement *currentExpandedElement = currentExpandedArray[0];
    currentExpandedElement.stringValue = adminData[3];
    NSArray *currentIndexArray = [xmlDocument nodesForXPath:[NSString stringWithFormat:@"//AdministrativeData/Index"] error:Nil];
    GDataXMLElement *currentIndexElement = currentIndexArray[0];
    currentIndexElement.stringValue = adminData[4];
    
    //you supply in the details of the new xml data that you want to write to the NSData variable
    xmlData = xmlDocument.XMLData;
    
    filePath = [self dataFilePath:TRUE nameOfFile:@"Administrative"];
    
    //finally write the data to the file in the doc directory
    [xmlData writeToFile:filePath atomically:YES];
}



@end
