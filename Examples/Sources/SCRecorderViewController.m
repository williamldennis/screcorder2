//
//  VRViewController.m
//  VideoRecorder
//
//  Created by Simon CORSIN on 8/3/13.
//  Copyright (c) 2013 SCorsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCTouchDetector.h"
#import "SCRecorderViewController.h"
#import "SCAudioTools.h"
#import "SCVideoPlayerViewController.h"
#import "SCRecorderFocusView.h"
#import "SCImageDisplayerViewController.h"
#import "SCRecorder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCSessionListViewController.h"
#import "SCRecordSessionManager.h"

#define kVideoPreset AVCaptureSessionPresetHigh

////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface SCRecorderViewController () {
    SCRecorder *_recorder;
    SCRecordSession *_recordSession;
    
    //TRYING TO MAKE MULTIPLE
    
    SCRecorder *_recorder1;
    SCRecordSession *_recordSession1;
}

@property (strong, nonatomic) SCRecorderFocusView *focusView;
@end

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation SCRecorderViewController

#pragma mark - UIViewController 

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (UIStatusBarStyle) preferredStatusBarStyle {
	return UIStatusBarStyleLightContent;
}

#endif

#pragma mark - Left cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_recordSession.recordSegments.count == 0) {
    
    //RECORDER 0
    self.videoPlayback.tapToPauseEnabled = YES;
    self.videoPlayback.player.loopEnabled = NO;
    
    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = AVCaptureSessionPreset1280x720;
    _recorder.audioEnabled = YES;
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    
    // On iOS 8 and iPhone 5S, enabling this seems to be slow
    _recorder.initializeRecordSessionLazily = NO;
    
    [self.recordView addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
    
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        NSError *error = nil;
        NSLog(@"%@", error);
        
        NSLog(@"==== Opened session ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera];
    }];
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    self.loadingView.hidden = YES;
    
    self.focusView = [[SCRecorderFocusView alloc] initWithFrame:previewView.bounds];
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"focus_ring"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"focus_ring"];
    }
    
    
    //RECORDER 1
    else {
        
    self.videoPlayback1.tapToPauseEnabled = YES;
    self.videoPlayback1.player.loopEnabled = NO;
    
    _recorder1 = [SCRecorder recorder];
    _recorder1.sessionPreset = AVCaptureSessionPreset1280x720;
    _recorder1.audioEnabled = YES;
    _recorder1.delegate = self;
    _recorder1.autoSetVideoOrientation = YES;
    
    // On iOS 8 and iPhone 5S, enabling this seems to be slow
    _recorder1.initializeRecordSessionLazily = NO;
    
    [self.recordView1 addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected1:)]];
        
    [_recorder1 openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        NSError *error = nil;
        NSLog(@"%@", error);
        
        NSLog(@"==== Opened session1 ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera1];
    }];
    
    UIView *previewView1 = self.previewView;
    _recorder1.previewView = previewView1;
    
    self.loadingView.hidden = YES;
//
//    self.focusView = [[SCRecorderFocusView alloc] initWithFrame:previewView1.bounds];
//    self.focusView.recorder1 = _recorder1;
//    [previewView1 addSubview:self.focusView];
//    
//    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"focus_ring"];
//    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"focus_ring"];
    }
    
    

    
//    [self.retakeButton addTarget:self action:@selector(handleRetakeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.stopButton addTarget:self action:@selector(handleStopButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
	[self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];


    

}

- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}
- (void)recorder1:(SCRecorder *)recorder1 didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}


- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}
- (void)recorder1:(SCRecorder *)recorder1 didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self prepareCamera];
//    [self prepareCamera1];
    
	self.navigationController.navigationBarHidden = YES;
    [self updateTimeRecordedLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
    [_recorder1 previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunningSession];
    [_recorder1 startRunningSession];
    [_recorder focusCenter];
    [_recorder1 focusCenter];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [_recorder endRunningSession];
    [_recorder1 endRunningSession];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

// Focus
- (void)recorderDidStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

- (void)recorderDidEndFocus:(SCRecorder *)recorder {
    [self.focusView hideFocusAnimation];
}

- (void)recorderWillStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

#pragma mark - Handle

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)showVideo {
    [self performSegueWithIdentifier:@"Video" sender:self];
}

