//
//  EMQParser.h
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 23/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@class ExtendedMatchingQuestion;

@interface EMQParser : NSObject
{
    
}

+ (ExtendedMatchingQuestion *)loadEMQ;

+ (NSArray *)loadExaminations;
+ (void)loadRemoteExaminations;
+ (NSArray *)clusterProperties:(NSString *)cid; // returns NSArray of NSStrings describing cluster properties such as CID, KnowledgeDomain etc
+ (NSArray *)loadAdministrativeData; // returns NSArray with NSString of QID of current question and NSString of current cluster and NSString of current examination
+ (void)saveAnswers:(NSArray *)questions; // Takes NSArray of qaPairs and writes their answeredText to the xml file
+ (void)setAdministrativeData:(NSArray *)adminData; // accepts array with current question id and current examination id, and updates EMQ.xml
@end
