//
//  CRNet.h
//  CRNet
//
//  Created by caine on 12/27/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const CR_NET_TYPE_UNKNOW = @"unknow";
static NSString *const CR_NET_TYPE_WIFI = @"wifi";
static NSString *const CR_NET_TYPE_WWAN = @"wwan";

static NSString *const CR_NET_FLOW_WIFI_RECEIVED = @"wifiReceived";
static NSString *const CR_NET_FLOW_WIFI_SENT     = @"wifiSent";
static NSString *const CR_NET_FLOW_WWAN_RECEIVED = @"wwanReceived";
static NSString *const CR_NET_FLOW_WWAN_SENT     = @"wwanSent";

static NSString *const SWIFIS = @"WIFIS";
static NSString *const SWIFIR = @"WIFIR";
static NSString *const SWWANS = @"WWANS";
static NSString *const SWWANR = @"WWANR";
static NSString *const SSPEED = @"SPEED";
static NSString *const SUPLOAD = @"SUPLOAD";

static NSString *const CR_UNIT_BIT = @"BIT";
static NSString *const CR_UNIT_KB = @"KB";
static NSString *const CR_UNIT_MB = @"MB";
static NSString *const CR_UNIT_GB = @"GB";
static NSString *const CR_UNIT_TB = @"TB";

@interface CRNetManager : NSObject

+ (NSString *)networktype;
+ (NSDictionary *)networkFlow;
+ (NSDictionary *)networkFlowFromUnit:(NSString *)unit;

@end
