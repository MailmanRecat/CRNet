//
//  CRNet.m
//  CRNet
//
//  Created by caine on 12/27/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>

#import "CRNetManager.h"

@interface CRNetManager()

@end

@implementation CRNetManager

+ (NSString *)networktype{
    
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSNumber *item = nil;
    
    for( id subview in subviews ){
        if( [subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]] ){
            item = subview;
            break;
        }
    }
    
    NSArray *types = @[
                        CR_NET_TYPE_UNKNOW,
                        CR_NET_TYPE_WWAN,
                        CR_NET_TYPE_WWAN,
                        CR_NET_TYPE_WWAN,
                        CR_NET_TYPE_WWAN,
                        CR_NET_TYPE_WIFI
                        ];
    
    NSUInteger type = [[item valueForKey:@"dataNetworkType"] integerValue];
    return type < 6 ? types[type] : CR_NET_TYPE_UNKNOW;
}

+ (NSDictionary *)networkFlow{
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    u_int32_t WiFiSent = 0;
    u_int32_t WiFiReceived = 0;
    u_int32_t WWANSent = 0;
    u_int32_t WWANReceived = 0;
    
    if (getifaddrs(&addrs) == 0)
    {
        cursor = addrs;
        while (cursor != NULL)
        {
            if (cursor->ifa_addr->sa_family == AF_LINK)
            {
                const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                if(ifa_data != NULL){}
                
                // name of interfaces:
                // en0 is WiFi
                // pdp_ip0 is WWAN
                NSString *name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
                if ([name hasPrefix:@"en"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WiFiSent += ifa_data->ifi_obytes;
                        WiFiReceived += ifa_data->ifi_ibytes;
                    }
                }
                
                if ([name hasPrefix:@"pdp_ip"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WWANSent += ifa_data->ifi_obytes;
                        WWANReceived += ifa_data->ifi_ibytes;
                    }
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return @{
             CR_NET_FLOW_WIFI_SENT: [NSNumber numberWithUnsignedInt:WiFiSent],
             CR_NET_FLOW_WIFI_RECEIVED: [NSNumber numberWithUnsignedInt:WiFiReceived],
             CR_NET_FLOW_WWAN_SENT: [NSNumber numberWithUnsignedInt:WWANSent],
             CR_NET_FLOW_WWAN_RECEIVED: [NSNumber numberWithUnsignedInt:WWANReceived]
             };
}

+ (NSDictionary *)networkFlowFromUnit:(NSString *)unit{
    
    NSDictionary *flow = [CRNetManager networkFlow];
    NSString     *type = [CRNetManager networktype];
    
    NSInteger WIFIS = [[flow valueForKey:CR_NET_FLOW_WIFI_SENT] integerValue];
    NSInteger WIFIR = [[flow valueForKey:CR_NET_FLOW_WIFI_RECEIVED] integerValue];
    NSInteger WWANS = [[flow valueForKey:CR_NET_FLOW_WWAN_SENT] integerValue];
    NSInteger WWANR = [[flow valueForKey:CR_NET_FLOW_WWAN_RECEIVED] integerValue];
    
    NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];

    NSInteger cacheWIFIR = [dfs integerForKey:CR_NET_FLOW_WIFI_RECEIVED];
    NSInteger cacheWIFIS = [dfs integerForKey:CR_NET_FLOW_WIFI_SENT];
    NSInteger cacheWWANR = [dfs integerForKey:CR_NET_FLOW_WWAN_RECEIVED];
    NSInteger cacheWWANS = [dfs integerForKey:CR_NET_FLOW_WWAN_SENT];
    
    [dfs setInteger:WIFIR forKey:CR_NET_FLOW_WIFI_RECEIVED];
    [dfs setInteger:WIFIS forKey:CR_NET_FLOW_WIFI_SENT];
    [dfs setInteger:WWANR forKey:CR_NET_FLOW_WWAN_RECEIVED];
    [dfs setInteger:WWANS forKey:CR_NET_FLOW_WWAN_SENT];
    
    
    NSInteger speed  = 0;
    NSInteger upload = 0;
    
    if( type == CR_NET_TYPE_UNKNOW ){
        
        speed = upload = 0;
        
    }else if( type == CR_NET_TYPE_WIFI ){
        
        speed = WIFIR - cacheWIFIR;
        upload = WIFIS - cacheWIFIS;
        
    }else if( type == CR_NET_TYPE_WWAN ){
        
        speed = WWANR - cacheWWANR;
        upload = WWANS - cacheWWANS;
        
    }
    
    if( speed < 0 ){
        speed = upload = 0;
        
        [@[ CR_NET_FLOW_WIFI_RECEIVED, CR_NET_FLOW_WIFI_SENT, CR_NET_FLOW_WWAN_RECEIVED, CR_NET_FLOW_WWAN_SENT ] enumerateObjectsUsingBlock:
         ^(NSString *key, NSUInteger index, BOOL *sS){
             [dfs setInteger:0 forKey:key];
         }];
    }
    
    if( unit == CR_UNIT_BIT ){}
    else if( unit == CR_UNIT_KB ){
        
        WIFIR = WIFIR / 1024;
        WIFIS = WIFIS / 1024;
        WWANR = WWANR / 1024;
        WWANS = WWANS / 1024;
        speed = speed / 1024;
        upload = upload / 1024;
        
    }
    else if( unit == CR_UNIT_MB ){

        WIFIR = WIFIR / ( 1024 * 1024 );
        WIFIS = WIFIS / ( 1024 * 1024 );
        WWANR = WWANR / ( 1024 * 1024 );
        WWANS = WWANS / ( 1024 * 1024 );
        speed = speed / ( 1024 * 1024 );
        upload = upload / ( 1024 * 1024 );
        
    }
    else if( unit == CR_UNIT_GB ){
        
        WIFIR = WIFIR / ( 1024 * 1024 * 1024 );
        WIFIS = WIFIS / ( 1024 * 1024 * 1024 );
        WWANR = WWANR / ( 1024 * 1024 * 1024 );
        WWANS = WWANS / ( 1024 * 1024 * 1024 );
        speed = speed / ( 1024 * 1024 * 1024 );
        upload = upload / ( 1024 * 1024 * 1024 );
        
    }
    else if( unit == CR_UNIT_TB ){}
    
    return @{
             SWIFIS:  [NSNumber numberWithUnsignedInteger:WIFIS],
             SWIFIR:  [NSNumber numberWithUnsignedInteger:WIFIR],
             SWWANS:  [NSNumber numberWithUnsignedInteger:WWANS],
             SWWANR:  [NSNumber numberWithUnsignedInteger:WWANR],
             SSPEED:  [NSNumber numberWithUnsignedInteger:speed],
             SUPLOAD: [NSNumber numberWithUnsignedInteger:upload]
             };
}

@end
