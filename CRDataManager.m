//
//  CRDataManager.m
//  CRNet
//
//  Created by caine on 12/27/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#import "CRDataManager.h"

static NSString *const LAST_WIFI_RECEIVED_DATA = @"LAST_WIFI_RECEIVED_DATA";
static NSString *const LAST_WIFI_SENT_DATA     = @"LAST_WIFI_SENT_DATA";
static NSString *const LAST_WWAN_RECEIVED_DATA = @"LAST_WWAN_RECEIVED_DATA";
static NSString *const LAST_WWAN_SENT_DATA     = @"LAST_WWAN_SENT_DATA";

static NSString *const LAST_WIFI_RECEIVED_RECORD = @"LAST_WIFI_RECEVIED_RECORD";
static NSString *const LAST_WIFI_SENT_RECORD = @"LAST_WIFI_SENT_RECOED";
static NSString *const LAST_WWAN_RECEIVED_RECORD = @"LAST_WWAN_RECEVIED_RECORD";
static NSString *const LAST_WWAN_SENT_RECORD = @"LAST_WWAN_SENT_RECORD";

static NSString *const LAST_PROGRESS_WIFI_CACHE = @"LAST_PROGRESS_WIFI_CACHE";
static NSString *const LAST_PROGRESS_WWAN_CACHE = @"LAST_PROGRESS_WWAN_CACHE";

@implementation CRDataManager

+ (void)setProgressTarget:(NSString *)type value:(NSUInteger)value{
    NSArray *lastRecord = [self lastDataRecord];
    
    NSInteger wir = [lastRecord[0] integerValue];
    NSInteger wwr = [lastRecord[2] integerValue];
    
    if( type == PROGRESS_TARGET_WIFI ){
        [[NSUserDefaults standardUserDefaults] setInteger:((value == 0 ? 1024 : value) * 1024) forKey:PROGRESS_TARGET_WIFI];
        [[NSUserDefaults standardUserDefaults] setInteger:wir forKey:LAST_PROGRESS_WIFI_CACHE];
    }else if( type == PROGRESS_TARGET_WWAN ){
        [[NSUserDefaults standardUserDefaults] setInteger:((value == 0 ? 1024 : value) * 1024) forKey:PROGRESS_TARGET_WWAN];
        [[NSUserDefaults standardUserDefaults] setInteger:wwr forKey:LAST_PROGRESS_WWAN_CACHE];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSUInteger)getProgressTarget:(NSString *)type{
    NSUInteger t = 0;
    if( type == PROGRESS_TARGET_WIFI )
        t = [[NSUserDefaults standardUserDefaults] integerForKey:PROGRESS_TARGET_WIFI];
    else if( type == PROGRESS_TARGET_WWAN )
        t = [[NSUserDefaults standardUserDefaults] integerForKey:PROGRESS_TARGET_WWAN];
    
    return t == 0 ? 1024 : t;
}

+ (float)getProgress:(NSString *)type{
    NSArray *lastRecord = [self lastDataRecord];
    
    NSInteger wir = [lastRecord[0] integerValue];
    NSInteger wwr = [lastRecord[2] integerValue];
    
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
    
    if( type == PROGRESS_TARGET_WWAN )
        return (wwr - [dfs integerForKey:LAST_PROGRESS_WWAN_CACHE] + 0.0) / [dfs integerForKey:PROGRESS_TARGET_WWAN];
    else
        return (wir - [dfs integerForKey:LAST_PROGRESS_WIFI_CACHE] + 0.0) / [dfs integerForKey:PROGRESS_TARGET_WIFI];
}

+ (void)setLastDataRecord:(NSInteger)WiFiR :(NSInteger)WiFiS :(NSInteger)WWANR :(NSInteger)WWANS{
    [[NSUserDefaults standardUserDefaults] setInteger:WiFiR forKey:LAST_WIFI_RECEIVED_RECORD];
    [[NSUserDefaults standardUserDefaults] setInteger:WiFiS forKey:LAST_WIFI_SENT_RECORD];
    [[NSUserDefaults standardUserDefaults] setInteger:WWANR forKey:LAST_WWAN_RECEIVED_RECORD];
    [[NSUserDefaults standardUserDefaults] setInteger:WWANS forKey:LAST_WWAN_SENT_RECORD];
}

+ (NSArray *)lastDataRecord{
    NSInteger wir, wis, wwr, wws;
    wir = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_WIFI_RECEIVED_RECORD];
    wis = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_WIFI_SENT_RECORD];
    wwr = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_WWAN_RECEIVED_RECORD];
    wws = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_WWAN_SENT_RECORD];
    
    if( !wir ) wir = 0;
    if( !wis ) wis = 0;
    if( !wwr ) wwr = 0;
    if( !wws ) wws = 0;
    
    return @[ [NSNumber numberWithInteger:wir],
              [NSNumber numberWithInteger:wis],
              [NSNumber numberWithInteger:wwr],
              [NSNumber numberWithInteger:wws]
              ];
}

+ (BOOL)autoCorrectOffset:(NSInteger)WiFiR :(NSInteger)WiFiS :(NSInteger)WWANR :(NSInteger)WWANS{
    
    NSArray *lastRecord = [self lastDataRecord];
    
    NSInteger wir = [lastRecord[0] integerValue];
    NSInteger wis = [lastRecord[1] integerValue];
    NSInteger wwr = [lastRecord[2] integerValue];
    NSInteger wws = [lastRecord[3] integerValue];
    
    if( wir == 0 ) wir = WiFiR;
    if( wis == 0 ) wis = WiFiS;
    if( wwr == 0 ) wwr = WWANR;
    if( wws == 0 ) wws = WWANS;
    
    NSInteger plusWirR = ( WiFiR - wir ) < 0 ? wir : 0;
    NSInteger plusWisR = ( WiFiS - wis ) < 0 ? wis : 0;
    NSInteger plusWwrR = ( WWANR - wwr ) < 0 ? wwr : 0;
    NSInteger plusWwsR = ( WWANS - wws ) < 0 ? wws : 0;
    
    [self setWiFiReceviedOffset:plusWirR];
    [self setWifiSentOffset:plusWisR];
    [self setWWANReceviedOffset:plusWwrR];
    [self setWWANSentOffset:plusWwsR];
    
    [self setLastDataRecord:WiFiR :WiFiS :WWANR :WWANS];
    
    return YES;
}

+ (NSInteger)setWiFiReceviedOffset:(NSInteger)offset{
    NSInteger old = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_WIFI_RECEIVED_DATA];
    if( !old ) old = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:offset + old forKey:LAST_WIFI_RECEIVED_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return offset;
}

+ (NSInteger)setWifiSentOffset:(NSInteger)offset{
    NSInteger old = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_WIFI_SENT_DATA];
    if( !old ) old = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:offset + old forKey:LAST_WIFI_SENT_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return offset;
}

+ (NSInteger)setWWANReceviedOffset:(NSInteger)offset{
    NSInteger old = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_WWAN_RECEIVED_DATA];
    if( !old ) old = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:offset + old forKey:LAST_WWAN_RECEIVED_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return offset;
}

+ (NSInteger)setWWANSentOffset:(NSInteger)offset{
    NSInteger old = [[NSUserDefaults standardUserDefaults] integerForKey:LAST_WWAN_SENT_DATA];
    if( !old ) old = 0;
    [[NSUserDefaults standardUserDefaults] setInteger:offset + old forKey:LAST_WWAN_SENT_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return offset;
}

@end
