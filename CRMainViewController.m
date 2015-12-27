//
//  CRMainViewController.m
//  CRNet
//
//  Created by caine on 12/27/15.
//  Copyright © 2015 com.caine. All rights reserved.
//

#define REFRESH_INTERVAL 1

#import "CRMainViewController.h"
//#import "CRNetManager.h"
#import "CRFlowAsset.h"

static NSString *const CR_NET_STATUS_BEAR = @"CR_NET_STATUS_BEAR";
static NSString *const CR_NET_STATUS_BABOON = @"CR_NET_STATUS_BABOON";
static NSString *const CR_NET_STATUS_MONKEY = @"CR_NET_STATUS_MONKEY";

@interface CRMainViewController()<UITextFieldDelegate>{
    dispatch_queue_t  queueToken;
    dispatch_source_t timerToken;
}

@property( nonatomic, strong ) NSString *status;

@property( nonatomic, strong ) UIButton *cancel;
@property( nonatomic, strong ) UITextField *targetField;
@property( nonatomic, strong ) UIVisualEffectView *effect;
@property( nonatomic, strong ) NSLayoutConstraint *effectLayoutGuide;

@property( nonatomic, strong ) UILabel *networkType;

@property( nonatomic, strong ) UILabel *speed;
@property( nonatomic, strong ) NSLayoutConstraint *speedLayoutGuide;

@property( nonatomic, strong ) CAGradientLayer *good;

@property( nonatomic, strong ) UIProgressView *progress;
@property( nonatomic, strong ) UILabel *progressLabel;
@property( nonatomic, strong ) NSLayoutConstraint *progressLayoutGuide;

@property( nonatomic, strong ) UIButton *addTarget;
@property( nonatomic, strong ) UIButton *targetCock;
@property( nonatomic, strong ) UIButton *targetDick;
@property( nonatomic, strong ) NSLayoutConstraint *addTargetLayoutGuide;

@property( nonatomic, strong ) NSArray *bearColors;
@property( nonatomic, strong ) NSArray *boboonColors;
@property( nonatomic, strong ) NSArray *monkeyColors;

@end

@implementation CRMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.bearColors = @[
                        (__bridge id)[UIColor colorWithRed:50  / 255.0 green:199 / 255.0 blue:244 / 255.0 alpha:1].CGColor,
                        (__bridge id)[UIColor colorWithRed:29  / 255.0 green:109 / 255.0 blue:217 / 255.0 alpha:1].CGColor
                        ];
    
    self.boboonColors = @[
                          (__bridge id)[UIColor colorWithRed:248 / 255.0 green:190 / 255.0 blue:62  / 255.0 alpha:1].CGColor,
                          (__bridge id)[UIColor colorWithRed:228 / 255.0 green:109 / 255.0 blue:58  / 255.0 alpha:1].CGColor
                          ];
    
    self.monkeyColors = @[
                          (__bridge id)[UIColor colorWithRed:255 / 255.0 green:59  / 255.0 blue:48  / 255.0 alpha:1].CGColor,
                          (__bridge id)[UIColor colorWithRed:175 / 255.0 green:19  / 255.0 blue:31  / 255.0 alpha:1].CGColor
                          ];
    
    CAGradientLayer *good = [CAGradientLayer layer];
    good.colors = self.bearColors;
    good.frame = self.view.bounds;
    
    self.status = CR_NET_STATUS_BEAR;
    
    self.good = good;
    
    [self.view.layer addSublayer:good];
    
    [self letSpeed];
    [self letProgress];
    [self letEffect];
    [self letButton];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(willKeyBoardChangeFrame:)
                   name:UIKeyboardWillChangeFrameNotification
                 object:nil];
    
    [self letStart];
}

- (void)letStart{
    uint64_t interval = REFRESH_INTERVAL * NSEC_PER_SEC;
    
    if( !queueToken )
        queueToken = dispatch_queue_create("com.crnet.queue", DISPATCH_QUEUE_CONCURRENT);
    
    timerToken = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queueToken);
    
    dispatch_source_set_timer(timerToken, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
    
    dispatch_source_set_event_handler(timerToken, ^{
        [self letRefresh];
    });
    
    dispatch_resume(timerToken);
}

- (void)letRefresh{
    CRFlowAsset *asset = [CRFlowAsset standarAsste];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.speed setText:asset.download];
        [self.networkType setText:asset.type];
        [self.progress setProgress:asset.progress animated:YES];
        [self.progressLabel setText:asset.progressString];
        
        if( asset.progress > 0.6 && ![self.status isEqualToString:CR_NET_STATUS_BABOON] )
            [self updateStatus:CR_NET_STATUS_BABOON];
        if( asset.progress > 0.9 && ![self.status isEqualToString:CR_NET_STATUS_MONKEY] )
            [self updateStatus:CR_NET_STATUS_MONKEY];
        else if( asset.progress <= 0.6 && ![self.status isEqualToString:CR_NET_STATUS_BEAR] )
            [self updateStatus:CR_NET_STATUS_BEAR];
    });
}

