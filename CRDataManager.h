//
//  CRDataManager.h
//  CRNet
//
//  Created by caine on 12/27/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const PROGRESS_TARGET_WIFI = @"PROGRESS_TARGET_WIFI";
static NSString *const PROGRESS_TARGET_WWAN = @"PROGRESS_TARGET_WWAN";

@interface CRDataManager : NSObject

+ (void)setProgressTarget:(NSString *)type value:(NSUInteger)value;
+ (float)getProgress:(NSString *)type;
+ (NSUInteger)getProgressTarget:(NSString *)type;

+ (BOOL)autoCorrectOffset:(NSInteger)WiFiR :(NSInteger)WiFiS :(NSInteger)WWANR :(NSInteger)WWANS;

@end
