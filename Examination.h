//
//  Examination.h
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 26/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Examination : NSObject
@property (readwrite, strong, nonatomic) NSString *eid; // Examination ID
@property (readwrite, strong, nonatomic) NSString *Source;
@property (readwrite, strong, nonatomic) NSString *Title;
@property (readwrite, strong, nonatomic) NSArray *Clusters;/*
@property (strong, nonatomic) NSNumber *currentQuestion;
@property (strong, nonatomic) NSNumber *currentCluster;*/
@property (readwrite, strong, nonatomic) NSString *currentExamination; // 0 means not current, 1 means is current

@end