- (void)letSpeed{
    self.networkType = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, STATUS_BAR_HEIGHT, 160, 56)];
        [self.view addSubview:label];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
        label.text = @"WiFi";
        label;
    });
    
    self.speed = ({
        UILabel *speed = [[UILabel alloc] init];
        speed.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:speed];
        [speed.heightAnchor constraintEqualToAnchor:speed.widthAnchor].active = YES;
        [speed.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
        [speed.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        self.speedLayoutGuide = [speed.centerYAnchor constraintEqualToAnchor:self.view.bottomAnchor];
        self.speedLayoutGuide.constant = -self.view.frame.size.height * 0.618;
        self.speedLayoutGuide.active = YES;
        speed.text = @"0 KB/S";
        speed.font = [UIFont systemFontOfSize:64 weight:UIFontWeightThin];
        speed.textAlignment = NSTextAlignmentCenter;
        speed.textColor = [UIColor whiteColor];
        speed;
    });
}

- (void)letProgress{
    self.progress = ({
        UIProgressView *progress = [[UIProgressView alloc] init];
        [progress setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:progress];
        [progress.widthAnchor constraintEqualToAnchor:self.view.widthAnchor constant:-56].active = YES;
        [progress.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
        self.progressLayoutGuide = [progress.centerYAnchor constraintEqualToAnchor:self.view.bottomAnchor];
        self.progressLayoutGuide.constant = - self.view.frame.size.height * 0.382;
        self.progressLayoutGuide.active = YES;
        progress.progress = 0.3;
        progress.tintColor = [UIColor colorWithRed:29  / 255.0 green:109 / 255.0 blue:217 / 255.0 alpha:1];
        progress.trackTintColor = [UIColor whiteColor];
        progress;
    });
    
    self.progressLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:label];
        [label.heightAnchor constraintEqualToConstant:36].active = YES;
        [label.leftAnchor constraintEqualToAnchor:self.progress.leftAnchor].active = YES;
        [label.topAnchor constraintEqualToAnchor:self.progress.bottomAnchor].active = YES;
        [label.rightAnchor constraintEqualToAnchor:self.progress.rightAnchor].active = YES;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        label.text = @"3 GB of 8 GB";
        label;
    });
}

