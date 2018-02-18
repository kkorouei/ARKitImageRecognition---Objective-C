//
//  ARCamera+TrackingState.h
//  ARKitImageRecognition-Objective C
//
//  Created by Koushan Korouei on 14/02/2018.
//  Copyright © 2018 Koushan Korouei. All rights reserved.
//

#import <ARKit/ARKit.h>

@interface ARCamera (TrackingState)

@property (nonatomic, readonly) NSString *presentationString;
@property (nonatomic, strong) NSString *recommendation;

@end
