//
//  ViewController.m
//  ARKitImageRecognition-Objective C
//
//  Created by Koushan Korouei on 11/02/2018.
//  Copyright © 2018 Koushan Korouei. All rights reserved.
//

#import "ViewController.h"
#import "ViewController+ARSessionDelegate.h"

@interface ViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

/// A serial queue for thread safety when modifying the SceneKit node graph.
@property (nonatomic, strong) dispatch_queue_t updateQueue;

@property (nonatomic, strong) SCNAction *imageHighlightAction;

@end

    
@implementation ViewController

- (SCNAction *)imageHighlightAction{
    if (_imageHighlightAction == nil) {
        SCNAction *wait = [SCNAction waitForDuration:0.25];
        SCNAction *fadeOpacity = [SCNAction fadeOpacityTo:0.85 duration:0.25];
        SCNAction *fadeOpacity2 = [SCNAction fadeOpacityTo:0.15 duration:0.25];
        SCNAction *fadeOut = [SCNAction fadeOutWithDuration:0.5];
        SCNAction *remove = [SCNAction removeFromParentNode];
        
        _imageHighlightAction = [SCNAction sequence:@[wait,
                                                      fadeOpacity,
                                                      fadeOpacity2,
                                                      fadeOpacity,
                                                      fadeOut,
                                                      remove]];
    }
    return _imageHighlightAction;
}

- (StatusViewController *)statusViewController{
    if (_statusViewController == nil) {
        _statusViewController = (StatusViewController *)self.childViewControllers.firstObject;
    }
    return _statusViewController;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isRestartAvailable = YES;
    
    // Hook up statusViewController callback(s)
    __weak typeof(self) weakSelf = self;
    self.statusViewController.restartExperienceHandler = ^{
        [weakSelf restartExperience];
    };
    
    // Initialize the queue
    self.updateQueue = dispatch_queue_create("serialSceneKitQueue", NULL);

    // Set the view's delegate
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    
    // Create a new scene
    SCNScene *scene = [SCNScene new];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Prevent the screen from being dimmed to avoid interrupting the AR experience
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Start the AR experience
    [self resetTracking];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

#pragma mark -Session Management(Image detection setup)

/// Creates a new AR configuration to run on the `session`.
- (void)resetTracking{
    
    NSSet *referenceImages = [ARReferenceImage referenceImagesInGroupNamed:@"AR Resources" bundle:nil];
    if (referenceImages == nil) {
        [NSException raise:@"Missing" format:@"The image resources could not be found"];
    }
    
    // Create a session configuration
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.detectionImages = referenceImages;
    
    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
    
    [self.statusViewController scheduleMessage:@"Look around to detect images" inSeconds:7.5 messageType:ContentPlacement];
    
    NSLog(@"Tracking has been reset");
}

#pragma mark - ARSCNViewDelegate (Image detection results)
- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if (![anchor isKindOfClass:[ARImageAnchor class]]) {
        return;
    }
    
    ARImageAnchor *imageAnchor = (ARImageAnchor *)anchor;
    ARReferenceImage *referenceImage = imageAnchor.referenceImage;
    
    dispatch_async(self.updateQueue, ^{
        // Create a plane to visualize the initial position of the detected image.
        SCNPlane *plane =[SCNPlane planeWithWidth:referenceImage.physicalSize.width
                                           height:referenceImage.physicalSize.height];
        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
        plane.firstMaterial.diffuse.contents = [UIColor redColor];
        planeNode.opacity = 0.25;
        
        /*
         `SCNPlane` is vertically oriented in its local coordinate space, but
         `ARImageAnchor` assumes the image is horizontal in its local space, so
         rotate the plane to match.
         */
        planeNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2);
        
        /*
         Image anchors are not tracked after initial detection, so create an
         animation that limits the duration for which the plane visualization appears.
         */
        [planeNode runAction:self.imageHighlightAction];
        
        // Add the plane visualization to the scene
        [node addChildNode:planeNode];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *imageName = referenceImage.name ?: @"";
        [self.statusViewController cancelAllScheduledMessages];
        [self.statusViewController showMessage:[NSString stringWithFormat:@"Detected image %@", imageName] autoHide:YES];
    });

}

@end
