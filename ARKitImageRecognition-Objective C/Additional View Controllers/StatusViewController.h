//
//  StatusViewController.h
//  ARKitImageRecognition-Objective C
//
//  Created by Koushan Korouei on 11/02/2018.
//  Copyright © 2018 Koushan Korouei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>

typedef enum{
    TrackingStateEscalation,
    ContentPlacement,
    Enum_Count
}MessageType;

@interface StatusViewController : UIViewController

// Trigerred when the "Restart Experience" button is tapped.
@property (copy, nonatomic)void (^restartExperienceHandler)(void);

- (void)showMessage:(NSString *)text autoHide:(BOOL)autoHide;
- (void)scheduleMessage:(NSString *)text inSeconds:(NSTimeInterval)seconds messageType:(MessageType)messageType;
- (void)cancelScheduledMessageForMessageType:(MessageType)messageType;
- (void)cancelAllScheduledMessages;
- (void)showTrackingQualityInfoForTrackingState:(ARCamera *)camera autoHide:(BOOL)autoHide;
- (void)escalateFeedbackForTrackingState:(ARCamera *)camera inSeconds:(NSTimeInterval)seconds;
@end
