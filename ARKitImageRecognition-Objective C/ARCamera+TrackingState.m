//
//  ARCamera+TrackingState.m
//  ARKitImageRecognition-Objective C
//
//  Created by Koushan Korouei on 14/02/2018.
//  Copyright © 2018 Koushan Korouei. All rights reserved.
//

#import "ARCamera+TrackingState.h"

// Becuase i was not able to add a category to the TrackingState directly, i was forced to add a category using ARCamera
@implementation ARCamera (TrackingState)

- (NSString *)presentationString{
    switch (self.trackingState) {
        case ARTrackingStateNotAvailable:
            return @"TRACKING UNAVAILABLE";
            break;
        case ARTrackingStateNormal:
            return @"TRACKING NORMAL";
        case ARTrackingStateLimited:
            switch (self.trackingStateReason) {
                case ARTrackingStateReasonExcessiveMotion:
                    return @"TRACKING LIMITED\nExcessive motion";
                    break;
                case ARTrackingStateReasonInsufficientFeatures:
                    return @"TRACKING LIMITED\nLow detail";
                    break;
                case ARTrackingStateReasonInitializing:
                    return @"Initializing";
                    break;
                case ARTrackingStateReasonRelocalizing:
                    return @"Recovering from session interruption";
                    break;
                default:
                    break;
            }
        default:
            return @"Default";
            break;
    }
}

- (NSString *)recommendation{
    switch (self.trackingStateReason) {
        case ARTrackingStateReasonExcessiveMotion:
            return @"Try slowing down your movement, or reset the session";
            break;
            case ARTrackingStateReasonInsufficientFeatures:
            return @"Try pointing at a flat surface, or reset the session";
            case ARTrackingStateReasonRelocalizing:
            return @"Try returning to where you were when the interruption began, or reset the session";
        default:
            return nil;
            break;
    }
}

@end
