//
//  ViewController.m
//  CameraApp-AVFoundation
//
//  Created by Karthick C on 08/01/18.
//  Copyright © 2018 Karthick C. All rights reserved.
//

#import "ViewController.h"
#import "CameraController.h"
#import <Photos/Photos.h>

@interface ViewController ()
@property (nonatomic,weak) IBOutlet UIButton *captureButton;

///Displays a preview of the video output generated by the device's cameras.
@property (nonatomic,weak) IBOutlet UIView *capturePreviewView;

//Allows the user to put the camera in photo mode.
@property (nonatomic,weak) IBOutlet UIButton *photoModeButton;
@property (nonatomic,weak) IBOutlet UIButton *toggleCameraButton;
@property (nonatomic,weak) IBOutlet UIButton *toggleFlashButton;

//Allows the user to put the camera in video mode.
@property (nonatomic,weak) IBOutlet UIButton *videoModeButton;

@property (nonatomic) CameraController *cameraController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleCaptureButton];
    [self configureCameraController];
    [_toggleCameraButton addTarget:self action:@selector(toggleCamera:) forControlEvents:UIControlEventTouchUpInside];
    [_toggleFlashButton addTarget:self action:@selector(toggleFlashMode:) forControlEvents:UIControlEventTouchUpInside];
    [_captureButton addTarget:self action:@selector(captureImage:) forControlEvents:UIControlEventTouchUpInside];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


- (CameraController *)cameraController {
    if(_cameraController == nil) {
        _cameraController = [[CameraController alloc] init];
    }
    return _cameraController;
}

- (void) configureCameraController {
    [self.cameraController prepareSession:^(NSException *exception) {
        if(exception == nil) {
            [self.cameraController displayPreviewOn:self.capturePreviewView];
        }else {
            NSLog(@"Exception Occurred %@",exception);
        }
    }];
}

#pragma mark -View Styles
- (void) styleCaptureButton {
    self.captureButton.layer.borderColor = [[UIColor blackColor] CGColor];
    self.captureButton.layer.borderWidth = 2;
    self.captureButton.layer.cornerRadius = MIN(self.captureButton.frame.size.width, self.captureButton.frame.size.height)/2;
}

#pragma mark -IBACtions

- (IBAction) toggleCamera:(id)sender {
    [self.cameraController switchCameras];
    if(self.cameraController.cameraPosition == CameraPositionFront) {
        [self.toggleCameraButton setImage:[UIImage imageNamed:@"Front Camera Icon"] forState:UIControlStateNormal];
    }else {
        [self.toggleCameraButton setImage:[UIImage imageNamed:@"Rear Camera Icon"] forState:UIControlStateNormal];
    }
}

- (IBAction) toggleFlashMode:(id)sender {
    [self.cameraController toggleFlashMode];
    if(self.cameraController.captureFlashMode == AVCaptureFlashModeOn) {
        [self.toggleFlashButton setImage:[UIImage imageNamed:@"Flash On Icon"] forState:UIControlStateNormal];
    }else {
        [self.toggleFlashButton setImage:[UIImage imageNamed:@"Flash Off Icon"] forState:UIControlStateNormal];
    }
}

- (IBAction) captureImage:(id)sender {
    [self.cameraController captureImage:^(UIImage *image, NSError *error) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            NSLog(@"created @ %@",[createAssetRequest location]);
        } completionHandler:^(BOOL succcess, NSError *error) {
            NSLog(@"adding asset succeeeded?%@",succcess?@"Success":error);
        }];
    }];
}

@end