- (void)showVideo1 {
    [self performSegueWithIdentifier:@"Video" sender:self];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.destinationViewController isKindOfClass:[SCVideoPlayerViewController class]]) {
//        SCVideoPlayerViewController *videoPlayer = segue.destinationViewController;
//        videoPlayer.recordSession = _recordSession;
//    } else if ([segue.destinationViewController isKindOfClass:[SCImageDisplayerViewController class]]) {
//        SCImageDisplayerViewController *imageDisplayer = segue.destinationViewController;
//
//    } else if ([segue.destinationViewController isKindOfClass:[SCSessionListViewController class]]) {
//        SCSessionListViewController *sessionListVC = segue.destinationViewController;
//        
//        sessionListVC.recorder = _recorder;
//    }
//}


- (void) handleReverseCameraTapped:(id)sender {
	[_recorder switchCaptureDevices];
}

- (void) handleStopButtonTapped:(id)sender {
    SCRecordSession *recordSession = _recorder.recordSession;
    
    if (recordSession != nil) {
        [self finishSession:recordSession];
    }

}

- (void) handleStopButtonTapped1:(id)sender {
    NSLog(@"handleStopButtonTapped1 being called");

    SCRecordSession *recordSession1 = _recorder1.recordSession;
    
    if (recordSession1 != nil) {
        [self finishSession1:recordSession1];
    }
}

- (void)finishSession:(SCRecordSession *)recordSession {
    
    NSLog(@"finishSession being called");

    [recordSession endRecordSegment:^(NSInteger segmentIndex, NSError *error) {
        [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
        
        _recordSession = recordSession;
        [self showVideo:0];
        
//        [self prepareCamera1];

    }];
}

- (void)finishSession1:(SCRecordSession *)recordSession1 {
    NSLog(@"finishSession1 being called");

    [recordSession1 endRecordSegment:^(NSInteger segmentIndex, NSError *error) {
        [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession1];
        
        _recordSession1 = recordSession1;
        [self showVideo1:0];
        
//        [self prepareCamera2];
        
    }];
}
//
//- (void) handleRetakeButtonTapped:(id)sender {
//    SCRecordSession *recordSession = _recorder.recordSession;
//    
//    if (recordSession != nil) {
//        _recorder.recordSession = nil;
//        
//        // If the recordSession was saved, we don't want to completely destroy it
//        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
//            [recordSession endRecordSegment:nil];
//        } else {
//            [recordSession cancelSession:nil];
//        }
//    }
//    
//	[self prepareCamera];
//    [self updateTimeRecordedLabel];
//}


- (IBAction)switchFlash:(id)sender {
    NSString *flashModeString = nil;
    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        switch (_recorder.flashMode) {
            case SCFlashModeAuto:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeOn;
                break;
            case SCFlashModeOn:
                flashModeString = @"Flash : Light";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Auto";
                _recorder.flashMode = SCFlashModeAuto;
                break;
            default:
                break;
        }
    } else {
        switch (_recorder.flashMode) {
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            default:
                break;
        }
    }
    
    [self.flashModeButton setTitle:flashModeString forState:UIControlStateNormal];
}

- (void) prepareCamera {
    NSLog(@"prepareCamera being called");
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(40, 10000);
        
        _recorder.recordSession = session;
        _recorder.recordSession.videoSizeAsSquare = YES;

    }
}

- (void) prepareCamera1 {
    NSLog(@"prepareCamera1 being called");

    if (_recorder1.recordSession == nil) {
        
        SCRecordSession *session1 = [SCRecordSession recordSession];
        session1.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(40, 10000);
        
        _recorder1.recordSession = session1;
        _recorder1.recordSession.videoSizeAsSquare = YES;
        
    }
}

- (void)recorder:(SCRecorder *)recorder didCompleteRecordSession:(SCRecordSession *)recordSession {
    NSLog(@"didCompleteRecordSession");
    [self finishSession:recordSession];
}

