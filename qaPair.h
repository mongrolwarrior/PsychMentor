//
//  qaPair.h
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 25/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface qaPair : NSObject
@property (readwrite, strong, nonatomic) NSString *qid;
@property (readwrite, strong, nonatomic) NSString *questionText;
@property (readwrite, strong, nonatomic) NSString *explanationText;
@property (readwrite, strong, nonatomic) NSString *marks;
@property (nonatomic, retain) NSArray *answerText;
@property (nonatomic, retain) NSArray *answeredText; // records current answer selected by candidate
@property (nonatomic) int questionNumber; // sequential question number within current examination

@end
