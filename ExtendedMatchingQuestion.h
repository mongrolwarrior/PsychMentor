#import <Foundation/Foundation.h>
#import "qaPair.h"

@interface ExtendedMatchingQuestion : NSObject
@property (nonatomic, strong) NSString *CID;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSString *GenericQuestion;
@property (nonatomic, strong) NSString *KnowledgeDomain;
@property (nonatomic, strong) NSString *KnowledgeSubDomain;
@property (nonatomic, strong) NSArray *questions;

//Factory class method to create new EMQs
+(ExtendedMatchingQuestion *)newEMQWithOptionsToAdd:(NSMutableArray *)optionsToAdd questionInstruction:(NSString *)questionInstruction questionsToAdd:(NSMutableArray *)questionsToAdd;

@end