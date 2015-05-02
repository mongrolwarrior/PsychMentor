//
//  ExtendedMatchingQuestion.m
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 22/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import "ExtendedMatchingQuestion.h"
#import "qaPair.h"

@implementation ExtendedMatchingQuestion
@synthesize CID, options, GenericQuestion, questions;

+ (ExtendedMatchingQuestion *)newEMQWithOptionsToAdd:(NSArray *)optionsToAdd questionInstruction:(NSString *)questionInstruction questionsToAdd:(NSArray *)questionsToAdd
{
    ExtendedMatchingQuestion *extendedMatchingQuestion = [[ExtendedMatchingQuestion alloc] init];
    NSMutableArray *opt = [[NSMutableArray alloc] init];
    for(NSString* option in optionsToAdd)
    {
        NSString *currentOption = [[NSString alloc] initWithString:option];
        [opt addObject:currentOption];
    }
    
    extendedMatchingQuestion.options = opt;
    
    extendedMatchingQuestion.GenericQuestion = questionInstruction;
    
    NSMutableArray *quest = [[NSMutableArray alloc] init];
    for(qaPair* question in questionsToAdd)
    {
        qaPair *currentQuestion = [[qaPair alloc] init];
        currentQuestion = question;
        [quest addObject:currentQuestion];
    }
    
    extendedMatchingQuestion.questions = quest;

    return extendedMatchingQuestion;
}
@end
