//
//  StatusViewController.m
//  ARKitImageRecognition-Objective C
//
//  Created by Koushan Korouei on 11/02/2018.
//  Copyright © 2018 Koushan Korouei. All rights reserved.
//

#import "StatusViewController.h"
#import "ARCamera+TrackingState.h"

@interface StatusViewController ()

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UIVisualEffectView *messagePanel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *restartExperienceButton;

#pragma mark - Properties
// Seconds before the timer message should fade out. Adjust if the app needs longer transient messages
@property (nonatomic) int displayDuration;

// Timer for hiding messages
@property (nonatomic, strong) NSTimer *messageHideTimer;

@property (nonatomic, strong) NSMutableDictionary *timers;

@end

@implementation StatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.timers= [NSMutableDictionary new];
    self.displayDuration = 6;
}

#pragma mark - Message handling
- (void)showMessage:(NSString *)text autoHide:(BOOL)autoHide{
    // Cancel any previous hide timer
    if (self.messageHideTimer) {
        [self.messageHideTimer invalidate];
    }
    
    self.messageLabel.text = text;
    
    // Make sure status is showing
    [self setMessageHidden:NO animated:YES];
    
    __weak typeof(self) weakSelf = self;
    if (autoHide) {
        self.messageHideTimer = [NSTimer scheduledTimerWithTimeInterval:self.displayDuration
                                                                repeats:NO
                                                                  block:^(NSTimer * _Nonnull timer) {
                                                                      [weakSelf setMessageHidden:YES animated:YES];
                                                                  }];
    }
}

- (void)scheduleMessage:(NSString *)text inSeconds:(NSTimeInterval)seconds messageType:(MessageType)messageType{
    [self cancelScheduledMessageForMessageType:messageType];
    
    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                     repeats:NO
                                                       block:^(NSTimer * _Nonnull timer) {
                                                           [weakSelf showMessage:text autoHide:YES];
                                                           [timer invalidate];
                                                       }];
    
    self.timers[[NSNumber numberWithInt:messageType]] = timer;
}

- (void)cancelScheduledMessageForMessageType:(MessageType)messageType{
    NSTimer *timer = self.timers[[NSNumber numberWithInt:messageType]];
    if (timer) {
        [timer invalidate];
        self.timers[[NSNumber numberWithInt:messageType]] = nil;
    }
    
}

- (void)cancelAllScheduledMessages{
    for (int i = 0; i <Enum_Count; i++) {
        [self cancelScheduledMessageForMessageType:i];
    }
    
}

- (void)setMessageHidden:(BOOL)hide animated:(BOOL)animated{
    // The panel starts out hidden, so show it before animating opacity
    self.messagePanel.hidden = NO;
    
    if (!animated) {
        self.messagePanel.alpha = hide ? 0 : 1;
        return;
    }
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.messagePanel.alpha = hide ? 0 : 1;
                     } completion:nil];
}


#pragma mark - IBAction
- (IBAction)restartExperience:(id)sender {
    self.restartExperienceHandler();
}

#pragma mark - ARKit

- (void)showTrackingQualityInfoForTrackingState:(ARCamera *)camera autoHide:(BOOL)autoHide{
    [self showMessage:camera.presentationString autoHide:autoHide];
}

- (void)escalateFeedbackForTrackingState:(ARCamera *)camera inSeconds:(NSTimeInterval)seconds{
    [self cancelScheduledMessageForMessageType:TrackingStateEscalation];
    
    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                     repeats:NO
                                                       block:^(NSTimer * _Nonnull timer) {
                                                           [weakSelf cancelScheduledMessageForMessageType:TrackingStateEscalation];
                                                       }];
    
    NSString *message = camera.presentationString;
    NSString *recommendation = camera.recommendation;
    if (recommendation) {
        [message stringByAppendingString:[NSString stringWithFormat:@": %@", recommendation]];
    }
    
    [self showMessage:message autoHide:NO];
    
    self.timers[[NSNumber numberWithInt:TrackingStateEscalation]] = timer;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