- (void)letButton{
    UIButton *(^letBtn)(NSUInteger, NSString *, NSLayoutAnchor *) = ^(NSUInteger tag, NSString *title, NSLayoutAnchor *pos){
        return ({
            UIButton *button = [[UIButton alloc] init];
            button.tag = 1000 + tag;
            button.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:button];
            [button.leftAnchor constraintEqualToAnchor:pos].active = YES;
            [button.heightAnchor constraintEqualToConstant:STATUS_BAR_HEIGHT + 56.0].active = YES;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:title forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    };
    
    self.targetCock = letBtn( 1, @"Set to WiFi", self.view.leftAnchor );
    self.targetDick = letBtn( 2, @"Set to Celluar", self.targetCock.rightAnchor );
    self.addTarget  = letBtn( 0, @"Add target", self.view.leftAnchor );
    
    self.targetCock.hidden = YES;
    self.targetDick.hidden = YES;
    
    [self.targetCock.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.5].active = YES;
    [self.targetDick.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.5].active = YES;
    [self.addTarget.widthAnchor  constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    
    self.addTargetLayoutGuide = [self.addTarget.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    self.addTargetLayoutGuide.active = YES;
    [self.targetCock.bottomAnchor constraintEqualToAnchor:self.addTarget.bottomAnchor].active = YES;
    [self.targetDick.bottomAnchor constraintEqualToAnchor:self.addTarget.bottomAnchor].active = YES;
}

- (void)buttonAction:(UIButton *)sender{
    NSUInteger tag = sender.tag - 1000;
    
    if( tag == 5 ){
        [self letPop];
    }else if( tag == 0 ){
        [self letPush];
    }
}

- (void)letEffect{
    self.effect = ({
        UIVisualEffectView *blurview = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        blurview.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:blurview];
        [blurview.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
        [blurview.rightAnchor constraintEqualToAnchor:self.view.rightAnchor].active = YES;
        [blurview.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
        self.effectLayoutGuide = [blurview.topAnchor constraintEqualToAnchor:self.view.bottomAnchor];
        self.effectLayoutGuide.constant = -(STATUS_BAR_HEIGHT + 56);
        self.effectLayoutGuide.active = YES;
        blurview;
    });
    
    self.cancel = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
        button.tag = 1005;
        button.titleLabel.font = [UIFont MaterialDesignIconsWithSize:24];
        [button setTitle:[UIFont mdiArrowLeft] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    self.targetField = ({
        UITextField *field = [[UITextField alloc] init];
        field.translatesAutoresizingMaskIntoConstraints = NO;
        [self.effect.contentView addSubview:field];
        [field.leftAnchor constraintEqualToAnchor:self.effect.contentView.leftAnchor constant:16].active = YES;
        [field.rightAnchor constraintEqualToAnchor:self.effect.contentView.rightAnchor constant:-16].active = YES;
        [field.topAnchor constraintEqualToAnchor:self.effect.contentView.topAnchor constant:STATUS_BAR_HEIGHT + 16].active = YES;
        [field.heightAnchor constraintEqualToConstant:42].active = YES;
        [field addTarget:self action:@selector(textFieldOnEditing:) forControlEvents:UIControlEventAllEditingEvents];
        field.leftViewMode = UITextFieldViewModeAlways;
        field.delegate = self;
        field.leftView = self.cancel;
        field.layer.borderWidth = 1.0f;
        field.layer.borderColor = [UIColor whiteColor].CGColor;
        field.layer.cornerRadius = 6.0f;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        field.keyboardType = UIKeyboardTypeNumberPad;
        field.tintColor = [UIColor whiteColor];
        field.textColor = [UIColor whiteColor];
//        field.placeholder = @"Set a target number";
        field.text = @" MB";
        
        field;
    });
    
    self.targetField.hidden = YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (void)textFieldOnEditing:(UITextField *)textField{
    UITextRange *range = textField.selectedTextRange;
    UITextPosition *start = [textField positionFromPosition:range.start inDirection:UITextLayoutDirectionLeft offset:textField.text.length - 4];
    if( start )
        [textField setSelectedTextRange:[textField textRangeFromPosition:range.start toPosition:start]];
}

- (void)willKeyBoardChangeFrame:(NSNotification *)keyboardInfo{
    NSDictionary *info = [keyboardInfo userInfo];
    CGFloat constant = self.view.frame.size.height - [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat duration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions option = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    self.addTargetLayoutGuide.constant = -constant > 0 ? 0 : -constant;
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:option
                     animations:^{
                         [self.addTarget layoutIfNeeded];
                         [self.targetCock layoutIfNeeded];
                         [self.targetDick layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)letPop{
    [self.view endEditing:YES];
    self.effectLayoutGuide.constant = -(STATUS_BAR_HEIGHT + 56);
    self.targetCock.hidden = YES;
    self.targetDick.hidden = YES;
    self.addTarget.hidden = NO;
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:(7 << 16)
                     animations:^{
                         self.targetField.alpha = 0;
                         [self.view layoutIfNeeded];
                     }completion:^(BOOL f){
                         self.targetField.hidden = YES;
                     }];
}

- (void)letPush{
    self.effectLayoutGuide.constant = -self.view.frame.size.height;
    self.targetCock.hidden = NO;
    self.targetDick.hidden = NO;
    self.targetField.alpha = 0;
    self.targetField.hidden = NO;
    self.addTarget.hidden = YES;
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:(7 << 16)
                     animations:^{
                         self.targetField.alpha = 1;
                         [self.view layoutIfNeeded];
                     }completion:^(BOOL f){
                         [self.targetField becomeFirstResponder];
                     }];
}

- (void)updateStatus:(NSString *)status{
    if( [status isEqualToString:CR_NET_STATUS_BEAR] ){
        self.good.colors = self.bearColors;
        self.progress.tintColor = [UIColor colorWithRed:29  / 255.0 green:109 / 255.0 blue:217 / 255.0 alpha:1];
    }else if( [status isEqualToString:CR_NET_STATUS_BABOON] ){
        self.good.colors = self.boboonColors;
        self.progress.tintColor = [UIColor colorWithRed:228 / 255.0 green:109 / 255.0 blue:58  / 255.0 alpha:1];
    }else if( [status isEqualToString:CR_NET_STATUS_MONKEY] ){
        self.good.colors = self.monkeyColors;
        self.progress.tintColor = [UIColor colorWithRed:175 / 255.0 green:19  / 255.0 blue:31  / 255.0 alpha:1];
    }
    
    self.status = status;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
//    if( [self.status isEqualToString:CR_NET_STATUS_BEAR] )
//        [self updateStatus:CR_NET_STATUS_BABOON];
//    else if( [self.status isEqualToString:CR_NET_STATUS_BABOON] )
//        [self updateStatus:CR_NET_STATUS_MONKEY];
//    else if( [self.status isEqualToString:CR_NET_STATUS_MONKEY] )
//        [self updateStatus:CR_NET_STATUS_BEAR];
    
}

- (void)viewDidLayoutSubviews{
    self.good.frame = self.view.bounds;
    
//    [self.speedLayoutGuide setConstant:- self.view.frame.size.height * 0.618];
    
//    if( self.effectLayoutGuide.constant != -(STATUS_BAR_HEIGHT + 56) )
//        [self.effectLayoutGuide setConstant:- self.view.frame.size.height];
    
//    [self.progressLayoutGuide setConstant:- self.view.frame.size.height * 0.382];
//    [self.view layoutIfNeeded];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
