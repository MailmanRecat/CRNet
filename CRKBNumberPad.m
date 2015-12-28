//
//  CRKBNumberPad.m
//  CRNet
//
//  Created by caine on 12/28/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#import "CRKBNumberPad.h"
#import "UIFont+MaterialDesignIcons.h"

@interface CRKBNumberPad()

@property( nonatomic, strong ) UIVisualEffectView *hightlightEffect;

@property( nonatomic, strong ) UIVisualEffectView *optionEffect;
@property( nonatomic, strong ) UIVisualEffectView *deleteEffect;

@property( nonatomic, strong ) CAShapeLayer *borderHI;
@property( nonatomic, strong ) CAShapeLayer *borderHII;
@property( nonatomic, strong ) CAShapeLayer *borderHIII;

@property( nonatomic, strong ) CAShapeLayer *borderVI;
@property( nonatomic, strong ) CAShapeLayer *borderVII;

@end

@implementation CRKBNumberPad

- (instancetype)init{
    self = [super init];
    if( self ){
        self.hightlightEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.optionEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.deleteEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        self.hightlightEffect.translatesAutoresizingMaskIntoConstraints = NO;
        self.optionEffect.translatesAutoresizingMaskIntoConstraints = NO;
        self.deleteEffect.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.hightlightEffect.userInteractionEnabled =
        self.optionEffect.userInteractionEnabled =
        self.deleteEffect.userInteractionEnabled = NO;
        
        [self initClass];
        [self letBorder];
    }
    return self;
}

