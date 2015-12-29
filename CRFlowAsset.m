//
//  CRFlowAsset.m
//  CRNet
//
//  Created by caine on 12/27/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#import "CRFlowAsset.h"
#import "CRNetManager.h"
#import "CRDataManager.h"

@interface CRFlowAsset()

@property( nonatomic, strong ) NSDictionary *flow;

@end

@implementation CRFlowAsset

- (NSString *)download{
    
    _download = [CRFlowAsset formatSpeed:[self.flow[SSPEED] floatValue]];
    
    return _download;
}

- (NSString *)upload{
    _upload = [CRFlowAsset formatSpeed:[self.flow[SUPLOAD] floatValue]];
    return _upload;
}

- (NSString *)type{
    NSString *type = [CRNetManager networktype];
    NSDictionary *map = @{
                          CR_NET_TYPE_UNKNOW: @"No connection",
                          CR_NET_TYPE_WIFI  : @"WiFi",
                          CR_NET_TYPE_WWAN  : @"Cellular"
                          };
    _type = map[type];
    return _type;
}

- (float)progress{
    NSString *type = [CRNetManager networktype];
    if( type == CR_NET_TYPE_WWAN ){
        CGFloat pro = [CRDataManager getProgress:PROGRESS_TARGET_WWAN];
        NSUInteger cache = [CRDataManager getProgressTarget:PROGRESS_TARGET_WWAN];
        if( cache / 1024 < 1024 )
            self.progressString = [NSString stringWithFormat:@"%.1f MB of %ld MB", cache / 1024 * pro, cache / 1024];
        else{
            if( cache / 1024 * pro < 1024 )
                self.progressString = [NSString stringWithFormat:@"%ld MB of %.2f GB", (NSUInteger)(cache / 1024 * pro), cache / 1024 / 1024.0];
            else
                self.progressString = [NSString stringWithFormat:@"%.2f GB of %.2f GB", cache / 1024 / 1024 * pro, cache / 1024 / 1024.0];
        }
        
        return pro;
    }else{
        CGFloat pro = [CRDataManager getProgress:PROGRESS_TARGET_WIFI];
        NSUInteger cache = [CRDataManager getProgressTarget:PROGRESS_TARGET_WIFI];
        if( cache / 1024 < 1024 )
            self.progressString = [NSString stringWithFormat:@"%.1f MB of %ld MB", cache / 1024 * pro, cache / 1024];
        else{
            if( cache / 1024 * pro < 1024 )
                self.progressString = [NSString stringWithFormat:@"%ld MB of %.2f GB", (NSUInteger)(cache / 1024 * pro), cache / 1024 / 1024.0];
            else
                self.progressString = [NSString stringWithFormat:@"%.2f GB of %.2f GB", cache / 1024 / 1024 * pro, cache / 1024 / 1024.0];
        }
        
        return pro;
    }
}

+ (NSString *)formatSpeed:(CGFloat)speed{
    return ({
        speed > 1024 ? [NSString stringWithFormat:@"%0.1f MB/S", speed / 1024] : [NSString stringWithFormat:@"%d KB/S", (int)speed];
    });
}

+ (instancetype)standarAsste{
    static CRFlowAsset *asset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asset = [[CRFlowAsset alloc] init];
    });
    asset.flow = [CRNetManager networkFlowFromUnit:CR_UNIT_KB];
    
    [CRDataManager autoCorrectOffset:[asset.flow[SWIFIR] integerValue]
                                    :[asset.flow[SWIFIS] integerValue]
                                    :[asset.flow[SWWANR] integerValue]
                                    :[asset.flow[SWWANS] integerValue]];
    
    return asset;
}

@end
