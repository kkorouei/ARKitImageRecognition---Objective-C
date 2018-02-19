//
//  ViewController.h
//  ARKitImageRecognition-Objective C
//
//  Created by Koushan Korouei on 11/02/2018.
//  Copyright © 2018 Koushan Korouei. All rights reserved.
//

#import "StatusViewController.h"
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface ViewController : UIViewController

/// The view controller that displays the status and "restart experience" UI.
@property (nonatomic, strong)StatusViewController *statusViewController;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;

/// Prevents restarting the session while a restart is in progress.
@property (nonatomic) BOOL isRestartAvailable;

- (void)resetTracking;


@end
