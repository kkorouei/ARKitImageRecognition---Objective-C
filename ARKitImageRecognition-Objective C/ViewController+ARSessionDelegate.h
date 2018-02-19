//
//  ViewController+ARSessionDelegate.h
//  ARKitImageRecognition-Objective C
//
//  Created by Koushan Korouei on 18/02/2018.
//  Copyright © 2018 Koushan Korouei. All rights reserved.
//

#import "ViewController.h"
#import "StatusViewController.h"
#import <ARKit/ARKit.h>


@interface ViewController (ARSessionDelegate) <ARSessionDelegate>

- (void)restartExperience;

@end
