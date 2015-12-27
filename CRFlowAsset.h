//
//  CRFlowAsset.h
//  CRNet
//
//  Created by caine on 12/27/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CRFlowAsset : NSObject

+ (instancetype)standarAsste;

@property( nonatomic, strong ) NSString *download;
@property( nonatomic, strong ) NSString *upload;
@property( nonatomic, strong ) NSString *type;

@property( nonatomic, assign ) float progress;
@property( nonatomic, strong ) NSString *progressString;

@end
