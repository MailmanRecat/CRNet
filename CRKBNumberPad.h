//
//  CRKBNumberPad.h
//  CRNet
//
//  Created by caine on 12/28/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRKBNumberPad : UIView

@property( nonatomic, strong ) void(^padHandler)(NSInteger);

@end
