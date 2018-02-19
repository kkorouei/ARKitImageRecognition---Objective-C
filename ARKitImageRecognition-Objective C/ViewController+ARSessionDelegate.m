//
//  ViewController+ARSessionDelegate.m
//  ARKitImageRecognition-Objective C
//
//  Created by Koushan Korouei on 18/02/2018.
//  Copyright © 2018 Koushan Korouei. All rights reserved.
//

#import "ViewController+ARSessionDelegate.h"

@implementation ViewController (ARSessionDelegate)

# pragma mark - ARSession Delegate
- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera{
    [self.statusViewController showTrackingQualityInfoForTrackingState:camera autoHide:YES];
    
    switch (camera.trackingState) {
        case ARTrackingStateNotAvailable:
        case ARTrackingStateLimited:
            [self.statusViewController escalateFeedbackForTrackingState:camera inSeconds:3.0];
            break;
        case ARTrackingStateNormal:
            [self.statusViewController cancelScheduledMessageForMessageType:TrackingStateEscalation];
            break;
        default:
            break;
    }
}


- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    if ((ARErrorCode)error) {
        if ([error.domain isEqualToString:ARErrorDomain]) {
            NSLog(@"yoyoma");
        }
        
    }
    
    NSError *errorWithInfo = (NSError *)error;
    NSArray *messages = @[errorWithInfo.localizedDescription,
                          errorWithInfo.localizedFailureReason,
                          errorWithInfo.localizedRecoverySuggestion];
    
    NSString *errorMessage = @"";
    for (NSString *errorString in messages) {
        if (errorString) {
            errorMessage = [errorMessage stringByAppendingString:[NSString stringWithFormat:@"%@\n", errorString]];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayErrorMessageWithTitle:@"The AR session failed." andMessage:errorMessage];
    });
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    self.blurView.hidden = NO;
    [self.statusViewController showMessage:@"SESSION INTERRUPTED/nThe session will be reset after the interruption has ended"
                                  autoHide:NO];
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    self.blurView.hidden = YES;
    [self.statusViewController showMessage:@"RESETTING SESSION" autoHide:YES];
    
    [self restartExperience];
    
}

- (BOOL)sessionShouldAttemptRelocalization:(ARSession *)session{
    return YES;
}

#pragma mark - Error handling
- (void)displayErrorMessageWithTitle:(NSString *)title andMessage:(NSString *)message{
    // Blur the background
    self.blurView.hidden = NO;
    
    // present an alert informing about the error that has occurred
    UIAlertController *alerController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *restartAction = [UIAlertAction actionWithTitle:@"Restart Session"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [alerController dismissViewControllerAnimated:YES completion:nil];
                                                              self.blurView.hidden = YES;
                                                              [self resetTracking];
                                                          }];
    
    [alerController addAction:restartAction];
    
    [self presentViewController:alerController animated:YES completion:nil];
}

#pragma mark - Interface Actions
- (void)restartExperience{
    if (self.isRestartAvailable) {
        self.isRestartAvailable = NO;
        
        [self.statusViewController cancelAllScheduledMessages];
        
        [self resetTracking];
        
        // Disable the restart for a while in order to give the session time to restart.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isRestartAvailable = YES;
        });
    }
}


@end
