//
//  CRFlowAsset.m
//  CRNet
//
//  Created by caine on 12/27/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#import "CRFlowAsset.h"
#import "CRNetManager.h"

@interface CRFlowAsset()

@property( nonatomic, strong ) NSDictionary *flow;

@end

@implementation CRFlowAsset

- (NSString *)download{
    NSDictionary *flow = [CRNetManager networkFlowFromUnit:CR_UNIT_KB];
    [CRFlowAsset standarAsste].flow = flow;
    
    _download = [CRFlowAsset formatSpeed:[flow[SSPEED] floatValue]];
    
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
        
    }else{
        
    }
    
//    NSLog(@"%ld", [self.flow[SWIFIR] integerValue] / 1024);
    CGFloat testing = [self.flow[SWIFIR] integerValue] / (1024.0 * 1024);
    self.progressString = [NSString stringWithFormat:@"%.2f GB of 6 GB", testing];
    
    return testing / 6.0;
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
    return asset;
}

@end
