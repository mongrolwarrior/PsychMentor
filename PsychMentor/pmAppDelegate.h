//
//  pmAppDelegate.h
//  PsychMentor
//
//  Created by STP02 Psychogeriatrics on 22/01/2014.
//  Copyright (c) 2014 APR. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightViewController.h"

@class RightViewController;

@interface pmAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (weak, nonatomic) RightViewController *myViewController;

@end