- (void)recorder1:(SCRecorder *)recorder1 didCompleteRecordSession:(SCRecordSession *)recordSession1 {
        NSLog(@"didCompleteRecordSession1");
    [self finishSession1:recordSession1];
}


- (void)recorder:(SCRecorder *)recorder didInitializeVideoInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in recorder session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder1:(SCRecorder *)recorder1 didInitializeVideoInRecordSession:(SCRecordSession *)recordSession1 error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in recorder1 session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginRecordSegment:(SCRecordSession *)recordSession error:(NSError *)error {
    
    if (recorder == _recorder) {
    
    NSLog(@"Began _recorder segment: %@", error);
    }
    
    else if (recorder == _recorder1) {
    NSLog(@"Began _recorder1 segment: %@", error);

    }
}


- (void)recorder:(SCRecorder *)recorder didEndRecordSegment:(SCRecordSession *)recordSession segmentIndex:(NSInteger)segmentIndex error:(NSError *)error {
    
    if (recorder == _recorder) {
    
    NSLog(@"End _recorder segment %d at %@: %@", (int)segmentIndex, segmentIndex >= 0 ? [recordSession.recordSegments objectAtIndex:segmentIndex] : nil, error);
        
    [self handleStopButtonTapped:self];
    }
    
    else if (recorder == _recorder1) {
        
    NSLog(@"End _recorder1 segment %d at %@: %@", (int)segmentIndex, segmentIndex >= 0 ? [recordSession.recordSegments objectAtIndex:segmentIndex] : nil, error);
    
    [self handleStopButtonTapped1:self];
    }
}


- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.recordSession != nil) {
        currentTime = _recorder.recordSession.currentRecordDuration;
    }
    
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"Recorded - %.2f sec", CMTimeGetSeconds(currentTime)];
}

- (void)updateTimeRecordedLabel1 {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder1.recordSession != nil) {
        currentTime = _recorder1.recordSession.currentRecordDuration;
    }
    
    self.timeRecordedLabel.text = [NSString stringWithFormat:@"Recorded - %.2f sec", CMTimeGetSeconds(currentTime)];
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
    
}

- (void)recorder1:(SCRecorder *)recorder1 didAppendVideoSampleBuffer:(SCRecordSession *)recordSession1 {
    [self updateTimeRecordedLabel];
    
}

- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
    NSLog(@"handleTouchDetected");
    if (_recordSession.recordSegments.count == 0) {
    
        if (touchDetector.state == UIGestureRecognizerStateBegan) {
            [_recorder record];
        } else if (touchDetector.state == UIGestureRecognizerStateEnded) {
            [_recorder pause];
        }}
    else {
            [_recorder pause];
    }
}

- (void)handleTouchDetected1:(SCTouchDetector*)touchDetector1 {
    NSLog(@"handleTouchDetected1");
    if (_recordSession1.recordSegments.count == 0) {
        if (touchDetector1.state == UIGestureRecognizerStateBegan) {
            NSLog(@"_recorder1 record");
            [_recorder1 record];
        } else if (touchDetector1.state == UIGestureRecognizerStateEnded) {
            [_recorder1 pause];
        }}
    else {
        [_recorder1 pause];
    }
}

- (void)showVideo:(NSInteger)idx {
    NSLog(@"showVideo");

    if (idx < 0) {
        idx = 0;
    }
    
    if (idx < _recordSession.recordSegments.count) {
        NSLog(@"recorder has segments");
        NSURL *url = [_recordSession.recordSegments objectAtIndex:idx];
        [self.videoPlayback.player setItemByUrl:url];
        [self.videoPlayback.player play];
        [self viewDidLoad];

    }
    
}

- (void)showVideo1:(NSInteger)idx1 {
    NSLog(@"showVideo1");

    if (idx1 < 0) {
        idx1 = 0;
    }
    
    if (idx1 < _recordSession1.recordSegments.count) {
        NSLog(@"recorder1 has segments");

        NSURL *url1 = [_recordSession1.recordSegments objectAtIndex:idx1];
        [self.videoPlayback1.player setItemByUrl:url1];
        [self.videoPlayback1.player play];
    }
    
}




@end