- (void)initClass{
    UIButton *(^letButton)(NSInteger, NSString *, UIFont *, BOOL) = ^(NSInteger tag, NSString *title, UIFont *font, BOOL option){
        UIButton *button = [[UIButton alloc] init];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.tag = 1000 + tag;
        if( font )
            button.titleLabel.font = font;
        else
            button.titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
        
        [button addTarget:self action:@selector(padTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(padTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button setTitle:title forState:UIControlStateNormal];
        
        if( option ){
            UIVisualEffectView *effect;
            if( tag == -1 )
                effect = self.deleteEffect;
            else
                effect = self.optionEffect;
            
            [button insertSubview:effect atIndex:0];
            [effect.topAnchor constraintEqualToAnchor:button.topAnchor].active = YES;
            [effect.leftAnchor constraintEqualToAnchor:button.leftAnchor].active = YES;
            [effect.rightAnchor constraintEqualToAnchor:button.rightAnchor].active = YES;
            [effect.bottomAnchor constraintEqualToAnchor:button.bottomAnchor].active = YES;
            
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        }else{
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
        
        [self addSubview:button];
        return button;
    };
    
    UIButton *btn1 = letButton(1, @"1", nil, NO);
    UIButton *btn2 = letButton(2, @"2", nil, NO);
    UIButton *btn3 = letButton(3, @"3", nil, NO);
    UIButton *btn4 = letButton(4, @"4", nil, NO);
    UIButton *btn5 = letButton(5, @"5", nil, NO);
    UIButton *btn6 = letButton(6, @"6", nil, NO);
    UIButton *btn7 = letButton(7, @"7", nil, NO);
    UIButton *btn8 = letButton(8, @"8", nil, NO);
    UIButton *btn9 = letButton(9, @"9", nil, NO);
    UIButton *btn0 = letButton(0, @"0", nil, NO);
    UIButton *btnO = letButton(-2, @"", [UIFont systemFontOfSize:16 weight:UIFontWeightLight], YES);
    UIButton *btnD = letButton(-1, [UIFont mdiKeyboardBackspace], [UIFont MaterialDesignIconsWithSize:24], YES);
    
    __block NSLayoutAnchor *toptargetAnchor = self.topAnchor;
    __block NSLayoutAnchor *leftTargetAnchor = self.leftAnchor;
    [@[btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9, btnO, btn0, btnD] enumerateObjectsUsingBlock:
     ^(UIView *btn, NSUInteger index, BOOL *sS){
         [btn.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:1 / 3.0].active = YES;
         [btn.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:1 / 4.0].active = YES;
         [btn.topAnchor constraintEqualToAnchor:toptargetAnchor].active = YES;
         [btn.leftAnchor constraintEqualToAnchor:leftTargetAnchor].active = YES;
         
         if( index % 3 == 2 ){
             toptargetAnchor = btn.bottomAnchor;
             leftTargetAnchor = self.leftAnchor;
         }else
             leftTargetAnchor = btn.rightAnchor;
    }];
}

- (void)letBorder{
    self.borderHI = [CAShapeLayer layer];
    self.borderHII = [CAShapeLayer layer];
    self.borderHIII = [CAShapeLayer layer];
    self.borderVI = [CAShapeLayer layer];
    self.borderVII = [CAShapeLayer layer];
    
    [@[ self.borderHI, self.borderHII, self.borderHIII, self.borderVI, self.borderVII ] enumerateObjectsUsingBlock:
     ^(CALayer *layer, NSUInteger index, BOOL *sS){
         layer.backgroundColor = [UIColor colorWithWhite:114 / 255.0 alpha:0.6].CGColor;
         [self.layer addSublayer:layer];
     }];

}

- (void)layoutSubviews{
    CGRect selfRect = self.frame;
    [@[ self.borderHI, self.borderHII, self.borderHIII, self.borderVI, self.borderVII ] enumerateObjectsUsingBlock:
     ^(CALayer *layer, NSUInteger index, BOOL *sS){
         if( index < 3 )
             layer.frame = CGRectMake(0, (selfRect.size.height / 4.0) * (index + 1) - 0.5, selfRect.size.width, 1);
         else
             layer.frame = CGRectMake((selfRect.size.width / 3.0) * (index - 3 + 1) - 0.5, 0, 1, selfRect.size.height);
     }];
}

- (void)padTouchUpInside:(UIButton *)sender{
    NSInteger tag = sender.tag - 1000;
    
    if( tag >= 0 ){
        [self.hightlightEffect removeFromSuperview];
    }else if( tag == -1 ){
        [sender insertSubview:self.deleteEffect atIndex:0];
        [self.deleteEffect.topAnchor constraintEqualToAnchor:sender.topAnchor].active = YES;
        [self.deleteEffect.leftAnchor constraintEqualToAnchor:sender.leftAnchor].active = YES;
        [self.deleteEffect.rightAnchor constraintEqualToAnchor:sender.rightAnchor].active = YES;
        [self.deleteEffect.bottomAnchor constraintEqualToAnchor:sender.bottomAnchor].active = YES;
    }else if( tag == -2 ){
        [sender insertSubview:self.optionEffect atIndex:0];
        [self.optionEffect.topAnchor constraintEqualToAnchor:sender.topAnchor].active = YES;
        [self.optionEffect.leftAnchor constraintEqualToAnchor:sender.leftAnchor].active = YES;
        [self.optionEffect.rightAnchor constraintEqualToAnchor:sender.rightAnchor].active = YES;
        [self.optionEffect.bottomAnchor constraintEqualToAnchor:sender.bottomAnchor].active = YES;
    }
    
    if( self.padHandler )
        self.padHandler( tag );
}

- (void)padTouchDown:(UIButton *)sender{
    NSInteger tag = sender.tag - 1000;
    if( tag == -1 ){
        [self.deleteEffect removeFromSuperview];
    }else if( tag == -2 ){
        [self.optionEffect removeFromSuperview];
    }else{
        [sender insertSubview:self.hightlightEffect atIndex:0];
        [self.hightlightEffect.topAnchor constraintEqualToAnchor:sender.topAnchor].active = YES;
        [self.hightlightEffect.leftAnchor constraintEqualToAnchor:sender.leftAnchor].active = YES;
        [self.hightlightEffect.rightAnchor constraintEqualToAnchor:sender.rightAnchor].active = YES;
        [self.hightlightEffect.bottomAnchor constraintEqualToAnchor:sender.bottomAnchor].active = YES;
    }
}

@end
